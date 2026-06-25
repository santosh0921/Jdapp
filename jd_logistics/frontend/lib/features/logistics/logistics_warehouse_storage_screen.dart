import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import '../../core/data/logistics_mock_data.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kCyan = Color(0xFF06B6D4);

class LogisticsWarehouseStorageScreen extends StatefulWidget {
  const LogisticsWarehouseStorageScreen({super.key});
  @override
  State<LogisticsWarehouseStorageScreen> createState() => _LogisticsWarehouseStorageScreenState();
}

class _LogisticsWarehouseStorageScreenState extends State<LogisticsWarehouseStorageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _selectedCity = 'All Cities';
  String _storageType = 'All Types';
  LWarehouse? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.darkBg1 : const Color(0xFFF0F4F8);
    final card = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? AppColors.textWhite : _kNavy;
    final textSub = isDark ? AppColors.darkSubtext : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textPrimary), onPressed: () => context.pop()),
        title: Text('Warehouse & Storage', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        bottom: TabBar(
          controller: _tab,
          labelColor: _kCyan,
          unselectedLabelColor: textSub,
          indicatorColor: _kCyan,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Find Warehouse'),
            Tab(text: 'My Storage'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildFindWarehouse(isDark, card, textPrimary, textSub),
          _buildMyStorage(isDark, card, textPrimary, textSub),
          _buildServices(isDark, card, textPrimary, textSub),
        ],
      ),
    );
  }

  // ── Tab 1: Find Warehouse ─────────────────────────────────────────────────

  Widget _buildFindWarehouse(bool isDark, Color card, Color textPrimary, Color textSub) {
    final warehouses = LogisticsMockData.warehouses;
    final cities = ['All Cities', ...warehouses.map((w) => w.city).toSet()];
    final types = ['All Types', 'Cold Storage', 'Bonded', 'Hazmat', 'ICD'];

    final filtered = warehouses.where((w) {
      final cityMatch = _selectedCity == 'All Cities' || w.city == _selectedCity;
      final typeMap = {'Cold Storage': 'cold_storage', 'Bonded': 'bonded', 'Hazmat': 'hazmat', 'ICD': 'ICD'};
      final typeMatch = _storageType == 'All Types' || w.features.contains(typeMap[_storageType] ?? '');
      return cityMatch && typeMatch;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          _buildStatsRow(isDark, card, textPrimary, textSub),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(child: _filterDrop(value: _selectedCity, items: cities, isDark: isDark, card: card, textPrimary: textPrimary, onChanged: (v) => setState(() => _selectedCity = v ?? 'All Cities'))),
              const SizedBox(width: 10),
              Expanded(child: _filterDrop(value: _storageType, items: types, isDark: isDark, card: card, textPrimary: textPrimary, onChanged: (v) => setState(() => _storageType = v ?? 'All Types'))),
            ],
          ),
          const SizedBox(height: 16),

          Text('${filtered.length} warehouses found', style: TextStyle(color: textSub, fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          ...filtered.map((w) => _buildWarehouseCard(w, isDark, card, textPrimary, textSub)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, Color card, Color textPrimary, Color textSub) {
    final stats = [
      {'label': 'Warehouses', 'value': '10', 'color': _kCyan},
      {'label': 'Total Sq Ft', 'value': '1.88M', 'color': _kTeal},
      {'label': 'Available', 'value': '49%', 'color': const Color(0xFF22C55E)},
    ];
    return Row(
      children: stats.asMap().entries.map((e) {
        final s = e.value;
        final color = s['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: e.key < stats.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.15)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Text(s['value'] as String, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 2),
                Text(s['label'] as String, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWarehouseCard(LWarehouse w, bool isDark, Color card, Color textPrimary, Color textSub) {
    final occupancy = ((w.totalCapacity - w.availableCapacity) / w.totalCapacity * 100).round();
    final featureLabels = {'cold_storage': '❄️ Cold', 'bonded': '🔒 Bonded', 'ICD': '🏭 ICD', 'hazmat': '☣️ Hazmat'};
    final isSelected = _selectedWarehouse?.code == w.code;

    return GestureDetector(
      onTap: () => setState(() => _selectedWarehouse = isSelected ? null : w),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _kCyan.withValues(alpha: 0.07) : card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _kCyan : Colors.transparent, width: isSelected ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warehouse_outlined, color: _kCyan, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(w.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13))),
                Text('₹${w.ratePerSqFtPerDay}/sqft/day', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: textSub),
                const SizedBox(width: 4),
                Text('${w.city}, ${w.state}', style: TextStyle(color: textSub, fontSize: 12)),
                const SizedBox(width: 10),
                Text('Code: ${w.code}', style: TextStyle(color: textSub, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            // Occupancy bar
            Row(
              children: [
                Text('Occupancy: $occupancy%', style: TextStyle(color: textSub, fontSize: 11)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: occupancy / 100,
                      backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(occupancy > 80 ? const Color(0xFFEF4444) : occupancy > 60 ? const Color(0xFFF59E0B) : _kTeal),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(w.availableCapacity / 1000).toStringAsFixed(0)}K free', style: TextStyle(color: _kTeal, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: w.features.map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _kCyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(featureLabels[f] ?? f, style: const TextStyle(color: _kCyan, fontSize: 10, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Storage request sent to ${w.name}'),
                    backgroundColor: _kCyan,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kCyan, _kTeal]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('Book Storage Space', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Tab 2: My Storage ─────────────────────────────────────────────────────

  Widget _buildMyStorage(bool isDark, Color card, Color textPrimary, Color textSub) {
    final myStorage = [
      {'wh': 'JD Hub Mumbai Central', 'space': '2,400', 'goods': 'Steel Coils', 'since': '01 Dec', 'expiry': '31 Dec', 'bill': '₹43,200'},
      {'wh': 'JD Hub Delhi NCR', 'space': '800', 'goods': 'Electronics', 'since': '08 Dec', 'expiry': '08 Jan', 'bill': '₹16,000'},
    ];
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCyan.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCyan.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.inventory_2_outlined, color: _kCyan, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Active Storage: 2 locations', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Total space in use: 3,200 sq ft', style: TextStyle(color: textSub, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        ...myStorage.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['wh']!, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              _storageRow('Goods', s['goods']!, textSub, textPrimary),
              _storageRow('Space', '${s['space']} sq ft', textSub, textPrimary),
              _storageRow('Since', s['since']!, textSub, textPrimary),
              _storageRow('Expiry', s['expiry']!, textSub, textPrimary),
              const Divider(height: 16),
              Row(children: [
                Expanded(child: Text('Monthly Bill', style: TextStyle(color: textSub, fontSize: 13))),
                Text(s['bill']!, style: const TextStyle(color: _kCyan, fontWeight: FontWeight.w800, fontSize: 15)),
              ]),
            ],
          ),
        )),
      ],
    );
  }

  Widget _storageRow(String label, String value, Color textSub, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(width: 70, child: Text(label, style: TextStyle(color: textSub, fontSize: 12))),
        Text(value, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Tab 3: Services ───────────────────────────────────────────────────────

  Widget _buildServices(bool isDark, Color card, Color textPrimary, Color textSub) {
    final services = [
      {'title': 'Cross Docking', 'desc': 'Transfer goods from inbound to outbound without storage. Same-day processing.', 'icon': Icons.compare_arrows_outlined, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Cold Chain Storage', 'desc': 'Temperature-controlled storage 2°C–8°C and -18°C for frozen goods.', 'icon': Icons.ac_unit_outlined, 'color': const Color(0xFF06B6D4)},
      {'title': 'Bonded Warehouse', 'desc': 'Store imported goods before customs clearance. Duty deferred storage.', 'icon': Icons.lock_outlined, 'color': const Color(0xFFF59E0B)},
      {'title': 'Container Yard (CY)', 'desc': 'Empty and laden container storage near JNPT and Chennai Port.', 'icon': Icons.inventory_2_outlined, 'color': _kTeal},
      {'title': 'Inventory Management', 'desc': 'Real-time stock tracking, pick-pack-ship, barcode scanning.', 'icon': Icons.inventory_outlined, 'color': const Color(0xFF22C55E)},
      {'title': 'Hazmat Storage', 'desc': 'Certified facilities for hazardous and dangerous goods (Class 1–9).', 'icon': Icons.warning_amber_outlined, 'color': const Color(0xFFEF4444)},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: services.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (s['color'] as Color).withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: (s['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['title'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(s['desc'] as String, style: TextStyle(color: textSub, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Request Service →', style: TextStyle(color: s['color'] as Color, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _filterDrop({required String value, required List<String> items, required bool isDark, required Color card, required Color textPrimary, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
