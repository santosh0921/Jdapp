import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
          // ── Hero ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF162233), Color(0xFF001A6E), Color(0xFF003EAA)],
              ),
            ),
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment_return_rounded,
                            color: AppColors.error, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Returns',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _HeroChip(
                            label: 'Total Returns', value: '12', color: AppColors.error),
                        SizedBox(width: 10),
                        _HeroChip(
                            label: 'Pending Review', value: '5', color: AppColors.saffron),
                        SizedBox(width: 10),
                        _HeroChip(
                            label: 'Re-shelved', value: '7', color: AppColors.warehouseColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // Summary card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RETURN REASONS',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppColors.textDarkSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ReasonBar(
                          reason: 'Damaged in Transit',
                          count: 5,
                          total: 12,
                          color: AppColors.error,
                          isDark: isDark),
                      const SizedBox(height: 10),
                      _ReasonBar(
                          reason: 'Wrong Item',
                          count: 3,
                          total: 12,
                          color: AppColors.saffron,
                          isDark: isDark),
                      const SizedBox(height: 10),
                      _ReasonBar(
                          reason: 'Customer Refused',
                          count: 2,
                          total: 12,
                          color: AppColors.primary,
                          isDark: isDark),
                      const SizedBox(height: 10),
                      _ReasonBar(
                          reason: 'Address Not Found',
                          count: 2,
                          total: 12,
                          color: AppColors.textDarkSecondary,
                          isDark: isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Return Items',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                ..._returns.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReturnCard(data: r, isDark: isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _returns = [
    {
      'id': 'RET-001',
      'parcel': 'JD-2024-087',
      'reason': 'Damaged in Transit',
      'customer': 'Anil Kumar',
      'date': '17 Jun 2026',
      'status': 'Pending Review',
      'item': 'USB-C Hub (7-in-1)',
    },
    {
      'id': 'RET-002',
      'parcel': 'JD-2024-081',
      'reason': 'Wrong Item',
      'customer': 'Priya Sharma',
      'date': '16 Jun 2026',
      'status': 'Re-shelved',
      'item': 'Cotton T-Shirt (M)',
    },
    {
      'id': 'RET-003',
      'parcel': 'JD-2024-075',
      'reason': 'Customer Refused',
      'customer': 'Rahul Mehta',
      'date': '15 Jun 2026',
      'status': 'Pending Review',
      'item': 'Wireless Earbuds',
    },
    {
      'id': 'RET-004',
      'parcel': 'JD-2024-069',
      'reason': 'Address Not Found',
      'customer': 'Sunita Rao',
      'date': '14 Jun 2026',
      'status': 'Re-shelved',
      'item': 'Laptop Bag 15"',
    },
    {
      'id': 'RET-005',
      'parcel': 'JD-2024-061',
      'reason': 'Damaged in Transit',
      'customer': 'Deepak Joshi',
      'date': '13 Jun 2026',
      'status': 'Pending Review',
      'item': 'Smartphone Case',
    },
  ];
}

class _HeroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ReasonBar extends StatelessWidget {
  final String reason;
  final int count;
  final int total;
  final Color color;
  final bool isDark;

  const _ReasonBar({
    required this.reason,
    required this.count,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _ReturnCard extends StatelessWidget {
  final Map<String, String> data;
  final bool isDark;

  const _ReturnCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPending = data['status'] == 'Pending Review';
    final statusColor = isPending ? AppColors.saffron : AppColors.warehouseColor;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_return_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['id']!,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data['parcel']!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : AppColors.textDarkSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['status']!,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow('Item', data['item']!, isDark),
          _InfoRow('Customer', data['customer']!, isDark),
          _InfoRow('Reason', data['reason']!, isDark,
              valueColor: AppColors.error),
          _InfoRow('Date', data['date']!, isDark),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => HapticFeedback.mediumImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.warehouseColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.warehouseColor
                                .withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shelves,
                              color: AppColors.warehouseColor, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Re-shelf',
                            style: TextStyle(
                              color: AppColors.warehouseColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: AppColors.error, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Discard',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, this.isDark, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ??
                    (isDark ? Colors.white : AppColors.textDark),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
