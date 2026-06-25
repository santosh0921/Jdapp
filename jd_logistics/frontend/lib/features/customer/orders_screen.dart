import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  late final AnimationController _motion;

  final _country = const _CountryData(
    countryCode: 'IN',
    countryName: 'India',
    flag: '🇮🇳',
    dialCode: '+91',
    region: 'South Asia',
    currency: 'INR',
    language: 'English / Hindi',
  );

  final _activeOrders = const [
    _OrderData(
      id: 'JD-IND-2048',
      type: 'Express Parcel',
      origin: 'Mumbai',
      destination: 'Delhi',
      status: 'In Transit',
      eta: 'Today · 7:30 PM',
      progress: 0.68,
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF2563EB),
      mode: _ShipmentMode.road,
      hub: 'Mumbai Road Hub',
      amount: '₹1,240',
      country: 'India',
      currency: 'INR',
      timeline: ['Booked', 'Picked', 'In Transit', 'Delivery'],
    ),
    _OrderData(
      id: 'JD-EXP-9172',
      type: 'International',
      origin: 'Pune',
      destination: 'Dubai',
      status: 'Customs Check',
      eta: 'Jun 19 · 4:00 PM',
      progress: 0.42,
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFFFF8A00),
      mode: _ShipmentMode.air,
      hub: 'BOM Air Cargo',
      amount: '₹6,850',
      country: 'UAE',
      currency: 'AED',
      timeline: ['Booked', 'Airport Hub', 'Customs', 'Delivery'],
    ),
  ];

  final _deliveredOrders = const [
    _OrderData(
      id: 'JD-DLV-1209',
      type: 'Document',
      origin: 'Navi Mumbai',
      destination: 'Thane',
      status: 'Delivered',
      eta: 'Jun 14 · 2:10 PM',
      progress: 1,
      icon: Icons.verified_rounded,
      color: Color(0xFF16A34A),
      mode: _ShipmentMode.road,
      hub: 'Navi Mumbai Hub',
      amount: '₹420',
      country: 'India',
      currency: 'INR',
      timeline: ['Booked', 'Picked', 'Transit', 'Delivered'],
    ),
    _OrderData(
      id: 'JD-DLV-8841',
      type: 'Freight',
      origin: 'Bhiwandi',
      destination: 'Bengaluru',
      status: 'Delivered',
      eta: 'Jun 11 · 6:40 PM',
      progress: 1,
      icon: Icons.fire_truck_rounded,
      color: Color(0xFF16A34A),
      mode: _ShipmentMode.ocean,
      hub: 'Container Yard',
      amount: '₹12,900',
      country: 'India',
      currency: 'INR',
      timeline: ['Loaded', 'Hub', 'Linehaul', 'Delivered'],
    ),
  ];

  final _cancelledOrders = const [
    _OrderData(
      id: 'JD-CAN-3102',
      type: 'Parcel',
      origin: 'Mumbai',
      destination: 'Pune',
      status: 'Cancelled',
      eta: 'Cancelled by customer',
      progress: 0.12,
      icon: Icons.cancel_rounded,
      color: Color(0xFFEF4444),
      mode: _ShipmentMode.road,
      hub: 'Mumbai Hub',
      amount: '₹0',
      country: 'India',
      currency: 'INR',
      timeline: ['Booked', 'Cancelled'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);
    final allOrders = [
      ..._activeOrders,
      ..._deliveredOrders,
      ..._cancelledOrders,
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.text,
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w900,
              ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _ClayTabBar(controller: _tabs),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _OrdersBackground(motion: _motion)),
            TabBarView(
              controller: _tabs,
              children: [
                _OrderList(
                  title: 'Active Shipments',
                  subtitle: 'Live orders moving through JD global network',
                  orders: _activeOrders,
                  allOrders: allOrders,
                  country: _country,
                  motion: _motion,
                ),
                _OrderList(
                  title: 'Completed Orders',
                  subtitle: 'Successfully delivered shipments and freight',
                  orders: _deliveredOrders,
                  allOrders: allOrders,
                  country: _country,
                  motion: _motion,
                ),
                _OrderList(
                  title: 'Cancelled Orders',
                  subtitle: 'Cancelled shipment history and rebooking options',
                  orders: _cancelledOrders,
                  allOrders: allOrders,
                  country: _country,
                  motion: _motion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_OrderData> orders;
  final List<_OrderData> allOrders;
  final _CountryData country;
  final Animation<double> motion;

  const _OrderList({
    required this.title,
    required this.subtitle,
    required this.orders,
    required this.allOrders,
    required this.country,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final tablet = constraints.maxWidth >= 980;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            wide ? 28 : 16,
            16,
            wide ? 28 : 16,
            110,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrdersHero(
                    title: title,
                    subtitle: subtitle,
                    orders: orders,
                    allOrders: allOrders,
                    country: country,
                    motion: motion,
                  ),
                  const SizedBox(height: 16),
                  _OverviewGrid(
                    active: allOrders
                        .where((e) =>
                            e.status != 'Delivered' &&
                            e.status != 'Cancelled')
                        .length,
                    completed:
                        allOrders.where((e) => e.status == 'Delivered').length,
                    cancelled:
                        allOrders.where((e) => e.status == 'Cancelled').length,
                    international:
                        allOrders.where((e) => e.type == 'International').length,
                  ),
                  const SizedBox(height: 18),
                  if (orders.isEmpty)
                    const _EmptyOrdersCard()
                  else
                    GridView.builder(
                      itemCount: orders.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: tablet ? 2 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: tablet ? 1.42 : (wide ? 1.60 : 0.90),
                      ),
                      itemBuilder: (context, index) {
                        return _OrderCard(order: orders[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrdersHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_OrderData> orders;
  final List<_OrderData> allOrders;
  final _CountryData country;
  final Animation<double> motion;

  const _OrdersHero({
    required this.title,
    required this.subtitle,
    required this.orders,
    required this.allOrders,
    required this.country,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);
    final totalProgress = allOrders.isEmpty
        ? 0.0
        : allOrders.map((e) => e.progress).reduce((a, b) => a + b) /
            allOrders.length;

    return _ClayCard(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;

          return SizedBox(
            height: wide ? 220 : 320,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WorldMapPainter(palette: palette),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: motion,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _HeroRoutePainter(
                          value: motion.value,
                          palette: palette,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  right: wide ? 300 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Pill(
                        label: 'JD ORDER NETWORK',
                        icon: Icons.public_rounded,
                        color: Color(0xFFFF8A00),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: palette.text,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.subText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniInfoPill(
                            label: '${country.flag} ${country.countryName}',
                            icon: Icons.flag_rounded,
                          ),
                          _MiniInfoPill(
                            label: country.region,
                            icon: Icons.travel_explore_rounded,
                          ),
                          _MiniInfoPill(
                            label: country.currency,
                            icon: Icons.payments_rounded,
                          ),
                          _MiniInfoPill(
                            label: country.language,
                            icon: Icons.translate_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: wide ? 0 : 12,
                  bottom: wide ? 0 : 12,
                  child: _HeroShipmentVisual(
                    count: orders.length,
                    progress: totalProgress,
                    motion: motion,
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

class _OverviewGrid extends StatelessWidget {
  final int active;
  final int completed;
  final int cancelled;
  final int international;

  const _OverviewGrid({
    required this.active,
    required this.completed,
    required this.cancelled,
    required this.international,
  });

  @override
  Widget build(BuildContext context) {
    final total = active + completed + cancelled;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 5 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: wide ? 1.35 : 1.20,
          ),
          children: [
            _MetricTile(
              label: 'Total Orders',
              value: '$total',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFF2563EB),
            ),
            _MetricTile(
              label: 'Active',
              value: '$active',
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFFFF8A00),
            ),
            _MetricTile(
              label: 'Completed',
              value: '$completed',
              icon: Icons.verified_rounded,
              color: const Color(0xFF16A34A),
            ),
            _MetricTile(
              label: 'Cancelled',
              value: '$cancelled',
              icon: Icons.cancel_rounded,
              color: const Color(0xFFEF4444),
            ),
            _MetricTile(
              label: 'International',
              value: '$international',
              icon: Icons.flight_takeoff_rounded,
              color: const Color(0xFF0EA5E9),
            ),
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatefulWidget {
  final _OrderData order;

  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final palette = _ClayPalette.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.98 : (_hover ? 1.01 : 1),
          duration: const Duration(milliseconds: 150),
          child: _ClayCard(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: Icon(
                    _modeIcon(order.mode),
                    size: 112,
                    color: order.color.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Sticker(icon: order.icon, color: order.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                order.type,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.subText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(label: order.status, color: order.color),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ModeBadge(mode: order.mode),
                        _HubBadge(label: order.hub),
                        _CurrencyBadge(label: '${order.currency} · ${order.amount}'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _LocationText(
                            label: 'Origin',
                            value: order.origin,
                            icon: Icons.my_location_rounded,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFFFF8A00),
                          ),
                        ),
                        Expanded(
                          child: _LocationText(
                            label: 'Destination',
                            value: order.destination,
                            icon: Icons.location_on_rounded,
                            color: const Color(0xFFFF8A00),
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ProgressSection(order: order),
                    const SizedBox(height: 12),
                    _TimelineRow(order: order),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Track',
                            icon: Icons.route_rounded,
                            color: const Color(0xFF2563EB),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            label: 'View Details',
                            icon: Icons.receipt_long_rounded,
                            color: const Color(0xFFFF8A00),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            label: order.status == 'Cancelled' ? 'Rebook' : 'Pay',
                            icon: order.status == 'Cancelled'
                                ? Icons.refresh_rounded
                                : Icons.payments_rounded,
                            color: order.status == 'Cancelled'
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF16A34A),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final _OrderData order;

  const _ProgressSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 16, color: order.color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                order.eta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.subText,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '${(order.progress * 100).round()}%',
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(color: palette.inner),
                FractionallySizedBox(
                  widthFactor: order.progress.clamp(0, 1),
                  child: Container(color: order.color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _OrderData order;

  const _TimelineRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Row(
      children: List.generate(order.timeline.length, (index) {
        final active =
            index / math.max(order.timeline.length - 1, 1) <= order.progress;

        return Expanded(
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: active ? order.color : palette.inner,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.timeline[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? palette.text : palette.subText,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != order.timeline.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: active
                        ? order.color.withValues(alpha: 0.55)
                        : palette.inner,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _HeroShipmentVisual extends StatelessWidget {
  final int count;
  final double progress;
  final Animation<double> motion;

  const _HeroShipmentVisual({
    required this.count,
    required this.progress,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return AnimatedBuilder(
      animation: motion,
      builder: (context, _) {
        return _ClayCircle(
          size: 154,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: motion.value * math.pi * 2,
                child: Icon(
                  Icons.public_rounded,
                  size: 112,
                  color: const Color(0xFF2563EB).withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                top: 28,
                child: Transform.translate(
                  offset: Offset(math.sin(motion.value * math.pi * 2) * 12, 0),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Color(0xFFFF8A00),
                    size: 28,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                child: Transform.translate(
                  offset: Offset(math.cos(motion.value * math.pi * 2) * 14, 0),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Color(0xFF2563EB),
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                right: 26,
                bottom: 54,
                child: Transform.translate(
                  offset: Offset(0, math.sin(motion.value * math.pi * 2) * 5),
                  child: const Icon(
                    Icons.directions_boat_filled_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 24,
                  ),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: palette.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'Orders',
                      style: TextStyle(
                        color: palette.subText,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return _ClayCard(
      padding: const EdgeInsets.all(12),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Sticker(icon: icon, color: color, size: 34),
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
                    color: palette.text,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.subText,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationText extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool alignEnd;

  const _LocationText({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.subText,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ClayTabBar extends StatelessWidget {
  final TabController controller;

  const _ClayTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(5, 5),
            blurRadius: 12,
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(17),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: palette.subText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }
}

class _ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _ClayCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ClayCircle extends StatelessWidget {
  final double size;
  final Widget child;

  const _ClayCircle({
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.card,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: child,
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
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * .36),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * .52),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: palette.highlight,
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: palette.shadow,
              offset: const Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  const _EmptyOrdersCard();

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return _ClayCard(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 320,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ClayCircle(
                size: 104,
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 50,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No Orders Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: palette.text,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your shipment orders will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.subText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniInfoPill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF2563EB)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: palette.text,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 116),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
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

class _ModeBadge extends StatelessWidget {
  final _ShipmentMode mode;

  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    return _MiniInfoPill(label: _modeLabel(mode), icon: _modeIcon(mode));
  }
}

class _HubBadge extends StatelessWidget {
  final String label;

  const _HubBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return _MiniInfoPill(label: label, icon: Icons.warehouse_rounded);
  }
}

class _CurrencyBadge extends StatelessWidget {
  final String label;

  const _CurrencyBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return _MiniInfoPill(label: label, icon: Icons.payments_rounded);
  }
}

class _OrdersBackground extends StatelessWidget {
  final Animation<double> motion;

  const _OrdersBackground({required this.motion});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return AnimatedBuilder(
      animation: motion,
      builder: (_, __) {
        return CustomPaint(
          painter: _BackgroundPainter(
            value: motion.value,
            palette: palette,
          ),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double value;
  final _ClayPalette palette;

  _BackgroundPainter({
    required this.value,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.08)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final saffron = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodes = [
      Offset(size.width * .08, size.height * .16),
      Offset(size.width * .46, size.height * .08),
      Offset(size.width * .88, size.height * .22),
      Offset(size.width * .18, size.height * .58),
      Offset(size.width * .72, size.height * .68),
      Offset(size.width * .38, size.height * .88),
    ];

    for (var i = 0; i < nodes.length - 1; i++) {
      final path = Path()
        ..moveTo(nodes[i].dx, nodes[i].dy)
        ..quadraticBezierTo(
          size.width * .52,
          nodes[i].dy - 42,
          nodes[i + 1].dx,
          nodes[i + 1].dy,
        );

      canvas.drawPath(path, i.isEven ? blue : saffron);

      final t = (value + i * .18) % 1;
      final p = _quadraticPoint(
        nodes[i],
        Offset(size.width * .52, nodes[i].dy - 42),
        nodes[i + 1],
        t,
      );

      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color =
              i.isEven ? const Color(0xFF2563EB) : const Color(0xFFFF8A00),
      );
    }

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        5,
        Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.10),
      );
      canvas.drawCircle(
        node,
        13,
        Paint()..color = const Color(0xFFFF8A00).withValues(alpha: 0.045),
      );
    }
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
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.palette != palette;
  }
}

class _HeroRoutePainter extends CustomPainter {
  final double value;
  final _ClayPalette palette;

  _HeroRoutePainter({
    required this.value,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.22)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * .12, size.height * .75)
      ..quadraticBezierTo(
        size.width * .46,
        size.height * .08,
        size.width * .88,
        size.height * .50,
      );

    canvas.drawPath(path, route);

    final p1 = Offset(size.width * .12, size.height * .75);
    final p2 = Offset(size.width * .46, size.height * .08);
    final p3 = Offset(size.width * .88, size.height * .50);

    final moving = _quadraticPoint(p1, p2, p3, value);

    canvas.drawCircle(
      Offset(size.width * .22, size.height * .61),
      5,
      Paint()..color = const Color(0xFF2563EB),
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .40),
      5,
      Paint()..color = const Color(0xFFFF8A00),
    );
    canvas.drawCircle(
      moving,
      5,
      Paint()..color = const Color(0xFFFF8A00),
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
    return oldDelegate.value != value || oldDelegate.palette != palette;
  }
}

class _WorldMapPainter extends CustomPainter {
  final _ClayPalette palette;

  _WorldMapPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;

    final shapes = [
      Rect.fromLTWH(size.width * .08, size.height * .20, 70, 34),
      Rect.fromLTWH(size.width * .22, size.height * .34, 90, 40),
      Rect.fromLTWH(size.width * .45, size.height * .16, 110, 48),
      Rect.fromLTWH(size.width * .65, size.height * .38, 130, 52),
      Rect.fromLTWH(size.width * .36, size.height * .62, 100, 38),
    ];

    for (final rect in shapes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter oldDelegate) => false;
}

class _ClayPalette {
  final Color background;
  final Color card;
  final Color highlight;
  final Color shadow;
  final Color text;
  final Color subText;
  final Color inner;

  const _ClayPalette({
    required this.background,
    required this.card,
    required this.highlight,
    required this.shadow,
    required this.text,
    required this.subText,
    required this.inner,
  });

  static _ClayPalette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (dark) {
      return const _ClayPalette(
        background: AppColors.darkBg1,
        card: AppColors.darkCard,
        highlight: AppColors.clayHighlightDark,
        shadow: AppColors.clayShadowDark,
        text: Colors.white,
        subText: AppColors.darkSubtext,
        inner: AppColors.darkBg3,
      );
    }

    return const _ClayPalette(
      background: Color(0xFFEAF4FF),
      card: Color(0xFFF8FBFF),
      highlight: Color(0xFFFFFFFF),
      shadow: Color(0xFFBDD2EA),
      text: Color(0xFF0F172A),
      subText: Color(0xFF64748B),
      inner: Color(0xFFD8E7F7),
    );
  }
}

enum _ShipmentMode { road, air, ocean }

IconData _modeIcon(_ShipmentMode mode) {
  switch (mode) {
    case _ShipmentMode.road:
      return Icons.local_shipping_rounded;
    case _ShipmentMode.air:
      return Icons.flight_takeoff_rounded;
    case _ShipmentMode.ocean:
      return Icons.directions_boat_filled_rounded;
  }
}

String _modeLabel(_ShipmentMode mode) {
  switch (mode) {
    case _ShipmentMode.road:
      return 'Road';
    case _ShipmentMode.air:
      return 'Air';
    case _ShipmentMode.ocean:
      return 'Ocean';
  }
}

class _CountryData {
  final String countryCode;
  final String countryName;
  final String flag;
  final String dialCode;
  final String region;
  final String currency;
  final String language;

  const _CountryData({
    required this.countryCode,
    required this.countryName,
    required this.flag,
    required this.dialCode,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _OrderData {
  final String id;
  final String type;
  final String origin;
  final String destination;
  final String status;
  final String eta;
  final double progress;
  final IconData icon;
  final Color color;
  final _ShipmentMode mode;
  final String hub;
  final String amount;
  final String country;
  final String currency;
  final List<String> timeline;

  const _OrderData({
    required this.id,
    required this.type,
    required this.origin,
    required this.destination,
    required this.status,
    required this.eta,
    required this.progress,
    required this.icon,
    required this.color,
    required this.mode,
    required this.hub,
    required this.amount,
    required this.country,
    required this.currency,
    required this.timeline,
  });
}