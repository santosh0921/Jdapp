import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/core/widgets/logistics_status_chip.dart';

class ShipmentDetailsScreen extends StatelessWidget {
  final String id;

  const ShipmentDetailsScreen({
    super.key,
    this.id = 'JDIN240001',
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => context.push('/shipment/share-tracking?id=$id'),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroStatusCard(id: id),
                const SizedBox(height: 16),
                const _ProgressCard(),
                const SizedBox(height: 16),
                const _SectionTitle('Package Info'),
                const _PackageInfoCard(),
                const SizedBox(height: 16),
                const _SectionTitle('Carrier & Service'),
                const _CarrierCard(),
                const SizedBox(height: 16),
                const _SectionTitle('Addresses'),
                const _AddressCard(),
                const SizedBox(height: 16),
                const _SectionTitle('Payment'),
                _PaymentCard(id: id),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Track Live',
                        icon: Icons.my_location_rounded,
                        onPressed: () =>
                            context.push('/shipment/live-map?id=$id&mode=road'),
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

  const _HeroStatusCard({required this.id});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const _Sticker(
                icon: Icons.local_shipping_rounded,
                color: AppColors.roadColor,
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
                    const LogisticsStatusChip(status: 'In Transit'),
                  ],
                ),
              ),
              _SmallAction(
                label: 'Timeline',
                onTap: () => context.push('/shipment/timeline?id=$id&mode=road'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _RouteBar(
            from: 'Mumbai',
            to: 'Delhi',
            color: AppColors.roadColor,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _MetaStat(
                label: 'ETA',
                value: 'Today 7:30 PM',
                color: AppColors.success,
              ),
              _MDivider(),
              _MetaStat(
                label: 'Progress',
                value: '68%',
                color: AppColors.roadColor,
              ),
              _MDivider(),
              _MetaStat(
                label: 'Distance',
                value: '1,418 km',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: 0.68,
              minHeight: 10,
              backgroundColor: AppColors.surface(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.roadColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SmallText('Pickup — Mumbai'),
              _SmallText('Delivery — Delhi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageInfoCard extends StatelessWidget {
  const _PackageInfoCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      borderRadius: 28,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _DetailRow(label: 'Category', value: 'Electronics'),
          _DetailRow(label: 'Weight', value: '5.2 kg'),
          _DetailRow(label: 'Dimensions', value: '30 × 20 × 15 cm'),
          _DetailRow(label: 'Quantity', value: '1 package'),
          _DetailRow(label: 'Declared Value', value: '₹45,000'),
          _DetailRow(
            label: 'Special Handling',
            value: 'Fragile',
            valueColor: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _CarrierCard extends StatelessWidget {
  const _CarrierCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      borderRadius: 28,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _DetailRow(label: 'Carrier', value: 'Blue Dart'),
          _DetailRow(label: 'Service', value: 'Road Freight'),
          _DetailRow(label: 'Mode', value: 'Full Truck Load'),
          _DetailRow(
            label: 'Insurance',
            value: 'Included ₹50k cover',
            valueColor: AppColors.success,
          ),
          _DetailRow(label: 'AWB / Docket', value: 'BD-994821745'),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _AddressBlock(
            label: 'Pickup',
            name: 'Raj Electronics Ltd.',
            address: '12, Andheri Industrial Area,\nMumbai, MH 400053',
            phone: '+91 98765 43210',
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
          const _AddressBlock(
            label: 'Delivery',
            name: 'TechMart Stores Pvt. Ltd.',
            address: '45, Connaught Place,\nNew Delhi, DL 110001',
            phone: '+91 91234 56789',
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

  const _PaymentCard({required this.id});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _DetailRow(
            label: 'Amount Paid',
            value: '₹1,952',
            valueColor: AppColors.success,
          ),
          const _DetailRow(label: 'Payment Method', value: 'UPI GPay'),
          const _DetailRow(label: 'Transaction ID', value: 'TXN82934710'),
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