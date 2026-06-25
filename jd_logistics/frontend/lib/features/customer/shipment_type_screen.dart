import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class ShipmentTypeScreen extends StatefulWidget {
  const ShipmentTypeScreen({super.key});

  @override
  State<ShipmentTypeScreen> createState() => _ShipmentTypeScreenState();
}

class _ShipmentMode {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String etaRange;
  final String priceRange;
  final List<String> features;
  final List<String> routes;

  const _ShipmentMode({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.etaRange,
    required this.priceRange,
    required this.features,
    required this.routes,
  });
}

class _ShipmentTypeScreenState extends State<ShipmentTypeScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'road';
  late final AnimationController _anim;

  static const _modes = [
    _ShipmentMode(
      key: 'road',
      title: 'Road / Truck',
      subtitle: 'Ground freight across India & neighbouring countries',
      icon: Icons.local_shipping_rounded,
      color: AppColors.roadColor,
      etaRange: '1–7 days',
      priceRange: '₹80–₹2,500/kg',
      features: [
        'Door-to-door pickup & delivery',
        'Full Truck Load (FTL) & LCL',
        'Real-time GPS tracking',
        'COD & prepaid options',
      ],
      routes: ['Mumbai → Delhi', 'Bangalore → Chennai', 'Pune → Hyderabad'],
    ),
    _ShipmentMode(
      key: 'air',
      title: 'Air Cargo',
      subtitle: 'Fast domestic & international air freight',
      icon: Icons.flight_takeoff_rounded,
      color: AppColors.airColor,
      etaRange: '1–3 days',
      priceRange: '₹350–₹8,000/kg',
      features: [
        'Next-day domestic delivery',
        'International freight in 3 days',
        'Airport-to-airport + door delivery',
        'Customs clearance support',
      ],
      routes: ['Mumbai ✈ Singapore', 'Delhi ✈ Dubai', 'Chennai ✈ London'],
    ),
    _ShipmentMode(
      key: 'ocean',
      title: 'Ocean Freight',
      subtitle: 'Cost-effective sea freight for large volumes',
      icon: Icons.directions_boat_rounded,
      color: AppColors.oceanColor,
      etaRange: '7–30 days',
      priceRange: '₹25–₹500/kg',
      features: [
        'FCL & LCL container options',
        'Port-to-port & door delivery',
        'Customs & documentation support',
        'Ideal for bulk & heavy cargo',
      ],
      routes: ['JNPT → Dubai Port', 'Chennai → Singapore Port', 'Kolkata → Shanghai'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final mode = _modes.firstWhere((m) => m.key == _selected);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg2 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Shipment Mode',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          // Step indicator
          _StepBar(current: 1, total: 6, isDark: isDark),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How do you want to ship?',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose the best mode for your cargo',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mode cards
                  ..._modes.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ModeCard(
                          mode: m,
                          selected: _selected == m.key,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selected = m.key);
                          },
                        ),
                      )),

                  const SizedBox(height: 8),

                  // Popular routes for selected mode
                  Text(
                    'Popular Routes',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mode.routes
                        .map((r) => _RouteChip(
                            label: r,
                            color: mode.color,
                            isDark: isDark))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // CTA
          _BottomCta(
            label: 'Continue with ${mode.title}',
            color: mode.color,
            isDark: isDark,
            onTap: () => context.push(
                '/shipment/package-details?mode=${mode.key}'),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final _ShipmentMode mode;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected
              ? mode.color.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.darkBg2 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? mode.color : (isDark ? AppColors.darkBorder : AppColors.skyBorder),
            width: selected ? 2 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: mode.color.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? AppColors.clayShadowDark.withValues(alpha: 0.45)
                        : AppColors.clayShadowLight.withValues(alpha: 0.55),
                    offset: const Offset(6, 6),
                    blurRadius: 16,
                  ),
                ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mode.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(mode.icon, color: mode.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        mode.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: mode.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Selected',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    mode.subtitle,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    _InfoChip(
                        icon: Icons.schedule_rounded,
                        label: mode.etaRange,
                        color: mode.color),
                    const SizedBox(width: 8),
                    _InfoChip(
                        icon: Icons.currency_rupee_rounded,
                        label: mode.priceRange,
                        color: mode.color),
                  ]),
                  if (selected) ...[
                    const SizedBox(height: 10),
                    ...mode.features.map((f) => Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: mode.color, size: 13),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkSubtext
                                        : AppColors.textDarkSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _RouteChip(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg3 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );
}

class _StepBar extends StatelessWidget {
  final int current;
  final int total;
  final bool isDark;
  const _StepBar(
      {required this.current, required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkBg2 : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'Step $current of $total',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtext
                      : AppColors.textDarkSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${((current / total) * 100).round()}% complete',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.skyBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _BottomCta(
      {required this.label,
      required this.color,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg2 : Colors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.skyBorder)),
      ),
      child: GradientButton(
        label: label,
        onPressed: onTap,
        gradient: [color, color.withValues(alpha: 0.8)],
        height: 52,
      ),
    );
  }
}
