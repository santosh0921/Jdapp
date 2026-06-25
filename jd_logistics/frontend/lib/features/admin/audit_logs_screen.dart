import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _categories = ['All', 'Auth', 'Shipment', 'User', 'Payment', 'System'];

  static const _logs = [
    _Log(id: 'AL-00921', actor: 'admin@jd.in', action: 'Logged in via 2FA', category: 'Auth', time: '10:32 AM', date: 'Today', severity: 'info', ip: '192.168.1.42', detail: 'Chrome · Windows 11'),
    _Log(id: 'AL-00920', actor: 'admin@jd.in', action: 'Exported analytics report', category: 'System', time: '10:14 AM', date: 'Today', severity: 'info', ip: '192.168.1.42', detail: 'June 2025 report'),
    _Log(id: 'AL-00919', actor: 'admin@jd.in', action: 'Updated user role: driver → admin', category: 'User', time: '09:58 AM', date: 'Today', severity: 'warning', ip: '192.168.1.42', detail: 'User ID: USR-0042'),
    _Log(id: 'AL-00918', actor: 'admin@jd.in', action: 'Cancelled shipment JD-IND-4182', category: 'Shipment', time: '09:31 AM', date: 'Today', severity: 'warning', ip: '192.168.1.42', detail: 'Reason: customer request'),
    _Log(id: 'AL-00917', actor: 'system', action: 'Scheduled backup completed', category: 'System', time: '04:00 AM', date: 'Today', severity: 'info', ip: 'system', detail: 'DB snapshot 2025-06-18'),
    _Log(id: 'AL-00916', actor: 'Unknown', action: 'Failed login attempt', category: 'Auth', time: '11:47 PM', date: 'Yesterday', severity: 'critical', ip: '61.91.47.13', detail: 'Blocked after 3 attempts'),
    _Log(id: 'AL-00915', actor: 'admin@jd.in', action: 'Issued refund ₹1,450', category: 'Payment', time: '06:20 PM', date: 'Yesterday', severity: 'info', ip: '192.168.1.42', detail: 'Order: JD-2025-9183'),
    _Log(id: 'AL-00914', actor: 'admin@jd.in', action: 'Added new warehouse: Pune Hub', category: 'System', time: '03:15 PM', date: 'Yesterday', severity: 'info', ip: '192.168.1.42', detail: 'WH-0014'),
    _Log(id: 'AL-00913', actor: 'admin@jd.in', action: 'Suspended driver account', category: 'User', time: '01:40 PM', date: 'Yesterday', severity: 'critical', ip: '192.168.1.42', detail: 'Driver ID: DRV-0082'),
    _Log(id: 'AL-00912', actor: 'admin@jd.in', action: 'Updated payment gateway config', category: 'Payment', time: '11:05 AM', date: 'Yesterday', severity: 'warning', ip: '192.168.1.42', detail: 'Razorpay key rotated'),
    _Log(id: 'AL-00911', actor: 'admin@jd.in', action: 'Logged in via 2FA', category: 'Auth', time: '09:00 AM', date: 'Yesterday', severity: 'info', ip: '192.168.1.42', detail: 'Chrome · Windows 11'),
    _Log(id: 'AL-00910', actor: 'system', action: 'OBC reward disbursement batch', category: 'Payment', time: '12:00 AM', date: '17 Jun', severity: 'info', ip: 'system', detail: '1,240 users credited'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Log> get _filtered {
    var list = _selectedCategory == 'All'
        ? _logs
        : _logs.where((l) => l.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((l) =>
          l.action.toLowerCase().contains(q) ||
          l.actor.toLowerCase().contains(q) ||
          l.id.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final p = _Palette.of(dark);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, dark, p),
            _buildSearch(dark, p),
            _buildCategories(dark, p),
            _buildStats(dark, p),
            Expanded(child: _buildList(filtered, dark, p)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool dark, _Palette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: p.card,
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          _ClayIcon(onTap: () => context.pop(), dark: dark,
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Audit Logs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text)),
                Text('System-wide activity trail',
                    style: TextStyle(fontSize: 12, color: p.sub)),
              ],
            ),
          ),
          _ClayIcon(
            onTap: () => _showExportSheet(context, p),
            dark: dark,
            child: const Icon(Icons.download_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(bool dark, _Palette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(2, 2)),
            BoxShadow(color: p.highlight, blurRadius: 4, offset: const Offset(-1, -1)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(fontSize: 13, color: p.text),
          decoration: InputDecoration(
            hintText: 'Search actions, actors, IDs...',
            hintStyle: TextStyle(fontSize: 13, color: p.sub),
            prefixIcon: Icon(Icons.search_rounded, size: 18, color: p.sub),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, size: 16, color: p.sub),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(bool dark, _Palette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = _categories[i];
            final active = _selectedCategory == c;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : p.card,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                      : [BoxShadow(color: p.shadow, blurRadius: 4, offset: const Offset(1, 1))],
                ),
                child: Text(c,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : p.sub,
                    )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats(bool dark, _Palette p) {
    final criticalCount = _logs.where((l) => l.severity == 'critical').length;
    final warningCount = _logs.where((l) => l.severity == 'warning').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _StatChip(label: '${_logs.length} total', color: AppColors.primary, p: p),
          const SizedBox(width: 8),
          _StatChip(label: '$criticalCount critical', color: AppColors.error, p: p),
          const SizedBox(width: 8),
          _StatChip(label: '$warningCount warnings', color: AppColors.warning, p: p),
        ],
      ),
    );
  }

  Widget _buildList(List<_Log> filtered, bool dark, _Palette p) {
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: p.sub),
            const SizedBox(height: 10),
            Text('No logs match your search', style: TextStyle(color: p.sub, fontSize: 14)),
          ],
        ),
      );
    }

    String? lastDate;
    final widgets = <Widget>[];

    for (final log in filtered) {
      if (log.date != lastDate) {
        lastDate = log.date;
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(log.date,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.sub, letterSpacing: 0.4)),
        ));
      }
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: _LogCard(log: log, dark: dark, p: p),
      ));
    }
    widgets.add(const SizedBox(height: 24));

    return ListView(padding: EdgeInsets.zero, children: widgets);
  }

  void _showExportSheet(BuildContext context, _Palette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text)),
            const SizedBox(height: 16),
            _ExportOption(label: 'Export as CSV', icon: Icons.table_chart_rounded, p: p, onTap: () => Navigator.pop(context)),
            _ExportOption(label: 'Export as PDF', icon: Icons.picture_as_pdf_rounded, p: p, onTap: () => Navigator.pop(context)),
            _ExportOption(label: 'Send via Email', icon: Icons.email_rounded, p: p, onTap: () => Navigator.pop(context)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Log Card ────────────────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final _Log log;
  final bool dark;
  final _Palette p;

  const _LogCard({required this.log, required this.dark, required this.p});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(log.severity);
    final icon = _severityIcon(log.severity);

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(2, 2)),
          BoxShadow(color: p.highlight, blurRadius: 3, offset: const Offset(-1, -1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(log.action,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(log.time, style: TextStyle(fontSize: 10, color: p.sub)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 11, color: p.sub),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(log.actor,
                            style: TextStyle(fontSize: 11, color: p.sub),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.lan_outlined, size: 11, color: p.sub),
                      const SizedBox(width: 3),
                      Text(log.ip, style: TextStyle(fontSize: 11, color: p.sub)),
                    ],
                  ),
                  if (log.detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.inner,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(log.detail,
                          style: TextStyle(fontSize: 10, color: p.sub),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(log.category,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(String s) {
    switch (s) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _severityIcon(String s) {
    switch (s) {
      case 'critical':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final _Palette p;

  const _StatChip({required this.label, required this.color, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final _Palette p;
  final VoidCallback onTap;

  const _ExportOption({required this.label, required this.icon, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.text)),
      trailing: Icon(Icons.chevron_right_rounded, color: p.sub),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ClayIcon extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool dark;

  const _ClayIcon({required this.onTap, required this.child, required this.dark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: dark ? AppColors.darkBg3 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: dark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                blurRadius: 8, offset: const Offset(2, 2)),
            BoxShadow(color: dark ? AppColors.darkBg1.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.9),
                blurRadius: 4, offset: const Offset(-1, -1)),
          ],
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(color: dark ? AppColors.darkSubtext : const Color(0xFF64748B), size: 18),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Log {
  final String id, actor, action, category, time, date, severity, ip, detail;
  const _Log({
    required this.id, required this.actor, required this.action,
    required this.category, required this.time, required this.date,
    required this.severity, required this.ip, required this.detail,
  });
}

// ─── Palette ─────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, inner;

  const _Palette({
    required this.bg, required this.card, required this.highlight,
    required this.shadow, required this.text, required this.sub, required this.inner,
  });

  factory _Palette.of(bool dark) => dark
      ? _Palette(
          bg: AppColors.darkBg1, card: AppColors.darkCard,
          highlight: AppColors.clayHighlightDark, shadow: AppColors.clayShadowDark,
          text: Colors.white, sub: AppColors.darkSubtext, inner: AppColors.darkBg3,
        )
      : _Palette(
          bg: const Color(0xFFF5F6FA), card: Colors.white,
          highlight: AppColors.clayHighlight, shadow: AppColors.clayShadow,
          text: AppColors.textDark, sub: AppColors.textDarkSecondary,
          inner: const Color(0xFFF0F2F8),
        );
}
