import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class OutboundScreen extends StatefulWidget {
  const OutboundScreen({super.key});

  @override
  State<OutboundScreen> createState() => _OutboundScreenState();
}

class _DispatchData {
  final String barcode;
  final String recipient;
  final String destination;
  final String mode;
  final String weight;
  final String cutoffTime;
  final String driverName;
  bool dispatched = false;

  _DispatchData({
    required this.barcode,
    required this.recipient,
    required this.destination,
    required this.mode,
    required this.weight,
    required this.cutoffTime,
    required this.driverName,
  });
}

class _OutboundScreenState extends State<OutboundScreen> {
  final _items = [
    _DispatchData(barcode: 'JD-OUT-00551', recipient: 'Tata Motors Ltd', destination: 'Pune', mode: 'Road', weight: '18.2 kg', cutoffTime: '12:00 PM', driverName: 'Ravi Kumar'),
    _DispatchData(barcode: 'JD-OUT-00552', recipient: 'Flipkart Seller', destination: 'Hyderabad', mode: 'Air', weight: '3.4 kg', cutoffTime: '01:30 PM', driverName: 'Anil Singh'),
    _DispatchData(barcode: 'JD-OUT-00553', recipient: 'Samsung India', destination: 'Dubai', mode: 'Air', weight: '5.6 kg', cutoffTime: '03:00 PM', driverName: 'Suresh P.'),
    _DispatchData(barcode: 'JD-OUT-00554', recipient: 'Myntra Warehouse', destination: 'Delhi', mode: 'Road', weight: '22.0 kg', cutoffTime: '04:00 PM', driverName: 'Vikram D.'),
    _DispatchData(barcode: 'JD-OUT-00555', recipient: 'IKEA India', destination: 'Bengaluru', mode: 'Road', weight: '45.0 kg', cutoffTime: '05:30 PM', driverName: 'Mahesh T.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dispatched = _items.where((p) => p.dispatched).length;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Outbound',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBadge(
                          label: 'Ready',
                          value: '${_items.length}',
                          icon: Icons.outbox_rounded,
                          color: AppColors.accent),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.15)),
                      _StatBadge(
                          label: 'Dispatched',
                          value: '$dispatched',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.warehouseColor),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.15)),
                      _StatBadge(
                          label: 'Pending',
                          value: '${_items.length - dispatched}',
                          icon: Icons.pending_rounded,
                          color: AppColors.warning),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DispatchCard(
                    item: _items[i],
                    onDispatch: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _items[i].dispatched = true);
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

class _StatBadge extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatBadge(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      );
}

class _DispatchCard extends StatelessWidget {
  final _DispatchData item;
  final VoidCallback onDispatch;

  const _DispatchCard(
      {required this.item, required this.onDispatch});

  @override
  Widget build(BuildContext context) {
    final modeColor =
        item.mode == 'Air' ? AppColors.airColor : AppColors.roadColor;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                item.mode == 'Air'
                    ? Icons.flight_rounded
                    : Icons.local_shipping_rounded,
                color: modeColor,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.barcode,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(item.recipient,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 10, color: Colors.white38),
                    const SizedBox(width: 3),
                    Text(item.destination,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.scale_rounded,
                        size: 10, color: Colors.white38),
                    const SizedBox(width: 3),
                    Text(item.weight,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.schedule_rounded,
                        size: 10, color: Colors.white38),
                    const SizedBox(width: 3),
                    Text(item.cutoffTime,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 10, color: AppColors.driverColor),
                    const SizedBox(width: 3),
                    Text(item.driverName,
                        style: const TextStyle(
                            color: AppColors.driverColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          item.dispatched
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        AppColors.warehouseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.warehouseColor, size: 16),
                )
              : GestureDetector(
                  onTap: onDispatch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              AppColors.accent.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Dispatch',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                  ),
                ),
        ],
      ),
    );
  }
}
