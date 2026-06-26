import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/services/pricing_service.dart';
import '../../core/data/logistics_mock_data.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kSaffron = Color(0xFFFF6B00);

class LogisticsFreightQuoteScreen extends StatefulWidget {
  const LogisticsFreightQuoteScreen({super.key});
  @override
  State<LogisticsFreightQuoteScreen> createState() => _LogisticsFreightQuoteScreenState();
}

class _LogisticsFreightQuoteScreenState extends State<LogisticsFreightQuoteScreen> {
  String _fromCity = 'Mumbai';
  String _toCity = 'Rotterdam';
  String _goodsCategory = 'Metals';
  LGoods? _selectedGoods;
  String _weightUnit = 'Ton';
  final _weightCtrl = TextEditingController(text: '25');
  final _valueCtrl = TextEditingController(text: '2000000');
  String _mode = 'sea';
  bool _needsWarehouse = false;
  LPricingResult? _result;
  LVehicle? _vehicle;
  bool _calculated = false;
  bool _calculating = false;

  @override
  void initState() {
    super.initState();
    _selectedGoods = LogisticsMockData.goodsByCategory(_goodsCategory).first;
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final g = _selectedGoods;
    if (g == null || _calculating) return;

    setState(() { _calculating = true; _calculated = false; });

    final rawWeight = double.tryParse(_weightCtrl.text) ?? 25;
    final weightKg  = LogisticsMockData.toKg(rawWeight, _weightUnit);
    final goodsValue = double.tryParse(_valueCtrl.text) ?? 2000000;

    try {
      final data = await PricingService.instance.estimateLogistics({
        'from_city': _fromCity,
        'to_city': _toCity,
        'goods_id': g.id,
        'weight_kg': weightKg,
        'goods_value': goodsValue,
        'transport_mode': _mode,
        'needs_warehouse': _needsWarehouse,
        'shipment_type': 'export',
      });
      _result = LPricingResult.fromMap(data);
      final vehType = data['recommended_vehicle'] as String? ?? '';
      _vehicle = LogisticsMockData.vehicles.where((v) => v.type == vehType).firstOrNull
          ?? LogisticsMockData.recommendVehicle(
              weightTons: LogisticsMockData.toTons(weightKg),
              shipmentType: _mode,
              classType: g.classType,
              isUrgent: _mode == 'air');
    } catch (e) {
      if (mounted) {
        setState(() { _calculating = false; _calculated = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Freight estimate failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _calculate,
          ),
        ));
      }
      return;
    }

    if (mounted) setState(() { _calculating = false; _calculated = true; });
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
        title: Text('Freight Quote Engine', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route selector
            _sectionLabel('Shipping Route', textPrimary),
            const SizedBox(height: 12),
            _buildRouteSelector(isDark, card, textPrimary, textSub),
            const SizedBox(height: 20),

            // Mode selector
            _sectionLabel('Transport Mode', textPrimary),
            const SizedBox(height: 12),
            _buildModeRow(isDark, card, textSub),
            const SizedBox(height: 20),

            // Goods selector
            _sectionLabel('Goods Type', textPrimary),
            const SizedBox(height: 12),
            _buildGoodsSelector(isDark, card, textPrimary, textSub),
            const SizedBox(height: 20),

            // Weight and value
            _sectionLabel('Weight & Value', textPrimary),
            const SizedBox(height: 12),
            _buildWeightValue(isDark, card, textPrimary, textSub),
            const SizedBox(height: 20),

            // Options
            _buildOptionsRow(isDark, card, textPrimary, textSub),
            const SizedBox(height: 24),

            // Calculate button
            GestureDetector(
              onTap: _calculating ? null : _calculate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _calculating
                      ? [const Color(0xFF999999), const Color(0xFF777777)]
                      : const [_kSaffron, Color(0xFFE05500)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _kSaffron.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: _calculating
                    ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calculate_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Calculate Freight Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
              ),
            ),

            if (_calculated && _result != null) ...[
              const SizedBox(height: 28),
              _buildQuoteResult(isDark, card, textPrimary, textSub),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector(bool isDark, Color card, Color textPrimary, Color textSub) {
    final cities = LogisticsMockData.cities.map((c) => c.name).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FROM', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: _fromCity,
                  underline: const SizedBox(),
                  isExpanded: true,
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _fromCity = v ?? _fromCity),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: _kTeal, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TO', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: _toCity,
                  underline: const SizedBox(),
                  isExpanded: true,
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _toCity = v ?? _toCity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeRow(bool isDark, Color card, Color textSub) {
    final modes = [
      {'mode': 'road', 'emoji': '🚛', 'label': 'Road'},
      {'mode': 'rail', 'emoji': '🚂', 'label': 'Rail'},
      {'mode': 'sea', 'emoji': '🚢', 'label': 'Sea'},
      {'mode': 'air', 'emoji': '✈️', 'label': 'Air'},
    ];
    return Row(
      children: modes.map((m) {
        final sel = _mode == m['mode'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mode = m['mode']!),
            child: Container(
              margin: EdgeInsets.only(right: m == modes.last ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? _kTeal : card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Text(m['emoji']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(m['label']!, style: TextStyle(color: sel ? Colors.white : textSub, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 11)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoodsSelector(bool isDark, Color card, Color textPrimary, Color textSub) {
    final cats = LogisticsMockData.goodsCategories;
    final goodsList = LogisticsMockData.goodsByCategory(_goodsCategory);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: DropdownButton<String>(
            value: _goodsCategory,
            underline: const SizedBox(),
            isExpanded: true,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
            items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() {
              _goodsCategory = v ?? _goodsCategory;
              _selectedGoods = LogisticsMockData.goodsByCategory(_goodsCategory).first;
            }),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: DropdownButton<LGoods>(
            value: _selectedGoods,
            underline: const SizedBox(),
            isExpanded: true,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
            items: goodsList.map((g) => DropdownMenuItem(value: g, child: Text('${g.emoji} ${g.name}', overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _selectedGoods = v),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightValue(bool isDark, Color card, Color textPrimary, Color textSub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
                      decoration: InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: textSub)),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('Unit', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _weightUnit,
                    underline: const SizedBox(),
                    style: TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 15),
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: LogisticsMockData.weightUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _weightUnit = v ?? 'Ton'),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Declared Value (₹)', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
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
    );
  }

  Widget _buildOptionsRow(bool isDark, Color card, Color textPrimary, Color textSub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.warehouse_outlined, color: _kTeal, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Include Warehouse Storage', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
          Switch.adaptive(value: _needsWarehouse, onChanged: (v) => setState(() => _needsWarehouse = v), activeColor: _kTeal),
        ],
      ),
    );
  }

  Widget _buildQuoteResult(bool isDark, Color card, Color textPrimary, Color textSub) {
    final p = _result!;
    final v = _vehicle!;
    final g = _selectedGoods!;

    final rows = [
      {'label': 'Base Freight', 'value': p.baseFreight, 'icon': Icons.local_shipping_outlined},
      {'label': 'Distance Charges', 'value': p.distanceCost, 'icon': Icons.route_outlined},
      {'label': 'Weight Charges', 'value': p.weightCost, 'icon': Icons.scale_outlined},
      {'label': 'Vehicle Cost', 'value': p.vehicleCost, 'icon': Icons.directions_car_outlined},
      {'label': 'Risk Surcharge', 'value': p.riskCost, 'icon': Icons.warning_amber_outlined},
      {'label': 'Handling Charges', 'value': p.handlingCharges, 'icon': Icons.handshake_outlined},
      {'label': 'Insurance Premium', 'value': p.insurancePremium, 'icon': Icons.shield_outlined},
      {'label': 'Documentation', 'value': p.documentationCharges, 'icon': Icons.description_outlined},
      {'label': 'Customs Charges', 'value': p.customsCharges, 'icon': Icons.gavel_outlined},
      if (_needsWarehouse) {'label': 'Warehouse Storage', 'value': p.warehouseCharges, 'icon': Icons.warehouse_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kNavy, Color(0xFF1E3A5F), _kTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(g.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Freight Quote', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(g.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${_fmt(p.totalAmount)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
                      Text('incl. GST ${g.gstRate.toInt()}%', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _chip('🚛 ${v.name}'),
                  const SizedBox(width: 6),
                  _chip('${_weightCtrl.text} ${_weightUnit}'),
                  const SizedBox(width: 6),
                  _chip(LogisticsMockData.riskLabel(g.riskLevel)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Breakdown
        _sectionLabel('Cost Breakdown', textPrimary),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              ...rows.map((r) => _row(r['label'] as String, r['value'] as double, r['icon'] as IconData, textPrimary, textSub, isDark)),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kTeal.withValues(alpha: 0.07),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_outlined, color: _kTeal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('GST Amount (${g.gstRate.toInt()}%)', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13))),
                    Text('+ ₹${_fmt(p.gstAmount)}', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kNavy.withValues(alpha: isDark ? 0.3 : 0.06),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('TOTAL', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5))),
                    Text('₹${_fmt(p.totalAmount)}', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Book button
        GestureDetector(
          onTap: () => context.push('/logistics/create-order'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kTeal, Color(0xFF0F9A8A)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: _kTeal.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Text('Book Shipment at This Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, double val, IconData icon, Color textPrimary, Color textSub, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)))),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textSub),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(color: textSub, fontSize: 12.5))),
          Text('₹${_fmt(val)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sectionLabel(String label, Color textPrimary) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
    ]);
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
