// frontend/lib/features/customer/presentation/rewards_screen.dart

import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  static const _offers = [
    _OfferData(
      title: 'First Shipment Free',
      desc: 'Book your first domestic delivery at zero cost.',
      discount: '100% OFF',
      color: AppColors.success,
      expiry: 'Expires Jun 30',
      icon: Icons.local_shipping_rounded,
    ),
    _OfferData(
      title: 'International Saver',
      desc: 'Save on customs-ready international shipments.',
      discount: '15% OFF',
      color: AppColors.primary,
      expiry: 'Global lanes',
      icon: Icons.flight_takeoff_rounded,
    ),
    _OfferData(
      title: 'Weekend Special',
      desc: 'Extra savings on weekend parcel bookings.',
      discount: '20% OFF',
      color: AppColors.portOrange,
      expiry: 'Weekends only',
      icon: Icons.card_giftcard_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const JdAppBar(
        title: 'Rewards & Offers',
        showBack: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 28 : 16,
                  16,
                  wide ? 28 : 16,
                  120,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RewardsHero(),
                        const SizedBox(height: 18),
                        GridView.count(
                          crossAxisCount: wide ? 3 : 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: wide ? 1.45 : 2.9,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            _RewardStat(
                              icon: Icons.stars_rounded,
                              label: 'JD Points',
                              value: '0 pts',
                              color: AppColors.portOrange,
                            ),
                            _RewardStat(
                              icon: Icons.local_shipping_rounded,
                              label: 'Earned Shipments',
                              value: '12',
                              color: AppColors.primary,
                            ),
                            _RewardStat(
                              icon: Icons.public_rounded,
                              label: 'Global Offers',
                              value: '3',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle(
                          title: 'Active Offers',
                          subtitle:
                              'Domestic and international logistics rewards',
                        ),
                        const SizedBox(height: 12),
                        ..._offers.map(
                          (offer) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OfferCard(offer: offer),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const _ReferralCard(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RewardsHero extends StatelessWidget {
  const _RewardsHero();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 34,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 176,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroRoutePainter(
                  dark: AppColors.isDark(context),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 4,
              right: 125,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Pill(
                    label: 'JD REWARDS CLUB',
                    icon: Icons.stars_rounded,
                    color: AppColors.portOrange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Earn rewards on every shipment.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ship more • Save more • Unlock global benefits',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 4,
              child: GlassCard(
                width: 112,
                height: 112,
                borderRadius: 36,
                padding: EdgeInsets.zero,
                color: AppColors.portOrange.withValues(
                  alpha: AppColors.isDark(context) ? 0.16 : 0.10,
                ),
                borderColor: AppColors.portOrange.withValues(alpha: 0.22),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.portOrange,
                  size: 56,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _Sticker(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
class _OfferCard extends StatefulWidget {
  final _OfferData offer;

  const _OfferCard({required this.offer});

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _down ? 0.985 : 1,
        duration: const Duration(milliseconds: 150),
        child: GlassCard(
          borderRadius: 30,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Sticker(icon: offer.icon, color: offer.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.subtext(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.expiry,
                      style: TextStyle(
                        color: offer.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: offer.color.withValues(
                    alpha: AppColors.isDark(context) ? 0.16 : 0.11,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: offer.color.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  offer.discount,
                  style: TextStyle(
                    color: offer.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Referral Program',
            subtitle: 'Invite friends and earn shipment credits',
          ),
          const SizedBox(height: 14),
          Text(
            'Refer a friend and earn ₹50 when they book their first shipment.',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 22,
            padding: const EdgeInsets.all(14),
            color: AppColors.surface(context),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'JD-REF-XXXX',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text(context),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Sticker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Sticker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: AppColors.isDark(context) ? 0.16 : 0.11,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}
class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Pill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: AppColors.isDark(context) ? 0.16 : 0.12,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRoutePainter extends CustomPainter {
  final bool dark;

  const _HeroRoutePainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.26 : 0.32)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * .15, size.height * .74)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .10,
        size.width * .86,
        size.height * .52,
      );

    canvas.drawPath(path, route);

    canvas.drawCircle(
      Offset(size.width * .24, size.height * .60),
      5,
      Paint()..color = AppColors.primary,
    );

    canvas.drawCircle(
      Offset(size.width * .72, size.height * .42),
      5,
      Paint()..color = AppColors.portOrange,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroRoutePainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class _OfferData {
  final String title;
  final String desc;
  final String discount;
  final Color color;
  final String expiry;
  final IconData icon;

  const _OfferData({
    required this.title,
    required this.desc,
    required this.discount,
    required this.color,
    required this.expiry,
    required this.icon,
  });
}