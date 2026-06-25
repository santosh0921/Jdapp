/**
 * JD Logistics — k6 Load Test
 *
 * Run:
 *   k6 run tools/k6_load_test.js
 *   k6 run --vus 50 --duration 60s tools/k6_load_test.js
 *
 * Env vars:
 *   BASE_URL   — default: http://localhost:8080/api/v1
 *   PHONE      — test phone number (default: +919876543210)
 *   OTP        — mock OTP (default: 123456)
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// ── Metrics ───────────────────────────────────────────────────────────────────

const errorRate        = new Rate('error_rate');
const authDuration     = new Trend('auth_duration_ms',    true);
const estimateDuration = new Trend('estimate_duration_ms', true);
const orderDuration    = new Trend('order_duration_ms',    true);
const adminDuration    = new Trend('admin_duration_ms',    true);
const paymentDuration  = new Trend('payment_duration_ms',  true);
const totalRequests    = new Counter('total_requests');

// ── Config ────────────────────────────────────────────────────────────────────

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080/api/v1';
const PHONE    = __ENV.PHONE    || '+919876543210';
const OTP      = __ENV.OTP      || '123456';

// ── Scenarios ─────────────────────────────────────────────────────────────────

export const options = {
  scenarios: {
    // Smoke test — 1 VU, 1 minute
    smoke: {
      executor: 'constant-vus',
      vus: 1,
      duration: '1m',
      tags: { scenario: 'smoke' },
    },
    // Normal load — ramp up to 30 VUs
    load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 10  },
        { duration: '2m',  target: 30  },
        { duration: '1m',  target: 30  },
        { duration: '30s', target: 0   },
      ],
      tags: { scenario: 'load' },
    },
    // Stress — spike to 100 VUs
    stress: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 50  },
        { duration: '1m',  target: 100 },
        { duration: '30s', target: 0   },
      ],
      tags: { scenario: 'stress' },
      startTime: '5m',
    },
  },
  thresholds: {
    http_req_failed:    ['rate<0.02'],           // <2% errors
    http_req_duration:  ['p(95)<2000'],          // 95th pct < 2s
    error_rate:         ['rate<0.05'],
    auth_duration_ms:   ['p(95)<1000'],
    estimate_duration_ms: ['p(95)<1500'],
    order_duration_ms:  ['p(95)<2000'],
    admin_duration_ms:  ['p(95)<2000'],
    payment_duration_ms: ['p(95)<1500'],
  },
};

// ── Helpers ───────────────────────────────────────────────────────────────────

function headers(token) {
  const h = { 'Content-Type': 'application/json' };
  if (token) h['Authorization'] = `Bearer ${token}`;
  return h;
}

function ok(res, name) {
  const passed = check(res, {
    [`${name} status 200`]: (r) => r.status === 200 || r.status === 201,
    [`${name} has body`]:   (r) => r.body && r.body.length > 0,
  });
  errorRate.add(!passed);
  totalRequests.add(1);
  return passed;
}

function post(path, body, token) {
  return http.post(`${BASE_URL}${path}`, JSON.stringify(body), { headers: headers(token) });
}

function get(path, token, params) {
  const opts = { headers: headers(token) };
  if (params) opts.tags = params;
  return http.get(`${BASE_URL}${path}`, opts);
}

// ── Auth flow ─────────────────────────────────────────────────────────────────

function login() {
  const start = Date.now();

  const sendRes = post('/auth/send-otp', { phone: PHONE, role: 'courier_customer' });
  ok(sendRes, 'send-otp');

  const verifyRes = post('/auth/verify-otp', { phone: PHONE, otp: OTP, role: 'courier_customer' });
  ok(verifyRes, 'verify-otp');

  authDuration.add(Date.now() - start);

  if (verifyRes.status !== 200) return null;
  try {
    const body = JSON.parse(verifyRes.body);
    return body.data ? body.data.access_token : null;
  } catch (_) {
    return null;
  }
}

function loginAdmin() {
  const loginRes = post('/auth/admin-login', {
    email: 'admin@jdlogistics.com',
    password: 'Admin@1234',
  });
  ok(loginRes, 'admin-login');

  const otpRes = post('/auth/admin-verify-otp', {
    email: 'admin@jdlogistics.com',
    otp: OTP,
  });
  ok(otpRes, 'admin-verify-otp');

  if (otpRes.status !== 200) return null;
  try {
    const body = JSON.parse(otpRes.body);
    return body.data ? body.data.access_token : null;
  } catch (_) {
    return null;
  }
}

// ── Main VU loop ──────────────────────────────────────────────────────────────

export default function () {
  // ── Auth ──────────────────────────────────────────────────────────────────
  let token = null;
  group('auth', () => {
    token = login();
  });
  if (!token) { sleep(1); return; }

  sleep(0.5);

  // ── Pricing ───────────────────────────────────────────────────────────────
  group('pricing', () => {
    const start = Date.now();

    const catRes = get('/pricing/goods-categories', token);
    ok(catRes, 'goods-categories');

    const estRes = post('/pricing/logistics-estimate', {
      from_city:       'Mumbai',
      to_city:         'Delhi',
      goods_category:  'electronics',
      weight_kg:       5000,
      transport_mode:  'road',
      needs_warehouse: false,
      goods_value:     2500000,
      is_export:       false,
    }, token);
    ok(estRes, 'logistics-estimate');

    const courierRes = post('/pricing/courier-estimate', {
      from_pincode: '400001',
      to_pincode:   '110001',
      weight_kg:    2.5,
      declared_value: 5000,
    }, token);
    ok(courierRes, 'courier-estimate');

    estimateDuration.add(Date.now() - start);
  });

  sleep(0.5);

  // ── Courier order ─────────────────────────────────────────────────────────
  let courierId = null;
  group('courier_order', () => {
    const start = Date.now();

    const createRes = post('/courier/orders', {
      sender_name:      'Load Test User',
      sender_phone:     PHONE,
      sender_address:   '201 Marine Lines, Mumbai',
      sender_pincode:   '400001',
      receiver_name:    'Test Receiver',
      receiver_phone:   '+919000000001',
      receiver_address: '45 Connaught Place, Delhi',
      receiver_pincode: '110001',
      weight_kg:        1.5,
      declared_value:   3000,
      payment_method:   'upi',
    }, token);
    ok(createRes, 'create-courier-order');

    try {
      const body = JSON.parse(createRes.body);
      if (body.data && body.data.id) courierId = body.data.id;
    } catch (_) {}

    if (courierId) {
      const getRes = get(`/courier/orders/${courierId}`, token);
      ok(getRes, 'get-courier-order');

      const trackRes = get(`/courier/track/${courierId}`, token);
      ok(trackRes, 'track-courier-order');
    }

    orderDuration.add(Date.now() - start);
  });

  sleep(0.5);

  // ── Payment ───────────────────────────────────────────────────────────────
  if (courierId) {
    group('payment', () => {
      const start = Date.now();

      const createRes = post('/payments/create-order', {
        order_id: courierId,
        amount:   1952,
        method:   'upi',
      }, token);
      ok(createRes, 'create-payment');

      let paymentId = 'PAY_K6_TEST';
      try {
        const body = JSON.parse(createRes.body);
        if (body.data && body.data.payment_id) paymentId = body.data.payment_id;
      } catch (_) {}

      const verifyRes = post('/payments/verify', {
        payment_id: paymentId,
        order_id:   courierId,
        signature:  'k6_test_sig',
      }, token);
      ok(verifyRes, 'verify-payment');

      const histRes = get('/payments/history', token);
      ok(histRes, 'payment-history');

      paymentDuration.add(Date.now() - start);
    });

    sleep(0.3);
  }

  // ── Profile & notifications ────────────────────────────────────────────────
  group('profile', () => {
    ok(get('/auth/profile', token), 'get-profile');
    ok(get('/driver/orders/available', token), 'available-orders'); // tests driver endpoint
  });

  sleep(1);
}

// ── Admin scenario (separate export) ─────────────────────────────────────────

export function adminScenario() {
  let token = null;
  group('admin_auth', () => {
    token = loginAdmin();
  });
  if (!token) { sleep(1); return; }

  sleep(0.5);

  group('admin_dashboard', () => {
    const start = Date.now();

    ok(get('/admin/dashboard', token), 'admin-dashboard');
    ok(get('/admin/shipments', token), 'admin-shipments');
    ok(get('/admin/users', token), 'admin-users');
    ok(get('/admin/drivers', token), 'admin-drivers');
    ok(get('/admin/analytics?period=monthly', token), 'admin-analytics');
    ok(get('/admin/payments', token), 'admin-payments');

    adminDuration.add(Date.now() - start);
  });

  sleep(1);
}

// ── Token refresh test ────────────────────────────────────────────────────────

export function tokenRefreshScenario() {
  // Simulate token refresh flow
  const token = login();
  if (!token) { sleep(1); return; }

  // Simulate getting an expired token scenario
  const refreshRes = post('/auth/refresh-token', {
    refresh_token: 'test_refresh_token_' + Math.random(),
  });

  // Either 200 (if test token is valid) or 401 (expected for random token)
  check(refreshRes, {
    'refresh endpoint reachable': (r) => r.status === 200 || r.status === 401,
  });
  totalRequests.add(1);

  sleep(1);
}

// ── Teardown — log summary ────────────────────────────────────────────────────

export function teardown(data) {
  console.log('=== JD Logistics k6 Load Test Complete ===');
  console.log(`Total requests: ${data ? JSON.stringify(data) : 'see metrics'}`);
}
