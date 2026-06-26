import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _PayRecord {
  final String id;
  final String customer;
  final String shipmentId;
  final String method;
  final double amount;
  final String status; // Settled / Pending / Refunded
  final String date;
  final bool isDriver; // driver payout vs customer payment

  const _PayRecord({
    required this.id,
    required this.customer,
    required this.shipmentId,
    required this.method,
    required this.amount,
    required this.status,
    required this.date,
    this.isDriver = false,
  });
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  bool _isLoading = true;
  String? _loadError;
  List<_PayRecord> _liveRecords = [];

  List<_PayRecord> get _records => _liveRecords;

  double get _revenue => _records
      .where((r) => !r.isDriver && r.status == 'Settled')
      .fold(0, (s, r) => s + r.amount);

  double get _pending => _records
      .where((r) => r.isDriver && r.status == 'Pending')
      .fold(0, (s, r) => s + r.amount);

  double get _month => _records
      .where((r) => !r.isDriver)
      .fold(0, (s, r) => s + r.amount);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() { _isLoading = true; _loadError = null; });
    try {
      final data = await AdminService.instance.getPayments();
      if (!mounted) return;
      setState(() {
        _liveRecords = data.map((m) {
          final isDriver = m['is_driver_payout'] == true || m['type'] == 'driver_payout';
          final raw = m['status']?.toString() ?? 'pending';
          final status = raw[0].toUpperCase() + raw.substring(1);
          return _PayRecord(
            id: m['id']?.toString() ?? m['payment_id']?.toString() ?? 'PAY',
            customer: m['customer_name']?.toString() ?? m['name']?.toString() ?? '—',
            shipmentId: m['order_id']?.toString() ?? m['shipment_id']?.toString() ?? '—',
            method: m['payment_method']?.toString() ?? m['method']?.toString() ?? '—',
            amount: (m['amount'] as num? ?? 0).toDouble(),
            status: status,
            date: (m['created_at']?.toString() ?? '').isNotEmpty
                ? m['created_at'].toString().substring(0, 10)
                : '—',
            isDriver: isDriver,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loadError = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<_PayRecord> _filtered(String f) {
    if (f == 'All') return _records;
    if (f == 'Customer') return _records.where((r) => !r.isDriver).toList();
    return _records.where((r) => r.isDriver).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.white54),
              const SizedBox(height: 16),
              const Text('Could not load payments', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_loadError!, style: const TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPayments,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Payments',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, color: Colors.white),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: AppColors.adminColor,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Customer'),
              Tab(text: 'Driver Payout'),
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
                    _PayStat(
                      label: "Today's Revenue",
                      value: '₹${_revenue.toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),
                    Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.2)),
                    _PayStat(
                      label: 'Pending Payouts',
                      value: '₹${_pending.toStringAsFixed(0)}',
                      color: AppColors.warning,
                    ),
                    Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.2)),
                    _PayStat(
                      label: 'Total Month',
                      value: '₹${_month.toStringAsFixed(0)}',
                      color: AppColors.adminColor,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _PayList(items: _filtered('All')),
                  _PayList(items: _filtered('Customer')),
                  _PayList(items: _filtered('Driver')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayList extends StatelessWidget {
  final List<_PayRecord> items;
  const _PayList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No records',
            style: TextStyle(color: Colors.white54, fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _PayCard(r: items[i]),
    );
  }
}

class _PayCard extends StatelessWidget {
  final _PayRecord r;
  const _PayCard({required this.r});

  static Color _statusColor(String s) {
    switch (s) {
      case 'Settled':
        return AppColors.success;
      case 'Refunded':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(r.status);
    final roleColor =
        r.isDriver ? AppColors.driverColor : AppColors.customerColor;
    final roleIcon =
        r.isDriver ? Icons.motorcycle_rounded : Icons.person_rounded;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(roleIcon, color: roleColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r.id,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    Text(r.shipmentId,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(r.customer,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(r.date,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(r.method,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${r.amount.toStringAsFixed(0)}',
                style: TextStyle(
                    color: r.isDriver ? AppColors.warning : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(r.status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PayStat(
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
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      );
}
