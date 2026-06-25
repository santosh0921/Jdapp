import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';

class InvoiceScreen extends StatelessWidget {
  final String? orderId;
  const InvoiceScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Invoice',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_rounded, color: Colors.white),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Payment Successful',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice #${orderId ?? 'INV-000000'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InvoiceRow(label: 'Shipment ID', value: orderId ?? '--'),
                      const Divider(color: Colors.white12),
                      const _InvoiceRow(label: 'Service', value: 'Standard Delivery'),
                      const _InvoiceRow(label: 'Base Fare', value: '₹0.00'),
                      const _InvoiceRow(label: 'Distance Charge', value: '₹0.00'),
                      const _InvoiceRow(label: 'GST (18%)', value: '₹0.00'),
                      const Divider(color: Colors.white12),
                      const _InvoiceRow(label: 'Total', value: '₹0.00', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const GlassCard(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InvoiceRow(label: 'Payment Method', value: 'UPI'),
                      _InvoiceRow(label: 'Transaction ID', value: '--'),
                      _InvoiceRow(label: 'Date', value: '--'),
                      _InvoiceRow(
                        label: 'Status',
                        value: 'Paid',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Back to Home',
                  onPressed: () => context.go('/customer/home'),
                  colors: AppColors.primaryGradient,
                  icon: Icons.home_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}
