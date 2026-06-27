import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/models/payment_model.dart';
import 'package:jd_style_logistics/services/payment_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  List<PaymentTransactionModel> _txList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await PaymentService.instance.getHistory();
      if (!mounted) return;
      setState(() { _txList = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  bool _isCredit(PaymentTransactionModel t) =>
      t.type == 'credit' || t.type == 'refund' || t.type == 'wallet_credit';

  List<PaymentTransactionModel> _filtered(String type) {
    if (type == 'All') return _txList;
    if (type == 'Credit') return _txList.where(_isCredit).toList();
    return _txList.where((t) => !_isCredit(t)).toList();
  }

  double get _totalSpent =>
      _txList.where((t) => !_isCredit(t)).fold(0.0, (s, t) => s + t.amount);

  double get _totalReceived =>
      _txList.where(_isCredit).fold(0.0, (s, t) => s + t.amount);

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
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
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
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _error != null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.white38),
                      const SizedBox(height: 12),
                      const Text('Failed to load history',
                          style: TextStyle(
                              color: Colors.white70, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(_error!,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadHistory,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Retry'),
                      ),
                    ]),
                  )
                : Column(
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
                                  value: '${_txList.length}',
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
  final List<PaymentTransactionModel> items;
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
  final PaymentTransactionModel t;
  const _TxCard({required this.t});

  bool get _isCredit =>
      t.type == 'credit' || t.type == 'refund' || t.type == 'wallet_credit';

  IconData get _icon {
    final tp = t.type.toLowerCase();
    if (tp.contains('refund')) return Icons.replay_rounded;
    if (tp.contains('wallet') || tp.contains('top')) return Icons.account_balance_wallet_rounded;
    if (tp.contains('promo') || tp.contains('gift')) return Icons.card_giftcard_rounded;
    if (t.method.toLowerCase() == 'card') return Icons.credit_card_rounded;
    return Icons.local_shipping_rounded;
  }

  String _fmtDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${_twoDigit(dt.hour)}:${_twoDigit(dt.minute)}';
  }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final amountColor = _isCredit ? AppColors.success : AppColors.error;
    final sign = _isCredit ? '+' : '−';
    final title = t.description?.isNotEmpty == true
        ? t.description!
        : t.shipmentId?.isNotEmpty == true
            ? 'Shipment ${t.shipmentId}'
            : t.type.replaceAll('_', ' ').toUpperCase();

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
            child: Icon(_icon, color: amountColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(t.reference ?? t.id,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(_fmtDate(t.createdAt),
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
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      );
}
