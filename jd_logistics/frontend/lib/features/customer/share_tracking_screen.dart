import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class ShareTrackingScreen extends StatefulWidget {
  final String id;
  const ShareTrackingScreen({super.key, this.id = 'JD-IND-2048'});

  @override
  State<ShareTrackingScreen> createState() => _ShareTrackingScreenState();
}

class _ShareTrackingScreenState extends State<ShareTrackingScreen> {
  bool _linkCopied = false;

  String get _trackingUrl =>
      'https://jdlogistics.in/track/${widget.id}';

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _trackingUrl));
    HapticFeedback.mediumImpact();
    setState(() => _linkCopied = true);
    Future.delayed(const Duration(seconds: 2),
        () { if (mounted) setState(() => _linkCopied = false); });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg2 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Share Tracking',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Order ID card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.id,
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5)),
                  Text('Mumbai → Delhi · In Transit',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.textDarkSecondary,
                          fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),

            // QR code placeholder
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('QR Code',
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 6),
                Text('Scan to open live tracking',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary,
                        fontSize: 12)),
                const SizedBox(height: 20),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.skyBorder,
                        width: 2),
                  ),
                  child: CustomPaint(painter: _QrPlaceholderPainter(isDark)),
                ),
                const SizedBox(height: 16),
                const Text('Valid for 72 hours',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 20),

            // Tracking link
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tracking Link',
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.skyBorder),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(_trackingUrl,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _copyLink,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _linkCopied
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            _linkCopied
                                ? Icons.check_rounded
                                : Icons.copy_rounded,
                            color: _linkCopied
                                ? AppColors.success
                                : AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _linkCopied ? 'Copied!' : 'Copy',
                            style: TextStyle(
                                color: _linkCopied
                                    ? AppColors.success
                                    : AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Share options
            Text('Share via',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  label: 'WhatsApp',
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  isDark: isDark,
                  onTap: () {},
                ),
                _ShareOption(
                  label: 'SMS',
                  icon: Icons.sms_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: () {},
                ),
                _ShareOption(
                  label: 'Email',
                  icon: Icons.email_rounded,
                  color: AppColors.saffron,
                  isDark: isDark,
                  onTap: () {},
                ),
                _ShareOption(
                  label: 'More',
                  icon: Icons.share_rounded,
                  color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),

            GradientButton(
              label: 'Share Tracking Link',
              onPressed: _copyLink,
              gradient: AppColors.primaryGradient,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _ShareOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

class _QrPlaceholderPainter extends CustomPainter {
  final bool isDark;
  _QrPlaceholderPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final block = size.width / 7;

    // Corner squares
    for (final pos in [
      Offset(block, block),
      Offset(size.width - block * 3, block),
      Offset(block, size.height - block * 3),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pos.dx, pos.dy, block * 2, block * 2),
          const Radius.circular(4),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              pos.dx + block * 0.3,
              pos.dy + block * 0.3,
              block * 1.4,
              block * 1.4),
          const Radius.circular(2),
        ),
        Paint()
          ..color = isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF)
          ..style = PaintingStyle.fill,
      );
    }

    // Random data blocks (mock QR pattern)
    final dataPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    const positions = [
      [3, 1], [4, 1], [3, 2], [5, 2], [1, 3], [3, 3], [4, 4],
      [5, 3], [1, 4], [2, 5], [3, 5], [4, 5], [5, 4], [5, 5],
    ];
    for (final p in positions) {
      canvas.drawRect(
        Rect.fromLTWH(
            p[0] * block + 4, p[1] * block + 4, block - 6, block - 6),
        dataPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QrPlaceholderPainter old) =>
      old.isDark != isDark;
}
