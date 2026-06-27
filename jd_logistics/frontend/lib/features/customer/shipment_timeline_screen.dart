import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/logistics_status_chip.dart';
import 'package:jd_style_logistics/core/widgets/logistics_timeline.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';
import 'package:jd_style_logistics/services/courier_service.dart';

class ShipmentTimelineScreen extends StatefulWidget {
  final String id;
  final String mode;
  const ShipmentTimelineScreen(
      {super.key, this.id = '', this.mode = 'road'});

  @override
  State<ShipmentTimelineScreen> createState() => _ShipmentTimelineScreenState();
}

class _ShipmentTimelineScreenState extends State<ShipmentTimelineScreen> {
  bool _loading = true;
  String? _error;
  List<TimelineStep> _liveSteps = [];

  Color get _modeColor {
    switch (widget.mode.toLowerCase()) {
      case 'air': return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  IconData get _modeIcon {
    switch (widget.mode.toLowerCase()) {
      case 'air': return Icons.flight_takeoff_rounded;
      case 'ocean': return Icons.directions_boat_rounded;
      default: return Icons.local_shipping_rounded;
    }
  }

  double get _progress {
    if (_liveSteps.isEmpty) return 0;
    final done = _liveSteps.where((s) => s.done).length;
    return done / _liveSteps.length;
  }

  String get _statusLabel {
    if (_liveSteps.isEmpty) return 'Pending';
    if (_liveSteps.every((s) => s.done)) return 'Delivered';
    if (_liveSteps.any((s) => s.done || s.active)) return 'In Transit';
    return 'Pending';
  }

  String get _currentLocation {
    if (_liveSteps.isEmpty) return '—';
    final active = _liveSteps.where((s) => s.active).toList();
    if (active.isNotEmpty) return active.last.location ?? '—';
    final done = _liveSteps.where((s) => s.done).toList();
    if (done.isNotEmpty) return done.last.location ?? '—';
    return '—';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final raw = await CourierService.instance.getTracking(widget.id);
      final steps = raw.map((e) {
        final statusStr = (e['status'] as String? ?? '').toLowerCase();
        final isDone = e['done'] as bool? ?? statusStr == 'done' || statusStr == 'delivered';
        final isActive = e['active'] as bool? ?? statusStr == 'in_transit' || statusStr == 'in transit';
        return TimelineStep(
          title: e['title'] as String? ?? e['event'] as String? ?? 'Event',
          location: e['location'] as String?,
          time: e['timestamp'] as String? ?? e['created_at'] as String?,
          done: isDone,
          active: isActive,
        );
      }).toList();
      if (mounted) setState(() { _liveSteps = steps; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
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
        title: Text('Shipment Timeline',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: isDark ? Colors.white70 : AppColors.textDarkSecondary,
                size: 20),
            onPressed: _load,
          ),
          IconButton(
            icon: Icon(Icons.share_rounded,
                color: isDark ? Colors.white70 : AppColors.textDarkSecondary,
                size: 20),
            onPressed: () =>
                context.push('/shipment/share-tracking?id=${widget.id}'),
          ),
          const ThemeToggleButton(mini: true),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text('Failed to load timeline',
                          style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            GlassCard(
              padding: const EdgeInsets.all(18),
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
                        Text(widget.id.isNotEmpty ? widget.id : '—',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text('Tracking shipment route',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.textDarkSecondary,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  LogisticsStatusChip(status: _statusLabel),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _modeColor.withValues(alpha: isDark ? 0.1 : 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCol(label: 'Partner', value: '—', isDark: isDark),
                      _VDiv(isDark: isDark),
                      _StatCol(label: 'Weight', value: '—', isDark: isDark),
                      _VDiv(isDark: isDark),
                      _StatCol(label: 'ETA', value: '—', isDark: isDark,
                          color: _modeColor),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Progress bar
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Journey Progress',
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text('${(_progress * 100).toStringAsFixed(0)}% complete',
                        style: TextStyle(
                            color: _modeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.skyBorder,
                    valueColor: AlwaysStoppedAnimation(_modeColor),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _JourneyPoint(label: '—',
                        icon: Icons.circle, color: _modeColor),
                    const _JourneyPoint(
                        label: '—',
                        icon: Icons.location_on_rounded,
                        color: AppColors.error),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Live location
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Location',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.textDarkSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(_currentLocation,
                          style: TextStyle(
                              color:
                                  isDark ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text('—',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.textDarkSecondary,
                              fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(
                      '/shipment/live-map?id=${widget.id}&mode=${widget.mode}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Live Map',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Timeline
            Text('Full Timeline',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const SizedBox(height: 14),
            _liveSteps.isEmpty
                ? GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timeline_rounded,
                              size: 40,
                              color: isDark
                                  ? Colors.white24
                                  : AppColors.primary.withValues(alpha: 0.3)),
                          const SizedBox(height: 10),
                          Text('No tracking events found',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : AppColors.textDarkSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: LogisticsTimeline(steps: _liveSteps),
                  ),
            const SizedBox(height: 16),

            // Quick actions
            Row(children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Rate Delivery',
                  icon: Icons.star_rounded,
                  color: AppColors.warning,
                  isDark: isDark,
                  onTap: () => context.push('/shipment/rating?id=${widget.id}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Get Support',
                  icon: Icons.headset_mic_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: () => context.push('/customer/chat-support'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? color;
  const _StatCol(
      {required this.label,
      required this.value,
      required this.isDark,
      this.color});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: TextStyle(
                color: color ?? (isDark ? Colors.white : AppColors.textDark),
                fontWeight: FontWeight.w800,
                fontSize: 13)),
        Text(label,
            style: TextStyle(
                color: isDark
                    ? AppColors.darkSubtext
                    : AppColors.textDarkSecondary,
                fontSize: 11)),
      ]);
}

class _VDiv extends StatelessWidget {
  final bool isDark;
  const _VDiv({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 28,
      color: isDark ? AppColors.darkBorder : AppColors.skyBorder);
}

class _JourneyPoint extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _JourneyPoint(
      {required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      ]);
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.isDark,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ]),
        ),
      );
}
