import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class PartnerSelectionScreen extends StatefulWidget {
  final String mode;
  const PartnerSelectionScreen({super.key, this.mode = 'road'});

  @override
  State<PartnerSelectionScreen> createState() =>
      _PartnerSelectionScreenState();
}

class _Partner {
  final String id;
  final String name;
  final String type; // domestic | international
  final double rating;
  final String etaLabel;
  final double pricePerKg;
  final String coverage;
  final bool hasInsurance;
  final bool hasTracking;
  final bool hasCustoms;
  final IconData icon;
  final Color color;
  final List<String> modes;

  const _Partner({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.etaLabel,
    required this.pricePerKg,
    required this.coverage,
    required this.hasInsurance,
    required this.hasTracking,
    required this.hasCustoms,
    required this.icon,
    required this.color,
    required this.modes,
  });
}

class _PartnerSelectionScreenState extends State<PartnerSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _selectedId = '';
  String _sortBy = 'rating';

  static const _partners = [
    // Domestic
    _Partner(
      id: 'vrl', name: 'VRL Logistics', type: 'domestic',
      rating: 4.6, etaLabel: '1–3 days', pricePerKg: 48.0,
      coverage: 'Pan India', hasInsurance: true, hasTracking: true,
      hasCustoms: false, icon: Icons.local_shipping_rounded,
      color: Color(0xFFD32F2F),
      modes: ['road'],
    ),
    _Partner(
      id: 'bluedart', name: 'Blue Dart', type: 'domestic',
      rating: 4.8, etaLabel: 'Next Day', pricePerKg: 120.0,
      coverage: 'Pan India + Intl', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.flight_rounded,
      color: Color(0xFF1565C0),
      modes: ['road', 'air'],
    ),
    _Partner(
      id: 'delhivery', name: 'Delhivery', type: 'domestic',
      rating: 4.5, etaLabel: '2–4 days', pricePerKg: 38.0,
      coverage: 'Pan India', hasInsurance: true, hasTracking: true,
      hasCustoms: false, icon: Icons.local_shipping_rounded,
      color: Color(0xFF7B1FA2),
      modes: ['road'],
    ),
    _Partner(
      id: 'dtdc', name: 'DTDC', type: 'domestic',
      rating: 4.3, etaLabel: '2–5 days', pricePerKg: 32.0,
      coverage: 'Pan India', hasInsurance: false, hasTracking: true,
      hasCustoms: false, icon: Icons.local_shipping_rounded,
      color: Color(0xFFE65100),
      modes: ['road'],
    ),
    _Partner(
      id: 'porter', name: 'Porter', type: 'domestic',
      rating: 4.7, etaLabel: 'Same Day', pricePerKg: 95.0,
      coverage: '30+ cities', hasInsurance: false, hasTracking: true,
      hasCustoms: false, icon: Icons.local_shipping_rounded,
      color: Color(0xFF00897B),
      modes: ['road'],
    ),
    _Partner(
      id: 'gati', name: 'Gati', type: 'domestic',
      rating: 4.4, etaLabel: '2–4 days', pricePerKg: 42.0,
      coverage: 'Pan India', hasInsurance: true, hasTracking: true,
      hasCustoms: false, icon: Icons.local_shipping_rounded,
      color: Color(0xFF558B2F),
      modes: ['road', 'air'],
    ),
    _Partner(
      id: 'tci', name: 'TCI Express', type: 'domestic',
      rating: 4.5, etaLabel: '1–3 days', pricePerKg: 52.0,
      coverage: 'Pan India', hasInsurance: true, hasTracking: true,
      hasCustoms: false, icon: Icons.local_shipping_rounded,
      color: Color(0xFF1976D2),
      modes: ['road'],
    ),
    _Partner(
      id: 'indiapost', name: 'India Post', type: 'domestic',
      rating: 3.9, etaLabel: '3–7 days', pricePerKg: 18.0,
      coverage: 'Nationwide', hasInsurance: true, hasTracking: false,
      hasCustoms: false, icon: Icons.mail_rounded,
      color: Color(0xFF388E3C),
      modes: ['road'],
    ),
    // International
    _Partner(
      id: 'dhl', name: 'DHL Express', type: 'international',
      rating: 4.9, etaLabel: '1–3 days intl', pricePerKg: 850.0,
      coverage: '220+ countries', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.flight_takeoff_rounded,
      color: Color(0xFFD32F2F),
      modes: ['air'],
    ),
    _Partner(
      id: 'fedex', name: 'FedEx', type: 'international',
      rating: 4.8, etaLabel: '2–4 days intl', pricePerKg: 720.0,
      coverage: '200+ countries', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF6A1B9A),
      modes: ['air'],
    ),
    _Partner(
      id: 'ups', name: 'UPS', type: 'international',
      rating: 4.7, etaLabel: '2–5 days intl', pricePerKg: 680.0,
      coverage: '200+ countries', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF4E342E),
      modes: ['air'],
    ),
    _Partner(
      id: 'aramex', name: 'Aramex', type: 'international',
      rating: 4.6, etaLabel: '3–5 days intl', pricePerKg: 580.0,
      coverage: 'Middle East + Global', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.flight_rounded,
      color: Color(0xFFE65100),
      modes: ['air'],
    ),
    _Partner(
      id: 'maersk', name: 'Maersk', type: 'international',
      rating: 4.7, etaLabel: '14–30 days', pricePerKg: 28.0,
      coverage: 'Global Ports', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.directions_boat_rounded,
      color: Color(0xFF0D47A1),
      modes: ['ocean'],
    ),
    _Partner(
      id: 'msc', name: 'MSC', type: 'international',
      rating: 4.5, etaLabel: '18–35 days', pricePerKg: 22.0,
      coverage: '500+ ports', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.directions_boat_filled_rounded,
      color: Color(0xFF006064),
      modes: ['ocean'],
    ),
    _Partner(
      id: 'emirates', name: 'Emirates SkyCargo', type: 'international',
      rating: 4.8, etaLabel: '1–2 days intl', pricePerKg: 920.0,
      coverage: '140+ destinations', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.airplanemode_active_rounded,
      color: Color(0xFFB71C1C),
      modes: ['air'],
    ),
    _Partner(
      id: 'sia', name: 'Singapore Airlines Cargo', type: 'international',
      rating: 4.9, etaLabel: '1–3 days intl', pricePerKg: 880.0,
      coverage: 'Asia Pacific + Global', hasInsurance: true, hasTracking: true,
      hasCustoms: true, icon: Icons.airplanemode_active_rounded,
      color: Color(0xFF0D47A1),
      modes: ['air'],
    ),
  ];

  List<_Partner> _filtered(String type) {
    var list = _partners.where((p) {
      if (p.type != type) return false;
      if (widget.mode.isNotEmpty) return p.modes.contains(widget.mode);
      return true;
    }).toList();
    if (_sortBy == 'price') {
      list.sort((a, b) => a.pricePerKg.compareTo(b.pricePerKg));
    } else if (_sortBy == 'eta') {
      list.sort((a, b) => a.etaLabel.compareTo(b.etaLabel));
    } else {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  Color get _modeColor {
    switch (widget.mode) {
      case 'air': return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

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
        title: Text('Choose Partner',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: isDark ? AppColors.darkBg2 : Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: _modeColor,
              unselectedLabelColor: isDark
                  ? AppColors.darkSubtext
                  : AppColors.textDarkSecondary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              indicatorColor: _modeColor,
              tabs: const [Tab(text: 'Domestic'), Tab(text: 'International')],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _StepBanner(current: 3, total: 6, isDark: isDark),
          // Sort bar
          Container(
            color: isDark ? AppColors.darkBg2 : Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Text('Sort by:',
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 12)),
              const SizedBox(width: 8),
              ...['rating', 'price', 'eta'].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _sortBy = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _sortBy == s
                              ? _modeColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _sortBy == s
                                  ? _modeColor
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.skyBorder)),
                        ),
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(
                              color: _sortBy == s
                                  ? Colors.white
                                  : isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.textDarkSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )),
            ]),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _PartnerList(
                    partners: _filtered('domestic'),
                    selectedId: _selectedId,
                    isDark: isDark,
                    modeColor: _modeColor,
                    onSelect: (id) => setState(() => _selectedId = id)),
                _PartnerList(
                    partners: _filtered('international'),
                    selectedId: _selectedId,
                    isDark: isDark,
                    modeColor: _modeColor,
                    onSelect: (id) => setState(() => _selectedId = id)),
              ],
            ),
          ),

          // CTA
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
            child: GradientButton(
              label: _selectedId.isEmpty
                  ? 'Select a Partner'
                  : 'Get Price Estimate',
              onPressed: _selectedId.isEmpty
                  ? null
                  : () => context.push(
                      '/shipment/price-estimate?mode=${widget.mode}&partner=$_selectedId'),
              gradient: [_modeColor, _modeColor.withValues(alpha: 0.8)],
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerList extends StatelessWidget {
  final List<_Partner> partners;
  final String selectedId;
  final bool isDark;
  final Color modeColor;
  final ValueChanged<String> onSelect;

  const _PartnerList({
    required this.partners,
    required this.selectedId,
    required this.isDark,
    required this.modeColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (partners.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off_rounded,
              size: 54,
              color: isDark ? AppColors.darkSubtext : AppColors.textDarkHint),
          const SizedBox(height: 12),
          Text('No partners for this mode',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtext
                      : AppColors.textDarkSecondary)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: partners.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _PartnerCard(
        partner: partners[i],
        selected: selectedId == partners[i].id,
        isDark: isDark,
        modeColor: modeColor,
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect(partners[i].id);
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final _Partner partner;
  final bool selected;
  final bool isDark;
  final Color modeColor;
  final VoidCallback onTap;

  const _PartnerCard({
    required this.partner,
    required this.selected,
    required this.isDark,
    required this.modeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? modeColor.withValues(alpha: isDark ? 0.12 : 0.06)
              : (isDark ? AppColors.darkBg2 : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? modeColor
                : (isDark ? AppColors.darkBorder : AppColors.skyBorder),
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.clayShadowDark.withValues(alpha: 0.4)
                  : AppColors.clayShadowLight.withValues(alpha: 0.5),
              offset: const Offset(4, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: partner.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(partner.icon, color: partner.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(partner.name,
                          style: TextStyle(
                              color:
                                  isDark ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 12),
                        const SizedBox(width: 3),
                        Text(partner.rating.toString(),
                            style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.schedule_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary),
                    const SizedBox(width: 4),
                    Text(partner.etaLabel,
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkSecondary,
                            fontSize: 12)),
                    const SizedBox(width: 12),
                    Icon(Icons.public_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(partner.coverage,
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.textDarkSecondary,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _FeatureTag(
                        label:
                            '₹${partner.pricePerKg.toStringAsFixed(0)}/kg',
                        color: modeColor),
                    const SizedBox(width: 6),
                    if (partner.hasTracking)
                      const _FeatureTag(
                          label: 'Tracking', color: AppColors.primary),
                    if (partner.hasInsurance) ...[
                      const SizedBox(width: 6),
                      const _FeatureTag(
                          label: 'Insurance', color: AppColors.success),
                    ],
                    if (partner.hasCustoms) ...[
                      const SizedBox(width: 6),
                      const _FeatureTag(
                          label: 'Customs', color: AppColors.warning),
                    ],
                  ]),
                ],
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded,
                    color: modeColor, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String label;
  final Color color;
  const _FeatureTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      );
}

class _StepBanner extends StatelessWidget {
  final int current;
  final int total;
  final bool isDark;
  const _StepBanner(
      {required this.current, required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        color: isDark ? AppColors.darkBg2 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Text('Step $current of $total',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtext
                      : AppColors.textDarkSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / total,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.skyBorder,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${((current / total) * 100).round()}%',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}
