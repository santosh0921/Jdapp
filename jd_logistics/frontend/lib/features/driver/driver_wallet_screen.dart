import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/utils/helpers.dart';
import 'package:jd_style_logistics/services/driver_service.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  late final AnimationController _entryController;
  late final AnimationController _coinController;

  static const List<_Payout> _payouts = [
    _Payout(
      id: 'PY-001',
      title: 'Delivery Payout',
      subtitle: '8 deliveries · Wed 18 Jun',
      date: 'Today',
      amount: 1240.0,
      obc: 18,
      type: 'delivery',
      status: 'Settled',
    ),
    _Payout(
      id: 'PY-002',
      title: 'Performance Bonus',
      subtitle: 'Top driver this week',
      date: 'Yesterday',
      amount: 500.0,
      obc: 25,
      type: 'bonus',
      status: 'Settled',
    ),
    _Payout(
      id: 'PY-003',
      title: 'Surge Earnings',
      subtitle: 'Peak hour multiplier ×1.5',
      date: '16 Jun',
      amount: 360.0,
      obc: 10,
      type: 'surge',
      status: 'Settled',
    ),
    _Payout(
      id: 'PY-004',
      title: 'Delivery Payout',
      subtitle: '6 deliveries · Mon 16 Jun',
      date: '16 Jun',
      amount: 930.0,
      obc: 14,
      type: 'delivery',
      status: 'Settled',
    ),
    _Payout(
      id: 'PY-005',
      title: 'Weekly Bonus',
      subtitle: 'Completed 40+ deliveries',
      date: '14 Jun',
      amount: 750.0,
      obc: 40,
      type: 'bonus',
      status: 'Pending',
    ),
    _Payout(
      id: 'PY-006',
      title: 'Delivery Payout',
      subtitle: '5 deliveries · Sat 14 Jun',
      date: '14 Jun',
      amount: 775.0,
      obc: 11,
      type: 'delivery',
      status: 'Settled',
    ),
  ];

  Map<String, dynamic>? _walletData;

  double get _settledBalance =>
      (_walletData?['balance'] as num?)?.toDouble() ??
      _payouts.where((p) => p.status == 'Settled').fold(0.0, (sum, item) => sum + item.amount);

  double get _pendingBalance =>
      (_walletData?['pending_balance'] as num?)?.toDouble() ??
      _payouts.where((p) => p.status == 'Pending').fold(0.0, (sum, item) => sum + item.amount);

  int get _obcBalance =>
      (_walletData?['obc_points'] as num?)?.toInt() ??
      _payouts.where((p) => p.status == 'Settled').fold(0, (s, p) => s + p.obc);

  @override
  void initState() {
    super.initState();

    _tabs = TabController(length: 4, vsync: this);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final data = await DriverService.instance.getWallet();
    if (!mounted || data.isEmpty) return;
    setState(() => _walletData = data);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _entryController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  List<_Payout> _filtered(String type) {
    if (type == 'all') return _payouts;
    if (type == 'bonus') {
      return _payouts.where((p) => p.type == 'bonus' || p.type == 'surge').toList();
    }
    if (type == 'obc') {
      return _payouts.where((p) => p.obc > 0).toList();
    }
    return _payouts.where((p) => p.type == type).toList();
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
            const _WalletBackground(),
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
                    child: NestedScrollView(
                      physics: const BouncingScrollPhysics(),
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                              child: Column(
                                children: [
                                  _WalletHeroCard(
                                    balance: _settledBalance,
                                    pending: _pendingBalance,
                                    obcBalance: _obcBalance,
                                    coinController: _coinController,
                                    textColor: _text(context),
                                    subTextColor: _sub(context),
                                    surfaceColor: _surface(context),
                                  ),
                                  const SizedBox(height: 14),
                                  _WalletStatsGrid(
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
                                  _ObcRedeemCard(
                                    textColor: _text(context),
                                    subTextColor: _sub(context),
                                    surfaceColor: _surface(context),
                                  ),
                                  const SizedBox(height: 14),
                                  _TabsCard(
                                    controller: _tabs,
                                    surfaceColor: _surface(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _tabs,
                        children: [
                          _PayoutList(
                            payouts: _filtered('all'),
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          _PayoutList(
                            payouts: _filtered('delivery'),
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          _PayoutList(
                            payouts: _filtered('bonus'),
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          _PayoutList(
                            payouts: _filtered('obc'),
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
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
                    'One Bharat Coin Enabled',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Driver Wallet',
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
            icon: Icons.account_balance_rounded,
            color: AppColors.success,
            surfaceColor: surfaceColor,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _WalletHeroCard extends StatelessWidget {
  final double balance;
  final double pending;
  final int obcBalance;
  final AnimationController coinController;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _WalletHeroCard({
    required this.balance,
    required this.pending,
    required this.obcBalance,
    required this.coinController,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
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
                  const _WalletPill(),
                  const SizedBox(height: 12),
                  Text(
                    Helpers.formatCurrency(balance),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Available balance',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: AppColors.warning.withValues(alpha: .95),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${Helpers.formatCurrency(pending)} pending',
                        style: TextStyle(
                          color: AppColors.warning.withValues(alpha: .95),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _CoinAvatar(
            obcBalance: obcBalance,
            coinController: coinController,
          ),
        ],
      ),
    );
  }
}

class _CoinAvatar extends StatelessWidget {
  final int obcBalance;
  final AnimationController coinController;

  const _CoinAvatar({
    required this.obcBalance,
    required this.coinController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: coinController,
      builder: (context, _) {
        final lift = math.sin(coinController.value * math.pi * 2) * 4;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Container(
            height: 112,
            width: 98,
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
                  top: 15,
                  child: Container(
                    height: 38,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5FFF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '$obcBalance OBC',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
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

class _WalletStatsGrid extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _WalletStatsGrid({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40) / 2;

    final items = [
      _MetricData('This Week', '₹3,555', Icons.date_range_rounded, const Color(0xFF0B5FFF)),
      _MetricData('Deliveries', '19', Icons.local_shipping_rounded, AppColors.success),
      _MetricData('Avg / Trip', '₹187', Icons.route_rounded, AppColors.warning),
      _MetricData('OBC Earned', '+108', Icons.monetization_on_rounded, const Color(0xFFFF8A00)),
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
                    'Withdraw to Bank',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Account ending 4521 • Instant payout eligible',
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

class _ObcRedeemCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _ObcRedeemCard({
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
            trailing: 'Redeem Rewards',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RewardBox(
                label: 'Balance',
                value: '108 OBC',
                color: const Color(0xFFFF8A00),
              ),
              const SizedBox(width: 10),
              _RewardBox(
                label: 'Redeemed',
                value: '150 OBC',
                color: const Color(0xFF0B5FFF),
              ),
              const SizedBox(width: 10),
              _RewardBox(
                label: 'Bonus',
                value: '+40 OBC',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabsCard extends StatelessWidget {
  final TabController controller;
  final Color surfaceColor;

  const _TabsCard({
    required this.controller,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(5),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF0B5FFF),
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        indicator: BoxDecoration(
          color: const Color(0xFF0B5FFF).withValues(alpha: .12),
          borderRadius: BorderRadius.circular(15),
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Deliveries'),
          Tab(text: 'Bonuses'),
          Tab(text: 'OBC'),
        ],
      ),
    );
  }
}

class _PayoutList extends StatelessWidget {
  final List<_Payout> payouts;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _PayoutList({
    required this.payouts,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
      itemCount: payouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _PayoutCard(
          payout: payouts[index],
          textColor: textColor,
          subTextColor: subTextColor,
          surfaceColor: surfaceColor,
        );
      },
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final _Payout payout;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _PayoutCard({
    required this.payout,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  Color get _typeColor {
    switch (payout.type) {
      case 'bonus':
        return AppColors.success;
      case 'surge':
        return AppColors.warning;
      default:
        return const Color(0xFF0B5FFF);
    }
  }

  IconData get _typeIcon {
    switch (payout.type) {
      case 'bonus':
        return Icons.emoji_events_rounded;
      case 'surge':
        return Icons.bolt_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settled = payout.status == 'Settled';

    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _SoftIcon(icon: _typeIcon, color: _typeColor),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payout.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    payout.subtitle,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        size: 13,
                        color: const Color(0xFFFF8A00).withValues(alpha: .95),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${payout.obc} OBC',
                        style: const TextStyle(
                          color: Color(0xFFFF8A00),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
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
                '+${Helpers.formatCurrency(payout.amount)}',
                style: TextStyle(
                  color: _typeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: settled
                      ? AppColors.success.withValues(alpha: .12)
                      : AppColors.warning.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payout.status,
                  style: TextStyle(
                    color: settled ? AppColors.success : AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                payout.date,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
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

class _RewardBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RewardBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
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

class _WalletPill extends StatelessWidget {
  const _WalletPill();

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
          Icon(Icons.verified_rounded, color: AppColors.success, size: 15),
          SizedBox(width: 6),
          Text(
            'SETTLEMENT READY',
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

class _WalletBackground extends StatelessWidget {
  const _WalletBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WalletBackgroundPainter(
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _WalletBackgroundPainter extends CustomPainter {
  final bool dark;

  const _WalletBackgroundPainter({required this.dark});

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
  bool shouldRepaint(covariant _WalletBackgroundPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData(this.label, this.value, this.icon, this.color);
}

class _Payout {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final double amount;
  final int obc;
  final String type;
  final String status;

  const _Payout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.obc,
    required this.type,
    required this.status,
  });
}