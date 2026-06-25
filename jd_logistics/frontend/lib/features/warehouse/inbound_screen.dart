import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class InboundScreen extends StatefulWidget {
  const InboundScreen({super.key});

  @override
  State<InboundScreen> createState() => _InboundScreenState();
}

class _ParcelData {
  final String barcode;
  final String sender;
  final String origin;
  final String mode;
  final String weight;
  final String arrivalTime;
  bool received = false;

  _ParcelData({
    required this.barcode,
    required this.sender,
    required this.origin,
    required this.mode,
    required this.weight,
    required this.arrivalTime,
  });
}

class _InboundScreenState extends State<InboundScreen> {
  final _parcels = [
    _ParcelData(barcode: 'JD-IN-00441', sender: 'Reliance Industries', origin: 'Mumbai', mode: 'Road', weight: '12.4 kg', arrivalTime: '08:30 AM'),
    _ParcelData(barcode: 'JD-IN-00442', sender: 'TCS Exports', origin: 'Chennai', mode: 'Air', weight: '2.1 kg', arrivalTime: '09:15 AM'),
    _ParcelData(barcode: 'JD-IN-00443', sender: 'Infosys Logistics', origin: 'Pune', mode: 'Road', weight: '7.8 kg', arrivalTime: '10:00 AM'),
    _ParcelData(barcode: 'JD-IN-00444', sender: 'HDFC Supplies', origin: 'Delhi', mode: 'Road', weight: '3.5 kg', arrivalTime: '11:30 AM'),
    _ParcelData(barcode: 'JD-IN-00445', sender: 'Amazon Seller', origin: 'Hyderabad', mode: 'Air', weight: '0.8 kg', arrivalTime: '02:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final received = _parcels.where((p) => p.received).length;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Inbound',
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
                          label: 'Expected',
                          value: '${_parcels.length}',
                          icon: Icons.move_to_inbox_rounded,
                          color: AppColors.primary),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.15)),
                      _StatBadge(
                          label: 'Received',
                          value: '$received',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.warehouseColor),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.15)),
                      _StatBadge(
                          label: 'Pending',
                          value: '${_parcels.length - received}',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.warning),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _parcels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ParcelCard(
                    parcel: _parcels[i],
                    onReceive: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _parcels[i].received = true);
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

class _ParcelCard extends StatelessWidget {
  final _ParcelData parcel;
  final VoidCallback onReceive;

  const _ParcelCard({required this.parcel, required this.onReceive});

  @override
  Widget build(BuildContext context) {
    final modeColor =
        parcel.mode == 'Air' ? AppColors.airColor : AppColors.roadColor;

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
                parcel.mode == 'Air'
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
                Text(parcel.barcode,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(parcel.sender,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(parcel.origin,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Text('·',
                        style: TextStyle(color: Colors.white38)),
                    const SizedBox(width: 8),
                    Text(parcel.weight,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Text('·',
                        style: TextStyle(color: Colors.white38)),
                    const SizedBox(width: 8),
                    Text(parcel.arrivalTime,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          parcel.received
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warehouseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.warehouseColor, size: 16),
                )
              : GestureDetector(
                  onTap: onReceive,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Mark Received',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                  ),
                ),
        ],
      ),
    );
  }
}
