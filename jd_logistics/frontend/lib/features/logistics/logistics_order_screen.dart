import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import '../../core/data/logistics_mock_data.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kSaffron = Color(0xFFFF6B00);

class LogisticsOrderScreen extends StatefulWidget {
  const LogisticsOrderScreen({super.key});
  @override
  State<LogisticsOrderScreen> createState() => _LogisticsOrderScreenState();
}

class _LogisticsOrderScreenState extends State<LogisticsOrderScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _anim;
  late Animation<double> _fade;

  // Step 1 — Shipment Type
  String _shipmentType = 'Export';
  String _transportMode = 'sea';

  // Step 2 — Goods
  String _selectedCategory = 'Metals';
  LGoods? _selectedGoods;

  // Step 3 — Weight/Volume
  final _weightCtrl = TextEditingController(text: '500');
  String _weightUnit = 'KG';
  final _valueCtrl = TextEditingController(text: '500000');
  bool _needsWarehouse = false;

  // Step 4 — Results
  LPricingResult? _pricing;
  LVehicle? _vehicle;
  List<Map<String, String>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
    _selectedGoods = LogisticsMockData.goodsByCategory(_selectedCategory).first;
  }

  @override
  void dispose() {
    _anim.dispose();
    _weightCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      if (_step == 2) _calculateFreight();
      _anim.reset();
      setState(() => _step++);
      _anim.forward();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      _anim.reset();
      setState(() => _step--);
      _anim.forward();
    }
  }

  void _calculateFreight() {
    final g = _selectedGoods;
    if (g == null) return;
    final rawWeight = double.tryParse(_weightCtrl.text) ?? 500;
    final weightKg = LogisticsMockData.toKg(rawWeight, _weightUnit);
    final weightTons = LogisticsMockData.toTons(weightKg);
    final goodsValue = double.tryParse(_valueCtrl.text) ?? 500000;
    final isUrgent = _transportMode == 'air';
    final veh = LogisticsMockData.recommendVehicle(
      weightTons: weightTons,
      shipmentType: _transportMode,
      classType: g.classType,
      isUrgent: isUrgent,
    );
    _vehicle = veh;
    _pricing = LogisticsMockData.calculateFreight(
      goods: g,
      weightKg: weightKg,
      distanceKm: LogisticsMockData.estimateDistance('Mumbai', 'Rotterdam'),
      vehicle: veh,
      isExport: _shipmentType == 'Export',
      needsWarehouse: _needsWarehouse,
      goodsValue: goodsValue,
    );
    _recommendations = LogisticsMockData.aiRecommendations(
      goods: g,
      weightKg: weightKg,
      shipmentType: _transportMode,
      isUrgent: isUrgent,
    );
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textPrimary),
          onPressed: _step > 0 ? _prevStep : () => context.pop(),
        ),
        title: Text('Create Shipment Order', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Step ${_step + 1}/4', style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.w600))),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStepper(isDark, textPrimary, textSub),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: _buildCurrentStep(isDark, card, textPrimary, textSub),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark, textPrimary),
    );
  }

  Widget _buildStepper(bool isDark, Color textPrimary, Color textSub) {
    final steps = ['Type', 'Goods', 'Details', 'Quote'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: done ? _kTeal : active ? _kTeal.withValues(alpha: 0.15) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: done || active ? _kTeal : const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? _kTeal : textSub)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(e.value, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: active ? _kTeal : textSub)),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1.5,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: i < _step ? _kTeal : const Color(0xFFCBD5E1),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark, Color card, Color textPrimary, Color textSub) {
    switch (_step) {
      case 0: return _buildStep1(isDark, card, textPrimary, textSub);
      case 1: return _buildStep2(isDark, card, textPrimary, textSub);
      case 2: return _buildStep3(isDark, card, textPrimary, textSub);
      case 3: return _buildStep4(isDark, card, textPrimary, textSub);
      default: return const SizedBox();
    }
  }

  // ── Step 1: Shipment Type ────────────────────────────────────────────────

  Widget _buildStep1(bool isDark, Color card, Color textPrimary, Color textSub) {
    final types = ['Import', 'Export', 'Domestic Bulk', 'Container Booking', 'Warehouse Storage'];
    final typeIcons = [Icons.south_west_rounded, Icons.north_east_rounded, Icons.local_shipping_outlined, Icons.inventory_2_outlined, Icons.warehouse_outlined];
    final modes = [
      {'mode': 'road', 'label': 'Road', 'emoji': '🚛'},
      {'mode': 'rail', 'label': 'Rail', 'emoji': '🚂'},
      {'mode': 'sea', 'label': 'Sea', 'emoji': '🚢'},
      {'mode': 'air', 'label': 'Air', 'emoji': '✈️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Shipment Type', textPrimary),
        const SizedBox(height: 12),
        ...types.asMap().entries.map((e) {
          final sel = _shipmentType == e.value;
          return GestureDetector(
            onTap: () => setState(() => _shipmentType = e.value),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel ? _kTeal.withValues(alpha: 0.08) : card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? _kTeal : Colors.transparent, width: sel ? 1.5 : 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: (sel ? _kTeal : textSub).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(typeIcons[e.key], color: sel ? _kTeal : textSub, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(e.value, style: TextStyle(color: textPrimary, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
                  const Spacer(),
                  if (sel) Icon(Icons.check_circle, color: _kTeal, size: 20),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        _sectionLabel('Transport Mode', textPrimary),
        const SizedBox(height: 12),
        Row(
          children: modes.map((m) {
            final sel = _transportMode == m['mode'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _transportMode = m['mode']!),
                child: Container(
                  margin: EdgeInsets.only(right: m == modes.last ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? _kTeal.withValues(alpha: 0.08) : card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? _kTeal : Colors.transparent, width: sel ? 1.5 : 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Text(m['emoji']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(m['label']!, style: TextStyle(color: sel ? _kTeal : textSub, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Step 2: Goods Selection ───────────────────────────────────────────────

  Widget _buildStep2(bool isDark, Color card, Color textPrimary, Color textSub) {
    final categories = LogisticsMockData.goodsCategories;
    final goods = LogisticsMockData.goodsByCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Select Goods Category', textPrimary),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final sel = _selectedCategory == categories[i];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = categories[i];
                  _selectedGoods = LogisticsMockData.goodsByCategory(categories[i]).first;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kTeal : card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Text(categories[i], style: TextStyle(color: sel ? Colors.white : textSub, fontWeight: FontWeight.w600, fontSize: 12.5)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Select Goods', textPrimary),
        const SizedBox(height: 12),
        ...goods.map((g) {
          final sel = _selectedGoods?.id == g.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedGoods = g),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? _kTeal.withValues(alpha: 0.07) : card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? _kTeal : Colors.transparent, width: sel ? 1.5 : 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Text(g.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: TextStyle(color: textPrimary, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('HSN: ${g.hsn}  •  GST: ${g.gstRate.toInt()}%  •  ${LogisticsMockData.classifyLabel(g.classType)}', style: TextStyle(color: textSub, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _riskColor(g.riskLevel).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(LogisticsMockData.riskLabel(g.riskLevel), style: TextStyle(color: _riskColor(g.riskLevel), fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 3: Weight / Volume / Options ─────────────────────────────────────

  Widget _buildStep3(bool isDark, Color card, Color textPrimary, Color textSub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedGoods != null) _buildGoodsInfoCard(isDark, card, textPrimary, textSub),
        const SizedBox(height: 20),
        _sectionLabel('Weight & Quantity', textPrimary),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weight / Volume', style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: textSub),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Unit', style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButton<String>(
                        value: _weightUnit,
                        underline: const SizedBox(),
                        style: TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 16),
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        items: LogisticsMockData.weightUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setState(() => _weightUnit = v ?? 'KG'),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goods Declared Value (₹)', style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _valueCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(color: textSub, fontSize: 18),
                      hintText: '0',
                      hintStyle: TextStyle(color: textSub),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Additional Options', textPrimary),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              const Icon(Icons.warehouse_outlined, color: _kTeal, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Warehouse Storage Required', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Add pre-shipment storage charges', style: TextStyle(color: textSub, fontSize: 11.5)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _needsWarehouse,
                onChanged: (v) => setState(() => _needsWarehouse = v),
                activeColor: _kTeal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 4: Quote & Confirm ───────────────────────────────────────────────

  Widget _buildStep4(bool isDark, Color card, Color textPrimary, Color textSub) {
    final p = _pricing;
    final v = _vehicle;
    if (p == null || v == null) {
      return Center(child: CircularProgressIndicator(color: _kTeal));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total cost hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kNavy, Color(0xFF1A3F6F), _kTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              const Text('Total Freight Cost', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('₹${_formatAmount(p.totalAmount)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32)),
              const SizedBox(height: 4),
              Text('incl. GST @${_selectedGoods?.gstRate.toInt()}%', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _summaryChip('🚛 ${v.name}'),
                  const SizedBox(width: 8),
                  _summaryChip('📦 ${_weightCtrl.text} ${_weightUnit}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Pricing breakdown
        _sectionLabel('Pricing Breakdown', textPrimary),
        const SizedBox(height: 12),
        _buildPricingCard(p, isDark, card, textPrimary, textSub),
        const SizedBox(height: 20),

        // AI Recommendations
        if (_recommendations.isNotEmpty) ...[
          _sectionLabel('AI Recommendations', textPrimary),
          const SizedBox(height: 12),
          ..._recommendations.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kTeal.withValues(alpha: 0.15)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Text(r['icon'] ?? '💡', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['title'] ?? '', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(r['desc'] ?? '', style: TextStyle(color: textSub, fontSize: 11.5, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),
        ],

        // Insurance
        _sectionLabel('Insurance Coverage', textPrimary),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shield_outlined, color: Color(0xFF22C55E), size: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cargo Insurance', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('Coverage: ₹${_formatAmount(p.insuranceCoverage)}', style: TextStyle(color: textSub, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${_formatAmount(p.insurancePremium)}', style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('premium', style: TextStyle(color: textSub, fontSize: 10.5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Confirm Button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order JDL-2024-${DateTime.now().millisecond.toString().padLeft(3, '0')} placed successfully!'),
                backgroundColor: _kTeal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            context.pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kTeal, Color(0xFF0F9A8A)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _kTeal.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Text('Confirm & Book Shipment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.3))),
          ),
        ),
      ],
    );
  }

  Widget _buildGoodsInfoCard(bool isDark, Color card, Color textPrimary, Color textSub) {
    final g = _selectedGoods!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kTeal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(g.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${g.category}  •  ${LogisticsMockData.classifyLabel(g.classType)}  •  ${_transportMode.toUpperCase()}', style: TextStyle(color: textSub, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(LPricingResult p, bool isDark, Color card, Color textPrimary, Color textSub) {
    final rows = [
      ['Base Freight', p.baseFreight],
      ['Distance Cost', p.distanceCost],
      ['Weight Charges', p.weightCost],
      ['Vehicle Cost', p.vehicleCost],
      ['Risk Surcharge', p.riskCost],
      ['Handling', p.handlingCharges],
      ['Documentation', p.documentationCharges],
      if (_shipmentType == 'Export' || _shipmentType == 'Import') ['Customs Charges', p.customsCharges],
      if (_needsWarehouse) ['Warehouse Storage', p.warehouseCharges],
    ];

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          ...rows.map((r) => _pricingRow(r[0] as String, r[1] as double, textPrimary, textSub, isDark)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('GST (${_selectedGoods?.gstRate.toInt()}%)', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13))),
                Text('₹${_formatAmount(p.gstAmount)}', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kNavy.withValues(alpha: isDark ? 0.3 : 0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Total Amount', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15))),
                Text('₹${_formatAmount(p.totalAmount)}', style: TextStyle(color: _kTeal, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricingRow(String label, double amount, Color textPrimary, Color textSub, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: textSub, fontSize: 13))),
          Text('₹${_formatAmount(amount)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _summaryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBottomBar(bool isDark, Color textPrimary) {
    if (_step == 3) return const SizedBox();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg1 : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: _step == 2 && (_weightCtrl.text.isEmpty || _selectedGoods == null) ? null : _nextStep,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kTeal, Color(0xFF0F9A8A)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _kTeal.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: Text(
              _step == 2 ? 'Calculate Freight' : 'Continue',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, Color textPrimary) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
      ],
    );
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'low': return const Color(0xFF22C55E);
      case 'medium': return const Color(0xFFF59E0B);
      case 'medium_high': return _kSaffron;
      case 'high': return const Color(0xFFEF4444);
      case 'critical': return const Color(0xFF7C3AED);
      case 'perishable': return const Color(0xFF06B6D4);
      default: return const Color(0xFF64748B);
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}
