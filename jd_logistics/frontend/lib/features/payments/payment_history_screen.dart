import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _TxData {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final double amount;
  final bool isCredit;
  final String method;
  final IconData icon;

  const _TxData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.method,
    required this.icon,
  });
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _transactions = [
    _TxData(id: 'TXN-5501', title: 'Shipment JD-24101', subtitle: 'Mumbai → Delhi · Road', date: 'Jun 17, 2:30 PM', amount: 850, isCredit: false, method: 'UPI', icon: Icons.local_shipping_rounded),
    _TxData(id: 'TXN-5502', title: 'Refund: JD-24089', subtitle: 'Cancelled shipment refund', date: 'Jun 16, 11:15 AM', amount: 320, isCredit: true, method: 'UPI', icon: Icons.replay_rounded),
    _TxData(id: 'TXN-5503', title: 'Shipment JD-24102', subtitle: 'Bengaluru → Dubai · Air', date: 'Jun 15, 4:00 PM', amount: 4250, isCredit: false, method: 'Card', icon: Icons.flight_rounded),
    _TxData(id: 'TXN-5504', title: 'Wallet Top-up', subtitle: 'Added to JD Wallet', date: 'Jun 14, 9:45 AM', amount: 2000, isCredit: true, method: 'Net Banking', icon: Icons.account_balance_wallet_rounded),
    _TxData(id: 'TXN-5505', title: 'Shipment JD-24096', subtitle: 'Chennai → Singapore · Ocean', date: 'Jun 12, 1:20 PM', amount: 12800, isCredit: false, method: 'Card', icon: Icons.directions_boat_rounded),
    _TxData(id: 'TXN-5506', title: 'Promo Credit', subtitle: 'First International Saver applied', date: 'Jun 12, 1:20 PM', amount: 1920, isCredit: true, method: 'Promo', icon: Icons.card_giftcard_rounded),
    _TxData(id: 'TXN-5507', title: 'Shipment JD-24088', subtitle: 'Delhi → Kolkata · Road', date: 'Jun 10, 8:00 AM', amount: 540, isCredit: false, method: 'COD', icon: Icons.local_shipping_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<_TxData> _filtered(String type) {
    if (type == 'All') return _transactions;
    if (type == 'Credit') return _transactions.where((t) => t.isCredit).toList();
    return _transactions.where((t) => !t.isCredit).toList();
  }

  double get _totalSpent => _transactions
      .where((t) => !t.isCredit)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalReceived => _transactions
      .where((t) => t.isCredit)
      .fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Payment History',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded,
                    color: Colors.white)),
          ],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: AppColors.customerColor,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Credit'),
              Tab(text: 'Debit'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SumStat(
                        label: 'Total Spent',
                        value: '₹${_totalSpent.toStringAsFixed(0)}',
                        color: AppColors.error),
                    Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.2)),
                    _SumStat(
                        label: 'Total Received',
                        value: '₹${_totalReceived.toStringAsFixed(0)}',
                        color: AppColors.success),
                    Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.2)),
                    _SumStat(
                        label: 'Transactions',
                        value: '${_transactions.length}',
                        color: AppColors.primary),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _TxList(items: _filtered('All')),
                  _TxList(items: _filtered('Credit')),
                  _TxList(items: _filtered('Debit')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxList extends StatelessWidget {
  final List<_TxData> items;
  const _TxList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No transactions',
            style: TextStyle(color: Colors.white54, fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TxCard(t: items[i]),
    );
  }
}

class _TxCard extends StatelessWidget {
  final _TxData t;
  const _TxCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final amountColor = t.isCredit ? AppColors.success : AppColors.error;
    final sign = t.isCredit ? '+' : '−';

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(t.icon, color: amountColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const SizedBox(height: 3),
                Text(t.subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(t.date,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(t.method,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 9)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$sign₹${t.amount.toStringAsFixed(0)}',
            style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w900,
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SumStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SumStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      );
}
