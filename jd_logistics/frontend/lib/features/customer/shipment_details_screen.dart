import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/core/widgets/logistics_status_chip.dart';
import 'package:jd_style_logistics/services/courier_service.dart';

String _s(Map<String, dynamic>? o, List<String> keys, {String fallback = '—'}) {
  if (o == null) return fallback;
  for (final k in keys) {
    final v = o[k];
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  return fallback;
}

String _money(Map<String, dynamic>? o, List<String> keys) {
  if (o == null) return '—';
  for (final k in keys) {
    final v = o[k];
    if (v != null) {
      final d = (v is num) ? v.toDouble() : double.tryParse(v.toString());
      if (d != null) return '₹${d.toStringAsFixed(0)}';
    }
  }
  return '—';
}

class ShipmentDetailsScreen extends StatefulWidget {
  final String id;

  const ShipmentDetailsScreen({
    super.key,
    this.id = '',
  });

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data = await CourierService.instance.getOrderById(widget.id);
      if (mounted) setState(() { _order = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayId = widget.id.isNotEmpty ? widget.id : '—';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: JdAppBar(
        title: 'Shipment Details',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: AppColors.text(context),
              size: 20,
            ),
            onPressed: () => context.push('/shipment/share-tracking?id=${widget.id}'),
          ),
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
                      Text('Failed to load shipment details',
                          style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : GradientBackground(
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroStatusCard(id: displayId, order: _order),
                          const SizedBox(height: 16),
                          _ProgressCard(order: _order),
                          const SizedBox(height: 16),
                          const _SectionTitle('Package Info'),
                          _PackageInfoCard(order: _order),
                          const SizedBox(height: 16),
                          const _SectionTitle('Carrier & Service'),
                          _CarrierCard(order: _order),
                          const SizedBox(height: 16),
                          const _SectionTitle('Addresses'),
                          _AddressCard(order: _order),
                          const SizedBox(height: 16),
                          const _SectionTitle('Payment'),
                          _PaymentCard(id: displayId, order: _order),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Track Live',
                                  icon: Icons.my_location_rounded,
                                  onPressed: () =>
                                      context.push('/shipment/live-map?id=${widget.id}&mode=road'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlineButton(
                                  label: 'Support',
                                  onPressed: () => context.push('/customer/chat-support'),
                                ),
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

class _HeroStatusCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic>? order;

  const _HeroStatusCard({required this.id, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = _s(order, ['status'], fallback: 'Pending');
    final from = _s(order, ['from_city', 'pickup_city', 'pickup_address']);
    final to = _s(order, ['to_city', 'delivery_city', 'delivery_address']);
    final mode = _s(order, ['transport_mode', 'mode'], fallback: 'road').toLowerCase();
    final modeColor = mode.contains('air')
        ? AppColors.airColor
        : mode.contains('ocean') || mode.contains('sea')
            ? AppColors.oceanColor
            : AppColors.roadColor;

    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              _Sticker(
                icon: Icons.local_shipping_rounded,
                color: modeColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id,
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LogisticsStatusChip(status: status),
                  ],
                ),
              ),
              _SmallAction(
                label: 'Timeline',
                onTap: () => context.push('/shipment/timeline?id=$id&mode=$mode'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _RouteBar(
            from: from,
            to: to,
            color: modeColor,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _MetaStat(label: 'ETA', value: '—', color: AppColors.success),
              const _MDivider(),
              _MetaStat(label: 'Progress', value: '—', color: modeColor),
              const _MDivider(),
              const _MetaStat(label: 'Distance', value: '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Map<String, dynamic>? order;
  const _ProgressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final from = _s(order, ['from_city', 'pickup_city', 'pickup_address']);
    final to = _s(order, ['to_city', 'delivery_city', 'delivery_address']);

    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(AppColors.roadColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SmallText('Pickup — $from'),
              _SmallText('Delivery — $to'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageInfoCard extends StatelessWidget {
  final Map<String, dynamic>? order;
  const _PackageInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final weight = order != null && order!['weight'] != null
        ? '${order!['weight']} kg'
        : '—';

    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _DetailRow(label: 'Category',
              value: _s(order, ['goods_type', 'category', 'package_type'])),
          _DetailRow(label: 'Weight', value: weight),
          _DetailRow(label: 'Dimensions',
              value: _s(order, ['dimensions', 'package_dimensions'])),
          _DetailRow(label: 'Quantity',
              value: _s(order, ['quantity', 'package_count'])),
          _DetailRow(label: 'Declared Value',
              value: _money(order, ['declared_value', 'item_value'])),
          _DetailRow(label: 'Special Handling',
              value: _s(order, ['special_handling', 'handling_instructions']),
              valueColor: AppColors.warning),
        ],
      ),
    );
  }
}

class _CarrierCard extends StatelessWidget {
  final Map<String, dynamic>? order;
  const _CarrierCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _DetailRow(label: 'Carrier',
              value: _s(order, ['carrier', 'carrier_name', 'partner'])),
          _DetailRow(label: 'Service',
              value: _s(order, ['service_type', 'service'])),
          _DetailRow(label: 'Mode',
              value: _s(order, ['transport_mode', 'mode'])),
          _DetailRow(label: 'Insurance',
              value: _s(order, ['insurance', 'insurance_cover']),
              valueColor: AppColors.success),
          _DetailRow(label: 'AWB / Docket',
              value: _s(order, ['awb', 'docket_number', 'tracking_id'])),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic>? order;
  const _AddressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AddressBlock(
            label: 'Pickup',
            name: _s(order, ['sender_name', 'pickup_contact_name']),
            address: _s(order, ['pickup_address']),
            phone: _s(order, ['sender_phone', 'pickup_contact_phone']),
            icon: Icons.circle,
            color: AppColors.roadColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 2,
              height: 24,
              color: AppColors.border(context),
            ),
          ),
          _AddressBlock(
            label: 'Delivery',
            name: _s(order, ['receiver_name', 'delivery_contact_name']),
            address: _s(order, ['delivery_address']),
            phone: _s(order, ['receiver_phone', 'delivery_contact_phone']),
            icon: Icons.location_on_rounded,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic>? order;

  const _PaymentCard({required this.id, required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _DetailRow(
            label: 'Amount Paid',
            value: _money(order, ['amount', 'total_amount', 'paid_amount']),
            valueColor: AppColors.success,
          ),
          _DetailRow(label: 'Payment Method',
              value: _s(order, ['payment_method', 'payment_mode'])),
          _DetailRow(label: 'Transaction ID',
              value: _s(order, ['transaction_id', 'payment_reference', 'reference'])),
          _DetailRow(
            label: 'Invoice',
            value: 'View →',
            valueColor: AppColors.primary,
            onTap: () => context.push('/payments/invoice?id=$id'),
          ),
        ],
      ),
    );
  }
}

class _RouteBar extends StatelessWidget {
  final String from;
  final String to;
  final Color color;

  const _RouteBar({
    required this.from,
    required this.to,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          from,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Expanded(
                child: Container(height: 2, color: color.withValues(alpha: 0.45)),
              ),
              Icon(Icons.local_shipping_rounded, color: color, size: 18),
              Expanded(
                child: Container(height: 2, color: color.withValues(alpha: 0.45)),
              ),
              const Icon(Icons.location_on_rounded, color: AppColors.error, size: 17),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          to,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _MetaStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetaStat({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.text(context),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MDivider extends StatelessWidget {
  const _MDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.border(context));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.text(context),
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? AppColors.text(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final String label;
  final String name;
  final String address;
  final String phone;
  final IconData icon;
  final Color color;

  const _AddressBlock({
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SmallText(label),
              Text(
                name,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              Text(
                phone,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SmallAction({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallText extends StatelessWidget {
  final String text;

  const _SmallText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.subtext(context),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Sticker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 46,
      height: 46,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
      borderColor: color.withValues(alpha: 0.24),
      child: Icon(icon, color: color, size: 23),
    );
  }
}
