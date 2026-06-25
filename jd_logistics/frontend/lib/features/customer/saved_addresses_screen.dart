import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';
import 'package:go_router/go_router.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _Address {
  final String id;
  final String label;
  final String name;
  final String line1;
  final String city;
  final String pin;
  final String phone;
  final bool isDefault;
  final IconData icon;

  const _Address({
    required this.id,
    required this.label,
    required this.name,
    required this.line1,
    required this.city,
    required this.pin,
    required this.phone,
    required this.isDefault,
    required this.icon,
  });
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final _addresses = [
    const _Address(
      id: 'a1',
      label: 'Home',
      name: 'Amit Sharma',
      line1: '204, Suncity Apartments, Andheri West',
      city: 'Mumbai, Maharashtra',
      pin: '400058',
      phone: '+91 98765 43210',
      isDefault: true,
      icon: Icons.home_rounded,
    ),
    const _Address(
      id: 'a2',
      label: 'Office',
      name: 'Raj Electronics Ltd.',
      line1: '12, Industrial Area, Phase II',
      city: 'Mumbai, Maharashtra',
      pin: '400053',
      phone: '+91 22 4567 8900',
      isDefault: false,
      icon: Icons.business_rounded,
    ),
    const _Address(
      id: 'a3',
      label: 'Warehouse',
      name: 'JD Mumbai Hub',
      line1: 'Plot 5, Bhiwandi Logistics Park',
      city: 'Bhiwandi, Maharashtra',
      pin: '421302',
      phone: '+91 91234 56789',
      isDefault: false,
      icon: Icons.warehouse_rounded,
    ),
  ];

  String _defaultId = 'a1';
  bool _showAddForm = false;

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
        title: Text('Saved Addresses',
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
              child: Column(
                children: [
                  // Stats row
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCol(
                            label: 'Saved',
                            value: '${_addresses.length}',
                            color: AppColors.primary,
                            isDark: isDark),
                        _VDiv(isDark: isDark),
                        _StatCol(
                            label: 'Default',
                            value: '1',
                            color: AppColors.success,
                            isDark: isDark),
                        _VDiv(isDark: isDark),
                        _StatCol(
                            label: 'Cities',
                            value: '2',
                            color: AppColors.saffron,
                            isDark: isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address cards
                  ..._addresses.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AddressCard(
                          address: a,
                          isDefault: _defaultId == a.id,
                          isDark: isDark,
                          onSetDefault: () {
                            HapticFeedback.selectionClick();
                            setState(() => _defaultId = a.id);
                          },
                          onEdit: () => _showEditSheet(context, a, isDark),
                          onDelete: () {
                            setState(() =>
                                _addresses.removeWhere((x) => x.id == a.id));
                          },
                        ),
                      )),

                  if (_showAddForm)
                    _AddAddressForm(
                      isDark: isDark,
                      onCancel: () =>
                          setState(() => _showAddForm = false),
                    ),
                ],
              ),
            ),
          ),

          // Add address CTA
          if (!_showAddForm)
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
                label: '+ Add New Address',
                onPressed: () =>
                    setState(() => _showAddForm = true),
                gradient: AppColors.primaryGradient,
                height: 52,
              ),
            ),
        ],
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, _Address a, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg2 : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit Address',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Text('${a.line1}\n${a.city} — ${a.pin}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtext
                      : AppColors.textDarkSecondary)),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Save Changes',
            onPressed: () => Navigator.pop(context),
            gradient: AppColors.primaryGradient,
            height: 48,
          ),
        ]),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final _Address address;
  final bool isDefault;
  final bool isDark;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isDefault,
    required this.isDark,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDefault ? AppColors.primary : AppColors.saffron;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(address.icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(address.label,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Default',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
              Text(address.name,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 12)),
            ]),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: isDark
                    ? AppColors.darkSubtext
                    : AppColors.textDarkSecondary,
                size: 20),
            color: isDark ? AppColors.darkBg2 : Colors.white,
            onSelected: (v) {
              if (v == 'default') onSetDefault();
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'default',
                child: Text('Set as Default',
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark)),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit',
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(address.line1,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            Text('${address.city} — ${address.pin}',
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary,
                    fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.phone_rounded,
                  color: AppColors.primary, size: 12),
              const SizedBox(width: 4),
              Text(address.phone,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _AddAddressForm extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCancel;
  const _AddAddressForm({required this.isDark, required this.onCancel});

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('New Address',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const Spacer(),
            GestureDetector(
              onTap: onCancel,
              child: Icon(Icons.close_rounded,
                  color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
                  size: 20),
            ),
          ]),
          const SizedBox(height: 12),
          Text('Full address entry form\n(connects to address autocomplete API)',
              style: TextStyle(
                  color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
                  fontSize: 13)),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Save Address',
            onPressed: onCancel,
            gradient: AppColors.primaryGradient,
            height: 46,
          ),
        ]),
      );
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _StatCol(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label,
            style: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
                fontSize: 11)),
      ]);
}

class _VDiv extends StatelessWidget {
  final bool isDark;
  const _VDiv({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.skyBorder);
}
