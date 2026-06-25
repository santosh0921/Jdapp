import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class DeliveryRatingScreen extends StatefulWidget {
  final String id;
  const DeliveryRatingScreen({super.key, this.id = 'JD-IND-2048'});

  @override
  State<DeliveryRatingScreen> createState() => _DeliveryRatingScreenState();
}

class _DeliveryRatingScreenState extends State<DeliveryRatingScreen> {
  int _overallRating = 0;
  int _driverRating = 0;
  int _packagingRating = 0;
  int _speedRating = 0;
  final _commentCtrl = TextEditingController();
  final _selectedTags = <String>{};
  bool _submitted = false;

  static const _positiveTags = [
    'On Time', 'Professional Driver', 'Well Packaged',
    'Fast Delivery', 'Easy Tracking', 'Good Communication',
  ];
  static const _negativeTags = [
    'Late Delivery', 'Damaged Package', 'Poor Communication',
    'Tracking Issues', 'Rude Driver',
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    if (_submitted) {
      return _ThankYouView(
        rating: _overallRating,
        orderId: widget.id,
        isDark: isDark,
        onDone: () => context.pop(),
      );
    }

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
        title: Text('Rate Delivery',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Delivery banner
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivered Successfully!',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            Text(widget.id,
                                style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkSubtext
                                        : AppColors.textDarkSecondary,
                                    fontSize: 12)),
                            const Text('Mumbai → Delhi · Jun 20, 2026',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Overall rating
                  Text('How was your overall experience?',
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  _StarRow(
                    rating: _overallRating,
                    size: 42,
                    onRate: (r) => setState(() => _overallRating = r),
                  ),
                  if (_overallRating > 0) ...[
                    const SizedBox(height: 8),
                    Text(_ratingLabel(_overallRating),
                        style: TextStyle(
                            color: _ratingColor(_overallRating),
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ],
                  const SizedBox(height: 24),

                  // Detailed ratings
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _RatingRow(
                          label: 'Driver',
                          icon: Icons.motorcycle_rounded,
                          color: AppColors.driverColor,
                          rating: _driverRating,
                          isDark: isDark,
                          onRate: (r) => setState(() => _driverRating = r)),
                      const SizedBox(height: 14),
                      _RatingRow(
                          label: 'Packaging',
                          icon: Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          rating: _packagingRating,
                          isDark: isDark,
                          onRate: (r) => setState(() => _packagingRating = r)),
                      const SizedBox(height: 14),
                      _RatingRow(
                          label: 'Speed',
                          icon: Icons.bolt_rounded,
                          color: AppColors.warning,
                          rating: _speedRating,
                          isDark: isDark,
                          onRate: (r) => setState(() => _speedRating = r)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('What went well?',
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _positiveTags
                        .map((t) => _TagChip(
                              label: t,
                              selected: _selectedTags.contains(t),
                              color: AppColors.success,
                              isDark: isDark,
                              onTap: () => setState(() {
                                _selectedTags.contains(t)
                                    ? _selectedTags.remove(t)
                                    : _selectedTags.add(t);
                              }),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Anything to improve?',
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _negativeTags
                        .map((t) => _TagChip(
                              label: t,
                              selected: _selectedTags.contains(t),
                              color: AppColors.error,
                              isDark: isDark,
                              onTap: () => setState(() {
                                _selectedTags.contains(t)
                                    ? _selectedTags.remove(t)
                                    : _selectedTags.add(t);
                              }),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Comment
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: TextField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Add a comment (optional)...',
                        hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkHint),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg2 : Colors.white,
              border: Border(
                  top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.skyBorder)),
            ),
            child: GradientButton(
              label: _overallRating == 0
                  ? 'Select a Rating First'
                  : 'Submit Rating',
              onPressed: _overallRating == 0 ? null : _submit,
              gradient: AppColors.primaryGradient,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  static String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Very Poor';
      case 2: return 'Poor';
      case 3: return 'Average';
      case 4: return 'Good';
      default: return 'Excellent!';
    }
  }

  static Color _ratingColor(int r) {
    if (r <= 2) return AppColors.error;
    if (r == 3) return AppColors.warning;
    return AppColors.success;
  }
}

class _StarRow extends StatelessWidget {
  final int rating;
  final double size;
  final ValueChanged<int> onRate;
  const _StarRow(
      {required this.rating, required this.size, required this.onRate});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (i) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRate(i + 1);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < rating ? AppColors.warning : AppColors.darkSubtext,
                size: size,
              ),
            ),
          ),
        ),
      );
}

class _RatingRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int rating;
  final bool isDark;
  final ValueChanged<int> onRate;
  const _RatingRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.rating,
    required this.isDark,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
        const Spacer(),
        Row(children: List.generate(
          5,
          (i) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRate(i + 1);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < rating ? AppColors.warning : AppColors.darkSubtext,
                size: 22,
              ),
            ),
          ),
        )),
      ]);
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _TagChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected
                    ? color
                    : (isDark ? AppColors.darkBorder : AppColors.skyBorder)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected
                      ? color
                      : isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ),
      );
}

class _ThankYouView extends StatelessWidget {
  final int rating;
  final String orderId;
  final bool isDark;
  final VoidCallback onDone;
  const _ThankYouView(
      {required this.rating,
      required this.orderId,
      required this.isDark,
      required this.onDone});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.thumb_up_rounded,
                      color: AppColors.success, size: 48),
                ),
                const SizedBox(height: 24),
                Text('Thank You!',
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Your $rating-star rating for $orderId\nhas been submitted.',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary,
                        fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Back to Home',
                  onPressed: onDone,
                  gradient: AppColors.primaryGradient,
                  height: 52,
                ),
              ],
            ),
          ),
        ),
      );
}
