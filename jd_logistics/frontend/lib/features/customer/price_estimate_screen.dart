import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class PriceEstimateScreen extends StatefulWidget {
  final String mode;
  final String partner;
  const PriceEstimateScreen(
      {super.key, this.mode = 'road', this.partner = 'bluedart'});

  @override
  State<PriceEstimateScreen> createState() => _PriceEstimateScreenState();
}

class _PriceEstimateScreenState extends State<PriceEstimateScreen> {
  final _promoCtrl = TextEditingController();
  bool _promoApplied = false;
  bool _insuranceAdded = false;

  // Mock price breakdown (INR)
  static const double _baseFreight = 1240.0;
  static const double _distanceSurcharge = 180.0;
  static const double _fuelSurcharge = 96.0;
  static const double _handling = 60.0;
  static const double _gstRate = 0.18;
  static const double _insurancePremium = 149.0;
  static const double _promoDiscount = 120.0;

  double get _subtotal =>
      _baseFreight + _distanceSurcharge + _fuelSurcharge + _handling;
  double get _gst => _subtotal * _gstRate;
  double get _insurance => _insuranceAdded ? _insurancePremium : 0;
  double get _discount => _promoApplied ? _promoDiscount : 0;
  double get _total => _subtotal + _gst + _insurance - _discount;

  Color get _modeColor {
    switch (widget.mode) {
      case 'air': return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  IconData get _modeIcon {
    switch (widget.mode) {
      case 'air': return Icons.flight_takeoff_rounded;
      case 'ocean': return Icons.directions_boat_rounded;
      default: return Icons.local_shipping_rounded;
    }
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
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
        title: Text('Price Estimate',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          _StepBanner(current: 4, total: 6, isDark: isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route hero card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _modeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_modeIcon, color: _modeColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.mode[0].toUpperCase()}${widget.mode.substring(1)} Freight',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15),
                              ),
                              Text(
                                widget.partner.toUpperCase(),
                                style: TextStyle(
                                    color: _modeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('5.2 kg',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w700)),
                            Text('Mumbai → Delhi',
                                style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkSubtext
                                        : AppColors.textDarkSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _RouteStatCol(
                              label: 'Distance',
                              value: '1,418 km',
                              isDark: isDark),
                          _VertDivider(isDark: isDark),
                          _RouteStatCol(
                              label: 'ETA',
                              value: '2–3 days',
                              isDark: isDark),
                          _VertDivider(isDark: isDark),
                          _RouteStatCol(
                              label: 'Category',
                              value: 'Electronics',
                              isDark: isDark),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Breakdown
                  _SLabel('Price Breakdown', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _LineItem(label: 'Base Freight',
                          value: _baseFreight, isDark: isDark),
                      _LineItem(label: 'Distance Surcharge (1,418 km)',
                          value: _distanceSurcharge, isDark: isDark),
                      _LineItem(label: 'Fuel Surcharge',
                          value: _fuelSurcharge, isDark: isDark),
                      _LineItem(label: 'Handling Fee',
                          value: _handling, isDark: isDark),
                      const _DividerLine(),
                      _LineItem(label: 'GST (18%)',
                          value: _gst, isDark: isDark),
                      if (_insuranceAdded)
                        _LineItem(
                            label: 'Cargo Insurance',
                            value: _insurance,
                            isDark: isDark,
                            color: AppColors.success),
                      if (_promoApplied)
                        _LineItem(
                            label: 'Promo: JD120',
                            value: -_discount,
                            isDark: isDark,
                            color: AppColors.success),
                      const _DividerLine(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                          Text(
                            '₹${_total.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: _modeColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Insurance add-on
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: AppColors.success, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add Cargo Insurance',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w700)),
                            Text('₹149 — covers up to ₹50,000',
                                style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkSubtext
                                        : AppColors.textDarkSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _insuranceAdded,
                        onChanged: (v) =>
                            setState(() => _insuranceAdded = v),
                        activeThumbColor: AppColors.success,
                        activeTrackColor:
                            AppColors.success.withValues(alpha: 0.3),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Promo code
                  _SLabel('Promo Code', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _promoCtrl,
                          style: TextStyle(
                              color:
                                  isDark ? Colors.white : AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: 'Enter promo code (try JD120)',
                            hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.textDarkHint,
                                fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _promoApplied =
                              _promoCtrl.text.trim().toUpperCase() == 'JD120';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: _promoApplied
                                ? AppColors.success
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _promoApplied ? 'Applied!' : 'Apply',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkSecondary,
                            fontWeight: FontWeight.w600)),
                    Text('₹${_total.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: _modeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),
                GradientButton(
                  label: 'Proceed to Payment',
                  onPressed: () => context.push(
                      '/shipment/order-confirmation?mode=${widget.mode}&total=${_total.toStringAsFixed(0)}'),
                  gradient: [_modeColor, _modeColor.withValues(alpha: 0.8)],
                  height: 52,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SLabel(this.text, {required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      );
}

class _LineItem extends StatelessWidget {
  final String label;
  final double value;
  final bool isDark;
  final Color? color;
  const _LineItem(
      {required this.label,
      required this.value,
      required this.isDark,
      this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 13)),
            ),
            Text(
              value < 0
                  ? '−₹${(-value).toStringAsFixed(0)}'
                  : '₹${value.toStringAsFixed(0)}',
              style: TextStyle(
                  color: color ??
                      (isDark ? Colors.white : AppColors.textDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ],
        ),
      );
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 16, thickness: 0.5);
}

class _RouteStatCol extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _RouteStatCol(
      {required this.label, required this.value, required this.isDark});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 13)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: isDark
                    ? AppColors.darkSubtext
                    : AppColors.textDarkSecondary,
                fontSize: 11)),
      ]);
}

class _VertDivider extends StatelessWidget {
  final bool isDark;
  const _VertDivider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 28,
      color:
          isDark ? AppColors.darkBorder : AppColors.skyBorder);
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
