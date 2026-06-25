import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';

class WarehouseProfileScreen extends StatefulWidget {
  const WarehouseProfileScreen({super.key});

  @override
  State<WarehouseProfileScreen> createState() => _WarehouseProfileScreenState();
}

class _WarehouseProfileScreenState extends State<WarehouseProfileScreen> {
  bool _notifyInbound = true;
  bool _notifyOutbound = true;
  bool _notifyLowStock = true;
  bool _notifyDispatch = false;

  static const _warehouseInfo = _WarehouseInfo(
    name: 'JD Hub — Bengaluru East',
    code: 'WH-0007',
    address: 'KIADB Industrial Area, Whitefield, Bengaluru, KA 560066',
    zone: 'South Zone',
    capacity: '12,000 sq ft',
    maxWeight: '80,000 kg',
    operatingHours: '06:00 AM – 11:00 PM',
    manager: 'Ravi Kumar S.',
    phone: '+91 98765 43210',
    email: 'wh007@jdlogistics.in',
    joinedDate: 'March 2023',
  );

  static const _stats = [
    _Stat(label: 'Active SKUs', value: '2,841', icon: Icons.inventory_2_rounded, color: 0xFF5EA2FF),
    _Stat(label: 'Pending Inbound', value: '34', icon: Icons.input_rounded, color: 0xFF22C55E),
    _Stat(label: 'Ready to Dispatch', value: '127', icon: Icons.output_rounded, color: 0xFFFF9F2F),
    _Stat(label: 'Returns Today', value: '12', icon: Icons.keyboard_return_rounded, color: 0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final auth = context.watch<AuthProvider>();
    final p = _Palette.of(dark);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(context, dark, p, auth),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStats(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Warehouse Details', p),
                    const SizedBox(height: 8),
                    _buildWarehouseDetails(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Contact Info', p),
                    const SizedBox(height: 8),
                    _buildContactInfo(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Notifications', p),
                    const SizedBox(height: 8),
                    _buildNotifications(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Quick Actions', p),
                    const SizedBox(height: 8),
                    _buildQuickActions(context, dark, p),
                    const SizedBox(height: 20),
                    _buildLogout(context, dark, p, auth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool dark, _Palette p, AuthProvider auth) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B4FCC), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // AppBar area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
            ),
            child: const Icon(Icons.warehouse_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(_warehouseInfo.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_warehouseInfo.code,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Active',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_warehouseInfo.zone,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStats(bool dark, _Palette p) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: _stats.map((s) {
        final color = Color(s.color);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: p.shadow, blurRadius: 10, offset: const Offset(3, 3)),
              BoxShadow(color: p.highlight, blurRadius: 4, offset: const Offset(-1, -1)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s.icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.value,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: p.text),
                        overflow: TextOverflow.ellipsis),
                    Text(s.label,
                        style: TextStyle(fontSize: 10, color: p.sub),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title, _Palette p) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.sub, letterSpacing: 0.4)),
      );

  Widget _buildWarehouseDetails(bool dark, _Palette p) {
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        children: [
          _InfoRow(icon: Icons.location_on_rounded, label: 'Address', value: _warehouseInfo.address, p: p, color: AppColors.primary),
          _divider(p),
          _InfoRow(icon: Icons.straighten_rounded, label: 'Capacity', value: _warehouseInfo.capacity, p: p, color: AppColors.success),
          _divider(p),
          _InfoRow(icon: Icons.scale_rounded, label: 'Max Weight', value: _warehouseInfo.maxWeight, p: p, color: AppColors.warning),
          _divider(p),
          _InfoRow(icon: Icons.schedule_rounded, label: 'Operating Hours', value: _warehouseInfo.operatingHours, p: p, color: const Color(0xFF8B5CF6)),
          _divider(p),
          _InfoRow(icon: Icons.calendar_month_rounded, label: 'Member Since', value: _warehouseInfo.joinedDate, p: p, color: AppColors.saffron),
        ],
      ),
    );
  }

  Widget _buildContactInfo(bool dark, _Palette p) {
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        children: [
          _InfoRow(icon: Icons.person_rounded, label: 'Manager', value: _warehouseInfo.manager, p: p, color: AppColors.primary),
          _divider(p),
          _InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: _warehouseInfo.phone, p: p, color: AppColors.success),
          _divider(p),
          _InfoRow(icon: Icons.email_rounded, label: 'Email', value: _warehouseInfo.email, p: p, color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildNotifications(bool dark, _Palette p) {
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        children: [
          _NotifToggle(
            icon: Icons.input_rounded,
            iconColor: AppColors.success,
            label: 'Inbound Alerts',
            sub: 'New items arriving at warehouse',
            value: _notifyInbound,
            onChanged: (v) => setState(() => _notifyInbound = v),
            p: p,
          ),
          _divider(p),
          _NotifToggle(
            icon: Icons.output_rounded,
            iconColor: AppColors.primary,
            label: 'Outbound Alerts',
            sub: 'Packages leaving warehouse',
            value: _notifyOutbound,
            onChanged: (v) => setState(() => _notifyOutbound = v),
            p: p,
          ),
          _divider(p),
          _NotifToggle(
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.error,
            label: 'Low Stock Warning',
            sub: 'Alert when inventory falls below threshold',
            value: _notifyLowStock,
            onChanged: (v) => setState(() => _notifyLowStock = v),
            p: p,
          ),
          _divider(p),
          _NotifToggle(
            icon: Icons.local_shipping_rounded,
            iconColor: AppColors.warning,
            label: 'Dispatch Reminders',
            sub: 'Pending dispatch queue alerts',
            value: _notifyDispatch,
            onChanged: (v) => setState(() => _notifyDispatch = v),
            p: p,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool dark, _Palette p) {
    final actions = [
      _Action(icon: Icons.input_rounded, label: 'Inbound', color: AppColors.success, onTap: () => context.push('/warehouse/inbound')),
      _Action(icon: Icons.output_rounded, label: 'Outbound', color: AppColors.primary, onTap: () => context.push('/warehouse/outbound')),
      _Action(icon: Icons.qr_code_scanner_rounded, label: 'Scan', color: AppColors.saffron, onTap: () => context.go('/warehouse/scan')),
      _Action(icon: Icons.bar_chart_rounded, label: 'Reports', color: const Color(0xFF8B5CF6), onTap: () => context.push('/warehouse/reports')),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: a.onTap,
            child: Container(
              margin: EdgeInsets.only(right: a == actions.last ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: p.shadow, blurRadius: 10, offset: const Offset(3, 3)),
                  BoxShadow(color: p.highlight, blurRadius: 4, offset: const Offset(-1, -1)),
                ],
              ),
              child: Column(
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
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.sub),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogout(BuildContext context, bool dark, _Palette p, AuthProvider auth) {
    return GestureDetector(
      onTap: () async {
        await auth.logoutAndChooseRole();
        if (context.mounted) context.go('/role-selection');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 10),
            Text('Log Out',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error)),
          ],
        ),
      ),
    );
  }

  Widget _divider(_Palette p) => Divider(height: 1, thickness: 1, color: p.border);
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final _Palette p;

  const _InfoRow({required this.icon, required this.color, required this.label, required this.value, required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: p.sub)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final _Palette p;

  const _NotifToggle({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                Text(sub, style: TextStyle(fontSize: 11, color: p.sub)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
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

// ─── Data Models ─────────────────────────────────────────────────────────────

class _WarehouseInfo {
  final String name, code, address, zone, capacity, maxWeight;
  final String operatingHours, manager, phone, email, joinedDate;
  const _WarehouseInfo({
    required this.name, required this.code, required this.address, required this.zone,
    required this.capacity, required this.maxWeight, required this.operatingHours,
    required this.manager, required this.phone, required this.email, required this.joinedDate,
  });
}

class _Stat {
  final String label, value;
  final IconData icon;
  final int color;
  const _Stat({required this.label, required this.value, required this.icon, required this.color});
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.color, required this.onTap});
}

// ─── Palette ─────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, border;

  const _Palette({
    required this.bg, required this.card, required this.highlight,
    required this.shadow, required this.text, required this.sub, required this.border,
  });

  factory _Palette.of(bool dark) => dark
      ? _Palette(
          bg: AppColors.darkBg1, card: AppColors.darkCard,
          highlight: AppColors.clayHighlightDark, shadow: AppColors.clayShadowDark,
          text: Colors.white, sub: AppColors.darkSubtext, border: AppColors.darkBorder,
        )
      : _Palette(
          bg: const Color(0xFFF5F6FA), card: Colors.white,
          highlight: AppColors.clayHighlight, shadow: AppColors.clayShadow,
          text: AppColors.textDark, sub: AppColors.textDarkSecondary,
          border: const Color(0xFFE8EDF5),
        );
}
