import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleData {
  final String key;
  final String label;
  final String desc;
  final String tag;
  final IconData icon;
  final String emoji;
  final Color color;
  final List<IconData> heroIcons;

  const _RoleData({
    required this.key,
    required this.label,
    required this.desc,
    required this.tag,
    required this.icon,
    required this.emoji,
    required this.color,
    required this.heroIcons,
  });
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;
  late final AnimationController _motion;

  static const List<_RoleData> _roles = [
    _RoleData(
      key: 'courier_customer',
      label: 'Customer',
      desc: 'Book parcels, track domestic shipments, manage payments and support.',
      tag: 'Courier Customer',
      icon: Icons.person_rounded,
      emoji: '📦',
      color: AppColors.customerColor,
      heroIcons: [
        Icons.inventory_2_rounded,
        Icons.location_on_rounded,
        Icons.payment_rounded,
      ],
    ),
    _RoleData(
      key: 'courier_driver',
      label: 'Driver',
      desc: 'Manage pickups, delivery routes, proof of delivery and earnings.',
      tag: 'Delivery Hero',
      icon: Icons.delivery_dining_rounded,
      emoji: '🚚',
      color: AppColors.driverColor,
      heroIcons: [
        Icons.route_rounded,
        Icons.local_shipping_rounded,
        Icons.task_alt_rounded,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

Future<void> _proceed() async {
  if (_selected == null) return;

  HapticFeedback.mediumImpact();

  final auth = context.read<AuthProvider>();

  await auth.selectLoginRole(_selected!);

  if (!mounted) return;

  context.go('/login');
}
  

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: GradientBackground(
        child: AnimatedBuilder(
          animation: _motion,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoleBackgroundPainter(
                      progress: _motion.value,
                      dark: AppColors.isDark(context),
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 860;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          wide ? 32 : 18,
                          18,
                          wide ? 32 : 18,
                          28,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: wide ? 1120 : 540,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GlassCard(
                                      width: 48,
                                      height: 48,
                                      borderRadius: 18,
                                      padding: EdgeInsets.zero,
                                      onTap: () => context.go('/service-selection'),
                                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 19),
                                    ),
                                    const _ThemeToggle(),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _Header(progress: _motion.value),
                                const SizedBox(height: 18),
                                _RouteControlStrip(progress: _motion.value),
                                const SizedBox(height: 18),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _roles.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: wide ? 2 : 1,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                    childAspectRatio: wide ? 1.46 : 1.42,
                                  ),
                                  itemBuilder: (context, index) {
                                    final role = _roles[index];

                                    return _RoleCard(
                                      role: role,
                                      progress: _motion.value,
                                      selected: _selected == role.key,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selected = role.key);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                AnimatedOpacity(
                                  opacity: _selected != null ? 1 : 0.45,
                                  duration: const Duration(milliseconds: 220),
                                  child: GradientButton(
                                    label: _selected == null
                                        ? 'Select Role'
                                        : 'Continue',
                                    isLoading: auth.isLoading,
                                    onPressed:
                                        _selected != null ? _proceed : null,
                                    colors: AppColors.primaryGradient,
                                    icon: Icons.arrow_forward_rounded,
                                    height: 58,
                                    borderRadius: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final dark = AppColors.isDark(context);

    return GlassCard(
      width: 48,
      height: 48,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      onTap: theme.toggleTheme,
      child: Icon(
        dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: dark ? AppColors.portOrange : AppColors.primary,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double progress;

  const _Header({required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GlassCard(
            width: 76,
            height: 76,
            borderRadius: 26,
            padding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.hub_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
                Positioned(
                  right: 8 + math.sin(progress * math.pi * 2) * 3,
                  bottom: 8,
                  child: const Text('🚚', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Courier Role',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your courier role for domestic parcel and last-mile delivery.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteControlStrip extends StatelessWidget {
  final double progress;

  const _RouteControlStrip({required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 86,
      borderRadius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const _MiniNode(icon: Icons.warehouse_rounded, label: 'Hub'),
          const SizedBox(width: 12),
          Expanded(
            child: CustomPaint(
              painter: _DashedRoutePainter(
                progress: progress,
                dark: AppColors.isDark(context),
              ),
              child: const SizedBox(height: 42),
            ),
          ),
          const SizedBox(width: 12),
          const _MiniNode(icon: Icons.flag_rounded, label: 'Global'),
        ],
      ),
    );
  }
}

class _MiniNode extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniNode({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final _RoleData role;
  final double progress;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.progress,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.985 : (active ? 1.012 : 1),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: GlassCard(
            borderRadius: 34,
            padding: const EdgeInsets.all(16),
            borderColor: widget.selected
                ? widget.role.color.withOpacity(0.75)
                : AppColors.border(context),
            child: Row(
              children: [
                _RoleHeroLogo(
                  role: widget.role,
                  progress: widget.progress,
                  selected: widget.selected,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _RoleInfo(role: widget.role),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: widget.selected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('selected'),
                          color: widget.role.color,
                          size: 30,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey('unselected'),
                          color: AppColors.subtext(context).withOpacity(0.55),
                          size: 28,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleHeroLogo extends StatelessWidget {
  final _RoleData role;
  final double progress;
  final bool selected;

  const _RoleHeroLogo({
    required this.role,
    required this.progress,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final wave = math.sin((progress * math.pi * 2) + role.key.length) * 5;

    return GlassCard(
      width: 108,
      height: 108,
      borderRadius: 34,
      padding: const EdgeInsets.all(10),
      color: role.color.withOpacity(AppColors.isDark(context) ? 0.14 : 0.08),
      borderColor: role.color.withOpacity(selected ? 0.55 : 0.20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 6,
            left: 8,
            child: Icon(
              role.heroIcons[0],
              color: role.color.withOpacity(0.85),
              size: 22,
            ),
          ),
          Positioned(
            top: 6,
            right: 8,
            child: Icon(
              role.heroIcons[1],
              color: role.color.withOpacity(0.65),
              size: 20,
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Icon(
              role.heroIcons[2],
              color: role.color.withOpacity(0.70),
              size: 20,
            ),
          ),
          Transform.translate(
            offset: Offset(0, wave * 0.35),
            child: Icon(
              role.icon,
              color: role.color,
              size: 44,
            ),
          ),
          Positioned(
            bottom: 6,
            left: 8 + wave,
            child: Text(
              role.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Positioned(
            left: 13 + wave,
            bottom: 35,
            child: Icon(
              Icons.local_shipping_rounded,
              size: 15,
              color: AppColors.subtext(context).withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleInfo extends StatelessWidget {
  final _RoleData role;

  const _RoleInfo({required this.role});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 245,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TagBadge(text: role.tag, color: role.color),
            const SizedBox(height: 9),
            Text(
              role.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              role.desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _TagBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(AppColors.isDark(context) ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _DashedRoutePainter extends CustomPainter {
  final double progress;
  final bool dark;

  _DashedRoutePainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;

    final paint = Paint()
      ..color = AppColors.primary.withOpacity(dark ? 0.65 : 0.80)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double x = -(progress * 26);

    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + 12, y), paint);
      x += 26;
    }

    final nodePaint = Paint()
      ..color = dark ? AppColors.darkCard : Colors.white;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final dx in [size.width * .28, size.width * .58, size.width * .84]) {
      canvas.drawCircle(Offset(dx, y), 7, nodePaint);
      canvas.drawCircle(Offset(dx, y), 7, borderPaint);
    }

    final truckPainter = TextPainter(
      text: const TextSpan(text: '🚚', style: TextStyle(fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();

    truckPainter.paint(
      canvas,
      Offset((size.width + 44) * progress - 22, y - 28),
    );

    final planePainter = TextPainter(
      text: const TextSpan(text: '✈️', style: TextStyle(fontSize: 17)),
      textDirection: TextDirection.ltr,
    )..layout();

    planePainter.paint(
      canvas,
      Offset(size.width - ((size.width + 50) * progress), y + 6),
    );
  }

  @override
  bool shouldRepaint(covariant _DashedRoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

class _RoleBackgroundPainter extends CustomPainter {
  final double progress;
  final bool dark;

  _RoleBackgroundPainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintRoutes(canvas, size);
    _paintMovingCargo(canvas, size);
    _paintContainers(canvas, size);
  }

  void _paintRoutes(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (dark ? AppColors.primaryLight : AppColors.routeLine)
          .withOpacity(dark ? 0.16 : 0.22)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routes = [
      Path()
        ..moveTo(size.width * .08, size.height * .30)
        ..quadraticBezierTo(
          size.width * .38,
          size.height * .10,
          size.width * .83,
          size.height * .26,
        ),
      Path()
        ..moveTo(size.width * .12, size.height * .78)
        ..quadraticBezierTo(
          size.width * .45,
          size.height * .58,
          size.width * .88,
          size.height * .72,
        ),
      Path()
        ..moveTo(size.width * .16, size.height * .54)
        ..quadraticBezierTo(
          size.width * .50,
          size.height * .38,
          size.width * .82,
          size.height * .52,
        ),
    ];

    for (final path in routes) {
      canvas.drawPath(path, routePaint);
    }
  }

  void _paintMovingCargo(Canvas canvas, Size size) {
    _drawEmoji(
      canvas,
      '🚚',
      Offset(
        (size.width + 80) * progress - 40,
        size.height * .33 + math.sin(progress * math.pi * 2) * 8,
      ),
      24,
    );

    _drawEmoji(
      canvas,
      '✈️',
      Offset(
        size.width - ((size.width + 90) * progress),
        size.height * .58 + math.cos(progress * math.pi * 2) * 10,
      ),
      25,
    );

    _drawEmoji(
      canvas,
      '🚢',
      Offset(
        (size.width + 120) * ((progress + .38) % 1) - 60,
        size.height * .84,
      ),
      22,
    );
  }

  void _paintContainers(Canvas canvas, Size size) {
    final baseY = size.height * .92;

    for (int i = 0; i < 7; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * (.05 + i * .13),
          baseY - (i.isEven ? 0 : 18),
          76,
          34,
        ),
        const Radius.circular(8),
      );

      final paint = Paint()
        ..color = (dark ? AppColors.darkCard : Colors.white)
            .withOpacity(dark ? 0.10 : 0.34);

      final border = Paint()
        ..color = (dark ? AppColors.darkBorder : AppColors.routeLine)
            .withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawRRect(rect, paint);
      canvas.drawRRect(rect, border);
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset offset, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _RoleBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}