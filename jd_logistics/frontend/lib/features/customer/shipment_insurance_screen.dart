import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class ShipmentInsuranceScreen extends StatefulWidget {
  final String id;
  const ShipmentInsuranceScreen({super.key, this.id = 'JD-IND-2048'});

  @override
  State<ShipmentInsuranceScreen> createState() =>
      _ShipmentInsuranceScreenState();
}

class _InsuranceTier {
  final String key;
  final String name;
  final String coverage;
  final double price;
  final Color color;
  final List<String> features;
  const _InsuranceTier({
    required this.key,
    required this.name,
    required this.coverage,
    required this.price,
    required this.color,
    required this.features,
  });
}

const _tiers = [
  _InsuranceTier(
    key: 'basic',
    name: 'Basic Cover',
    coverage: '₹25,000',
    price: 99,
    color: AppColors.primary,
    features: [
      'Covers loss in transit',
      'Fire & natural disaster',
      'Valid for domestic routes',
      'Claim within 7 days',
    ],
  ),
  _InsuranceTier(
    key: 'standard',
    name: 'Standard Cover',
    coverage: '₹1,00,000',
    price: 249,
    color: AppColors.success,
    features: [
      'All Basic benefits',
      'Theft & pilferage covered',
      'Damage during handling',
      '24×7 claim support',
      'International routes',
    ],
  ),
  _InsuranceTier(
    key: 'premium',
    name: 'Premium Cover',
    coverage: '₹5,00,000',
    price: 599,
    color: AppColors.saffron,
    features: [
      'All Standard benefits',
      'Full replacement value',
      'Express claim — 48 hrs',
      'Door-to-door coverage',
      'Temperature-sensitive goods',
      'Dedicated claims manager',
    ],
  ),
];

class _ShipmentInsuranceScreenState extends State<ShipmentInsuranceScreen> {
  String _selected = 'standard';
  bool _adding = false;

  void _add() async {
    setState(() => _adding = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final tier = _tiers.firstWhere((t) => t.key == _selected);

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
        title: Text('Shipment Insurance',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(children: [
                // Shipment reference
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    const Icon(Icons.verified_user_rounded,
                        color: AppColors.success, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insuring: ${widget.id}',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text('Mumbai → Delhi · Blue Dart · 5.2 kg',
                              style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.textDarkSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                // Why insure banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.shield_rounded,
                        color: AppColors.warning, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Protect your shipment',
                              style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          Text(
                            'In case of damage or loss, insurance\nguarantees full reimbursement.',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.textDarkSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                // Tier cards
                ..._tiers.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TierCard(
                        tier: t,
                        selected: _selected == t.key,
                        isDark: isDark,
                        onSelect: () =>
                            setState(() => _selected = t.key),
                      ),
                    )),

                const SizedBox(height: 8),

                // Fine print
                Text(
                  'All plans are underwritten by National Insurance Co. Ltd.\n'
                  'Claims subject to terms & conditions.',
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkHint,
                      fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),

          // CTA bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg2 : Colors.white,
              border: Border(
                  top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.skyBorder)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tier.name,
                        style: TextStyle(
                            color: tier.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    Text('Coverage: ${tier.coverage}',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkSecondary,
                            fontSize: 12)),
                  ]),
                  Text('₹${tier.price.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ],
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: _adding ? 'Adding...' : 'Add Insurance',
                onPressed: _adding ? null : _add,
                gradient: AppColors.primaryGradient,
                height: 52,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final _InsuranceTier tier;
  final bool selected;
  final bool isDark;
  final VoidCallback onSelect;
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? tier.color.withValues(alpha: isDark ? 0.12 : 0.06)
                : (isDark ? AppColors.darkBg2 : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected
                    ? tier.color
                    : (isDark ? AppColors.darkBorder : AppColors.skyBorder),
                width: selected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.clayShadowDark
                    : AppColors.clayShadowLight,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tier.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shield_rounded, color: tier.color, size: 18),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tier.name,
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text('Coverage: ${tier.coverage}',
                      style: TextStyle(
                          color: tier.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${tier.price.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 18)),
                  Text('one-time',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.textDarkSecondary,
                          fontSize: 10)),
                ]),
              ]),
              const SizedBox(height: 12),
              ...tier.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(children: [
                    Icon(Icons.check_circle_rounded,
                        color: tier.color, size: 14),
                    const SizedBox(width: 8),
                    Text(f,
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkSecondary,
                            fontSize: 12)),
                  ]),
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tier.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Selected',
                      style: TextStyle(
                          color: tier.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      );
}
