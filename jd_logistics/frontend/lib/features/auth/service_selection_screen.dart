import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

// ── Service data ──────────────────────────────────────────────────────────────

class _Service {
  final String key;
  final String label;
  final String subtitle;
  final String tag;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<String> features;
  const _Service({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.tag,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.features,
  });
}

const _kLogisticsColor = Color(0xFF0D9488);
const _kAdminColor = AppColors.adminColor;

const _services = [
  _Service(
    key: 'courier',
    label: 'Courier',
    subtitle: 'Domestic parcel & local delivery',
    tag: 'Domestic · Local · Intercity',
    emoji: '📦',
    icon: Icons.local_shipping_rounded,
    color: AppColors.customerColor,
    features: ['Pickup & Drop', 'Documents', 'Bike / Van / Truck', 'OBC Rewards'],
  ),
  _Service(
    key: 'logistics',
    label: 'Logistics',
    subtitle: 'Import, export & bulk cargo',
    tag: 'International · Freight · Containers',
    emoji: '🚢',
    icon: Icons.directions_boat_rounded,
    color: _kLogisticsColor,
    features: ['Import / Export', 'Containers & Pallets', 'Customs & Docs', 'Warehouse Storage'],
  ),
  _Service(
    key: 'admin',
    label: 'Admin Access',
    subtitle: 'Control tower — full system access',
    tag: 'Control Tower · Analytics',
    emoji: '📊',
    icon: Icons.admin_panel_settings_rounded,
    color: _kAdminColor,
    features: ['All Shipments', 'Fleet & Drivers', 'Warehouse Mgmt', 'Analytics & Reports'],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (_selected == null) return;
    HapticFeedback.mediumImpact();

    final auth = context.read<AuthProvider>();

    switch (_selected!) {
      case 'courier':
        await auth.setServiceType('courier');
        if (!mounted) return;
        context.go('/role-selection');
        break;
      case 'logistics':
        await auth.setServiceType('logistics');
        await auth.selectLoginRole('logistics_customer');
        if (!mounted) return;
        context.go('/login');
        break;
      case 'admin':
        await auth.setServiceType('admin');
        await auth.selectLoginRole('admin');
        if (!mounted) return;
        context.go('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: GradientBackground(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, _) => Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ServiceBgPainter(progress: _motion.value, dark: dark),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 840;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(wide ? 32 : 18, 16, wide ? 32 : 18, 28),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: wide ? 1100 : 520),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ThemeToggle(dark: dark),
                                const SizedBox(height: 16),
                                _Hero(progress: _motion.value),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _services.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                                  itemBuilder: (_, i) {
                                    final s = _services[i];
                                    return _ServiceCard(
                                      service: s,
                                      selected: _selected == s.key,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selected = s.key);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                _ProceedButton(
                                  selected: _selected,
                                  services: _services,
                                  onPressed: _proceed,
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    'JD Logistics · Powered by OBC Rewards',
                                    style: TextStyle(
                                      color: AppColors.subtext(context).withValues(alpha: 0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme toggle ──────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final bool dark;
  const _ThemeToggle({required this.dark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 44,
      height: 44,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      onTap: context.read<ThemeProvider>().toggleTheme,
      child: Icon(
        dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: dark ? AppColors.portOrange : AppColors.primary,
        size: 20,
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final double progress;
  const _Hero({required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GlassCard(
            width: 68,
            height: 68,
            borderRadius: 22,
            padding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.hub_rounded, color: AppColors.primary, size: 34),
                Positioned(
                  right: 6 + math.sin(progress * math.pi * 2) * 3,
                  bottom: 6,
                  child: const Text('🚢', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JD Logistics',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your service to get started',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _Pill(text: '🌏 Global Reach', color: AppColors.primary),
                    _Pill(text: '🔒 Secure', color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatefulWidget {
  final _Service service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final active = widget.selected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.982 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: GlassCard(
          borderRadius: 30,
          padding: const EdgeInsets.all(16),
          borderColor: active ? s.color.withValues(alpha: 0.7) : AppColors.border(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon block
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: AppColors.isDark(context) ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: s.color.withValues(alpha: active ? 0.5 : 0.2)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(s.icon, color: s.color, size: 34),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Text(s.emoji, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.label,
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: active
                              ? Icon(Icons.check_circle_rounded, key: const ValueKey('check'), color: s.color, size: 24)
                              : Icon(Icons.radio_button_unchecked_rounded, key: const ValueKey('circle'), color: AppColors.subtext(context).withValues(alpha: 0.4), size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: AppColors.isDark(context) ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        s.tag,
                        style: TextStyle(color: s.color, fontSize: 9.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.subtitle,
                      style: TextStyle(color: AppColors.subtext(context), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: s.features
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.isDark(context)
                                      ? AppColors.darkBg2.withValues(alpha: 0.6)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: AppColors.text(context),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Proceed button ────────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  final String? selected;
  final List<_Service> services;
  final VoidCallback onPressed;

  const _ProceedButton({
    required this.selected,
    required this.services,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final s = selected != null
        ? services.firstWhere((x) => x.key == selected, orElse: () => services.first)
        : null;
    final label = s == null ? 'Select Service' : 'Continue with ${s.label}';
    final color = s?.color ?? AppColors.primary;

    return AnimatedOpacity(
      opacity: selected != null ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: selected != null ? onPressed : null,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// ── Pill ──────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ── Background painter ────────────────────────────────────────────────────────

class _ServiceBgPainter extends CustomPainter {
  final double progress;
  final bool dark;
  _ServiceBgPainter({required this.progress, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: dark ? 0.08 : 0.12)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paths = [
      Path()
        ..moveTo(size.width * .06, size.height * .25)
        ..quadraticBezierTo(size.width * .42, size.height * .06, size.width * .84, size.height * .28),
      Path()
        ..moveTo(size.width * .10, size.height * .76)
        ..quadraticBezierTo(size.width * .46, size.height * .56, size.width * .88, size.height * .72),
    ];
    for (final p in paths) canvas.drawPath(p, routePaint);

    // moving truck
    _drawEmoji(canvas, '🚢', Offset((size.width + 80) * progress - 40, size.height * .28 + math.sin(progress * math.pi * 2) * 10), 22);
    _drawEmoji(canvas, '✈️', Offset(size.width - ((size.width + 90) * progress), size.height * .18 + math.cos(progress * math.pi * 2) * 8), 22);
    _drawEmoji(canvas, '📦', Offset((size.width + 100) * ((progress + .4) % 1) - 50, size.height * .82), 20);
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset offset, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ServiceBgPainter old) => old.progress != progress || old.dark != dark;
}
