import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/utils/helpers.dart';
import 'package:jd_style_logistics/providers/driver_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _routeController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _routeController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _routeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final driver = context.watch<DriverProvider>();
    final p = _Palette.of(dark);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(context, dark, p, driver),
                    const SizedBox(height: 16),
                    _buildHeroMap(context, dark, p, driver),
                    const SizedBox(height: 16),
                    _buildKpiRow(context, dark, p),
                    const SizedBox(height: 16),
                    _buildObcWallet(context, dark, p),
                    const SizedBox(height: 16),
                    _buildActiveDelivery(context, dark, p),
                    const SizedBox(height: 16),
                    _buildQuickActions(context, dark, p),
                    const SizedBox(height: 16),
                    _buildWeeklyPerformance(dark, p),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool dark, _Palette p, DriverProvider driver) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.driverColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.delivery_dining_rounded, color: AppColors.driverColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Helpers.greetingByTime(),
                  style: TextStyle(color: p.sub, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Driver Dashboard',
                  style: TextStyle(color: p.text, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        // Online toggle
        GestureDetector(
          onTap: () => driver.toggleOnlineStatus(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (driver.isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (driver.isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: driver.isOnline
                          ? AppColors.success.withValues(alpha: 0.5 + _pulseController.value * 0.5)
                          : AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  driver.isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: driver.isOnline ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Theme toggle
        GestureDetector(
          onTap: () => context.read<ThemeProvider>().toggleTheme(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: p.shadow, blurRadius: 6, offset: const Offset(2, 2))],
            ),
            child: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: p.text, size: 17),
          ),
        ),
      ],
    );
  }

  // ── Hero Map ──────────────────────────────────────────────────────────────

  Widget _buildHeroMap(BuildContext context, bool dark, _Palette p, DriverProvider driver) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 18, offset: const Offset(6, 6)),
          BoxShadow(color: p.highlight, blurRadius: 8, offset: const Offset(-3, -3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                _StatusPill(isOnline: driver.isOnline),
                const Spacer(),
                Text('WH-007 → Destination', style: TextStyle(fontSize: 11, color: p.sub, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              driver.isOnline ? 'Route: Active · ETA 28 min' : 'Go online to receive orders',
              style: TextStyle(color: p.text, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          // Map area
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: RepaintBoundary(
              child: SizedBox(
                height: 160,
                child: AnimatedBuilder(
                  animation: _routeController,
                  builder: (_, __) => CustomPaint(
                    painter: _MockMapPainter(progress: _routeController.value, dark: dark),
                    child: Stack(
                      children: [
                        // Start pin
                        Positioned(
                          left: 24,
                          top: 28,
                          child: _MapPin(color: AppColors.success),
                        ),
                        // End pin
                        Positioned(
                          right: 28,
                          bottom: 24,
                          child: _MapPin(color: AppColors.driverColor),
                        ),
                        // Moving truck
                        _MovingTruck(controller: _routeController),
                        // ETA card
                        Positioned(
                          right: 14,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF1E3A5F) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(2, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('ETA', style: TextStyle(fontSize: 9, color: p.sub, fontWeight: FontWeight.w600)),
                                Text('28 min', style: TextStyle(fontSize: 13, color: p.text, fontWeight: FontWeight.w800)),
                                Text('4.2 km', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KPI Row ───────────────────────────────────────────────────────────────

  Widget _buildKpiRow(BuildContext context, bool dark, _Palette p) {
    final kpis = [
      _Kpi(label: "Today's Earnings", value: '₹2,850', icon: Icons.account_balance_wallet_rounded, color: AppColors.success),
      _Kpi(label: 'Deliveries', value: '18', icon: Icons.local_shipping_rounded, color: AppColors.driverColor),
      _Kpi(label: 'Distance', value: '126 km', icon: Icons.route_rounded, color: AppColors.primary),
      _Kpi(label: 'Rating', value: '5.0 ★', icon: Icons.star_rounded, color: AppColors.saffron),
    ];

    return Row(
      children: kpis.map((k) => Expanded(
        child: Container(
          margin: EdgeInsets.only(left: kpis.indexOf(k) == 0 ? 0 : 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: p.shadow, blurRadius: 10, offset: const Offset(3, 3)),
              BoxShadow(color: p.highlight, blurRadius: 4, offset: const Offset(-1, -1)),
            ],
          ),
          child: Column(
            children: [
              Icon(k.icon, color: k.color, size: 18),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(k.value, style: TextStyle(color: p.text, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              Text(k.label, style: TextStyle(color: p.sub, fontSize: 8, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      )).toList(),
    );
  }

  // ── OBC Wallet Card ───────────────────────────────────────────────────────

  Widget _buildObcWallet(BuildContext context, bool dark, _Palette p) {
    return GestureDetector(
      onTap: () => context.push('/driver/earnings'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF162233), Color(0xFF003EAA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('OBC Wallet', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.saffron.withValues(alpha: 0.4)),
                  ),
                  child: const Text('View All', style: TextStyle(color: AppColors.saffron, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OBC Balance', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Text(
                        '1,240 OBC',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85 + _pulseController.value * 0.15),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Text('≈ ₹620 redeemable', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ObcStat(label: 'Today', value: '+42 OBC', color: AppColors.success),
                    const SizedBox(height: 4),
                    _ObcStat(label: 'This Week', value: '+320 OBC', color: AppColors.saffron),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Active Delivery ───────────────────────────────────────────────────────

  Widget _buildActiveDelivery(BuildContext context, bool dark, _Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2_rounded, size: 16, color: AppColors.driverColor),
            const SizedBox(width: 6),
            Text('Active Delivery', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.text)),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/driver/active'),
              child: Text('Details', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.driverColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(3, 3)),
              BoxShadow(color: p.highlight, blurRadius: 5, offset: const Offset(-2, -2)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JDL-IND-58291', style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
                        Text('Ghansoli → Vashi', style: TextStyle(color: p.sub, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('+12 OBC', style: TextStyle(color: AppColors.saffron, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: p.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.driverColor),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('65% complete', style: TextStyle(fontSize: 10, color: p.sub)),
                  Text('ETA: 28 min', style: TextStyle(fontSize: 10, color: AppColors.driverColor, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, bool dark, _Palette p) {
    final actions = [
      _Action(label: 'Active\nDeliveries', icon: Icons.inventory_2_rounded, color: AppColors.primary, onTap: () => context.push('/driver/active')),
      _Action(label: 'Navigate\nRoute', icon: Icons.navigation_rounded, color: AppColors.success, onTap: () {}),
      _Action(label: 'Proof of\nDelivery', icon: Icons.fact_check_rounded, color: AppColors.saffron, onTap: () {}),
      _Action(label: 'OBC\nWallet', icon: Icons.account_balance_wallet_rounded, color: AppColors.driverColor, onTap: () => context.push('/driver/earnings')),
      _Action(label: 'Order\nHistory', icon: Icons.history_rounded, color: AppColors.warning, onTap: () => context.push('/driver/history')),
      _Action(label: 'My\nProfile', icon: Icons.person_rounded, color: const Color(0xFF8B5CF6), onTap: () {}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.text)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: actions.map((a) => GestureDetector(
            onTap: a.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(2, 2)),
                  BoxShadow(color: p.highlight, blurRadius: 3, offset: const Offset(-1, -1)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.icon, color: a.color, size: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(a.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: p.sub),
                      textAlign: TextAlign.center, maxLines: 2),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ── Weekly Performance ────────────────────────────────────────────────────

  Widget _buildWeeklyPerformance(bool dark, _Palette p) {
    const bars = [0.35, 0.62, 0.46, 0.78, 0.55, 0.90, 0.72];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Weekly Performance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.text)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: p.shadow, blurRadius: 14, offset: const Offset(4, 4)),
              BoxShadow(color: p.highlight, blurRadius: 6, offset: const Offset(-2, -2)),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(bars.length, (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 20 + (bars[i] * 70),
                            decoration: BoxDecoration(
                              color: i == 5 ? AppColors.saffron : AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(days[i], style: TextStyle(fontSize: 8, color: p.sub)),
                        ],
                      ),
                    ),
                  )),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _WeekStat(label: 'Completed', value: '84', p: p),
                  _WeekStat(label: 'OBC Earned', value: '320', p: p),
                  _WeekStat(label: 'Score', value: '96%', p: p),
                  _WeekStat(label: 'Distance', value: '812 km', p: p),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Moving Truck Widget ───────────────────────────────────────────────────────

class _MovingTruck extends StatelessWidget {
  final AnimationController controller;
  const _MovingTruck({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        const maxW = 300.0;
        final truckX = 24 + (t * (maxW - 80));
        final truckY = 46 + math.sin(t * math.pi * 4) * 12;

        return Positioned(
          left: truckX.clamp(0, maxW - 40),
          top: truckY.clamp(0, 120),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.driverColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.driverColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
          ),
        );
      },
    );
  }
}

// ── Mock Map Painter ──────────────────────────────────────────────────────────

class _MockMapPainter extends CustomPainter {
  final double progress;
  final bool dark;
  _MockMapPainter({required this.progress, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = dark ? const Color(0xFF1A2B3E) : const Color(0xFFEAF6FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bg);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: dark ? 0.06 : 0.08)
      ..strokeWidth = 1;
    for (double x = 30; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 20; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Buildings
    final buildingPaint = Paint()..color = AppColors.primary.withValues(alpha: dark ? 0.1 : 0.06);
    for (final rect in [
      const Rect.fromLTWH(50, 60, 30, 40),
      const Rect.fromLTWH(110, 70, 25, 35),
      const Rect.fromLTWH(180, 55, 35, 45),
      const Rect.fromLTWH(250, 65, 28, 38),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), buildingPaint);
    }

    // Route path (full, faded)
    final fullPath = Path()
      ..moveTo(34, 34)
      ..cubicTo(size.width * .3, 10, size.width * .5, size.height - 10, size.width - 36, size.height - 28);
    canvas.drawPath(
      fullPath,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.2)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Active segment (orange)
    final metric = fullPath.computeMetrics().first;
    final activePath = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      activePath,
      Paint()
        ..color = AppColors.saffron
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MockMapPainter old) => old.progress != progress || old.dark != dark;
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final bool isOnline;
  const _StatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        isOnline ? '● ONLINE' : '● OFFLINE',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.location_on_rounded, color: color, size: 26);
  }
}

class _ObcStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ObcStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String label, value;
  final _Palette p;
  const _WeekStat({required this.label, required this.value, required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: p.text, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: p.sub, fontSize: 9)),
      ],
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _Kpi {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi({required this.label, required this.value, required this.icon, required this.color});
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.label, required this.icon, required this.color, required this.onTap});
}

// ── Palette ───────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, border;
  const _Palette({required this.bg, required this.card, required this.highlight, required this.shadow, required this.text, required this.sub, required this.border});

  factory _Palette.of(bool dark) => dark
      ? _Palette(bg: AppColors.darkBg1, card: AppColors.darkCard, highlight: AppColors.clayHighlightDark, shadow: AppColors.clayShadowDark, text: Colors.white, sub: AppColors.darkSubtext, border: AppColors.darkBorder)
      : _Palette(bg: const Color(0xFFF5F6FA), card: Colors.white, highlight: AppColors.clayHighlight, shadow: AppColors.clayShadow, text: AppColors.textDark, sub: AppColors.textDarkSecondary, border: const Color(0xFFE8EDF5));
}
