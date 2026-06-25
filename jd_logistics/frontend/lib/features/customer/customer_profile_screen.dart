// Full updated Profile screen with JD Customer hero + OBC Wallet section.
// Uses existing AppColors, JdAppBar, GlassCard, GradientBackground.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final userName = auth.user?.name ?? 'JD Customer';
    final userPhone = auth.user?.phone ?? '+91 98765 43210';
    final region = _RegionResolver.fromPhone(userPhone);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const JdAppBar(
        title: 'My Profile',
        showBack: false,
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
                      children: [
                        _ProfileHero(
                          name: userName,
                          phone: userPhone,
                          region: region,
                          motion: _motion,
                        ),
                        const SizedBox(height: 18),
                        _QuickActionsGrid(wide: wide),
                        const SizedBox(height: 18),
                        _ObcWalletCard(wide: wide),
                        const SizedBox(height: 18),
                        _StatsGrid(wide: wide),
                        const SizedBox(height: 18),
                        _LogisticsIdentityCard(region: region),
                        const SizedBox(height: 18),
                        _KycStatusCard(),
                        const SizedBox(height: 18),
                        _ProfileMenuCard(themeProvider: themeProvider),
                        const SizedBox(height: 18),
                        _SupportMenuCard(),
                        const SizedBox(height: 18),
                        GlassCard(
                          borderRadius: 32,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _ProfileTile(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            iconColor: AppColors.error,
                            labelColor: AppColors.error,
                            onTap: () async {
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) context.go('/login');
                            },
                          ),
                        ),
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
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final String phone;
  final _UserRegion region;
  final Animation<double> motion;

  const _ProfileHero({
    required this.name,
    required this.phone,
    required this.region,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 34,
      padding: const EdgeInsets.all(22),
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
          Column(
            children: [
              AnimatedBuilder(
                animation: motion,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(motion.value * math.pi * 2) * 7,
                      0,
                    ),
                    child: child,
                  );
                },
                child: GlassCard(
                  width: 96,
                  height: 96,
                  borderRadius: 48,
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                phone,
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: const [
                  _RegionChip(
                    icon: Icons.badge_rounded,
                    label: 'JD-CUS-2048',
                    color: AppColors.primary,
                  ),
                  _RegionChip(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Gold Member',
                    color: AppColors.portOrange,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  const _RegionChip(
                    icon: Icons.stars_rounded,
                    label: '1240 Points',
                    color: AppColors.saffron,
                  ),
                  const _RegionChip(
                    icon: Icons.local_shipping_rounded,
                    label: '48 Deliveries',
                    color: AppColors.primary,
                  ),
                  const _RegionChip(
                    icon: Icons.public_rounded,
                    label: '6 Countries',
                    color: AppColors.success,
                  ),
                  const _RegionChip(
                    icon: Icons.monetization_on_rounded,
                    label: '1250 OBC',
                    color: AppColors.oceanColor,
                  ),
                  _RegionChip(
                    icon: Icons.flag_rounded,
                    label: '${region.flag} ${region.country}',
                    color: AppColors.portOrange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _TierProgress(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      color: AppColors.surface(context),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.portOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gold Tier Progress',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const Text(
                '1240 / 2000',
                style: TextStyle(
                  color: AppColors.portOrange,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: 0.62,
              minHeight: 9,
              backgroundColor: AppColors.border(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.portOrange),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final bool wide;

  const _QuickActionsGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.9 : 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _QuickAction(
          icon: Icons.edit_rounded,
          label: 'Edit',
          color: AppColors.primary,
          onTap: () {},
        ),
        _QuickAction(
          icon: Icons.location_on_rounded,
          label: 'Addresses',
          color: AppColors.success,
          onTap: () {},
        ),
        _QuickAction(
          icon: Icons.stars_rounded,
          label: 'Rewards',
          color: AppColors.portOrange,
          onTap: () => context.push('/rewards'),
        ),
        _QuickAction(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Wallet',
          color: AppColors.oceanColor,
          onTap: () => context.push('/payments'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          _Sticker(icon: icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObcWalletCard extends StatelessWidget {
  final bool wide;

  const _ObcWalletCard({required this.wide});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 34,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'OBC Wallet — One Bharat Coins',
            subtitle: 'Use organisation coins for shipment payments and credits',
          ),
          const SizedBox(height: 16),
          if (wide)
            Row(
              children: [
                const Expanded(child: _ObcBalanceCard()),
                const SizedBox(width: 14),
                Expanded(child: _ObcBenefits()),
              ],
            )
          else ...[
            const _ObcBalanceCard(),
            const SizedBox(height: 14),
            _ObcBenefits(),
          ],
        ],
      ),
    );
  }
}

class _ObcBalanceCard extends StatelessWidget {
  const _ObcBalanceCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(18),
      color: AppColors.oceanColor.withValues(
        alpha: AppColors.isDark(context) ? 0.16 : 0.08,
      ),
      borderColor: AppColors.oceanColor.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RegionChip(
            icon: Icons.monetization_on_rounded,
            label: 'One Bharat Coins',
            color: AppColors.oceanColor,
          ),
          const SizedBox(height: 14),
          Text(
            '1,250 OBC',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '1 OBC = ₹1 usable value',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SmallActionButton(
                  label: 'Use OBC',
                  icon: Icons.payments_rounded,
                  color: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallActionButton(
                  label: 'History',
                  icon: Icons.history_rounded,
                  color: AppColors.portOrange,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ObcBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const benefits = [
      ('Shipment payments', Icons.local_shipping_rounded),
      ('Wallet top-up', Icons.account_balance_wallet_rounded),
      ('Shipment discounts', Icons.discount_rounded),
      ('International invoice credits', Icons.public_rounded),
    ];

    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: benefits.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              children: [
                Icon(item.$2, color: AppColors.oceanColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.$1,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      onTap: onTap,
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.10),
      borderColor: color.withValues(alpha: 0.22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool wide;

  const _StatsGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.45 : 1.20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _StatCard(
          icon: Icons.local_shipping_rounded,
          label: 'Deliveries',
          value: '48',
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.public_rounded,
          label: 'Countries',
          value: '06',
          color: AppColors.portOrange,
        ),
        _StatCard(
          icon: Icons.location_on_rounded,
          label: 'Addresses',
          value: '04',
          color: AppColors.success,
        ),
        _StatCard(
          icon: Icons.verified_rounded,
          label: 'KYC',
          value: 'Done',
          color: AppColors.oceanColor,
        ),
      ],
    );
  }
}

class _LogisticsIdentityCard extends StatelessWidget {
  final _UserRegion region;

  const _LogisticsIdentityCard({required this.region});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Logistics Identity',
            subtitle: 'Customer network, wallet and shipping preferences',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              const _IdentityPill(
                icon: Icons.badge_rounded,
                label: 'Customer ID',
                value: 'JD-CUS-2048',
                color: AppColors.primary,
              ),
              _IdentityPill(
                icon: Icons.public_rounded,
                label: 'Active Region',
                value: '${region.flag} ${region.country}',
                color: AppColors.portOrange,
              ),
              const _IdentityPill(
                icon: Icons.workspace_premium_rounded,
                label: 'Customer Tier',
                value: 'Gold',
                color: AppColors.saffron,
              ),
              const _IdentityPill(
                icon: Icons.group_rounded,
                label: 'Referrals',
                value: '12',
                color: AppColors.success,
              ),
              const _IdentityPill(
                icon: Icons.flight_takeoff_rounded,
                label: 'Preferred Mode',
                value: 'Road + Air',
                color: AppColors.primary,
              ),
              const _IdentityPill(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet Status',
                value: 'Active',
                color: AppColors.oceanColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KycStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'KYC & Verification',
            subtitle: 'Verification status for secure logistics billing',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _VerifyChip(label: 'KYC Verified', color: AppColors.success),
              _VerifyChip(label: 'PAN Linked', color: AppColors.primary),
              _VerifyChip(label: 'Address Verified', color: AppColors.oceanColor),
              _VerifyChip(label: 'GST Optional', color: AppColors.portOrange),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifyChip extends StatelessWidget {
  final String label;
  final Color color;

  const _VerifyChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ProfileMenuCard({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _ProfileTile(
            icon: Icons.edit_rounded,
            label: 'Edit Profile',
            trailing: 'Update',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.location_city_rounded,
            label: 'Saved Addresses',
            trailing: '4',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.payment_rounded,
            label: 'Payment Methods',
            trailing: 'UPI, Card',
            onTap: () => context.push('/payments'),
          ),
          _ProfileTile(
            icon: Icons.stars_rounded,
            label: 'Rewards & OBC',
            trailing: '1250 OBC',
            onTap: () => context.push('/rewards'),
          ),
          _ProfileTile(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            trailing: '8',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.language_rounded,
            label: 'Country & Region',
            trailing: 'India',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.tune_rounded,
            label: 'Shipment Preferences',
            trailing: 'Road + Air',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.security_rounded,
            label: 'Security Settings',
            trailing: 'Active',
            onTap: () {},
          ),
          SwitchListTile(
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            secondary: const _Sticker(
              icon: Icons.dark_mode_rounded,
              color: AppColors.primary,
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            activeThumbColor: AppColors.portOrange,
          ),
        ],
      ),
    );
  }
}

class _SupportMenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _ProfileTile(
            icon: Icons.support_agent_rounded,
            label: 'Help & Support',
            trailing: '24x7',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.confirmation_number_rounded,
            label: 'Support Tickets',
            trailing: '2 Open',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Sticker(icon: icon, color: color),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _Sticker(
        icon: icon,
        color: iconColor ?? AppColors.primary,
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: labelColor ?? AppColors.text(context),
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.subtext(context),
              size: 14,
            ),
      onTap: onTap,
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

class _IdentityPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _IdentityPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 170),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RegionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, color: color, size: 22),
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
          .withValues(alpha: dark ? 0.26 : 0.30)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * .12, size.height * .78);
    final control = Offset(size.width * .48, size.height * .05);
    final end = Offset(size.width * .88, size.height * .42);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(path, route);

    final moving = _quadraticPoint(start, control, end, value);

    canvas.drawCircle(moving, 5, Paint()..color = AppColors.portOrange);
    canvas.drawCircle(
      Offset(size.width * .22, size.height * .62),
      4.5,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      Offset(size.width * .74, size.height * .42),
      4.5,
      Paint()..color = AppColors.success,
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

class _UserRegion {
  final String flag;
  final String country;
  final String region;
  final String market;

  const _UserRegion({
    required this.flag,
    required this.country,
    required this.region,
    required this.market,
  });
}

class _RegionResolver {
  static _UserRegion fromPhone(String phone) {
    final cleaned = phone.replaceAll(' ', '');

    if (cleaned.startsWith('+91')) {
      return const _UserRegion(
        flag: '🇮🇳',
        country: 'India',
        region: 'South Asia',
        market: 'Domestic + International',
      );
    }

    if (cleaned.startsWith('+971')) {
      return const _UserRegion(
        flag: '🇦🇪',
        country: 'UAE',
        region: 'Middle East',
        market: 'International',
      );
    }

    if (cleaned.startsWith('+1')) {
      return const _UserRegion(
        flag: '🇺🇸',
        country: 'USA',
        region: 'North America',
        market: 'International',
      );
    }

    if (cleaned.startsWith('+44')) {
      return const _UserRegion(
        flag: '🇬🇧',
        country: 'United Kingdom',
        region: 'Europe',
        market: 'International',
      );
    }

    if (cleaned.startsWith('+65')) {
      return const _UserRegion(
        flag: '🇸🇬',
        country: 'Singapore',
        region: 'Southeast Asia',
        market: 'International',
      );
    }

    return const _UserRegion(
      flag: '🌍',
      country: 'Global',
      region: 'International',
      market: 'Domestic + International',
    );
  }
}