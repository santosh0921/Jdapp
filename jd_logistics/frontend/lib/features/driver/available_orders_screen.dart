import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';
import 'package:jd_style_logistics/providers/driver_provider.dart';
import 'package:provider/provider.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _OrderData {
  final String id;
  final String pickup;
  final String delivery;
  final String distance;
  final double earnings;
  final String packageType;
  final int items;
  final double weightKg;

  const _OrderData({
    required this.id,
    required this.pickup,
    required this.delivery,
    required this.distance,
    required this.earnings,
    required this.packageType,
    required this.items,
    required this.weightKg,
  });
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  static _OrderData _fromShipment(ShipmentModel s) => _OrderData(
        id: s.trackingId.isNotEmpty ? s.trackingId : s.id,
        pickup: s.pickupAddress,
        delivery: s.deliveryAddress,
        distance: '—',
        earnings: s.amount,
        packageType: s.packageType.isNotEmpty ? s.packageType : 'Parcel',
        items: 1,
        weightKg: s.weight,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadAvailableOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dp = context.watch<DriverProvider>();
    final live = dp.availableOrders;
    final pending = live.map(_fromShipment).toList();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Available Orders',
            style: theme.textTheme.titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(
                          label: 'Available',
                          value: '${pending.length}',
                          icon: Icons.list_alt_rounded,
                          color: AppColors.driverColor),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.15)),
                      const _QuickStat(
                          label: 'Radius',
                          value: '10 km',
                          icon: Icons.radar_rounded,
                          color: AppColors.primary),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.15)),
                      _QuickStat(
                          label: 'Active',
                          value: dp.activeDelivery != null ? '1' : '0',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: pending.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 64, color: Colors.white24),
                            SizedBox(height: 16),
                            Text('No Orders Available',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            Text(
                              'New orders will appear here.\nMake sure you are online.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: pending.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => _OrderCard(
                          order: pending[i],
                          onAccept: () async {
                            HapticFeedback.mediumImpact();
                            await dp.acceptOrder(live[i].id);
                          },
                          onDecline: () async {
                            HapticFeedback.lightImpact();
                            await dp.rejectOrder(live[i].id);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      );
}

class _OrderCard extends StatelessWidget {
  final _OrderData order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _OrderCard(
      {required this.order,
      required this.onAccept,
      required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      AppColors.driverColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.id,
                    style: const TextStyle(
                        color: AppColors.driverColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.packageType,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ),
              const Spacer(),
              Text(
                '₹${order.earnings.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RoutePoint(
              icon: Icons.radio_button_checked,
              color: AppColors.primary,
              label: order.pickup),
          Padding(
            padding: const EdgeInsets.only(left: 7, top: 2, bottom: 2),
            child: Container(
                width: 1,
                height: 14,
                color: Colors.white.withValues(alpha: 0.2)),
          ),
          _RoutePoint(
              icon: Icons.location_on_rounded,
              color: AppColors.driverColor,
              label: order.delivery),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaChip(
                  icon: Icons.straighten_rounded, label: order.distance),
              const SizedBox(width: 8),
              _MetaChip(
                  icon: Icons.scale_rounded,
                  label: '${order.weightKg} kg'),
              const SizedBox(width: 8),
              _MetaChip(
                  icon: Icons.inventory_2_rounded,
                  label:
                      '${order.items} item${order.items > 1 ? "s" : ""}'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Accept Order',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _RoutePoint(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white54),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
