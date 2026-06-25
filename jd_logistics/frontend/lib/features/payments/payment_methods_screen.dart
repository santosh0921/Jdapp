import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Payment Methods', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved Cards', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                const GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    _MethodTile(icon: Icons.credit_card_rounded, label: 'No saved cards yet', sublabel: 'Add a card to pay faster', trailing: null),
                  ]),
                ),
                const SizedBox(height: 24),
                Text('UPI', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                const GlassCard(
                  padding: EdgeInsets.all(16),
                  child: _MethodTile(icon: Icons.account_balance_wallet_rounded, label: 'Add UPI ID', sublabel: 'Link your UPI for instant payments', trailing: Icons.add_rounded),
                ),
                const SizedBox(height: 24),
                Text('Net Banking', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                const GlassCard(
                  padding: EdgeInsets.all(16),
                  child: _MethodTile(icon: Icons.account_balance_rounded, label: 'Select Bank', sublabel: 'Pay via internet banking', trailing: Icons.arrow_forward_ios_rounded),
                ),
                const Spacer(),
                GradientButton(
                  onPressed: () => context.push('/payments/add-card'),
                  gradient: AppColors.primaryGradient,
                  child: const Text('Add New Card'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final IconData? trailing;
  const _MethodTile({required this.icon, required this.label, required this.sublabel, this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.primary, size: 20),
    ),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      Text(sublabel, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ])),
    if (trailing != null) Icon(trailing, color: Colors.white38, size: 16),
  ]);
}
