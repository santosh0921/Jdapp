import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import '../../core/data/logistics_mock_data.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kBlue = Color(0xFF3B82F6);

class LogisticsImportScreen extends StatefulWidget {
  const LogisticsImportScreen({super.key});
  @override
  State<LogisticsImportScreen> createState() => _LogisticsImportScreenState();
}

class _LogisticsImportScreenState extends State<LogisticsImportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Form state
  String _originCountry = 'China';
  String _destinationPort = 'JNPT Mumbai';
  String _goodsCategory = 'Metals';
  String _containerType = '20ft Standard (TEU)';

  // Doc checklist
  final Map<String, bool> _docs = {
    'Bill of Lading (BL)': false,
    'Commercial Invoice': false,
    'Packing List': false,
    'Certificate of Origin': false,
    'Import License': false,
    'Customs Declaration (Bill of Entry)': false,
    'Insurance Certificate': false,
    'IEC Certificate': false,
  };

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
        title: Text('Import Management', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        bottom: TabBar(
          controller: _tab,
          labelColor: _kBlue,
          unselectedLabelColor: textSub,
          indicatorColor: _kBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'New Import'),
            Tab(text: 'Documents'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildNewImport(isDark, card, textPrimary, textSub),
          _buildDocuments(isDark, card, textPrimary, textSub),
          _buildActive(isDark, card, textPrimary, textSub),
        ],
      ),
    );
  }

  // ── Tab 1: New Import ────────────────────────────────────────────────────

  Widget _buildNewImport(bool isDark, Color card, Color textPrimary, Color textSub) {
    final countries = LogisticsMockData.importCountries;
    final seaPorts = LogisticsMockData.ports.where((p) => p.type == 'sea' && p.country == 'India').map((p) => p.name).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_kBlue, _kBlue.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _kBlue.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.south_west_rounded, color: Colors.white, size: 26)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Import Shipment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('International → India', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionLabel('Origin Country', textPrimary),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: countries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final c = countries[i];
                final sel = _originCountry == c['name'];
                return GestureDetector(
                  onTap: () => setState(() => _originCountry = c['name']!),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sel ? _kBlue.withValues(alpha: 0.1) : card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? _kBlue : Colors.transparent, width: sel ? 1.5 : 1),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c['flag']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(c['name']!, style: TextStyle(color: sel ? _kBlue : textSub, fontSize: 9.5, fontWeight: sel ? FontWeight.w700 : FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Destination Port (India)', textPrimary),
          const SizedBox(height: 12),
          _dropdownCard(
            value: _destinationPort,
            items: seaPorts,
            isDark: isDark,
            card: card,
            textPrimary: textPrimary,
            onChanged: (v) => setState(() => _destinationPort = v ?? _destinationPort),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Goods Category', textPrimary),
          const SizedBox(height: 12),
          _dropdownCard(
            value: _goodsCategory,
            items: LogisticsMockData.goodsCategories,
            isDark: isDark,
            card: card,
            textPrimary: textPrimary,
            onChanged: (v) {
              setState(() {
                _goodsCategory = v ?? _goodsCategory;
              });
            },
          ),
          const SizedBox(height: 20),

          _sectionLabel('Container Type', textPrimary),
          const SizedBox(height: 12),
          _dropdownCard(
            value: _containerType,
            items: LogisticsMockData.containerTypes,
            isDark: isDark,
            card: card,
            textPrimary: textPrimary,
            onChanged: (v) => setState(() => _containerType = v ?? _containerType),
          ),
          const SizedBox(height: 20),

          // Transit info
          _sectionLabel('Estimated Transit', textPrimary),
          const SizedBox(height: 12),
          _buildTransitCard(isDark, card, textPrimary, textSub),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => context.push('/logistics/freight-quote'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kBlue, Color(0xFF2563EB)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _kBlue.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Center(child: Text('Get Import Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitCard(bool isDark, Color card, Color textPrimary, Color textSub) {
    final transitMap = {
      'China': {'days': '18-22', 'route': 'Shanghai → JNPT', 'mode': '🚢'},
      'Germany': {'days': '22-28', 'route': 'Hamburg → JNPT', 'mode': '🚢'},
      'USA': {'days': '25-35', 'route': 'Los Angeles → JNPT', 'mode': '🚢'},
      'UAE': {'days': '5-8', 'route': 'Jebel Ali → JNPT', 'mode': '🚢'},
      'Japan': {'days': '14-18', 'route': 'Osaka → JNPT', 'mode': '🚢'},
    };
    final info = transitMap[_originCountry] ?? {'days': '15-25', 'route': '$_originCountry → JNPT', 'mode': '🚢'};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kTeal.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(info['mode']!, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info['route']!, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Estimated transit: ${info['days']} days', style: TextStyle(color: textSub, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _kTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${info['days']} days', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Documents ─────────────────────────────────────────────────────

  Widget _buildDocuments(bool isDark, Color card, Color textPrimary, Color textSub) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _kBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Mark documents ready before customs clearance. Upload function coming soon.', style: TextStyle(color: textSub, fontSize: 12, height: 1.4))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Import Document Checklist', textPrimary),
          const SizedBox(height: 12),
          ..._docs.keys.map((docName) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _docs[docName]! ? _kTeal.withValues(alpha: 0.3) : Colors.transparent),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _docs[docName] = !_docs[docName]!),
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _docs[docName]! ? _kTeal : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _docs[docName]! ? _kTeal : const Color(0xFFCBD5E1), width: 1.5),
                    ),
                    child: _docs[docName]! ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(docName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13))),
                Icon(Icons.upload_file_outlined, color: textSub, size: 18),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${_docs.values.where((v) => v).length}/${_docs.length} ready', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              if (_docs.values.where((v) => v).length == _docs.length)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(20)),
                  child: const Text('All Ready ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Active Imports ─────────────────────────────────────────────────

  Widget _buildActive(bool isDark, Color card, Color textPrimary, Color textSub) {
    final imports = [
      {'id': 'IMP-2024-041', 'origin': '🇨🇳 China', 'goods': 'CNC Machines', 'status': 'At Customs', 'color': const Color(0xFF8B5CF6), 'eta': '2 days'},
      {'id': 'IMP-2024-038', 'origin': '🇩🇪 Germany', 'goods': 'Industrial Pumps', 'status': 'In Transit', 'color': _kBlue, 'eta': '8 days'},
      {'id': 'IMP-2024-033', 'origin': '🇯🇵 Japan', 'goods': 'Electronics Parts', 'status': 'Port Loading', 'color': _kTeal, 'eta': '12 days'},
      {'id': 'IMP-2024-028', 'origin': '🇺🇸 USA', 'goods': 'Medical Equipment', 'status': 'Delivered', 'color': const Color(0xFF22C55E), 'eta': 'Done'},
    ];
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: imports.map((imp) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(imp['id'] as String, style: TextStyle(color: textSub, fontSize: 11.5, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: (imp['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(imp['status'] as String, style: TextStyle(color: imp['color'] as Color, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(imp['goods'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 14, color: _kBlue),
                const SizedBox(width: 4),
                Text(imp['origin'] as String, style: TextStyle(color: textSub, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.schedule_outlined, size: 14, color: _kTeal),
                const SizedBox(width: 4),
                Text('ETA: ${imp['eta']}', style: TextStyle(color: textSub, fontSize: 12)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _dropdownCard({
    required String value,
    required List<String> items,
    required bool isDark,
    required Color card,
    required Color textPrimary,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _sectionLabel(String label, Color textPrimary) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: _kBlue, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
    ]);
  }
}
