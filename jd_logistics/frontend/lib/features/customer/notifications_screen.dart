import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/models/notification_model.dart';
import 'package:jd_style_logistics/services/notification_service.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends State<CustomerNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  List<_NotificationData>? _liveNotifications;

  static const _country = _CountryData(
    countryName: 'India',
    flag: '🇮🇳',
    region: 'South Asia',
    currency: 'INR',
    language: 'English / Hindi',
  );

  static const _notifications = [
    _NotificationData(
      icon: Icons.local_shipping_rounded,
      title: 'Shipment in transit',
      message: 'JDIN240001 has reached Pune sorting hub.',
      time: '12 min ago',
      tag: 'Shipment',
      color: AppColors.primary,
      unread: true,
      trackingId: 'JDIN240001',
      route: 'Mumbai → Delhi',
      hub: 'Pune Sorting Hub',
      countryFlag: '🇮🇳',
      countryName: 'India',
      group: 'Recent',
    ),
    _NotificationData(
      icon: Icons.flight_takeoff_rounded,
      title: 'International route updated',
      message: 'JDAIR240801 is waiting for customs clearance.',
      time: '42 min ago',
      tag: 'Customs',
      color: AppColors.portOrange,
      unread: true,
      trackingId: 'JDAIR240801',
      route: 'Pune → Dubai',
      hub: 'BOM Air Cargo',
      countryFlag: '🇦🇪',
      countryName: 'UAE',
      group: 'Recent',
    ),
    _NotificationData(
      icon: Icons.payments_rounded,
      title: 'Payment pending',
      message: 'Invoice INV-JD-9172 has a pending amount of ₹3,999.',
      time: '2 hrs ago',
      tag: 'Payment',
      color: AppColors.success,
      unread: false,
      trackingId: 'INV-JD-9172',
      route: 'International Billing',
      hub: 'JD Finance Desk',
      countryFlag: '🇮🇳',
      countryName: 'India',
      group: 'Today',
    ),
    _NotificationData(
      icon: Icons.verified_rounded,
      title: 'Shipment delivered',
      message: 'JDDLV1209 was delivered successfully.',
      time: 'Yesterday',
      tag: 'Delivered',
      color: AppColors.oceanColor,
      unread: false,
      trackingId: 'JDDLV1209',
      route: 'Navi Mumbai → Thane',
      hub: 'Thane Delivery Hub',
      countryFlag: '🇮🇳',
      countryName: 'India',
      group: 'Yesterday',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final models = await NotificationService.instance.getNotifications();
    if (!mounted) return;
    // Always set _liveNotifications (even empty) so we never fall through to mock data in release
    setState(() => _liveNotifications = models.map(_fromModel).toList());
  }

  Future<void> _markAllRead() async {
    await NotificationService.instance.markAllRead();
    if (!mounted) return;
    setState(() {
      _liveNotifications = (_liveNotifications ?? _notifications)
          .map((n) => _NotificationData(
                icon: n.icon, title: n.title, message: n.message,
                time: n.time, tag: n.tag, color: n.color,
                unread: false, trackingId: n.trackingId,
                route: n.route, hub: n.hub,
                countryFlag: n.countryFlag, countryName: n.countryName,
                group: n.group,
              ))
          .toList();
    });
  }

  Future<void> _markOneRead(String notifId) async {
    await NotificationService.instance.markRead(notifId);
    if (!mounted) return;
    setState(() {
      _liveNotifications = (_liveNotifications ?? _notifications)
          .map((n) => n.trackingId == notifId
              ? _NotificationData(
                  icon: n.icon, title: n.title, message: n.message,
                  time: n.time, tag: n.tag, color: n.color,
                  unread: false, trackingId: n.trackingId,
                  route: n.route, hub: n.hub,
                  countryFlag: n.countryFlag, countryName: n.countryName,
                  group: n.group,
                )
              : n)
          .toList();
    });
  }

  static _NotificationData _fromModel(NotificationModel m) {
    final now = DateTime.now();
    final diff = now.difference(m.createdAt);
    String time;
    if (diff.inMinutes < 60) {
      time = '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      time = '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      time = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    String group;
    if (diff.inHours < 1) {
      group = 'Recent';
    } else if (diff.inHours < 24) {
      group = 'Today';
    } else if (diff.inDays == 1) {
      group = 'Yesterday';
    } else {
      group = 'Older';
    }
    IconData icon;
    Color color;
    String tag;
    switch (m.type) {
      case 'shipment':
        icon = Icons.local_shipping_rounded; color = AppColors.primary; tag = 'Shipment'; break;
      case 'payment':
        icon = Icons.payments_rounded; color = AppColors.success; tag = 'Payment'; break;
      case 'customs':
        icon = Icons.gavel_rounded; color = AppColors.portOrange; tag = 'Customs'; break;
      case 'delivery':
        icon = Icons.verified_rounded; color = AppColors.success; tag = 'Delivery'; break;
      case 'driver':
        icon = Icons.delivery_dining_rounded; color = AppColors.driverColor; tag = 'Driver'; break;
      default:
        icon = Icons.notifications_rounded; color = AppColors.primary; tag = 'Update';
    }
    return _NotificationData(
      icon: icon,
      title: m.title,
      message: m.body,
      time: time,
      tag: tag,
      color: color,
      unread: !m.isRead,
      trackingId: m.id,
      route: '',
      hub: '',
      countryFlag: '🇮🇳',
      countryName: 'India',
      group: group,
    );
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: JdAppBar(
        title: 'Notifications',
        showBack: false,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 28 : 16,
                  16,
                  wide ? 28 : 16,
                  120,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NotificationHero(
                          country: _country,
                          motion: _motion,
                        ),
                        const SizedBox(height: 18),
                        _SummaryGrid(wide: wide, notifications: _liveNotifications),
                        const SizedBox(height: 18),
                        const _CategoryChips(),
                        const SizedBox(height: 18),
                        const _SectionTitle(
                          title: 'Latest Updates',
                          subtitle:
                              'Shipment, customs, warehouse and payment alerts',
                        ),
                        const SizedBox(height: 12),
                        ..._groupedNotifications(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _groupedNotifications() {
    final groups = ['Recent', 'Today', 'Yesterday', 'Older'];
    final widgets = <Widget>[];

    // In release: use only live data. In debug: fall back to mock when live is null (not yet loaded).
    final source = _liveNotifications ?? (kDebugMode ? _notifications : const <_NotificationData>[]);

    if (source.isEmpty && _liveNotifications != null) {
      return [
        const SizedBox(height: 24),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_rounded,
                  color: AppColors.subtext(context), size: 48),
              const SizedBox(height: 12),
              Text('No notifications yet',
                  style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 4),
              Text('Your shipment alerts will appear here',
                  style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ];
    }

    for (final group in groups) {
      final items = source.where((item) => item.group == group).toList();

      if (items.isEmpty) continue;

      widgets.add(_TimelineLabel(label: group));
      widgets.add(const SizedBox(height: 10));

      widgets.addAll(
        items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NotificationTile(
              data: item,
              onTap: () => _markOneRead(item.trackingId),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

class _NotificationHero extends StatelessWidget {
  final _CountryData country;
  final Animation<double> motion;

  const _NotificationHero({
    required this.country,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 34,
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;

          return SizedBox(
            height: wide ? 238 : 330,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: motion,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _HeroRoutePainter(
                          value: motion.value,
                          dark: AppColors.isDark(context),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 4,
                  right: wide ? 140 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Pill(
                        label: 'JD GLOBAL ALERT CENTER',
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.portOrange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Stay updated across every shipment route.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.text(context),
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                  letterSpacing: -0.5,
                                  fontSize: wide ? null : 22,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Live logistics alerts • International customs • Payments',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.subtext(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniPill(
                            label: '${country.flag} ${country.countryName}',
                            color: AppColors.primary,
                          ),
                          _MiniPill(
                            label: country.region,
                            color: AppColors.portOrange,
                          ),
                          _MiniPill(
                            label: country.currency,
                            color: AppColors.success,
                          ),
                          _MiniPill(
                            label: country.language,
                            color: AppColors.oceanColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: wide ? 0 : 8,
                  bottom: wide ? 8 : 10,
                  child: AnimatedBuilder(
                    animation: motion,
                    builder: (_, __) {
                      return _HeroVisual(value: motion.value);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final double value;

  const _HeroVisual({required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 118,
      height: 118,
      borderRadius: 36,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.public_rounded,
            color: AppColors.primary.withValues(alpha: 0.14),
            size: 90,
          ),
          Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 11, -28),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: AppColors.portOrange,
              size: 24,
            ),
          ),
          Transform.translate(
            offset: Offset(math.cos(value * math.pi * 2) * 13, 24),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          Transform.translate(
            offset: Offset(0, math.sin(value * math.pi * 2) * 6),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.portOrange,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final bool wide;
  final List<_NotificationData>? notifications;

  const _SummaryGrid({required this.wide, this.notifications});

  @override
  Widget build(BuildContext context) {
    final all = notifications ?? const <_NotificationData>[];
    final unread    = all.where((n) => n.unread).length;
    final shipment  = all.where((n) => n.tag == 'Shipment').length;
    final customs   = all.where((n) => n.tag == 'Customs').length;
    final payment   = all.where((n) => n.tag == 'Payment').length;
    final delivery  = all.where((n) => n.tag == 'Delivery' || n.tag == 'Delivered').length;
    final driver    = all.where((n) => n.tag == 'Driver').length;
    final total     = all.length;
    final other     = all.where((n) => !['Shipment','Customs','Payment','Delivery','Delivered','Driver'].contains(n.tag)).length;

    String v(int count) => notifications == null ? '—' : '$count';

    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.5 : 1.22,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _SummaryCard(icon: Icons.mark_email_unread_rounded, label: 'Unread',     value: v(unread),   color: AppColors.primary),
        _SummaryCard(icon: Icons.local_shipping_rounded,    label: 'Shipment',   value: v(shipment), color: AppColors.portOrange),
        _SummaryCard(icon: Icons.public_rounded,            label: 'Customs',    value: v(customs),  color: AppColors.success),
        _SummaryCard(icon: Icons.payments_rounded,          label: 'Payments',   value: v(payment),  color: AppColors.oceanColor),
        _SummaryCard(icon: Icons.verified_rounded,          label: 'Delivered',  value: v(delivery), color: AppColors.success),
        _SummaryCard(icon: Icons.delivery_dining_rounded,   label: 'Driver',     value: v(driver),   color: AppColors.driverColor),
        _SummaryCard(icon: Icons.notifications_rounded,     label: 'Total',      value: v(total),    color: AppColors.saffron),
        _SummaryCard(icon: Icons.info_outline_rounded,      label: 'Other',      value: v(other),    color: AppColors.error),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      borderRadius: 30,
      padding: EdgeInsets.all(14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MiniPill(label: 'All Alerts', color: AppColors.primary),
          _MiniPill(label: 'Shipment', color: AppColors.portOrange),
          _MiniPill(label: 'Customs', color: AppColors.success),
          _MiniPill(label: 'Payments', color: AppColors.oceanColor),
          _MiniPill(label: 'Warehouse', color: AppColors.statusCustoms),
          _MiniPill(label: 'International', color: AppColors.saffron),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final _NotificationData data;
  final VoidCallback? onTap;

  const _NotificationTile({required this.data, this.onTap});

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.data;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.985 : 1,
        duration: const Duration(milliseconds: 150),
        child: GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Sticker(icon: item.icon, color: item.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (item.unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.portOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.subtext(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MiniPill(label: item.tag, color: item.color),
                        _MiniPill(
                          label: item.time,
                          color: AppColors.textDarkSecondary,
                        ),
                        _MiniPill(
                          label: '${item.countryFlag} ${item.countryName}',
                          color: AppColors.primary,
                        ),
                        _MiniPill(
                          label: item.trackingId,
                          color: AppColors.portOrange,
                        ),
                        _MiniPill(
                          label: item.hub,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Sticker(icon: icon, color: color, size: 40),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  final String label;

  const _TimelineLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.text(context),
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Sticker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _Sticker({
    required this.icon,
    required this.color,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(size * .35),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Icon(icon, color: color, size: size * .50),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Pill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _HeroRoutePainter extends CustomPainter {
  final double value;
  final bool dark;

  _HeroRoutePainter({
    required this.value,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.28 : 0.34)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * .15, size.height * .74);
    final control = Offset(size.width * .48, size.height * .10);
    final end = Offset(size.width * .86, size.height * .52);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(path, route);

    final moving = _quadraticPoint(start, control, end, value);

    canvas.drawCircle(
      Offset(size.width * .25, size.height * .60),
      5,
      Paint()..color = AppColors.primary,
    );

    canvas.drawCircle(
      Offset(size.width * .72, size.height * .43),
      5,
      Paint()..color = AppColors.portOrange,
    );

    canvas.drawCircle(
      moving,
      5,
      Paint()..color = AppColors.portOrange,
    );
  }

  Offset _quadraticPoint(Offset a, Offset b, Offset c, double t) {
    final x = math.pow(1 - t, 2) * a.dx +
        2 * (1 - t) * t * b.dx +
        math.pow(t, 2) * c.dx;

    final y = math.pow(1 - t, 2) * a.dy +
        2 * (1 - t) * t * b.dy +
        math.pow(t, 2) * c.dy;

    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  bool shouldRepaint(covariant _HeroRoutePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.dark != dark;
  }
}

class _CountryData {
  final String countryName;
  final String flag;
  final String region;
  final String currency;
  final String language;

  const _CountryData({
    required this.countryName,
    required this.flag,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _NotificationData {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final String tag;
  final Color color;
  final bool unread;
  final String trackingId;
  final String route;
  final String hub;
  final String countryFlag;
  final String countryName;
  final String group;

  const _NotificationData({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.tag,
    required this.color,
    required this.unread,
    required this.trackingId,
    required this.route,
    required this.hub,
    required this.countryFlag,
    required this.countryName,
    required this.group,
  });
}