import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class RebookShipmentScreen extends StatefulWidget {
  final String id;
  const RebookShipmentScreen({super.key, this.id = 'JD-IND-1987'});

  @override
  State<RebookShipmentScreen> createState() => _RebookShipmentScreenState();
}

class _RebookShipmentScreenState extends State<RebookShipmentScreen> {
  // Pre-filled from prior shipment
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _dimCtrl;
  String _mode = 'Road';
  String _category = 'Electronics';
  bool _fragile = false;
  bool _insurance = false;
  bool _booking = false;

  static const _modes = ['Road', 'Air', 'Ocean'];
  static const _categories = [
    'Electronics', 'Clothing', 'Furniture', 'Food & Perishables',
    'Industrial Goods', 'Documents', 'Automotive Parts', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fromCtrl = TextEditingController(text: 'Delhi, India');
    _toCtrl = TextEditingController(text: 'Bangalore, India');
    _weightCtrl = TextEditingController(text: '5.2');
    _dimCtrl = TextEditingController(text: '30 × 20 × 15 cm');
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _weightCtrl.dispose();
    _dimCtrl.dispose();
    super.dispose();
  }

  void _book() async {
    setState(() => _booking = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.pushReplacement('/shipment/type');
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
        title: Text('Rebook Shipment',
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
                // Original shipment notice
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pre-filled from ${widget.id} · Edit any field to update',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Route section
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Route', isDark: isDark),
                      const SizedBox(height: 12),
                      _Field(
                        controller: _fromCtrl,
                        label: 'From',
                        icon: Icons.circle,
                        iconColor: AppColors.success,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _SwapBtn(onTap: () {
                        final tmp = _fromCtrl.text;
                        _fromCtrl.text = _toCtrl.text;
                        _toCtrl.text = tmp;
                      }, isDark: isDark),
                      const SizedBox(height: 10),
                      _Field(
                        controller: _toCtrl,
                        label: 'To',
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.error,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Mode selector
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Shipping Mode', isDark: isDark),
                      const SizedBox(height: 12),
                      Row(children: _modes
                          .map((m) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: m == _modes.last ? 0 : 8),
                                  child: _ModeChip(
                                    label: m,
                                    selected: _mode == m,
                                    isDark: isDark,
                                    onTap: () =>
                                        setState(() => _mode = m),
                                  ),
                                ),
                              ))
                          .toList()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Package details
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Package Details', isDark: isDark),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: _Field(
                            controller: _weightCtrl,
                            label: 'Weight (kg)',
                            icon: Icons.scale_rounded,
                            iconColor: AppColors.saffron,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Field(
                            controller: _dimCtrl,
                            label: 'Dimensions',
                            icon: Icons.straighten_rounded,
                            iconColor: AppColors.airColor,
                            isDark: isDark,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _CategoryDropdown(
                        value: _category,
                        categories: _categories,
                        isDark: isDark,
                        onChange: (v) =>
                            setState(() => _category = v ?? _category),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Options
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _ToggleRow(
                      label: 'Fragile Package',
                      subtitle: 'Extra handling care',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      value: _fragile,
                      isDark: isDark,
                      onChange: (v) => setState(() => _fragile = v),
                    ),
                    const SizedBox(height: 12),
                    _ToggleRow(
                      label: 'Add Insurance',
                      subtitle: 'Coverage up to ₹50,000',
                      icon: Icons.verified_user_rounded,
                      color: AppColors.success,
                      value: _insurance,
                      isDark: isDark,
                      onChange: (v) => setState(() => _insurance = v),
                    ),
                  ]),
                ),
              ]),
            ),
          ),

          // Rebook CTA
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
              label: _booking ? 'Processing...' : 'Rebook Shipment',
              onPressed: _booking ? null : _book,
              gradient: AppColors.primaryGradient,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, {required this.isDark});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: isDark ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 14));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final TextInputType? keyboardType;
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.skyBorder),
        ),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 13),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkHint,
                    fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ]),
      );
}

class _SwapBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _SwapBtn({required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.swap_vert_rounded,
                color: AppColors.primary, size: 18),
          ),
        ),
      );
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : (isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.skyBorder)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13)),
          ),
        ),
      );
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> categories;
  final bool isDark;
  final ValueChanged<String?> onChange;
  const _CategoryDropdown({
    required this.value,
    required this.categories,
    required this.isDark,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.skyBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: isDark ? AppColors.darkBg2 : Colors.white,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: isDark
                    ? AppColors.darkSubtext
                    : AppColors.textDarkSecondary),
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500),
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: onChange,
          ),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChange;
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.isDark,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              Text(subtitle,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChange,
          activeThumbColor: color,
          activeTrackColor: color.withValues(alpha: 0.3),
        ),
      ]);
}
