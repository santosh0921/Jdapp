import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kSaffron = Color(0xFFFF6B00);
const Color _kPink = Color(0xFFEC4899);

class LogisticsAnalyticsScreen extends StatefulWidget {
  const LogisticsAnalyticsScreen({super.key});
  @override
  State<LogisticsAnalyticsScreen> createState() => _LogisticsAnalyticsScreenState();
}

class _LogisticsAnalyticsScreenState extends State<LogisticsAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String _period = '30 Days';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
        title: Text('Logistics Analytics', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _period,
              underline: const SizedBox(),
              style: TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 13),
              dropdownColor: isDark ? AppColors.darkCard : Colors.white,
              items: ['7 Days', '30 Days', '90 Days', '1 Year'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _period = v ?? '30 Days'),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKpiCards(isDark, card, textPrimary, textSub),
              const SizedBox(height: 24),
              _sectionLabel('Monthly Shipment Volume', textPrimary),
              const SizedBox(height: 12),
              _buildBarChart(isDark, card, textSub),
              const SizedBox(height: 24),
              _sectionLabel('Freight Spend (₹ Lakhs)', textPrimary),
              const SizedBox(height: 12),
              _buildSpendChart(isDark, card, textSub),
              const SizedBox(height: 24),
              _sectionLabel('Transport Mode Split', textPrimary),
              const SizedBox(height: 12),
              _buildModeSplit(isDark, card, textPrimary, textSub),
              const SizedBox(height: 24),
              _sectionLabel('Top Trade Corridors', textPrimary),
              const SizedBox(height: 12),
              _buildTopCorridors(isDark, card, textPrimary, textSub),
              const SizedBox(height: 24),
              _sectionLabel('Country Distribution', textPrimary),
              const SizedBox(height: 12),
              _buildCountryDist(isDark, card, textPrimary, textSub),
              const SizedBox(height: 24),
              _sectionLabel('Goods Category Performance', textPrimary),
              const SizedBox(height: 12),
              _buildGoodsPerformance(isDark, card, textPrimary, textSub),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCards(bool isDark, Color card, Color textPrimary, Color textSub) {
    final kpis = [
      {'label': 'Total Shipments', 'value': '1,248', 'change': '+12%', 'up': true, 'color': _kTeal, 'icon': Icons.local_shipping_outlined},
      {'label': 'Total Freight Spend', 'value': '₹4.2Cr', 'change': '+8%', 'up': true, 'color': const Color(0xFF3B82F6), 'icon': Icons.currency_rupee_outlined},
      {'label': 'Weight Moved', 'value': '8,420 MT', 'change': '+15%', 'up': true, 'color': const Color(0xFF8B5CF6), 'icon': Icons.scale_outlined},
      {'label': 'On-Time Delivery', 'value': '94.2%', 'change': '+2.1%', 'up': true, 'color': const Color(0xFF22C55E), 'icon': Icons.check_circle_outline},
      {'label': 'Customs Hold', 'value': '3 cases', 'change': '-2', 'up': true, 'color': _kSaffron, 'icon': Icons.gavel_outlined},
      {'label': 'Avg Transit Days', 'value': '12.4 days', 'change': '-0.8', 'up': true, 'color': _kPink, 'icon': Icons.schedule_outlined},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: kpis.map((k) {
        final color = k['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(k['icon'] as IconData, color: color, size: 16),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (k['up'] as bool ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(k['change'] as String, style: TextStyle(color: k['up'] as bool ? const Color(0xFF22C55E) : const Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k['value'] as String, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(k['label'] as String, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarChart(bool isDark, Color card, Color textSub) {
    final data = [
      {'month': 'Jul', 'value': 82},
      {'month': 'Aug', 'value': 95},
      {'month': 'Sep', 'value': 88},
      {'month': 'Oct', 'value': 112},
      {'month': 'Nov', 'value': 124},
      {'month': 'Dec', 'value': 98},
    ];
    final maxVal = data.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final fraction = (_anim.value * (d['value'] as int) / maxVal).clamp(0.0, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${d['value']}', style: TextStyle(color: textSub, fontSize: 9.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Container(
                          height: 100 * fraction,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [_kTeal, _kTeal.withValues(alpha: 0.6)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data.map((d) => Expanded(child: Center(child: Text(d['month'] as String, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w600))))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendChart(bool isDark, Color card, Color textSub) {
    final data = [
      {'month': 'Jul', 'value': 0.62},
      {'month': 'Aug', 'value': 0.71},
      {'month': 'Sep', 'value': 0.68},
      {'month': 'Oct', 'value': 0.84},
      {'month': 'Nov', 'value': 0.91},
      {'month': 'Dec', 'value': 0.74},
    ];
    final maxVal = data.map((d) => d['value'] as double).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final fraction = (_anim.value * (d['value'] as double) / maxVal).clamp(0.0, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${d['value']}L', style: TextStyle(color: textSub, fontSize: 9.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Container(
                          height: 100 * fraction,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [_kSaffron, _kSaffron.withValues(alpha: 0.6)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: data.map((d) => Expanded(child: Center(child: Text(d['month'] as String, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w600))))).toList()),
        ],
      ),
    );
  }

  Widget _buildModeSplit(bool isDark, Color card, Color textPrimary, Color textSub) {
    final modes = [
      {'mode': 'Sea', 'pct': 0.62, 'color': const Color(0xFF3B82F6), 'emoji': '🚢'},
      {'mode': 'Road', 'pct': 0.22, 'color': _kSaffron, 'emoji': '🚛'},
      {'mode': 'Air', 'pct': 0.10, 'color': const Color(0xFF8B5CF6), 'emoji': '✈️'},
      {'mode': 'Rail', 'pct': 0.06, 'color': _kTeal, 'emoji': '🚂'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: modes.map((m) {
          final pct = m['pct'] as double;
          final color = m['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(m['emoji'] as String, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                SizedBox(width: 40, child: Text(m['mode'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 12))),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct * _anim.value,
                      backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(pct * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopCorridors(bool isDark, Color card, Color textPrimary, Color textSub) {
    final corridors = [
      {'route': 'Mumbai → Rotterdam', 'shipments': 48, 'value': '₹1.2Cr', 'mode': '🚢'},
      {'route': 'Delhi → Dubai', 'shipments': 35, 'value': '₹84L', 'mode': '✈️'},
      {'route': 'Chennai → Singapore', 'shipments': 28, 'value': '₹62L', 'mode': '🚢'},
      {'route': 'Kolkata → Hamburg', 'shipments': 22, 'value': '₹48L', 'mode': '🚢'},
      {'route': 'Bengaluru → USA', 'shipments': 18, 'value': '₹95L', 'mode': '✈️'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: corridors.asMap().entries.map((e) {
          final c = e.value;
          final isLast = e.key == corridors.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Text(c['mode'] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['route'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${c['shipments']} shipments', style: TextStyle(color: textSub, fontSize: 11.5)),
                    ],
                  ),
                ),
                Text(c['value'] as String, style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCountryDist(bool isDark, Color card, Color textPrimary, Color textSub) {
    final countries = [
      {'flag': '🇦🇪', 'name': 'UAE', 'pct': 0.24, 'color': _kSaffron},
      {'flag': '🇩🇪', 'name': 'Germany', 'pct': 0.18, 'color': const Color(0xFF3B82F6)},
      {'flag': '🇺🇸', 'name': 'USA', 'pct': 0.15, 'color': _kPink},
      {'flag': '🇸🇬', 'name': 'Singapore', 'pct': 0.13, 'color': const Color(0xFF22C55E)},
      {'flag': '🇨🇳', 'name': 'China', 'pct': 0.10, 'color': const Color(0xFFEF4444)},
      {'flag': '🌍', 'name': 'Others', 'pct': 0.20, 'color': const Color(0xFF64748B)},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: countries.map((c) {
          final pct = c['pct'] as double;
          final color = c['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(c['flag'] as String, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                SizedBox(width: 72, child: Text(c['name'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 12))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct * _anim.value,
                      backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(pct * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoodsPerformance(bool isDark, Color card, Color textPrimary, Color textSub) {
    final goods = [
      {'name': 'Metals', 'emoji': '🔩', 'shipments': 312, 'value': '₹1.8Cr', 'change': '+18%'},
      {'name': 'Textiles', 'emoji': '🧶', 'shipments': 248, 'value': '₹62L', 'change': '+8%'},
      {'name': 'Electronics', 'emoji': '💻', 'shipments': 186, 'value': '₹2.4Cr', 'change': '+24%'},
      {'name': 'Pharmaceuticals', 'emoji': '💊', 'shipments': 142, 'value': '₹3.1Cr', 'change': '+32%'},
      {'name': 'Food / Agro', 'emoji': '🌾', 'shipments': 198, 'value': '₹48L', 'change': '+5%'},
    ];
    return Column(
      children: goods.map((g) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Text(g['emoji'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g['name'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('${g['shipments']} shipments', style: TextStyle(color: textSub, fontSize: 11.5)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(g['value'] as String, style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w800, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(g['change'] as String, style: const TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
          ],
        ),
      )).toList(),
    );
  }

  Widget _sectionLabel(String label, Color textPrimary) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
    ]);
  }
}
