import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/utils/helpers.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/services/courier_service.dart';
import 'package:jd_style_logistics/services/payment_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _routeCtrl;
  late final AnimationController _vehicleCtrl;

  final _country = const _CountryInfo(
    countryName: 'India',
    flag: '🇮🇳',
    region: 'South Asia',
    currency: 'INR',
    language: 'English / Hindi',
  );

  List<Map<String, dynamic>> _liveOrders = [];
  double _walletBalance = 0;
  bool _homeLoaded = false;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _routeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _vehicleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final orders = await CourierService.instance.getOrders(limit: 50);
      if (!mounted) return;
      setState(() { _liveOrders = orders; _homeLoaded = true; });
    } catch (_) {
      if (mounted) setState(() { _homeLoaded = true; });
    }
    try {
      final wallet = await PaymentService.instance.getWallet();
      if (mounted) setState(() { _walletBalance = wallet.balance; });
    } catch (_) {}
  }

  List<_Shipment> get _activeShipments {
    return _liveOrders
        .where((o) {
          final s = (o['status'] as String? ?? '').toLowerCase();
          return s != 'delivered' && s != 'completed' && s != 'cancelled';
        })
        .take(5)
        .map((o) {
          final mode = (o['mode'] as String? ?? o['transport_mode'] as String? ?? 'road').toLowerCase();
          final isAir   = mode == 'air';
          final isOcean = mode == 'sea' || mode == 'ocean';
          return _Shipment(
            id:          o['tracking_id'] as String? ?? o['id']?.toString() ?? '--',
            origin:      o['pickup_address'] as String? ?? o['from_city'] as String? ?? 'Origin',
            destination: o['delivery_address'] as String? ?? o['to_city'] as String? ?? 'Destination',
            partner:     o['partner'] as String? ?? 'JD Logistics',
            mode:        isAir ? 'Air' : (isOcean ? 'Ocean' : 'Road'),
            status:      _fmtStatus(o['status'] as String? ?? 'Pending'),
            eta:         o['estimated_delivery'] as String? ?? '--',
            progress:    0.5,
            icon:        isAir ? Icons.flight_takeoff_rounded : (isOcean ? Icons.directions_boat_filled_rounded : Icons.local_shipping_rounded),
            color:       isAir ? AppColors.airColor : (isOcean ? AppColors.oceanColor : AppColors.roadColor),
          );
        })
        .toList();
  }

  static String _fmtStatus(String s) {
    switch (s.toLowerCase()) {
      case 'in_transit':       return 'In Transit';
      case 'picked_up':        return 'Picked Up';
      case 'out_for_delivery': return 'Out for Delivery';
      default:                 return s[0].toUpperCase() + s.substring(1);
    }
  }

  String get _walletDisplay {
    if (_walletBalance >= 100000)  return '₹${(_walletBalance / 100000).toStringAsFixed(1)}L';
    if (_walletBalance >= 1000)    return '₹${(_walletBalance / 1000).toStringAsFixed(1)}K';
    return '₹${_walletBalance.toStringAsFixed(0)}';
  }

  int get _totalOrders    => _liveOrders.length;
  int get _deliveredCount => _liveOrders.where((o) { final s = (o['status'] as String? ?? '').toLowerCase(); return s == 'delivered' || s == 'completed'; }).length;
  int get _activeCount    => _liveOrders.where((o) { final s = (o['status'] as String? ?? '').toLowerCase(); return s != 'delivered' && s != 'completed' && s != 'cancelled'; }).length;
  int get _pendingCount   => _liveOrders.where((o) => (o['status'] as String? ?? '').toLowerCase() == 'pending').length;

  @override
  void dispose() {
    _floatCtrl.dispose();
    _routeCtrl.dispose();
    _vehicleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = Helpers.greetingByTime();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final tablet = constraints.maxWidth >= 560;

            return AnimatedBuilder(
              animation: Listenable.merge([
                _floatCtrl,
                _routeCtrl,
                _vehicleCtrl,
              ]),
              builder: (context, _) {
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
                          _Header(
                            greeting: greeting,
                            country: _country,
                          ),
                          const SizedBox(height: 18),
                          _HeroCard(
                            country: _country,
                            floatValue: _floatCtrl.value,
                            routeValue: _routeCtrl.value,
                            vehicleValue: _vehicleCtrl.value,
                          ),
                          const SizedBox(height: 18),
                          _QuickActions(wide: wide),
                          const SizedBox(height: 18),
                          _ShipmentModeGrid(tablet: tablet),
                          const SizedBox(height: 18),
                          _DashboardStats(
                            tablet: tablet,
                            totalOrders: _totalOrders,
                            delivered: _deliveredCount,
                            walletDisplay: _walletDisplay,
                            active: _activeCount,
                          ),
                          const SizedBox(height: 18),
                          const _SectionTitle(
                            title: 'Global Operations',
                            action: 'Live overview',
                          ),
                          const SizedBox(height: 12),
                          _BentoGrid(
                            wide: wide,
                            active: _activeCount,
                            pending: _pendingCount,
                            walletDisplay: _walletDisplay,
                          ),
                          const SizedBox(height: 18),
                          _SectionTitle(
                            title: 'Active Shipments',
                            action: _activeCount > 0 ? '$_activeCount moving' : 'None yet',
                          ),
                          const SizedBox(height: 12),
                          if (_activeShipments.isEmpty)
                            GlassCard(
                              borderRadius: 24,
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  _homeLoaded ? 'No active shipments' : 'Loading…',
                                  style: TextStyle(color: AppColors.subtext(context), fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                          else
                            ..._activeShipments.map(
                              (shipment) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ShipmentCard(
                                  shipment: shipment,
                                  vehicleValue: _vehicleCtrl.value,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          _GlobalStatusPanel(country: _country),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final _CountryInfo country;

  const _Header({
    required this.greeting,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const GlassCard(
          width: 58,
          height: 58,
          borderRadius: 22,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text('👨‍💼', style: TextStyle(fontSize: 30)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, Santosh',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniChip(label: '${country.flag} ${country.countryName}'),
                  _MiniChip(label: country.region),
                  _MiniChip(label: '${country.currency} • ${country.language}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GlassCard(
          width: 52,
          height: 52,
          borderRadius: 20,
          padding: EdgeInsets.zero,
          onTap: () => context.push('/notifications'),
          child: Icon(
            Icons.notifications_rounded,
            color: AppColors.text(context),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final _CountryInfo country;
  final double floatValue;
  final double routeValue;
  final double vehicleValue;

  const _HeroCard({
    required this.country,
    required this.floatValue,
    required this.routeValue,
    required this.vehicleValue,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;
    final dark = AppColors.isDark(context);

    return GlassCard(
      borderRadius: 34,
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: SizedBox(
        height: compact ? 306 : 286,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroRoutePainter(
                  dark: dark,
                  progress: routeValue,
                ),
              ),
            ),
            const Positioned(
              left: 0,
              top: 0,
              child: _Tag(
                label: 'JD GLOBAL NETWORK',
                icon: Icons.public_rounded,
              ),
            ),
            Positioned(
              left: 0,
              top: 50,
              right: compact ? 0 : 152,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Logistics\nControl Tower',
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: compact ? 25 : 30,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Road, air and ocean shipments connected through smart route operations from ${country.countryName}.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: 6,
              child: _RouteVehicles(progress: vehicleValue),
            ),
            Positioned(
              right: compact ? 0 : 12,
              bottom: compact ? 6 : 14,
              child: Transform.translate(
                offset: Offset(0, math.sin(floatValue * math.pi) * -8),
                child: Row(
                  children: const [
                    _MiniPerson(emoji: '🚚', label: 'Road'),
                    SizedBox(width: 8),
                    _MiniPerson(emoji: '✈️', label: 'Air'),
                    SizedBox(width: 8),
                    _MiniPerson(emoji: '🚢', label: 'Ocean'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPerson extends StatelessWidget {
  final String emoji;
  final String label;

  const _MiniPerson({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 66,
      borderRadius: 23,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteVehicles extends StatelessWidget {
  final double progress;

  const _RouteVehicles({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 76,
      child: Stack(
        children: [
          Positioned(
            left: 4 + (progress * 44),
            bottom: 0,
            child: const _Sticker(
              icon: Icons.local_shipping_rounded,
              color: AppColors.roadColor,
            ),
          ),
          Positioned(
            left: 56 + (progress * 30),
            top: 0,
            child: const _Sticker(
              icon: Icons.flight_takeoff_rounded,
              color: AppColors.airColor,
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 4,
            child: _Sticker(
              icon: Icons.directions_boat_filled_rounded,
              color: AppColors.oceanColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool wide;

  const _QuickActions({required this.wide});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        'Book Shipment',
        'Create order',
        Icons.add_box_rounded,
        AppColors.primary,
        () => context.push('/book-shipment'),
      ),
      _ActionItem(
        'Track Shipment',
        'Live tracking',
        Icons.route_rounded,
        AppColors.saffron,
        () => context.go('/customer/track'),
      ),
      _ActionItem(
        'Orders',
        'History',
        Icons.inventory_2_rounded,
        AppColors.oceanColor,
        () => context.go('/customer/orders'),
      ),
      _ActionItem(
        'Payments',
        'Wallet & invoices',
        Icons.account_balance_wallet_rounded,
        AppColors.success,
        () => context.go('/customer/payments'),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map(
            (item) => SizedBox(
              width: wide ? 278 : (MediaQuery.sizeOf(context).width - 44) / 2,
              child: _ActionCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final _ActionItem item;

  const _ActionCard({required this.item});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: GlassCard(
          height: 126,
          borderRadius: 28,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.item.icon, color: widget.item.color, size: 32),
              const Spacer(),
              Text(
                widget.item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShipmentModeGrid extends StatelessWidget {
  final bool tablet;

  const _ShipmentModeGrid({required this.tablet});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _ModeItem('Road Freight', '128 active', Icons.local_shipping_rounded, AppColors.roadColor),
      const _ModeItem('Air Cargo', '34 active', Icons.flight_takeoff_rounded, AppColors.airColor),
      const _ModeItem('Ocean Freight', '18 active', Icons.directions_boat_rounded, AppColors.oceanColor),
      const _ModeItem('Customs', '9 pending', Icons.gpp_maybe_rounded, AppColors.statusCustoms),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: tablet ? 270 : (MediaQuery.sizeOf(context).width - 44) / 2,
              child: GlassCard(
                height: 94,
                borderRadius: 26,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _InsetIcon(icon: item.icon, color: item.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.subtext(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DashboardStats extends StatelessWidget {
  final bool tablet;
  final int totalOrders;
  final int delivered;
  final String walletDisplay;
  final int active;

  const _DashboardStats({
    required this.tablet,
    required this.totalOrders,
    required this.delivered,
    required this.walletDisplay,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Total Orders', '$totalOrders', Icons.all_inbox_rounded),
      _StatItem('Delivered', '$delivered', Icons.verified_rounded),
      _StatItem('Wallet', walletDisplay, Icons.account_balance_wallet_rounded),
      _StatItem('Active', '$active', Icons.local_shipping_rounded),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: tablet ? 270 : (MediaQuery.sizeOf(context).width - 44) / 2,
              child: _StatCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 112,
      borderRadius: 26,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          _InsetIcon(icon: item.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final bool wide;
  final int active;
  final int pending;
  final String walletDisplay;

  const _BentoGrid({
    required this.wide,
    required this.active,
    required this.pending,
    required this.walletDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _BentoItem('Active Shipments', '$active', 'Road, air & sea moving', Icons.local_shipping_rounded, AppColors.primary),
      _BentoItem('Pending Pickups', '$pending', 'Awaiting collection', Icons.pending_actions_rounded, AppColors.saffron),
      _BentoItem('Wallet Balance', walletDisplay, 'Ready for payments', Icons.account_balance_wallet_rounded, AppColors.success),
      const _BentoItem('Rewards', '--', 'JD loyalty points', Icons.workspace_premium_rounded, AppColors.oceanColor),
      const _BentoItem('Service Coverage', 'Pan-India', 'Road, Air & Sea', Icons.badge_rounded, AppColors.airColor),
      const _BentoItem('Network Hubs', 'Active', 'Connected warehouses', Icons.warehouse_rounded, AppColors.portOrange),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: wide ? 1.75 : 1.04,
      ),
      itemBuilder: (context, index) {
        return _BentoCard(item: items[index]);
      },
    );
  }
}

class _BentoCard extends StatelessWidget {
  final _BentoItem item;

  const _BentoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              item.icon,
              size: 60,
              color: item.color.withValues(alpha: dark ? 0.14 : 0.11),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsetIcon(icon: item.icon, color: item.color),
              const Spacer(),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
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
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final _Shipment shipment;
  final double vehicleValue;

  const _ShipmentCard({
    required this.shipment,
    required this.vehicleValue,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 30,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _Sticker(
                icon: shipment.icon,
                small: true,
                color: shipment.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  shipment.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Tag(label: shipment.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LocationPoint(
                  title: shipment.origin,
                  subtitle: 'Origin',
                  color: AppColors.primary,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: shipment.color,
              ),
              Expanded(
                child: _LocationPoint(
                  title: shipment.destination,
                  subtitle: 'Destination',
                  color: shipment.color,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _ShipmentProgress(
            shipment: shipment,
            vehicleValue: vehicleValue,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.subtext(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ETA ${shipment.eta}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${shipment.mode} • ${shipment.partner}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShipmentProgress extends StatelessWidget {
  final _Shipment shipment;
  final double vehicleValue;

  const _ShipmentProgress({
    required this.shipment,
    required this.vehicleValue,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxMove = math.max(0.0, constraints.maxWidth - 26);
        final position = maxMove * shipment.progress * vehicleValue;

        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 18,
            child: Stack(
              children: [
                Container(
                  color: dark ? AppColors.darkSurface : AppColors.lightBg3,
                ),
                FractionallySizedBox(
                  widthFactor: shipment.progress,
                  child: Container(
                    color: shipment.color.withValues(alpha: dark ? 0.78 : 0.70),
                  ),
                ),
                Positioned(
                  left: position,
                  top: -3,
                  child: Icon(
                    shipment.icon,
                    size: 23,
                    color: dark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlobalStatusPanel extends StatelessWidget {
  final _CountryInfo country;

  const _GlobalStatusPanel({required this.country});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const _InsetIcon(
            icon: Icons.hub_rounded,
            color: AppColors.portOrange,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${country.flag} ${country.countryName} Global Shipping Status',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${country.region} lanes active • ${country.currency} billing ready • Domestic + International network online',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;

  const _SectionTitle({
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Flexible(
          child: Text(
            action,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPoint extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool alignEnd;

  const _LocationPoint({
    required this.title,
    required this.subtitle,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_rounded, color: color, size: 20),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _InsetIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _InsetIcon({
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayShadowColor(context)
                .withValues(alpha: dark ? 0.72 : 0.38),
            offset: const Offset(4, 4),
            blurRadius: 12,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.clayHighlightColor(context)
                .withValues(alpha: dark ? 0.20 : 0.95),
            offset: const Offset(-4, -4),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Icon(icon, color: color ?? AppColors.primary),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;

  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 99,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.subtext(context),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _Tag({
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.portOrange.withValues(alpha: 0.16)
            : const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.portOrange.withValues(alpha: dark ? 0.30 : 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.portOrange),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: dark ? AppColors.saffronLight : const Color(0xFFC2410C),
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  final IconData icon;
  final bool small;
  final Color color;

  const _Sticker({
    required this.icon,
    this.small = false,
    this.color = AppColors.saffron,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: small ? 40 : 48,
      height: small ? 40 : 48,
      borderRadius: small ? 15 : 18,
      padding: EdgeInsets.zero,
      child: Icon(icon, color: color, size: small ? 21 : 25),
    );
  }
}

class _HeroRoutePainter extends CustomPainter {
  final bool dark;
  final double progress;

  _HeroRoutePainter({
    required this.dark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.30 : 0.32)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(size.width * .10, size.height * .72)
      ..quadraticBezierTo(
        size.width * .38,
        size.height * .12,
        size.width * .78,
        size.height * .46,
      )
      ..quadraticBezierTo(
        size.width * .92,
        size.height * .58,
        size.width * .84,
        size.height * .80,
      );

    canvas.drawPath(route, routePaint);

    final metric = route.computeMetrics().first;
    final pos = metric.getTangentForOffset(metric.length * progress)?.position;

    if (pos != null) {
      canvas.drawCircle(pos, 5, Paint()..color = AppColors.portOrange);
    }

    final nodePaint = Paint()
      ..color = (dark ? AppColors.oceanBlue : AppColors.primary)
          .withValues(alpha: dark ? 0.22 : 0.18);

    for (final point in [
      Offset(size.width * .10, size.height * .72),
      Offset(size.width * .44, size.height * .20),
      Offset(size.width * .78, size.height * .46),
      Offset(size.width * .84, size.height * .80),
    ]) {
      canvas.drawCircle(point, 4.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroRoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  );
}

class _ModeItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ModeItem(this.title, this.value, this.icon, this.color);
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem(this.title, this.value, this.icon);
}

class _BentoItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _BentoItem(
    this.title,
    this.value,
    this.subtitle,
    this.icon,
    this.color,
  );
}

class _CountryInfo {
  final String countryName;
  final String flag;
  final String region;
  final String currency;
  final String language;

  const _CountryInfo({
    required this.countryName,
    required this.flag,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _Shipment {
  final String id;
  final String origin;
  final String destination;
  final String partner;
  final String mode;
  final String status;
  final String eta;
  final double progress;
  final IconData icon;
  final Color color;

  const _Shipment({
    required this.id,
    required this.origin,
    required this.destination,
    required this.partner,
    required this.mode,
    required this.status,
    required this.eta,
    required this.progress,
    required this.icon,
    required this.color,
  });
}