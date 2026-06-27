import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';

class WarehouseHomeScreen extends StatefulWidget {
  const WarehouseHomeScreen({super.key});

  @override
  State<WarehouseHomeScreen> createState() => _WarehouseHomeScreenState();
}

class _WarehouseHomeScreenState extends State<WarehouseHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _conveyorCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _heroFade;
  late Animation<double> _conveyorAnim;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _conveyorCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _conveyorAnim = CurvedAnimation(parent: _conveyorCtrl, curve: Curves.linear);
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _conveyorCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final auth = context.watch<AuthProvider>();
    final p = _Palette.of(dark);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context, dark, p, auth)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAlerts(dark, p),
                  const SizedBox(height: 20),
                  _buildBentoGrid(context, dark, p),
                  const SizedBox(height: 20),
                  _buildConveyorSection(dark, p),
                  const SizedBox(height: 20),
                  _buildInboundQueue(context, dark, p),
                  const SizedBox(height: 20),
                  _buildDispatchQueue(context, dark, p),
                  const SizedBox(height: 20),
                  _buildQuickActions(context, dark, p),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, bool dark, _Palette p, AuthProvider auth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162233), Color(0xFF001A6E), Color(0xFF003EAA)],
        ),
      ),
      child: FadeTransition(
        opacity: _heroFade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warehouseColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warehouseColor.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.warehouse_rounded, color: AppColors.warehouseColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Good Morning,', style: TextStyle(color: Colors.white60, fontSize: 12)),
                        Text(
                          auth.user?.name ?? 'Warehouse Manager',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _HeroBtn(
                    icon: context.read<ThemeProvider>().isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    onTap: () => context.read<ThemeProvider>().toggleTheme(),
                  ),
                  const SizedBox(width: 8),
                  _HeroBtn(icon: Icons.person_rounded, onTap: () => context.push('/warehouse/profile')),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warehouseColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warehouseColor.withValues(alpha: 0.3)),
                ),
                child: const Text('—',
                    style: TextStyle(color: AppColors.warehouseColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              // KPI strip
              Row(
                children: [
                  const _HeroKpi(label: 'Total SKUs', value: '—', icon: Icons.inventory_2_rounded),
                  _vDiv(),
                  const _HeroKpi(label: 'Capacity Used', value: '—', icon: Icons.warehouse_rounded),
                  _vDiv(),
                  const _HeroKpi(label: 'Pending Scans', value: '—', icon: Icons.qr_code_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDiv() => Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 12));

  // ── Alerts ────────────────────────────────────────────────────────────────

  Widget _buildAlerts(bool dark, _Palette p) {
    const alerts = <_Alert>[];

    return Column(
      children: alerts.map((a) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Color(a.color).withValues(alpha: dark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(a.color).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(a.color), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.type, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(a.color))),
                  Text(a.msg, style: TextStyle(fontSize: 12, color: p.text), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(a.color), size: 18),
          ],
        ),
      )).toList(),
    );
  }

  // ── Bento Grid ────────────────────────────────────────────────────────────

  Widget _buildBentoGrid(BuildContext context, bool dark, _Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Today\'s Overview', icon: Icons.today_rounded, p: p),
        const SizedBox(height: 12),
        Row(
          children: [
            // Left column - tall card
            Expanded(
              flex: 5,
              child: _BentoTall(
                title: 'Inbound',
                value: '—',
                sub: 'parcels arriving',
                icon: Icons.input_rounded,
                color: AppColors.success,
                dark: dark,
                p: p,
                onTap: () => context.push('/warehouse/inbound'),
              ),
            ),
            const SizedBox(width: 10),
            // Right column - two stacked cards
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _BentoSmall(
                    title: 'Outbound',
                    value: '—',
                    icon: Icons.output_rounded,
                    color: AppColors.primary,
                    dark: dark,
                    p: p,
                    onTap: () => context.push('/warehouse/outbound'),
                  ),
                  const SizedBox(height: 10),
                  _BentoSmall(
                    title: 'Returns',
                    value: '—',
                    icon: Icons.keyboard_return_rounded,
                    color: AppColors.error,
                    dark: dark,
                    p: p,
                    onTap: () => context.push('/warehouse/returns'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _BentoSmall(
                title: 'Pending Dispatch',
                value: '—',
                icon: Icons.local_shipping_rounded,
                color: AppColors.warning,
                dark: dark,
                p: p,
                onTap: () => context.go('/warehouse/dispatch'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoSmall(
                title: 'Damaged Parcels',
                value: '—',
                icon: Icons.broken_image_rounded,
                color: AppColors.error,
                dark: dark,
                p: p,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoSmall(
                title: 'Scan Queue',
                value: '—',
                icon: Icons.qr_code_scanner_rounded,
                color: AppColors.saffron,
                dark: dark,
                p: p,
                onTap: () => context.go('/warehouse/scan'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Conveyor Belt Animation ───────────────────────────────────────────────

  Widget _buildConveyorSection(bool dark, _Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Live Conveyor', icon: Icons.linear_scale_rounded, p: p),
        const SizedBox(height: 12),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(3, 3)),
              BoxShadow(color: p.highlight, blurRadius: 5, offset: const Offset(-2, -2)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _conveyorAnim,
              builder: (_, __) => CustomPaint(
                painter: _ConveyorPainter(_conveyorAnim.value, dark),
                child: Container(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Inbound Queue ─────────────────────────────────────────────────────────

  Widget _buildInboundQueue(BuildContext context, bool dark, _Palette p) {
    const items = <_QueueItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionHeader(title: 'Inbound Queue', icon: Icons.input_rounded, p: p)),
            GestureDetector(
              onTap: () => context.push('/warehouse/inbound'),
              child: Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No inbound shipments', style: TextStyle(color: p.sub, fontSize: 13))),
            )
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final arrived = item.status == 'arrived';
                return Column(
                  children: [
                    if (i > 0) Divider(height: 1, thickness: 1, color: p.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (arrived ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.local_shipping_rounded,
                                color: arrived ? AppColors.success : AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(item.carrier, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (arrived ? AppColors.success : AppColors.primary).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(arrived ? 'ARRIVED' : 'IN TRANSIT',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                              color: arrived ? AppColors.success : AppColors.primary)),
                                    ),
                                  ],
                                ),
                                Text('${item.parcels} parcels · ${item.weight}',
                                    style: TextStyle(fontSize: 11, color: p.sub)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item.id, style: TextStyle(fontSize: 10, color: p.sub)),
                              Text(item.eta, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.text)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            )),
      ],
    );
  }

  // ── Dispatch Queue ────────────────────────────────────────────────────────

  Widget _buildDispatchQueue(BuildContext context, bool dark, _Palette p) {
    const items = <_DispatchItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionHeader(title: 'Ready for Dispatch', icon: Icons.output_rounded, p: p)),
            GestureDetector(
              onTap: () => context.go('/warehouse/dispatch'),
              child: Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No items ready for dispatch', style: TextStyle(color: p.sub, fontSize: 13))),
            )
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Column(
                  children: [
                    if (i > 0) Divider(height: 1, thickness: 1, color: p.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (item.ready ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.ready ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
                                color: item.ready ? AppColors.success : AppColors.warning, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.id, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                                Text('${item.destination} · ${item.carrier} · ${item.weight}',
                                    style: TextStyle(fontSize: 11, color: p.sub)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item.time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                  color: item.ready ? AppColors.success : AppColors.warning)),
                              Text(item.ready ? 'Ready' : 'Pending', style: TextStyle(fontSize: 10, color: p.sub)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            )),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, bool dark, _Palette p) {
    final actions = [
      _Action(icon: Icons.qr_code_scanner_rounded, label: 'Scan Parcel', color: AppColors.saffron, onTap: () => context.go('/warehouse/scan')),
      _Action(icon: Icons.input_rounded, label: 'Inbound', color: AppColors.success, onTap: () => context.push('/warehouse/inbound')),
      _Action(icon: Icons.output_rounded, label: 'Outbound', color: AppColors.primary, onTap: () => context.push('/warehouse/outbound')),
      _Action(icon: Icons.category_rounded, label: 'Inventory', color: const Color(0xFF8B5CF6), onTap: () => context.go('/warehouse/inventory')),
      _Action(icon: Icons.keyboard_return_rounded, label: 'Returns', color: AppColors.error, onTap: () => context.push('/warehouse/returns')),
      _Action(icon: Icons.bar_chart_rounded, label: 'Reports', color: AppColors.warning, onTap: () => context.push('/warehouse/reports')),
      _Action(icon: Icons.local_shipping_rounded, label: 'Dispatch', color: AppColors.warehouseColor, onTap: () => context.go('/warehouse/dispatch')),
      _Action(icon: Icons.person_rounded, label: 'Profile', color: AppColors.primary, onTap: () => context.push('/warehouse/profile')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Quick Actions', icon: Icons.grid_view_rounded, p: p),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: actions.map((a) => GestureDetector(
            onTap: a.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(2, 2)),
                  BoxShadow(color: p.highlight, blurRadius: 3, offset: const Offset(-1, -1)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.icon, color: a.color, size: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(a.label,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: p.sub),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

// ── Bento Cards ───────────────────────────────────────────────────────────────

class _BentoTall extends StatelessWidget {
  final String title, value, sub;
  final IconData icon;
  final Color color;
  final bool dark;
  final _Palette p;
  final VoidCallback onTap;

  const _BentoTall({required this.title, required this.value, required this.sub, required this.icon, required this.color, required this.dark, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(3, 3)),
            BoxShadow(color: p.highlight, blurRadius: 5, offset: const Offset(-2, -2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: p.text)),
            Text(sub, style: TextStyle(fontSize: 11, color: p.sub)),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _BentoSmall extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final bool dark;
  final _Palette p;
  final VoidCallback onTap;

  const _BentoSmall({required this.title, required this.value, required this.icon, required this.color, required this.dark, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: p.shadow, blurRadius: 10, offset: const Offset(3, 3)),
            BoxShadow(color: p.highlight, blurRadius: 4, offset: const Offset(-1, -1)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
                  Text(title, style: TextStyle(fontSize: 10, color: p.sub), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conveyor Painter ──────────────────────────────────────────────────────────

class _ConveyorPainter extends CustomPainter {
  final double t;
  final bool dark;
  _ConveyorPainter(this.t, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final beltColor = dark ? const Color(0xFF2E4663) : const Color(0xFFE8EDF5);
    final lineColor = dark ? const Color(0xFF3F5E7F) : const Color(0xFFCDD7E6);
    final boxColors = [
      const Color(0xFF5EA2FF),
      const Color(0xFF22C55E),
      const Color(0xFFFF9F2F),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
    ];

    // Belt base
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4),
      Paint()..color = beltColor,
    );

    // Belt stripes (moving)
    final stripePaint = Paint()..color = lineColor;
    const stripeSpacing = 40.0;
    final offset = (t * size.width * 0.5) % stripeSpacing;
    for (double x = -stripeSpacing + offset; x < size.width + stripeSpacing; x += stripeSpacing) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.3, 3, size.height * 0.4),
        stripePaint,
      );
    }

    // Moving parcels
    for (int i = 0; i < 4; i++) {
      final baseX = (t * size.width + i * (size.width / 3)) % (size.width + 60) - 30;
      final color = boxColors[i % boxColors.length];
      final boxPaint = Paint()..color = color.withValues(alpha: 0.85);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX, size.height * 0.25, 32, 30),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, boxPaint);

      // Box lines
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(baseX + 8, size.height * 0.25 + 8),
          Offset(baseX + 24, size.height * 0.25 + 8), linePaint);
      canvas.drawLine(Offset(baseX + 8, size.height * 0.25 + 16),
          Offset(baseX + 20, size.height * 0.25 + 16), linePaint);
    }
  }

  @override
  bool shouldRepaint(_ConveyorPainter old) => old.t != t;
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _HeroBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _HeroKpi extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _HeroKpi({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final _Palette p;

  const _SectionHeader({required this.title, required this.icon, required this.p});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.text)),
      ],
    );
  }
}

class _ClayCard extends StatelessWidget {
  final bool dark;
  final _Palette p;
  final Widget child;

  const _ClayCard({required this.dark, required this.p, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 14, offset: const Offset(4, 4)),
          BoxShadow(color: p.highlight, blurRadius: 6, offset: const Offset(-2, -2)),
        ],
      ),
      child: child,
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _Alert {
  final String type, msg;
  final int color;
  const _Alert({required this.type, required this.msg, required this.color});
}

class _QueueItem {
  final String id, carrier, weight, eta, status;
  final int parcels;
  const _QueueItem({required this.id, required this.carrier, required this.parcels, required this.weight, required this.eta, required this.status});
}

class _DispatchItem {
  final String id, destination, carrier, weight, time;
  final bool ready;
  const _DispatchItem({required this.id, required this.destination, required this.carrier, required this.weight, required this.ready, required this.time});
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.color, required this.onTap});
}

// ── Palette ───────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, border;
  const _Palette({required this.bg, required this.card, required this.highlight, required this.shadow, required this.text, required this.sub, required this.border});

  factory _Palette.of(bool dark) => dark
      ? _Palette(bg: AppColors.darkBg1, card: AppColors.darkCard, highlight: AppColors.clayHighlightDark, shadow: AppColors.clayShadowDark, text: Colors.white, sub: AppColors.darkSubtext, border: AppColors.darkBorder)
      : _Palette(bg: const Color(0xFFF5F6FA), card: Colors.white, highlight: AppColors.clayHighlight, shadow: AppColors.clayShadow, text: AppColors.textDark, sub: AppColors.textDarkSecondary, border: const Color(0xFFE8EDF5));
}
