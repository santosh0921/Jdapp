import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/models/driver_model.dart';
import 'package:jd_style_logistics/providers/driver_provider.dart';

// Computes earnings stats from the live list.
class _EarnStats {
  final double total;
  final double today;
  final double week;
  final int deliveries;
  final double avgPerTrip;
  final List<double> chart; // 7 normalised values Mon→Sun

  const _EarnStats({
    required this.total,
    required this.today,
    required this.week,
    required this.deliveries,
    required this.avgPerTrip,
    required this.chart,
  });

  static _EarnStats from(List<EarningModel> list) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));

    double total = 0, todayAmt = 0, weekAmt = 0;
    int deliveries = 0;

    // Buckets for Mon=0 … Sun=6 (relative to weekStart)
    final buckets = List<double>.filled(7, 0);

    for (final e in list) {
      if (e.amount <= 0) continue;
      total += e.amount;
      if (!e.createdAt.isBefore(todayStart)) todayAmt += e.amount;
      if (!e.createdAt.isBefore(weekStart)) {
        weekAmt += e.amount;
        final dayOffset = e.createdAt.difference(weekStart).inDays.clamp(0, 6);
        buckets[dayOffset] += e.amount;
      }
      if (e.type == 'delivery') deliveries++;
    }

    final maxBucket = buckets.reduce(math.max);
    final chart = maxBucket > 0
        ? buckets.map((v) => (v / maxBucket).clamp(0.05, 1.0)).toList()
        : List<double>.filled(7, 0.0);

    return _EarnStats(
      total: total,
      today: todayAmt,
      week: weekAmt,
      deliveries: deliveries,
      avgPerTrip: deliveries > 0 ? total / deliveries : 0,
      chart: chart,
    );
  }

  String fmt(double v) => v >= 1000
      ? '₹${(v / 1000).toStringAsFixed(1)}k'
      : '₹${v.toStringAsFixed(0)}';
}

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _walletController;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _walletController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadEarnings();
    });
  }

  static _TransactionData _fromEarning(EarningModel e) {
    final isCredit = e.amount >= 0;
    return _TransactionData(
      title: e.type == 'delivery'
          ? 'Delivery Reward'
          : e.type == 'obc'
              ? 'OBC Reward'
              : e.type == 'withdrawal'
                  ? 'Withdrawal'
                  : 'Earning',
      subtitle: e.description ?? e.shipmentId ?? '—',
      amount: isCredit
          ? '+₹${e.amount.toStringAsFixed(0)}'
          : '-₹${e.amount.abs().toStringAsFixed(0)}',
      time: '${e.createdAt.hour.toString().padLeft(2, '0')}:${e.createdAt.minute.toString().padLeft(2, '0')}',
      credit: isCredit,
      icon: e.type == 'obc'
          ? Icons.monetization_on_rounded
          : e.type == 'withdrawal'
              ? Icons.account_balance_rounded
              : Icons.local_shipping_rounded,
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _dark(context) ? AppColors.darkBg1 : const Color(0xFFFFFFFF);

  Color _surface(BuildContext context) =>
      _dark(context) ? AppColors.darkCard : const Color(0xFFF8FAFF);

  Color _text(BuildContext context) =>
      _dark(context) ? Colors.white : const Color(0xFF0F172A);

  Color _sub(BuildContext context) =>
      _dark(context) ? Colors.white70 : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            const _EarningsBackground(),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: Curves.easeOut,
              ),
              child: Column(
                children: [
                  _Header(
                    textColor: _text(context),
                    subTextColor: _sub(context),
                    surfaceColor: _surface(context),
                    onBack: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) context.pop();
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                      child: Column(
                        children: [
                          _HeroEarningsCard(
                            walletController: _walletController,
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _MetricGrid(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _GoalProgressCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _EarningsGraphCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _ObcCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _PerformanceCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _IncentivesCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _WithdrawCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _TransactionsCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                            live: context.watch<DriverProvider>().earnings.map(_fromEarning).toList(),
                          ),
                        ],
                      ),
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

class _Header extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final VoidCallback onBack;

  const _Header({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          _ClayButton(
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFF0B5FFF),
            surfaceColor: surfaceColor,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'June 2026',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Driver Earnings',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ClayButton(
            icon: Icons.receipt_long_rounded,
            color: AppColors.success,
            surfaceColor: surfaceColor,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _HeroEarningsCard extends StatelessWidget {
  final AnimationController walletController;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _HeroEarningsCard({
    required this.walletController,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _EarnStats.from(context.watch<DriverProvider>().earnings);
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TrendPill(),
                  const SizedBox(height: 12),
                  Text(
                    stats.fmt(stats.total),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total earnings this month',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _WalletAvatar(walletController: walletController),
        ],
      ),
    );
  }
}

class _WalletAvatar extends StatelessWidget {
  final AnimationController walletController;

  const _WalletAvatar({required this.walletController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: walletController,
      builder: (context, _) {
        final lift = math.sin(walletController.value * math.pi * 2) * 4;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Container(
            height: 106,
            width: 94,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 18,
                  offset: const Offset(8, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: .90),
                  blurRadius: 18,
                  offset: const Offset(-8, -8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 16,
                  child: Container(
                    height: 36,
                    width: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5FFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  child: Container(
                    height: 40,
                    width: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.currency_rupee_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _MetricGrid({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40) / 2;
    final stats = _EarnStats.from(context.watch<DriverProvider>().earnings);

    final items = [
      _MetricData('Today', stats.fmt(stats.today), Icons.today_rounded, const Color(0xFF0B5FFF)),
      _MetricData('This Week', stats.fmt(stats.week), Icons.date_range_rounded, const Color(0xFFFF8A00)),
      _MetricData('Deliveries', '${stats.deliveries}', Icons.local_shipping_rounded, AppColors.success),
      _MetricData('Avg / Trip', stats.fmt(stats.avgPerTrip), Icons.route_rounded, AppColors.warning),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: width,
              child: _ClayCard(
                surfaceColor: surfaceColor,
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    _SoftIcon(icon: item.icon, color: item.color),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.value,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _GoalProgressCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _EarnStats.from(context.watch<DriverProvider>().earnings);
    const double target = 25000;
    final progress = (stats.total / target).clamp(0.0, 1.0);
    final left = (target - stats.total).clamp(0.0, target);
    final pct = (progress * 100).toStringAsFixed(0);
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Monthly Goal',
            trailing: '$pct% Complete',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF0B5FFF).withValues(alpha: .10),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8A00)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _GoalMini(label: 'Target', value: stats.fmt(target), color: const Color(0xFF0B5FFF)),
              const SizedBox(width: 10),
              _GoalMini(label: 'Current', value: stats.fmt(stats.total), color: AppColors.success),
              const SizedBox(width: 10),
              _GoalMini(label: 'Left', value: stats.fmt(left), color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _GoalMini({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: .75),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsGraphCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _EarningsGraphCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _EarnStats.from(context.watch<DriverProvider>().earnings);
    final chartValues = stats.chart.every((v) => v == 0.0)
        ? [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
        : stats.chart;
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Weekly Breakdown',
            trailing: stats.fmt(stats.week),
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _EarningsGraphPainter(values: chartValues),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EarningsGraphPainter extends CustomPainter {
  final List<double> values;

  const _EarningsGraphPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: .08)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] * size.height);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final midX = (prev.dx + current.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, current.dy, current.dx, current.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B5FFF).withValues(alpha: .18),
            const Color(0xFF0B5FFF).withValues(alpha: .02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0B5FFF)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = const Color(0xFFFF8A00));
      canvas.drawCircle(
        p,
        9,
        Paint()..color = const Color(0xFFFF8A00).withValues(alpha: .12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EarningsGraphPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _ObcCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _ObcCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'One Bharat Coin',
            trailing: 'Driver Wallet',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _RewardMini(label: 'Balance', value: '425 OBC', color: Color(0xFFFF8A00)),
              _RewardMini(label: 'This Week', value: '+65 OBC', color: Color(0xFF0B5FFF)),
              _RewardMini(label: 'Redeemed', value: '150 OBC', color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _PerformanceCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Performance Score',
            trailing: 'Excellent',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _RewardMini(label: 'On Time', value: '96%', color: AppColors.success),
              _RewardMini(label: 'Rating', value: '4.9 ★', color: AppColors.warning),
              _RewardMini(label: 'Safety', value: '98%', color: Color(0xFF0B5FFF)),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncentivesCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _IncentivesCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Incentives',
            trailing: 'Bonus Active',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          _IncentiveRow(
            icon: Icons.bolt_rounded,
            title: 'Peak Hour Bonus',
            subtitle: '6 PM - 10 PM completion rewards',
            value: '+₹850',
            color: const Color(0xFFFF8A00),
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 10),
          _IncentiveRow(
            icon: Icons.weekend_rounded,
            title: 'Weekend Bonus',
            subtitle: 'Saturday and Sunday delivery streak',
            value: '+₹1,200',
            color: const Color(0xFF0B5FFF),
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 10),
          _IncentiveRow(
            icon: Icons.celebration_rounded,
            title: 'Festival Bonus',
            subtitle: 'Special logistics surge reward',
            value: '+₹500',
            color: AppColors.success,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
        ],
      ),
    );
  }
}

class _IncentiveRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color color;
  final Color textColor;
  final Color subTextColor;

  const _IncentiveRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SoftIcon(icon: icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _WithdrawCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _WithdrawCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _EarnStats.from(context.watch<DriverProvider>().earnings);
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _SoftIcon(
            icon: Icons.account_balance_rounded,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.fmt(stats.total)} Available',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Withdraw to linked bank account',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SmallButton(
            label: 'Withdraw',
            color: AppColors.success,
            onTap: () => HapticFeedback.mediumImpact(),
          ),
        ],
      ),
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final List<_TransactionData>? live;

  const _TransactionsCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    this.live,
  });

  @override
  Widget build(BuildContext context) {
    final items = live ?? const <_TransactionData>[];
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Recent Transactions',
            trailing: 'View All',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No transactions yet',
                  style: TextStyle(color: subTextColor, fontSize: 13)),
            ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TransactionRow(
                item: item,
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final _TransactionData item;
  final Color textColor;
  final Color subTextColor;

  const _TransactionRow({
    required this.item,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.credit ? AppColors.success : AppColors.error;

    return Row(
      children: [
        _SoftIcon(icon: item.icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.amount,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              item.time,
              style: TextStyle(
                color: subTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color surfaceColor;

  const _ClayCard({
    required this.child,
    required this.surfaceColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .05)
              : const Color(0xFFDFEAFF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .24 : .075),
            blurRadius: 22,
            offset: const Offset(10, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: dark ? .03 : .92),
            blurRadius: 18,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ClayButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _ClayButton({
    required this.icon,
    required this.color,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: color.withValues(alpha: .14)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SoftIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RewardMini({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 58) / 3,
      constraints: const BoxConstraints(minWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: .75),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String trailing;
  final Color textColor;
  final Color subTextColor;

  const _CardTitle({
    required this.title,
    required this.trailing,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            trailing,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: .22)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, color: AppColors.success, size: 15),
          SizedBox(width: 6),
          Text(
            '+12% VS LAST MONTH',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsBackground extends StatelessWidget {
  const _EarningsBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _EarningsBackgroundPainter(
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _EarningsBackgroundPainter extends CustomPainter {
  final bool dark;

  const _EarningsBackgroundPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: dark ? .08 : .06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(-20, size.height * .16)
      ..cubicTo(size.width * .25, size.height * .08, size.width * .60,
          size.height * .30, size.width + 20, size.height * .18);

    final p2 = Path()
      ..moveTo(size.width + 20, size.height * .64)
      ..cubicTo(size.width * .70, size.height * .52, size.width * .42,
          size.height * .80, -20, size.height * .72);

    canvas.drawPath(p1, routePaint);
    canvas.drawPath(p2, routePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: dark ? .10 : .15);

    for (int i = 0; i < 18; i++) {
      final x = ((i * 53) % size.width).toDouble();
      final y = (55 + ((i * 97) % size.height)).toDouble();
      canvas.drawCircle(Offset(x, y), 2.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EarningsBackgroundPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData(this.label, this.value, this.icon, this.color);
}

class _TransactionData {
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final bool credit;
  final IconData icon;

  const _TransactionData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.credit,
    required this.icon,
  });
}