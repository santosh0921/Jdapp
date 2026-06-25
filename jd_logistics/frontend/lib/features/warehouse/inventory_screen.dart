import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _selectedCategory = 0;

  static const _categories = [
    'All', 'Electronics', 'Apparel', 'Documents', 'Fragile', 'Perishable',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _selectedCategory == 0
        ? _items
        : _items
            .where((i) => i['category'] == _categories[_selectedCategory])
            .toList();

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
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.category_rounded,
                            color: AppColors.saffron, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Inventory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    const Row(
                      children: [
                        _HeroChip(label: 'Total', value: '1,248'),
                        SizedBox(width: 10),
                        _HeroChip(label: 'In Stock', value: '1,102', positive: true),
                        SizedBox(width: 10),
                        _HeroChip(label: 'Low Stock', value: '46', warn: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category chips ─────────────────────────────────────────────
          Container(
            color: isDark ? AppColors.darkBg2 : Colors.white,
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedCategory == i
                        ? AppColors.primary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.07)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _categories[i],
                    style: TextStyle(
                      color: _selectedCategory == i
                          ? Colors.white
                          : (isDark
                              ? Colors.white70
                              : AppColors.primary),
                      fontSize: 13,
                      fontWeight: _selectedCategory == i
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Items list ─────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color: isDark
                                ? Colors.white24
                                : AppColors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 14),
                        Text(
                          'No items in this category',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : AppColors.textDarkSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _ItemRow(data: filtered[i], isDark: isDark),
                  ),
          ),
        ],
      ),
    );
  }

  static const _items = [
    {
      'sku': 'SKU-1001',
      'name': 'Laptop Bag 15"',
      'category': 'Apparel',
      'qty': '82',
      'status': 'In Stock',
    },
    {
      'sku': 'SKU-1002',
      'name': 'USB-C Hub (7-in-1)',
      'category': 'Electronics',
      'qty': '14',
      'status': 'Low Stock',
    },
    {
      'sku': 'SKU-1003',
      'name': 'Bubble Wrap Roll 50m',
      'category': 'Fragile',
      'qty': '230',
      'status': 'In Stock',
    },
    {
      'sku': 'SKU-1004',
      'name': 'A4 Document Box',
      'category': 'Documents',
      'qty': '0',
      'status': 'Out of Stock',
    },
    {
      'sku': 'SKU-1005',
      'name': 'Smartphone Case',
      'category': 'Electronics',
      'qty': '47',
      'status': 'In Stock',
    },
    {
      'sku': 'SKU-1006',
      'name': 'Refrigerated Pack',
      'category': 'Perishable',
      'qty': '8',
      'status': 'Low Stock',
    },
    {
      'sku': 'SKU-1007',
      'name': 'Cotton T-Shirt (M)',
      'category': 'Apparel',
      'qty': '150',
      'status': 'In Stock',
    },
    {
      'sku': 'SKU-1008',
      'name': 'Wireless Earbuds',
      'category': 'Electronics',
      'qty': '0',
      'status': 'Out of Stock',
    },
  ];
}

class _HeroChip extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;
  final bool warn;

  const _HeroChip({
    required this.label,
    required this.value,
    this.positive = false,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warn
        ? AppColors.saffron
        : positive
            ? AppColors.warehouseColor
            : Colors.white70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final Map<String, String> data;
  final bool isDark;

  const _ItemRow({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(data['status']!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name']!,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${data['sku']}  ·  ${data['category']}',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white54
                          : AppColors.textDarkSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Qty: ${data['qty']}',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data['status']!,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'In Stock':
        return AppColors.warehouseColor;
      case 'Low Stock':
        return AppColors.saffron;
      default:
        return AppColors.error;
    }
  }
}
