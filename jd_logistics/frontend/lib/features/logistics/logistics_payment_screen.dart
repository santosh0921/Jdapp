import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/payment_service.dart';
import 'package:provider/provider.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────
// Push this screen with:
//   context.push('/logistics/payment', extra: LogisticsPaymentArgs(...))

class LogisticsPaymentArgs {
  final String orderId;
  final double totalAmount;
  final Map<String, dynamic> breakdown;
  final String fromCity;
  final String toCity;
  final String goodsName;

  const LogisticsPaymentArgs({
    required this.orderId,
    required this.totalAmount,
    required this.breakdown,
    required this.fromCity,
    required this.toCity,
    required this.goodsName,
  });
}

class LogisticsPaymentScreen extends StatefulWidget {
  final LogisticsPaymentArgs args;
  const LogisticsPaymentScreen({super.key, required this.args});

  @override
  State<LogisticsPaymentScreen> createState() => _LogisticsPaymentScreenState();
}

class _LogisticsPaymentScreenState extends State<LogisticsPaymentScreen>
    with SingleTickerProviderStateMixin {
  // ── Colors ────────────────────────────────────────────────────────────────
  static const _kNavy    = Color(0xFF0F2D5A);
  static const _kTeal    = Color(0xFF0D9488);
  static const _kSaffron = Color(0xFFFF6B00);

  // ── State ─────────────────────────────────────────────────────────────────
  String _selectedMethod = 'upi';
  bool _isProcessing = false;
  bool _paymentDone = false;
  String? _error;
  String? _confirmedOrderId;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  // Payment method options
  static const _methods = [
    {'id': 'upi',         'label': 'UPI',          'sub': 'Google Pay, PhonePe, BHIM', 'icon': Icons.qr_code_rounded},
    {'id': 'card',        'label': 'Credit / Debit Card', 'sub': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card_rounded},
    {'id': 'net_banking', 'label': 'Net Banking',   'sub': 'All major banks', 'icon': Icons.account_balance_rounded},
    {'id': 'wallet',      'label': 'JD Wallet',     'sub': 'Balance: ₹12,840', 'icon': Icons.account_balance_wallet_rounded},
    {'id': 'obc',         'label': 'OBC Points',    'sub': '1,840 pts available', 'icon': Icons.toll_rounded},
    {'id': 'pay_later',   'label': 'Pay Later (Business)', 'sub': '30-day credit line', 'icon': Icons.schedule_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  // ── Pay action ────────────────────────────────────────────────────────────

  Future<void> _pay() async {
    setState(() { _isProcessing = true; _error = null; });

    try {
      // Step 1: Create payment order
      final orderResult = await PaymentService.instance.createPaymentOrder(
        orderId: widget.args.orderId,
        amount: widget.args.totalAmount,
        method: _selectedMethod,
      );
      final paymentId = orderResult['payment_id'] as String? ?? 'PAY_DEMO';

      // Step 2: Verify (mock gateway completes immediately)
      final verifyResult = await PaymentService.instance.verifyPayment(
        paymentId: paymentId,
        orderId: widget.args.orderId,
      );

      if (verifyResult['success'] == true || verifyResult['status'] == 'paid') {
        _confirmedOrderId = widget.args.orderId;
        setState(() { _paymentDone = true; _isProcessing = false; });
        _successCtrl.forward();
      } else {
        setState(() { _error = 'Payment verification failed. Please retry.'; _isProcessing = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isProcessing = false; });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final bg   = dark ? AppColors.darkBg1 : const Color(0xFFF8FAFF);
    final card = dark ? AppColors.darkCard : Colors.white;
    final text = dark ? AppColors.textWhite : _kNavy;
    final sub  = dark ? AppColors.darkSubtext : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        title: const Text('Complete Payment',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _paymentDone
          ? _buildSuccess(text, sub)
          : _buildPaymentForm(dark, bg, card, text, sub),
      bottomNavigationBar: _paymentDone ? null : _buildPayBar(dark),
    );
  }

  // ── Success screen ────────────────────────────────────────────────────────

  Widget _buildSuccess(Color text, Color sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _successScale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.success, width: 2.5),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 52),
              ),
            ),
            const SizedBox(height: 24),
            Text('Payment Successful!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: text)),
            const SizedBox(height: 8),
            Text('Order $_confirmedOrderId is confirmed.',
                style: TextStyle(fontSize: 14, color: sub),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Amount: ₹${_fmt(widget.args.totalAmount)}',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: _kTeal),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/logistics/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  context.push('/payments/invoice?id=${widget.args.orderId}'),
              child: Text('View Invoice',
                  style: TextStyle(color: _kNavy, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Payment form ──────────────────────────────────────────────────────────

  Widget _buildPaymentForm(
      bool dark, Color bg, Color card, Color text, Color sub) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            _buildOrderSummary(dark, card, text, sub),
            const SizedBox(height: 20),

            // Breakdown
            _buildBreakdown(dark, card, text, sub),
            const SizedBox(height: 20),

            // Payment method selector
            Text('Select Payment Method',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: text)),
            const SizedBox(height: 12),
            ..._methods.map(
              (m) => _MethodTile(
                method: m,
                isSelected: _selectedMethod == m['id'],
                dark: dark,
                card: card,
                text: text,
                sub: sub,
                onTap: () => setState(() => _selectedMethod = m['id'] as String),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
      bool dark, Color card, Color text, Color sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.receipt_long_rounded, color: Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text('Order Summary',
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kSaffron.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kSaffron.withValues(alpha: 0.4)),
              ),
              child: Text(widget.args.orderId,
                  style: const TextStyle(
                      color: _kSaffron, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Text('${widget.args.fromCity}  →  ${widget.args.toCity}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(widget.args.goodsName,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const Divider(color: Colors.white12, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payable',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13)),
              Text('₹${_fmt(widget.args.totalAmount)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(bool dark, Color card, Color text, Color sub) {
    final rows = <MapEntry<String, double>>[];
    void add(String k, String label) {
      final v = (widget.args.breakdown[k] as num?)?.toDouble();
      if (v != null && v > 0) rows.add(MapEntry(label, v));
    }
    add('base_freight',         'Base Freight');
    add('distance_cost',        'Distance Charge');
    add('weight_cost',          'Weight Charge');
    add('vehicle_cost',         'Vehicle Charge');
    add('risk_cost',            'Risk Surcharge');
    add('handling_charges',     'Handling');
    add('insurance_premium',    'Insurance');
    add('warehouse_charges',    'Warehouse Storage');
    add('documentation_charges','Documentation');
    add('customs_charges',      'Customs / Duty');
    add('gst_amount',           'GST');

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              const Icon(Icons.receipt_rounded, size: 16, color: _kTeal),
              const SizedBox(width: 6),
              Text('Price Breakdown',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: text)),
            ]),
          ),
          const Divider(height: 1),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            final isGst  = e.value.key == 'GST';
            return Column(children: [
              if (isGst) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value.key,
                        style: TextStyle(
                            fontSize: 13,
                            color: isGst ? _kSaffron : sub,
                            fontWeight: isLast || isGst
                                ? FontWeight.w600
                                : FontWeight.w400)),
                    Text('₹${_fmt(e.value.value)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: isGst ? _kSaffron : text,
                            fontWeight: isLast || isGst
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ],
                ),
              ),
            ]);
          }),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(2)}K';
    return v.toStringAsFixed(0);
  }

  Widget _buildPayBar(bool dark) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text(
                    'Pay ₹${_fmt(widget.args.totalAmount)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      );
}

// ─── Method tile ──────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  final Map<String, Object> method;
  final bool isSelected;
  final bool dark;
  final Color card, text, sub;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.dark,
    required this.card,
    required this.text,
    required this.sub,
    required this.onTap,
  });

  static const _kTeal = Color(0xFF0D9488);
  static const _kNavy = Color(0xFF0F2D5A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _kTeal.withValues(alpha: dark ? 0.15 : 0.07)
              : card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _kTeal
                : (dark ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.15 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? _kTeal.withValues(alpha: 0.15)
                  : (dark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(method['icon'] as IconData,
                color: isSelected ? _kTeal : sub, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method['label'] as String,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? _kNavy : text)),
                const SizedBox(height: 2),
                Text(method['sub'] as String,
                    style: TextStyle(fontSize: 11, color: sub),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: _kTeal, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 13),
            )
          else
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: dark ? Colors.white24 : Colors.black26),
              ),
            ),
        ]),
      ),
    );
  }
}
