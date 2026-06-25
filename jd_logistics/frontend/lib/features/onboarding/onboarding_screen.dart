import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _moveCtrl;

  int _current = 0;

  static const _pages = [
    _OnboardingData(
      title: 'Book Shipments in Seconds',
      desc:
          'Domestic, Express, Freight and International shipping from one platform.',
      icon: Icons.inventory_2_rounded,
      accentIcon: Icons.local_shipping_rounded,
      hero: '👨‍✈️',
      scene: 'Warehouse pickup • Parcel handover • Fast dispatch',
      cta: 'Book & Ship',
      color: Color(0xFF2563EB),
    ),
    _OnboardingData(
      title: 'Track Every Shipment Live',
      desc: 'Monitor vehicles, warehouses and delivery progress in real time.',
      icon: Icons.route_rounded,
      accentIcon: Icons.flight_takeoff_rounded,
      hero: '👩‍💼',
      scene: 'Live map • Route markers • Cargo movement',
      cta: 'Track Logistics',
      color: Color(0xFFFF8A00),
    ),
    _OnboardingData(
      title: 'Trusted Global Logistics',
      desc:
          'Reliable logistics network connecting cities, states and countries.',
      icon: Icons.verified_rounded,
      accentIcon: Icons.public_rounded,
      hero: '🌎',
      scene: 'Global routes • Secure delivery • Verified network',
      cta: 'Enter JD Logistics',
      color: Color(0xFF16A34A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _moveCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _current == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF08111F) : const Color(0xFFEAF4FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _moveCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _MovingLogisticsBackground(
                    progress: _moveCtrl.value,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 12),
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (_, i) => _OnboardingPage(
                      data: _pages[i],
                      isDark: isDark,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: _current == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _current == i
                                  ? _pages[_current].color
                                  : isDark
                                      ? Colors.white24
                                      : const Color(0xFFBDD2EA),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: isLast ? 'Enter JD Logistics' : _pages[_current].cta,
                        onPressed: _next,
                        colors: AppColors.primaryGradient,
                        icon: isLast
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final bool isDark;

  const _OnboardingPage({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 48 : 24,
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: _HeroClayScene(data: data, isDark: isDark)),
                        const SizedBox(width: 34),
                        Expanded(child: _TextContent(data: data, isDark: isDark)),
                      ],
                    )
                  : Column(
                      children: [
                        _HeroClayScene(data: data, isDark: isDark),
                        const SizedBox(height: 34),
                        _TextContent(data: data, isDark: isDark),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroClayScene extends StatelessWidget {
  final _OnboardingData data;
  final bool isDark;

  const _HeroClayScene({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      isDark: isDark,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 390,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SceneRoutePainter(isDark: isDark, color: data.color),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: _ScenePill(
                label: data.scene,
                color: data.color,
                isDark: isDark,
              ),
            ),
            Positioned(
              right: 8,
              top: 48,
              child: _ClayIcon(
                isDark: isDark,
                icon: data.accentIcon,
                color: data.color,
              ),
            ),
            Positioned(
              left: 12,
              bottom: 28,
              child: _CharacterTile(
                isDark: isDark,
                emoji: data.hero,
                label: data.title.contains('Track')
                    ? 'JD Ops'
                    : data.title.contains('Global')
                        ? 'Global'
                        : 'JD Hero',
                color: data.color,
              ),
            ),
            Center(
              child: _MainIconCard(
                isDark: isDark,
                data: data,
              ),
            ),
            const Positioned(
              left: 30,
              top: 78,
              child: _SmallLogisticsSticker(
                icon: Icons.local_shipping_rounded,
                color: Color(0xFF2563EB),
              ),
            ),
            const Positioned(
              right: 34,
              bottom: 62,
              child: _SmallLogisticsSticker(
                icon: Icons.flight_takeoff_rounded,
                color: Color(0xFFFF8A00),
              ),
            ),
            const Positioned(
              left: 142,
              bottom: 24,
              child: _SmallLogisticsSticker(
                icon: Icons.warehouse_rounded,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainIconCard extends StatelessWidget {
  final bool isDark;
  final _OnboardingData data;

  const _MainIconCard({
    required this.isDark,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 168,
      decoration: _clayDecoration(
        isDark: isDark,
        radius: 42,
        baseColor: isDark ? const Color(0xFF102034) : const Color(0xFFF8FBFF),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 72, color: data.color),
          const SizedBox(height: 12),
          Container(
            width: 86,
            height: 8,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final _OnboardingData data;
  final bool isDark;

  const _TextContent({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScenePill(
          label: 'JD LOGISTICS',
          color: data.color,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Text(
          data.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -0.7,
              ),
        ),
        const SizedBox(height: 14),
        Text(
          data.desc,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: subColor,
                height: 1.55,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 22),
        _ClayCard(
          isDark: isDark,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, color: data.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _screenLine(data.title),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _screenLine(String title) {
    if (title.contains('Book')) {
      return 'Create shipment orders for parcels, documents, freight and global routes.';
    }
    if (title.contains('Track')) {
      return 'Follow route movement across pickup points, hubs, vehicles and delivery zones.';
    }
    return 'Move shipments securely through trusted domestic and international lanes.';
  }
}

class _CharacterTile extends StatelessWidget {
  final bool isDark;
  final String emoji;
  final String label;
  final Color color;

  const _CharacterTile({
    required this.isDark,
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: _clayDecoration(
        isDark: isDark,
        radius: 26,
        baseColor: isDark ? const Color(0xFF102034) : const Color(0xFFF8FBFF),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 46)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClayIcon extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;

  const _ClayIcon({
    required this.isDark,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: _clayDecoration(
        isDark: isDark,
        radius: 20,
        baseColor: isDark ? const Color(0xFF102034) : const Color(0xFFF8FBFF),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _SmallLogisticsSticker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SmallLogisticsSticker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color.withValues(alpha: 0.72), size: 28);
  }
}

class _ScenePill extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _ScenePill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ClayCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry padding;

  const _ClayCard({
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: _clayDecoration(
        isDark: isDark,
        radius: 34,
        baseColor: isDark ? const Color(0xFF0E1B2E) : const Color(0xFFF8FBFF),
      ),
      child: child,
    );
  }
}

class _MovingLogisticsBackground extends CustomPainter {
  final double progress;
  final bool isDark;

  _MovingLogisticsBackground({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF2563EB))
          .withValues(alpha: isDark ? 0.08 : 0.09)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(-100 + size.width * progress, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.05,
        size.width + 120,
        size.height * 0.24,
      );

    final path2 = Path()
      ..moveTo(size.width + 100 - size.width * progress, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.56,
        -120,
        size.height * 0.82,
      );

    canvas.drawPath(path1, routePaint);
    canvas.drawPath(path2, routePaint);

    _drawIcon(
      canvas,
      Icons.local_shipping_rounded,
      Offset(size.width * progress, size.height * 0.30),
      const Color(0xFF2563EB),
    );

    _drawIcon(
      canvas,
      Icons.flight_takeoff_rounded,
      Offset(size.width * (1 - progress), size.height * 0.15),
      const Color(0xFFFF8A00),
    );

    _drawIcon(
      canvas,
      Icons.warehouse_rounded,
      Offset(size.width * 0.08, size.height * 0.76),
      isDark ? Colors.white38 : const Color(0xFF2563EB),
    );

    _drawIcon(
      canvas,
      Icons.directions_boat_rounded,
      Offset(size.width * 0.78, size.height * 0.80),
      const Color(0xFF16A34A),
    );

    final nodePaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF2563EB))
          .withValues(alpha: 0.08);

    for (final p in [
      Offset(size.width * 0.14, size.height * 0.22),
      Offset(size.width * 0.62, size.height * 0.18),
      Offset(size.width * 0.84, size.height * 0.68),
      Offset(size.width * 0.24, size.height * 0.80),
    ]) {
      canvas.drawCircle(p, 4, nodePaint);
    }
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 26,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color.withValues(alpha: 0.18),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MovingLogisticsBackground oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

class _SceneRoutePainter extends CustomPainter {
  final bool isDark;
  final Color color;

  _SceneRoutePainter({
    required this.isDark,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = color.withValues(alpha: isDark ? 0.20 : 0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.16,
        size.width * 0.88,
        size.height * 0.38,
      );

    canvas.drawPath(path, route);

    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.62),
      5,
      Paint()..color = const Color(0xFF2563EB),
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.40),
      5,
      Paint()..color = const Color(0xFFFF8A00),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

BoxDecoration _clayDecoration({
  required bool isDark,
  double radius = 28,
  Color? baseColor,
}) {
  final bg = baseColor ?? (isDark ? const Color(0xFF0E1B2E) : const Color(0xFFF8FBFF));

  return BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: isDark
        ? const [
            BoxShadow(
              color: Color(0xFF050A12),
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Color(0xFF1A314D),
              offset: Offset(-7, -7),
              blurRadius: 14,
            ),
          ]
        : const [
            BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Color(0xFFBDD2EA),
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
          ],
  );
}

class _OnboardingData {
  final String title;
  final String desc;
  final IconData icon;
  final IconData accentIcon;
  final String hero;
  final String scene;
  final String cta;
  final Color color;

  const _OnboardingData({
    required this.title,
    required this.desc,
    required this.icon,
    required this.accentIcon,
    required this.hero,
    required this.scene,
    required this.cta,
    required this.color,
  });
}