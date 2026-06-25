import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kSaffron = Color(0xFFFF6B00);

class LogisticsNetworkScreen extends StatefulWidget {
  const LogisticsNetworkScreen({super.key});
  @override
  State<LogisticsNetworkScreen> createState() => _LogisticsNetworkScreenState();
}

class _LogisticsNetworkScreenState extends State<LogisticsNetworkScreen>
    with TickerProviderStateMixin {
  late AnimationController _routeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _routeAnim;
  late Animation<double> _pulseAnim;
  String _selectedMode = 'All';
  _PortNode? _selectedPort;

  static const List<_PortNode> _ports = [
    _PortNode('JNPT Mumbai', 0.25, 0.55, '🇮🇳', 'sea'),
    _PortNode('Chennai', 0.32, 0.65, '🇮🇳', 'sea'),
    _PortNode('Kolkata', 0.38, 0.52, '🇮🇳', 'sea'),
    _PortNode('Delhi ICD', 0.30, 0.42, '🇮🇳', 'ICD'),
    _PortNode('Jebel Ali', 0.52, 0.48, '🇦🇪', 'sea'),
    _PortNode('Singapore', 0.72, 0.62, '🇸🇬', 'sea'),
    _PortNode('Shanghai', 0.78, 0.38, '🇨🇳', 'sea'),
    _PortNode('Rotterdam', 0.42, 0.22, '🇳🇱', 'sea'),
    _PortNode('Hamburg', 0.44, 0.18, '🇩🇪', 'sea'),
    _PortNode('Dubai Air', 0.52, 0.44, '🇦🇪', 'air'),
    _PortNode('Colombo', 0.35, 0.68, '🇱🇰', 'sea'),
  ];

  static const List<_SeaRoute> _routes = [
    _SeaRoute('JNPT Mumbai', 'Jebel Ali', 'sea', Color(0xFF3B82F6)),
    _SeaRoute('JNPT Mumbai', 'Rotterdam', 'sea', Color(0xFF3B82F6)),
    _SeaRoute('JNPT Mumbai', 'Singapore', 'sea', Color(0xFF3B82F6)),
    _SeaRoute('Chennai', 'Singapore', 'sea', Color(0xFF22C55E)),
    _SeaRoute('Kolkata', 'Singapore', 'sea', Color(0xFF22C55E)),
    _SeaRoute('Singapore', 'Shanghai', 'sea', Color(0xFFEC4899)),
    _SeaRoute('Jebel Ali', 'Rotterdam', 'sea', Color(0xFF8B5CF6)),
    _SeaRoute('JNPT Mumbai', 'Colombo', 'sea', Color(0xFFF59E0B)),
    _SeaRoute('Delhi ICD', 'Dubai Air', 'air', Color(0xFFFF6B00)),
    _SeaRoute('JNPT Mumbai', 'Dubai Air', 'air', Color(0xFFFF6B00)),
    _SeaRoute('Chennai', 'Dubai Air', 'air', Color(0xFFFF6B00)),
  ];

  @override
  void initState() {
    super.initState();
    _routeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _routeAnim = CurvedAnimation(parent: _routeCtrl, curve: Curves.linear);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _routeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.darkBg1 : const Color(0xFFF0F4F8);
    final textPrimary = isDark ? AppColors.textWhite : _kNavy;
    final textSub = isDark ? AppColors.darkSubtext : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textPrimary), onPressed: () => context.pop()),
        title: Text('Global Logistics Network', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: Column(
        children: [
          // Mode filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Sea', 'Air', 'ICD'].map((m) {
                final sel = _selectedMode == m;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMode = m),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? _kTeal : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: Text(m, style: TextStyle(color: sel ? Colors.white : textSub, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Network map
          Expanded(
            flex: 5,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([_routeAnim, _pulseAnim]),
                builder: (_, __) => GestureDetector(
                  onTapDown: (details) => _handleTap(details.localPosition, context),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0A1628), const Color(0xFF0F1E36), const Color(0xFF0A2040)]
                            : [const Color(0xFFDEEEFA), const Color(0xFFE8F4FD), const Color(0xFFCFE8F8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: isDark ? 0.5 : 0.12), blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: _NetworkPainter(
                          progress: _routeAnim.value,
                          pulse: _pulseAnim.value,
                          ports: _ports,
                          routes: _routes,
                          selectedMode: _selectedMode,
                          selectedPort: _selectedPort,
                          isDark: isDark,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Port info or legend
          Expanded(
            flex: 2,
            child: _selectedPort != null
                ? _buildPortInfo(isDark, textPrimary, textSub)
                : _buildLegend(isDark, textPrimary, textSub),
          ),
        ],
      ),
    );
  }

  void _handleTap(Offset local, BuildContext context) {
    final size = context.size;
    if (size == null) return;
    // Map from painter area (accounting for margin)
    final mapW = size.width - 24;
    final mapH = size.height * 5 / 7 - 8; // approx
    for (final port in _ports) {
      final px = port.xRatio * mapW + 12;
      final py = port.yRatio * mapH;
      if ((local.dx - px).abs() < 28 && (local.dy - py).abs() < 28) {
        setState(() => _selectedPort = _selectedPort?.name == port.name ? null : port);
        return;
      }
    }
    setState(() => _selectedPort = null);
  }

  Widget _buildPortInfo(bool isDark, Color textPrimary, Color textSub) {
    final port = _selectedPort!;
    final connectedRoutes = _routes.where((r) => r.from == port.name || r.to == port.name).toList();
    final card = isDark ? AppColors.darkCard : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Text(port.flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(port.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
                Text('Type: ${port.type.toUpperCase()}  •  ${connectedRoutes.length} active routes', style: TextStyle(color: textSub, fontSize: 12)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _kTeal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: const Text('LIVE', style: TextStyle(color: _kTeal, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
              const SizedBox(height: 4),
              Text('${connectedRoutes.length} routes', style: TextStyle(color: textSub, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark, Color textPrimary, Color textSub) {
    final items = [
      {'label': 'Sea Route', 'color': const Color(0xFF3B82F6)},
      {'label': 'Air Route', 'color': _kSaffron},
      {'label': 'Sea Port', 'color': _kTeal},
      {'label': 'ICD', 'color': const Color(0xFF8B5CF6)},
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tap a port node for details', style: TextStyle(color: textSub, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: items.map((item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 20, height: 3, decoration: BoxDecoration(color: item['color'] as Color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text(item['label'] as String, style: TextStyle(color: textSub, fontSize: 11.5, fontWeight: FontWeight.w500)),
              ],
            )).toList(),
          ),
          const SizedBox(height: 8),
          Text('${_ports.length} ports  •  ${_routes.length} active routes  •  LIVE tracking', style: TextStyle(color: _kTeal, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PortNode {
  final String name;
  final double xRatio, yRatio;
  final String flag, type;
  const _PortNode(this.name, this.xRatio, this.yRatio, this.flag, this.type);
}

class _SeaRoute {
  final String from, to, mode;
  final Color color;
  const _SeaRoute(this.from, this.to, this.mode, this.color);
}

class _NetworkPainter extends CustomPainter {
  final double progress, pulse;
  final List<_PortNode> ports;
  final List<_SeaRoute> routes;
  final String selectedMode;
  final _PortNode? selectedPort;
  final bool isDark;

  const _NetworkPainter({
    required this.progress,
    required this.pulse,
    required this.ports,
    required this.routes,
    required this.selectedMode,
    required this.selectedPort,
    required this.isDark,
  });

  Offset _portOffset(String name, Size size) {
    final p = ports.firstWhere((p) => p.name == name, orElse: () => const _PortNode('', 0.5, 0.5, '', 'sea'));
    return Offset(p.xRatio * size.width, p.yRatio * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background grid
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw routes
    for (final route in routes) {
      final shouldShow = selectedMode == 'All' || route.mode.toLowerCase() == selectedMode.toLowerCase();
      if (!shouldShow) continue;

      final fromOffset = _portOffset(route.from, size);
      final toOffset = _portOffset(route.to, size);
      if (fromOffset == toOffset) continue;

      final dx = (toOffset.dx - fromOffset.dx) * 0.3;
      final cp = Offset(fromOffset.dx + dx, fromOffset.dy - 60);

      final path = Path()..moveTo(fromOffset.dx, fromOffset.dy)..quadraticBezierTo(cp.dx, cp.dy, toOffset.dx, toOffset.dy);
      final metrics = path.computeMetrics().toList();
      if (metrics.isEmpty) continue;
      final metric = metrics.first;

      // Base route line
      final basePaint = Paint()
        ..color = route.color.withValues(alpha: route.mode == 'air' ? 0.25 : 0.2)
        ..strokeWidth = route.mode == 'air' ? 1.5 : 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      if (route.mode == 'air') {
        basePaint.shader = null;
      }
      canvas.drawPath(path, basePaint);

      // Animated vessel/plane dot
      final dotProgress = (progress + routes.indexOf(route) * 0.15) % 1.0;
      final tang = metric.getTangentForOffset(dotProgress * metric.length);
      if (tang != null) {
        canvas.drawCircle(tang.position, route.mode == 'air' ? 4 : 5,
            Paint()..color = route.color);
        canvas.drawCircle(tang.position, route.mode == 'air' ? 2 : 3,
            Paint()..color = Colors.white);
      }
    }

    // Draw port nodes
    for (final port in ports) {
      final shouldShow = selectedMode == 'All' ||
          selectedMode == 'Sea' && port.type == 'sea' ||
          selectedMode == 'Air' && port.type == 'air' ||
          selectedMode == 'ICD' && port.type == 'ICD';
      if (!shouldShow) continue;

      final offset = Offset(port.xRatio * size.width, port.yRatio * size.height);
      final isSelected = selectedPort?.name == port.name;
      final color = port.type == 'air' ? const Color(0xFFFF6B00) : port.type == 'ICD' ? const Color(0xFF8B5CF6) : const Color(0xFF0D9488);
      final radius = isSelected ? 10.0 : 7.0;

      // Pulse ring for selected
      if (isSelected) {
        canvas.drawCircle(offset, radius + 8 + pulse * 6,
            Paint()..color = color.withValues(alpha: 0.15 * (1 - pulse)));
      }

      // Glow
      canvas.drawCircle(offset, radius + 4, Paint()..color = color.withValues(alpha: 0.15));
      // Port dot
      canvas.drawCircle(offset, radius, Paint()..color = color);
      canvas.drawCircle(offset, radius - 3, Paint()..color = Colors.white);

      // Flag emoji (TextPainter not usable in CustomPainter easily, skip — just use dot colors)
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => old.progress != progress || old.pulse != pulse || old.selectedMode != selectedMode || old.selectedPort != selectedPort;
}
