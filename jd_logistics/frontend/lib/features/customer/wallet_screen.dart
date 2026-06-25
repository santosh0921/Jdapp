// frontend/lib/features/customer/presentation/wallet_screen.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/utils/helpers.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class CustomerWalletScreen extends StatefulWidget {
  const CustomerWalletScreen({super.key});

  @override
  State<CustomerWalletScreen> createState() => _CustomerWalletScreenState();
}

class _CustomerWalletScreenState extends State<CustomerWalletScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  static const _country = _CountryData(
    countryName: 'India',
    flag: '🇮🇳',
    region: 'South Asia',
    currency: 'INR',
    language: 'English / Hindi',
  );

  static const _transactions = [
    _WalletTransaction(
      id: 'WLT-JD-2048',
      title: 'Shipment Payment',
      amount: '- ₹499',
      date: 'Today • 10:20 AM',
      shipmentId: 'JDIN240001',
      type: 'Road Shipment',
      status: 'Paid',
      countryFlag: '🇮🇳',
      currency: 'INR',
      icon: Icons.local_shipping_rounded,
      color: AppColors.roadColor,
      debit: true,
    ),
    _WalletTransaction(
      id: 'WLT-JD-4501',
      title: 'Wallet Top Up',
      amount: '+ ₹2,000',
      date: 'Yesterday • 08:45 PM',
      shipmentId: 'JD-WALLET',
      type: 'Wallet Credit',
      status: 'Success',
      countryFlag: '🇮🇳',
      currency: 'INR',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.success,
      debit: false,
    ),
    _WalletTransaction(
      id: 'WLT-JD-9172',
      title: 'International Freight',
      amount: '- ₹1,299 / USD 15',
      date: 'Jun 15 • 03:15 PM',
      shipmentId: 'JDAIR240801',
      type: 'Air Freight',
      status: 'Paid',
      countryFlag: '🇦🇪',
      currency: 'AED',
      icon: Icons.flight_takeoff_rounded,
      color: AppColors.airColor,
      debit: true,
    ),
    _WalletTransaction(
      id: 'WLT-JD-8841',
      title: 'Shipping Credit Reward',
      amount: '+ ₹250',
      date: 'Jun 14 • 06:40 PM',
      shipmentId: 'JD-REWARD',
      type: 'Reward Credit',
      status: 'Credited',
      countryFlag: '🇮🇳',
      currency: 'INR',
      icon: Icons.card_giftcard_rounded,
      color: AppColors.oceanColor,
      debit: false,
    ),
  ];

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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const JdAppBar(
        title: 'JD Wallet',
        showBack: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final tablet = constraints.maxWidth >= 980;

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
                        _WalletHero(country: _country, motion: _motion),
                        const SizedBox(height: 18),
                        _WalletStatsGrid(wide: wide, tablet: tablet),
                        const SizedBox(height: 18),
                        _WalletActionsGrid(wide: wide),
                        const SizedBox(height: 18),
                        const _RewardsCard(),
                        const SizedBox(height: 18),
                        const _CoverageCard(),
                        const SizedBox(height: 18),
                        const _SectionTitle(
                          title: 'Transaction History',
                          subtitle:
                              'Wallet credits, rewards and shipment payments',
                        ),
                        const SizedBox(height: 12),
                        ..._transactions.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TransactionCard(item: item),
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

class _WalletHero extends StatelessWidget {
  final _CountryData country;
  final Animation<double> motion;

  const _WalletHero({
    required this.country,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 34,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 270,
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
            Positioned(
              left: 0,
              top: 0,
              right: 132,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Pill(
                    label: 'JD GLOBAL WALLET',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.portOrange,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    Helpers.formatCurrency(0),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.text(context),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use your wallet for domestic shipments, international freight, invoices and COD settlements.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(
                        label: '${country.flag} ${country.countryName}',
                        color: AppColors.primary,
                      ),
                      _MiniPill(
                        label: country.region,
                        color: AppColors.portOrange,
                      ),
                      _MiniPill(
                        label: country.currency,
                        color: AppColors.success,
                      ),
                      const _MiniPill(
                        label: 'Gold Tier',
                        color: AppColors.oceanColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 8,
              child: AnimatedBuilder(
                animation: motion,
                builder: (_, __) {
                  return _HeroWalletVisual(value: motion.value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _HeroWalletVisual extends StatelessWidget {
  final double value;

  const _HeroWalletVisual({required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 120,
      height: 120,
      borderRadius: 38,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.public_rounded,
            size: 92,
            color: AppColors.primary.withValues(alpha: 0.14),
          ),
          Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 12, -29),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: AppColors.airColor,
              size: 24,
            ),
          ),
          Transform.translate(
            offset: Offset(math.cos(value * math.pi * 2) * 13, 25),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: AppColors.roadColor,
              size: 27,
            ),
          ),
          Transform.translate(
            offset: Offset(0, math.sin(value * math.pi * 2) * 5),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.portOrange,
              size: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletStatsGrid extends StatelessWidget {
  final bool wide;
  final bool tablet;

  const _WalletStatsGrid({
    required this.wide,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: tablet ? 3 : (wide ? 3 : 2),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.45 : 1.12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _WalletStat(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Wallet Balance',
          value: '₹0',
          color: AppColors.primary,
        ),
        _WalletStat(
          icon: Icons.redeem_rounded,
          label: 'Shipping Credits',
          value: '₹750',
          color: AppColors.success,
        ),
        _WalletStat(
          icon: Icons.stars_rounded,
          label: 'Reward Coins',
          value: '2,450',
          color: AppColors.portOrange,
        ),
        _WalletStat(
          icon: Icons.public_rounded,
          label: 'Global Payments',
          value: '06',
          color: AppColors.oceanColor,
        ),
        _WalletStat(
          icon: Icons.payments_rounded,
          label: 'Monthly Spend',
          value: '₹12.3K',
          color: AppColors.statusCustoms,
        ),
        _WalletStat(
          icon: Icons.workspace_premium_rounded,
          label: 'Active Rewards',
          value: '04',
          color: AppColors.saffron,
        ),
      ],
    );
  }
}

class _WalletActionsGrid extends StatelessWidget {
  final bool wide;

  const _WalletActionsGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.5 : 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _ActionCard(
          icon: Icons.add_rounded,
          title: 'Add Money',
          subtitle: 'Top up wallet instantly',
          color: AppColors.success,
        ),
        _ActionCard(
          icon: Icons.send_rounded,
          title: 'Transfer',
          subtitle: 'Send wallet balance',
          color: AppColors.primary,
        ),
        _ActionCard(
          icon: Icons.card_giftcard_rounded,
          title: 'Redeem',
          subtitle: 'Use reward coins',
          color: AppColors.portOrange,
        ),
        _ActionCard(
          icon: Icons.receipt_long_rounded,
          title: 'History',
          subtitle: 'View wallet ledger',
          color: AppColors.oceanColor,
        ),
      ],
    );
  }
}

class _WalletStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WalletStat({
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
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text(context),
              fontWeight: FontWeight.w900,
              fontSize: 21,
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

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.965 : 1,
        duration: const Duration(milliseconds: 150),
        child: GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  widget.icon,
                  size: 58,
                  color: widget.color.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Sticker(icon: widget.icon, color: widget.color),
                  const Spacer(),
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardsCard extends StatelessWidget {
  const _RewardsCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Rewards & Shipping Credits',
            subtitle:
                'Use credits for domestic and international logistics payments',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              return GridView.count(
                crossAxisCount: wide ? 3 : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: wide ? 1.55 : 3.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _CreditTile(
                    icon: Icons.stars_rounded,
                    title: 'Reward Coins',
                    value: '2,450',
                    subtitle: 'Redeem on shipping',
                    color: AppColors.portOrange,
                  ),
                  _CreditTile(
                    icon: Icons.redeem_rounded,
                    title: 'Shipping Credits',
                    value: '₹750',
                    subtitle: 'Valid for 30 days',
                    color: AppColors.primary,
                  ),
                  _CreditTile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Wallet Tier',
                    value: 'Gold',
                    subtitle: 'Priority support enabled',
                    color: AppColors.success,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      borderRadius: 32,
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Global Wallet Coverage',
            subtitle: 'Currency and route support for shipment billing',
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '🇮🇳 INR', color: AppColors.primary),
              _MiniPill(label: '🇦🇪 AED', color: AppColors.portOrange),
              _MiniPill(label: '🇺🇸 USD', color: AppColors.success),
              _MiniPill(label: '🇬🇧 GBP', color: AppColors.oceanColor),
              _MiniPill(label: '🇸🇬 SGD', color: AppColors.statusCustoms),
              _MiniPill(label: 'Road • Air • Ocean', color: AppColors.saffron),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _CreditTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _Sticker(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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
class _TransactionCard extends StatelessWidget {
  final _WalletTransaction item;

  const _TransactionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _Sticker(icon: item.icon, color: item.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.id} • ${item.date}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniPill(label: item.shipmentId, color: item.color),
                    _MiniPill(
                      label: '${item.countryFlag} ${item.currency}',
                      color: AppColors.primary,
                    ),
                    _MiniPill(
                      label: item.status,
                      color: item.debit ? AppColors.error : AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: item.debit ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
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
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Icon(icon, color: color, size: 23),
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
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
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

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
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
          .withValues(alpha: dark ? 0.28 : 0.34)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * .12, size.height * .72);
    final control = Offset(size.width * .5, size.height * .05);
    final end = Offset(size.width * .88, size.height * .5);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(path, route);

    final moving = _quadraticPoint(start, control, end, value);

    canvas.drawCircle(
      Offset(size.width * .22, size.height * .62),
      5,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      Offset(size.width * .74, size.height * .42),
      5,
      Paint()..color = AppColors.portOrange,
    );
    canvas.drawCircle(
      moving,
      5,
      Paint()..color = AppColors.portOrange,
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

class _CountryData {
  final String countryName;
  final String flag;
  final String region;
  final String currency;
  final String language;

  const _CountryData({
    required this.countryName,
    required this.flag,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _WalletTransaction {
  final String id;
  final String title;
  final String amount;
  final String date;
  final String shipmentId;
  final String type;
  final String status;
  final String countryFlag;
  final String currency;
  final IconData icon;
  final Color color;
  final bool debit;

  const _WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.shipmentId,
    required this.type,
    required this.status,
    required this.countryFlag,
    required this.currency,
    required this.icon,
    required this.color,
    required this.debit,
  });
}