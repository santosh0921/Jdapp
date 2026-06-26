import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactor = true;
  bool _loginAlerts = true;
  bool _sessionTimeout = true;
  bool _ipWhitelist = false;
  bool _auditLogging = true;
  bool _deviceTrust = false;
  String _sessionDuration = '8 hours';

  static const _sessionOptions = ['1 hour', '4 hours', '8 hours', '24 hours', '7 days'];

  List<_Session> _activeSessions = [];
  List<_SecurityEvent> _recentEvents = [];

  @override
  void initState() {
    super.initState();
    _loadSecurity();
  }

  Future<void> _loadSecurity() async {
    final data = await AdminService.instance.getSecurity();
    if (!mounted || data.isEmpty) return;
    setState(() {
      _twoFactor      = data['two_factor_enabled']  as bool? ?? _twoFactor;
      _loginAlerts    = data['login_alerts_enabled'] as bool? ?? _loginAlerts;
      _sessionTimeout = data['session_timeout']      as bool? ?? _sessionTimeout;
      _ipWhitelist    = data['ip_whitelist_enabled'] as bool? ?? _ipWhitelist;
      _auditLogging   = data['audit_logging']        as bool? ?? _auditLogging;
      _deviceTrust    = data['device_trust']         as bool? ?? _deviceTrust;
      if (data['session_duration'] != null) {
        _sessionDuration = data['session_duration'].toString();
      }
      // Parse active sessions if API provides them
      final rawSessions = data['active_sessions'] as List<dynamic>?;
      if (rawSessions != null) {
        _activeSessions = rawSessions.map((s) => _Session(
          device:    s['device']?.toString()   ?? 'Unknown device',
          ip:        s['ip']?.toString()       ?? '—',
          location:  s['location']?.toString() ?? '—',
          since:     s['since']?.toString()    ?? '—',
          isCurrent: s['is_current'] as bool?  ?? false,
        )).toList();
      }
      // Parse recent security events if API provides them
      final rawEvents = data['recent_events'] as List<dynamic>?;
      if (rawEvents != null) {
        _recentEvents = rawEvents.map((e) => _SecurityEvent(
          icon:  Icons.shield_rounded,
          label: e['label']?.toString() ?? '—',
          sub:   e['sub']?.toString()   ?? '—',
          color: 0xFF5EA2FF,
        )).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final p = _Palette.of(dark);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, dark, p),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Authentication', p),
                    const SizedBox(height: 8),
                    _buildAuthSection(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Session Management', p),
                    const SizedBox(height: 8),
                    _buildSessionSection(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Active Sessions', p),
                    const SizedBox(height: 8),
                    _buildActiveSessions(dark, p),
                    const SizedBox(height: 20),
                    _sectionTitle('Recent Security Events', p),
                    const SizedBox(height: 8),
                    _buildEvents(dark, p),
                    const SizedBox(height: 20),
                    _buildDangerZone(dark, p),
                  ],
                ),
              ),
            ),
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
                Text('Security Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text)),
                Text('Manage access and permissions',
                    style: TextStyle(fontSize: 12, color: p.sub)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 7, height: 7,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text('Secure', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, _Palette p) => Text(
        title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.sub, letterSpacing: 0.5),
      );

  Widget _buildAuthSection(bool dark, _Palette p) {
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.security_rounded,
            iconColor: AppColors.primary,
            title: 'Two-Factor Authentication',
            subtitle: 'Require 2FA for all admin logins',
            value: _twoFactor,
            onChanged: (v) => setState(() => _twoFactor = v),
            p: p,
          ),
          _divider(p),
          _ToggleTile(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.warning,
            title: 'Login Alerts',
            subtitle: 'Email alert on new device login',
            value: _loginAlerts,
            onChanged: (v) => setState(() => _loginAlerts = v),
            p: p,
          ),
          _divider(p),
          _ToggleTile(
            icon: Icons.phone_android_rounded,
            iconColor: AppColors.success,
            title: 'Device Trust',
            subtitle: 'Remember trusted devices for 30 days',
            value: _deviceTrust,
            onChanged: (v) => setState(() => _deviceTrust = v),
            p: p,
          ),
          _divider(p),
          _ToggleTile(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'IP Allowlist',
            subtitle: 'Restrict access to specific IPs',
            value: _ipWhitelist,
            onChanged: (v) => setState(() => _ipWhitelist = v),
            p: p,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSection(bool dark, _Palette p) {
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleTile(
            icon: Icons.timer_rounded,
            iconColor: AppColors.saffron,
            title: 'Auto Session Timeout',
            subtitle: 'Logout after inactivity',
            value: _sessionTimeout,
            onChanged: (v) => setState(() => _sessionTimeout = v),
            p: p,
          ),
          if (_sessionTimeout) ...[
            _divider(p),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timeout Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sessionOptions.map((opt) {
                      final active = _sessionDuration == opt;
                      return GestureDetector(
                        onTap: () => setState(() => _sessionDuration = opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : p.inner,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(opt,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : p.sub,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          _divider(p),
          _ToggleTile(
            icon: Icons.history_rounded,
            iconColor: AppColors.primary,
            title: 'Audit Logging',
            subtitle: 'Record all admin actions',
            value: _auditLogging,
            onChanged: (v) => setState(() => _auditLogging = v),
            p: p,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessions(bool dark, _Palette p) {
    if (_activeSessions.isEmpty) {
      return _ClayCard(
        dark: dark,
        p: p,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(Icons.devices_rounded, color: p.sub, size: 20),
              const SizedBox(width: 10),
              Text('No active session data available',
                  style: TextStyle(fontSize: 13, color: p.sub)),
            ],
          ),
        ),
      );
    }
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        children: [
          for (int i = 0; i < _activeSessions.length; i++) ...[
            if (i > 0) _divider(p),
            _SessionTile(session: _activeSessions[i], p: p),
          ],
        ],
      ),
    );
  }

  Widget _buildEvents(bool dark, _Palette p) {
    return _ClayCard(
      dark: dark,
      p: p,
      child: Column(
        children: [
          if (_recentEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Icon(Icons.shield_rounded, color: p.sub, size: 20),
                  const SizedBox(width: 10),
                  Text('No recent security events',
                      style: TextStyle(fontSize: 13, color: p.sub)),
                ],
              ),
            )
          else
            for (int i = 0; i < _recentEvents.length; i++) ...[
              if (i > 0) _divider(p),
              _EventTile(event: _recentEvents[i], p: p),
            ],
          _divider(p),
          InkWell(
            onTap: () => context.push('/admin/audit-logs'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View Full Audit Log',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(bool dark, _Palette p) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text('Danger Zone',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
              ],
            ),
          ),
          _divider(p),
          _DangerTile(
            label: 'Revoke All Sessions',
            sub: 'Force logout on all active devices',
            icon: Icons.logout_rounded,
            p: p,
            onTap: () => _confirmRevoke(context, p),
          ),
          _divider(p),
          _DangerTile(
            label: 'Reset 2FA',
            sub: 'Re-enroll two-factor authentication',
            icon: Icons.refresh_rounded,
            p: p,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(BuildContext context, _Palette p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Revoke All Sessions?', style: TextStyle(color: p.text, fontWeight: FontWeight.w700)),
        content: Text('All devices will be logged out immediately.', style: TextStyle(color: p.sub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: p.sub))),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Revoke', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _divider(_Palette p) => Divider(height: 1, thickness: 1, color: p.border);
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final _Palette p;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: p.sub)),
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

class _SessionTile extends StatelessWidget {
  final _Session session;
  final _Palette p;

  const _SessionTile({required this.session, required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (session.isCurrent ? AppColors.success : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.devices_rounded,
                color: session.isCurrent ? AppColors.success : AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(session.device,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (session.isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Current',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${session.ip} · ${session.location}',
                    style: TextStyle(fontSize: 11, color: p.sub)),
                Text(session.since, style: TextStyle(fontSize: 11, color: p.sub)),
              ],
            ),
          ),
          if (!session.isCurrent)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Revoke',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error)),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final _SecurityEvent event;
  final _Palette p;

  const _EventTile({required this.event, required this.p});

  @override
  Widget build(BuildContext context) {
    final color = Color(event.color);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(event.icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                Text(event.sub, style: TextStyle(fontSize: 11, color: p.sub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final _Palette p;
  final VoidCallback onTap;

  const _DangerTile({
    required this.label,
    required this.sub,
    required this.icon,
    required this.p,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.error, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                  Text(sub, style: TextStyle(fontSize: 11, color: p.sub)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.error, size: 18),
          ],
        ),
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

class _Session {
  final String device, ip, location, since;
  final bool isCurrent;
  const _Session({required this.device, required this.ip, required this.location, required this.since, required this.isCurrent});
}

class _SecurityEvent {
  final IconData icon;
  final String label, sub;
  final int color;
  const _SecurityEvent({required this.icon, required this.label, required this.sub, required this.color});
}

// ─── Palette ─────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, inner, border;

  const _Palette({
    required this.bg,
    required this.card,
    required this.highlight,
    required this.shadow,
    required this.text,
    required this.sub,
    required this.inner,
    required this.border,
  });

  factory _Palette.of(bool dark) => dark
      ? _Palette(
          bg: AppColors.darkBg1,
          card: AppColors.darkCard,
          highlight: AppColors.clayHighlightDark,
          shadow: AppColors.clayShadowDark,
          text: Colors.white,
          sub: AppColors.darkSubtext,
          inner: AppColors.darkBg3,
          border: AppColors.darkBorder,
        )
      : _Palette(
          bg: const Color(0xFFF5F6FA),
          card: Colors.white,
          highlight: AppColors.clayHighlight,
          shadow: AppColors.clayShadow,
          text: AppColors.textDark,
          sub: AppColors.textDarkSecondary,
          inner: const Color(0xFFF0F2F8),
          border: const Color(0xFFE8EDF5),
        );
}
