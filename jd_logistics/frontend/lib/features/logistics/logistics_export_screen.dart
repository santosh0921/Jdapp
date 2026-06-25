import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import '../../core/data/logistics_mock_data.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kGreen = Color(0xFF22C55E);

class LogisticsExportScreen extends StatefulWidget {
  const LogisticsExportScreen({super.key});
  @override
  State<LogisticsExportScreen> createState() => _LogisticsExportScreenState();
}

class _LogisticsExportScreenState extends State<LogisticsExportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  String _destinationCountry = 'USA';
  String _originPort = 'JNPT Mumbai';
  String _goodsCategory = 'Textiles';
  LGoods? _selectedGoods;
  String _containerType = '40ft Standard';
  bool _hasIEC = false;
  bool _hasGSTIN = false;

  final Map<String, bool> _docs = {
    'Shipping Bill': false,
    'Commercial Invoice': false,
    'Packing List': false,
    'Certificate of Origin': false,
    'GST Invoice (IGST)': false,
    'Letter of Credit (LC)': false,
    'Phytosanitary Certificate': false,
    'IEC Copy': false,
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _selectedGoods = LogisticsMockData.goodsByCategory(_goodsCategory).first;
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
        title: Text('Export Management', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        bottom: TabBar(
          controller: _tab,
          labelColor: _kGreen,
          unselectedLabelColor: textSub,
          indicatorColor: _kGreen,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'New Export'),
            Tab(text: 'Documents'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildNewExport(isDark, card, textPrimary, textSub),
          _buildDocuments(isDark, card, textPrimary, textSub),
          _buildActive(isDark, card, textPrimary, textSub),
        ],
      ),
    );
  }

  Widget _buildNewExport(bool isDark, Color card, Color textPrimary, Color textSub) {
    final countries = LogisticsMockData.exportCountries;
    final seaPorts = LogisticsMockData.ports.where((p) => p.type == 'sea' && p.country == 'India').map((p) => p.name).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_kGreen, _kGreen.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _kGreen.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.north_east_rounded, color: Colors.white, size: 26)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Export Shipment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('India → International', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business Verification
          _sectionLabel('Business Verification', textPrimary),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                _verifyRow('IEC Number', 'Import Export Code', _hasIEC, () => setState(() => _hasIEC = !_hasIEC), isDark, textPrimary, textSub),
                const Divider(height: 20),
                _verifyRow('GSTIN', 'GST Identification No.', _hasGSTIN, () => setState(() => _hasGSTIN = !_hasGSTIN), isDark, textPrimary, textSub),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Destination
          _sectionLabel('Destination Country', textPrimary),
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
                final sel = _destinationCountry == c['name'];
                return GestureDetector(
                  onTap: () => setState(() => _destinationCountry = c['name']!),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sel ? _kGreen.withValues(alpha: 0.1) : card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? _kGreen : Colors.transparent, width: sel ? 1.5 : 1),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c['flag']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(c['name']!, style: TextStyle(color: sel ? _kGreen : textSub, fontSize: 9.5, fontWeight: sel ? FontWeight.w700 : FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Origin Port (India)', textPrimary),
          const SizedBox(height: 12),
          _dropdownCard(value: _originPort, items: seaPorts, isDark: isDark, card: card, textPrimary: textPrimary, onChanged: (v) => setState(() => _originPort = v ?? _originPort)),
          const SizedBox(height: 20),

          _sectionLabel('Goods Category', textPrimary),
          const SizedBox(height: 12),
          _dropdownCard(
            value: _goodsCategory,
            items: LogisticsMockData.goodsCategories,
            isDark: isDark, card: card, textPrimary: textPrimary,
            onChanged: (v) => setState(() {
              _goodsCategory = v ?? _goodsCategory;
              _selectedGoods = LogisticsMockData.goodsByCategory(_goodsCategory).first;
            }),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Container Type', textPrimary),
          const SizedBox(height: 12),
          _dropdownCard(value: _containerType, items: LogisticsMockData.containerTypes, isDark: isDark, card: card, textPrimary: textPrimary, onChanged: (v) => setState(() => _containerType = v ?? _containerType)),
          const SizedBox(height: 24),

          // HSN & Duties info strip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kTeal.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: _kTeal, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HSN: ${_selectedGoods?.hsn ?? 'N/A'}  •  Export Duty: Nil (Most goods)', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 12.5)),
                      Text('IGST refund eligible on export', style: TextStyle(color: textSub, fontSize: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => context.push('/logistics/freight-quote'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kGreen, Color(0xFF16A34A)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _kGreen.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Center(child: Text('Get Export Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyRow(String title, String sub, bool verified, VoidCallback onTap, bool isDark, Color textPrimary, Color textSub) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: (verified ? _kGreen : textSub).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(verified ? Icons.verified : Icons.badge_outlined, color: verified ? _kGreen : textSub, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          Text(sub, style: TextStyle(color: textSub, fontSize: 11)),
        ])),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: (verified ? _kGreen : const Color(0xFFCBD5E1)).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(verified ? 'Verified ✓' : 'Mark Ready', style: TextStyle(color: verified ? _kGreen : textSub, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

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
              color: _kGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _kGreen, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Ensure all export documents are signed and stamped before loading.', style: TextStyle(color: textSub, fontSize: 12, height: 1.4))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Export Document Checklist', textPrimary),
          const SizedBox(height: 12),
          ..._docs.keys.map((docName) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _docs[docName]! ? _kGreen.withValues(alpha: 0.3) : Colors.transparent),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _docs[docName] = !_docs[docName]!),
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _docs[docName]! ? _kGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _docs[docName]! ? _kGreen : const Color(0xFFCBD5E1), width: 1.5),
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
          Text('${_docs.values.where((v) => v).length}/${_docs.length} documents ready', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActive(bool isDark, Color card, Color textPrimary, Color textSub) {
    final exports = [
      {'id': 'EXP-2024-087', 'dest': '🇺🇸 USA', 'goods': 'Cotton Garments', 'status': 'Customs Cleared', 'color': _kTeal, 'eta': '18 days'},
      {'id': 'EXP-2024-082', 'dest': '🇦🇪 UAE', 'goods': 'Basmati Rice', 'status': 'In Transit', 'color': const Color(0xFF3B82F6), 'eta': '5 days'},
      {'id': 'EXP-2024-074', 'dest': '🇩🇪 Germany', 'goods': 'Auto Parts', 'status': 'Port Loading', 'color': _kGreen, 'eta': '22 days'},
      {'id': 'EXP-2024-069', 'dest': '🇬🇧 UK', 'goods': 'Pharmaceuticals', 'status': 'Delivered', 'color': const Color(0xFF22C55E), 'eta': 'Done'},
    ];
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: exports.map((exp) => Container(
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
            Row(children: [
              Text(exp['id'] as String, style: TextStyle(color: textSub, fontSize: 11.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: (exp['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(exp['status'] as String, style: TextStyle(color: exp['color'] as Color, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(exp['goods'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.flag_outlined, size: 14, color: _kGreen),
              const SizedBox(width: 4),
              Text(exp['dest'] as String, style: TextStyle(color: textSub, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.schedule_outlined, size: 14, color: _kTeal),
              const SizedBox(width: 4),
              Text('ETA: ${exp['eta']}', style: TextStyle(color: textSub, fontSize: 12)),
            ]),
          ],
        ),
      )).toList(),
    );
  }

  Widget _dropdownCard({required String value, required List<String> items, required bool isDark, required Color card, required Color textPrimary, required ValueChanged<String?> onChanged}) {
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
      Container(width: 3, height: 18, decoration: BoxDecoration(color: _kGreen, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
    ]);
  }
}
