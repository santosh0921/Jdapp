import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class PackageDetailsScreen extends StatefulWidget {
  final String mode;
  const PackageDetailsScreen({super.key, this.mode = 'road'});

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  final _weightCtrl = TextEditingController(text: '');
  final _lengthCtrl = TextEditingController(text: '');
  final _widthCtrl = TextEditingController(text: '');
  final _heightCtrl = TextEditingController(text: '');
  final _valueCtrl = TextEditingController(text: '');
  final _descCtrl = TextEditingController(text: '');

  String _category = 'Electronics';
  int _quantity = 1;
  bool _fragile = false;
  bool _tempSensitive = false;
  bool _hazardous = false;
  bool _kgSelected = true;

  static const _categories = [
    'Electronics', 'Clothing & Apparel', 'Furniture', 'Automotive Parts',
    'Pharmaceuticals', 'Food & Beverages', 'Documents', 'Industrial Goods',
    'Chemicals', 'Machinery', 'Artwork', 'Other',
  ];

  Color get _modeColor {
    switch (widget.mode) {
      case 'air': return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _valueCtrl.dispose();
    _descCtrl.dispose();
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
        title: Text('Package Details',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          _StepIndicator(current: 2, total: 6, isDark: isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weight
                  _SectionLabel('Weight', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                          child: _InputField(
                            controller: _weightCtrl,
                            label: 'Total Weight',
                            hint: '0.0',
                            suffix: _kgSelected ? 'kg' : 'lb',
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _UnitToggle(
                          kg: _kgSelected,
                          isDark: isDark,
                          onToggle: (v) => setState(() => _kgSelected = v),
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Dimensions
                  _SectionLabel('Dimensions (cm)', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Expanded(
                        child: _InputField(
                          controller: _lengthCtrl,
                          label: 'Length',
                          hint: 'L',
                          suffix: 'cm',
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InputField(
                          controller: _widthCtrl,
                          label: 'Width',
                          hint: 'W',
                          suffix: 'cm',
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InputField(
                          controller: _heightCtrl,
                          label: 'Height',
                          hint: 'H',
                          suffix: 'cm',
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Category + Quantity
                  _SectionLabel('Package Info', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _DropdownRow(
                        label: 'Category',
                        value: _category,
                        items: _categories,
                        isDark: isDark,
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity',
                              style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.textDarkSecondary,
                                  fontWeight: FontWeight.w600)),
                          _QuantityStepper(
                            value: _quantity,
                            isDark: isDark,
                            color: _modeColor,
                            onChanged: (v) => setState(() => _quantity = v),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Special Handling
                  _SectionLabel('Special Handling', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(4),
                    child: Column(children: [
                      _ToggleTile(
                        icon: Icons.egg_rounded,
                        label: 'Fragile',
                        subtitle: 'Handle with extra care',
                        color: AppColors.warning,
                        value: _fragile,
                        isDark: isDark,
                        onChanged: (v) => setState(() => _fragile = v),
                      ),
                      _ToggleTile(
                        icon: Icons.thermostat_rounded,
                        label: 'Temperature Sensitive',
                        subtitle: 'Cold-chain / refrigerated transport',
                        color: AppColors.airColor,
                        value: _tempSensitive,
                        isDark: isDark,
                        onChanged: (v) => setState(() => _tempSensitive = v),
                      ),
                      _ToggleTile(
                        icon: Icons.warning_rounded,
                        label: 'Hazardous Material',
                        subtitle: 'Requires DG documentation',
                        color: AppColors.error,
                        value: _hazardous,
                        isDark: isDark,
                        onChanged: (v) => setState(() => _hazardous = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Declared Value
                  _SectionLabel('Declared Value (for insurance)', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: _InputField(
                      controller: _valueCtrl,
                      label: 'Value (INR)',
                      hint: 'e.g. 50000',
                      prefix: '₹',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  _SectionLabel('Package Description', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Brief description of contents...',
                        hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkHint),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CTA
          _BottomBar(
            isDark: isDark,
            label: 'Choose Partner',
            color: _modeColor,
            onTap: () => context.push(
                '/shipment/partners?mode=${widget.mode}'),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, {required this.isDark});

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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final String? prefix;
  final TextInputType keyboardType;
  final bool isDark;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.suffix,
    this.prefix,
    required this.keyboardType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark
                    ? AppColors.darkSubtext
                    : AppColors.textDarkSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style:
              TextStyle(color: isDark ? Colors.white : AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.textDarkHint),
            prefixText: prefix,
            suffixText: suffix,
            prefixStyle: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.textDark),
            suffixStyle: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.textDark),
            filled: true,
            fillColor: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.skyBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.skyBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final bool kg;
  final bool isDark;
  final ValueChanged<bool> onToggle;
  const _UnitToggle(
      {required this.kg, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.skyBorder),
      ),
      child: Row(children: [
        _UnitBtn(label: 'kg', selected: kg, isDark: isDark,
            onTap: () => onToggle(true)),
        _UnitBtn(label: 'lb', selected: !kg, isDark: isDark,
            onTap: () => onToggle(false)),
      ]),
    );
  }
}

class _UnitBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _UnitBtn(
      {required this.label,
      required this.selected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected
                      ? Colors.white
                      : isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      );
}

class _DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;
  const _DropdownRow(
      {required this.label,
      required this.value,
      required this.items,
      required this.isDark,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: TextStyle(
              color: isDark
                  ? AppColors.darkSubtext
                  : AppColors.textDarkSecondary,
              fontWeight: FontWeight.w600)),
      const Spacer(),
      DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppColors.darkBg2 : Colors.white,
        style: TextStyle(
            color: isDark ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 14),
        icon: Icon(Icons.expand_more_rounded,
            color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
            size: 18),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    ]);
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final bool isDark;
  final Color color;
  final ValueChanged<int> onChanged;
  const _QuantityStepper(
      {required this.value,
      required this.isDark,
      required this.color,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StepBtn(
          icon: Icons.remove_rounded,
          color: color,
          enabled: value > 1,
          onTap: () {
            HapticFeedback.selectionClick();
            if (value > 1) onChanged(value - 1);
          }),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('$value',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
      ),
      _StepBtn(
          icon: Icons.add_rounded,
          color: color,
          enabled: true,
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(value + 1);
          }),
    ]);
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  const _StepBtn(
      {required this.icon,
      required this.color,
      required this.enabled,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: enabled ? color : AppColors.darkBorder),
          ),
          child: Icon(icon,
              color: enabled ? color : AppColors.darkSubtext, size: 16),
        ),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: color,
        secondary: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(label,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: isDark
                    ? AppColors.darkSubtext
                    : AppColors.textDarkSecondary,
                fontSize: 11)),
      );
}

class _BottomBar extends StatelessWidget {
  final bool isDark;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BottomBar(
      {required this.isDark,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg2 : Colors.white,
          border: Border(
              top: BorderSide(
                  color:
                      isDark ? AppColors.darkBorder : AppColors.skyBorder)),
        ),
        child: GradientButton(
          label: label,
          onPressed: onTap,
          gradient: [color, color.withValues(alpha: 0.8)],
          height: 52,
        ),
      );
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final bool isDark;
  const _StepIndicator(
      {required this.current, required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        color: isDark ? AppColors.darkBg2 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Step $current of $total',
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${((current / total) * 100).round()}% complete',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.skyBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ]),
      );
}
