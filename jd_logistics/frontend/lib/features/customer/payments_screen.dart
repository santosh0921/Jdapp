import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/utils/helpers.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  static const _country = _CountryData(
    countryName: 'India',
    flag: '🇮🇳',
    region: 'South Asia',
    currency: 'INR',
    language: 'English / Hindi',
  );

  static const _methods = [
    _PaymentMethod(
      icon: Icons.account_balance_wallet_rounded,
      label: 'UPI',
      subtitle: 'Instant shipment payments',
      color: AppColors.success,
    ),
    _PaymentMethod(
      icon: Icons.credit_card_rounded,
      label: 'Card',
      subtitle: 'Credit / Debit cards',
      color: AppColors.primary,
    ),
    _PaymentMethod(
      icon: Icons.account_balance_rounded,
      label: 'Net Banking',
      subtitle: 'Bank transfer billing',
      color: AppColors.portOrange,
    ),
    _PaymentMethod(
      icon: Icons.money_rounded,
      label: 'COD',
      subtitle: 'Cash on delivery',
      color: AppColors.saffron,
    ),
    _PaymentMethod(
      icon: Icons.public_rounded,
      label: 'USD',
      subtitle: 'International freight',
      color: AppColors.airColor,
    ),
    _PaymentMethod(
      icon: Icons.directions_boat_rounded,
      label: 'AED',
      subtitle: 'Ocean cargo billing',
      color: AppColors.oceanColor,
    ),
  ];

  static const _transactions = [
    _TransactionData(
      title: 'Express Parcel Payment',
      id: 'INV-JD-2048',
      amount: '₹499',
      date: 'Jun 17 · 10:20 AM',
      status: 'Paid',
      icon: Icons.local_shipping_rounded,
      color: AppColors.success,
      mode: 'Road',
      hub: 'Mumbai Road Hub',
    ),
    _TransactionData(
      title: 'International Shipping',
      id: 'INV-JD-9172',
      amount: '₹3,999 / USD 48',
      date: 'Jun 16 · 4:30 PM',
      status: 'Pending',
      icon: Icons.flight_takeoff_rounded,
      color: AppColors.portOrange,
      mode: 'Air',
      hub: 'BOM Air Cargo',
    ),
    _TransactionData(
      title: 'Ocean Freight Invoice',
      id: 'INV-JD-8841',
      amount: '₹7,899 / AED 348',
      date: 'Jun 14 · 2:10 PM',
      status: 'Paid',
      icon: Icons.directions_boat_rounded,
      color: AppColors.oceanColor,
      mode: 'Ocean',
      hub: 'Nhava Sheva Port',
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
        title: 'Payments',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _WalletHero(
                                  country: _country,
                                  motion: _motion,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                flex: 2,
                                child: _PaymentStatsCard(),
                              ),
                            ],
                          )
                        else ...[
                          _WalletHero(country: _country, motion: _motion),
                          const SizedBox(height: 16),
                          const _PaymentStatsCard(),
                        ],
                        const SizedBox(height: 18),
                        GlassCard(
                          borderRadius: 32,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: _SectionTitle(
                                      title: 'Payment Methods',
                                      subtitle:
                                          'Domestic and international logistics billing',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.push('/payments/add-card'),
                                    child: const Text(
                                      '+ Add',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              GridView.builder(
                                itemCount: _methods.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: wide ? 6 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: wide ? 1.05 : 0.88,
                                ),
                                itemBuilder: (context, index) {
                                  return _PaymentMethodCard(
                                    method: _methods[index],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        GlassCard(
                          borderRadius: 32,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: _SectionTitle(
                                      title: 'Recent Transactions',
                                      subtitle:
                                          'Invoices, shipment charges and wallet activity',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.push('/payments/history'),
                                    child: const Text(
                                      'See All',
                                      style: TextStyle(
                                        color: AppColors.portOrange,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ..._transactions.map(
                                (txn) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _TransactionTile(transaction: txn),
                                ),
                              ),
                            ],
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;

          return SizedBox(
            height: wide ? 286 : 340,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: motion,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _WalletRoutePainter(
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
                  right: wide ? 120 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Pill(
                        label: 'JD GLOBAL WALLET',
                        icon: Icons.public_rounded,
                        color: AppColors.portOrange,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        Helpers.formatCurrency(0),
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.text(context),
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Wallet balance for shipments, invoices, COD settlements and international freight billing.',
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
                          _MiniInfoPill(
                            label: '${country.flag} ${country.countryName}',
                          ),
                          _MiniInfoPill(label: country.region),
                          _MiniInfoPill(label: country.currency),
                          const _MiniInfoPill(label: 'USD Ready'),
                          const _MiniInfoPill(label: 'AED Ready'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 180,
                        child: GradientButton(
                          label: 'Add Money',
                          onPressed: () {},
                          colors: AppColors.accentGradient,
                          icon: Icons.add_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 12,
                  child: _ClayIconBox(
                    size: wide ? 116 : 104,
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.portOrange,
                  ),
                ),
                Positioned(
                  right: wide ? 102 : 90,
                  top: 18,
                  child: AnimatedBuilder(
                    animation: motion,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(
                          math.sin(motion.value * math.pi * 2) * 8,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: const _Sticker(
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.primary,
                    ),
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

class _PaymentStatsCard extends StatelessWidget {
  const _PaymentStatsCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      borderRadius: 32,
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Payment Overview',
            subtitle: 'Shipment billing summary',
          ),
          SizedBox(height: 18),
          _StatRow(
            icon: Icons.payments_rounded,
            label: 'Total Spent',
            value: '₹12,397',
            color: AppColors.primary,
          ),
          _StatRow(
            icon: Icons.pending_actions_rounded,
            label: 'Pending Payments',
            value: '₹3,999',
            color: AppColors.portOrange,
          ),
          _StatRow(
            icon: Icons.receipt_long_rounded,
            label: 'Invoices',
            value: '18',
            color: AppColors.success,
          ),
          _StatRow(
            icon: Icons.public_rounded,
            label: 'International Bills',
            value: '04',
            color: AppColors.oceanColor,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatefulWidget {
  final _PaymentMethod method;

  const _PaymentMethodCard({required this.method});

  @override
  State<_PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<_PaymentMethodCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final method = widget.method;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.965 : 1,
        duration: const Duration(milliseconds: 150),
        child: GlassCard(
          borderRadius: 26,
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  method.icon,
                  size: 58,
                  color: method.color.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Sticker(icon: method.icon, color: method.color),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            method.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.subtext(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

class _TransactionTile extends StatelessWidget {
  final _TransactionData transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 370;

          final details = Column(
            crossAxisAlignment:
                compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              _StatusPill(
                label: transaction.status,
                color: transaction.color,
              ),
            ],
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Sticker(icon: transaction.icon, color: transaction.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${transaction.id} • ${transaction.date}',
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
                      runSpacing: 8,
                      children: [
                        _MiniInfoPill(label: transaction.mode),
                        _MiniInfoPill(label: transaction.hub),
                      ],
                    ),
                    if (compact) ...[
                      const SizedBox(height: 10),
                      details,
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                details,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        children: [
          _Sticker(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text(context),
              fontWeight: FontWeight.w900,
              fontSize: 16,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _ClayIconBox extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;

  const _ClayIconBox({
    required this.size,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: size,
      height: size,
      borderRadius: 36,
      padding: EdgeInsets.zero,
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.18 : 0.11),
      borderColor: color.withValues(alpha: 0.24),
      child: Icon(icon, color: color, size: size * .46),
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
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Flexible(
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
          ),
        ],
      ),
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  final String label;

  const _MiniInfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.text(context),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
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
      constraints: const BoxConstraints(maxWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
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

class _WalletRoutePainter extends CustomPainter {
  final double value;
  final bool dark;

  _WalletRoutePainter({
    required this.value,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.28 : 0.34)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * .14, size.height * .78);
    final control = Offset(size.width * .48, size.height * .12);
    final end = Offset(size.width * .88, size.height * .50);

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
  bool shouldRepaint(covariant _WalletRoutePainter oldDelegate) {
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

class _PaymentMethod {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _PaymentMethod({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}

class _TransactionData {
  final String title;
  final String id;
  final String amount;
  final String date;
  final String status;
  final IconData icon;
  final Color color;
  final String mode;
  final String hub;

  const _TransactionData({
    required this.title,
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.icon,
    required this.color,
    required this.mode,
    required this.hub,
  });
}