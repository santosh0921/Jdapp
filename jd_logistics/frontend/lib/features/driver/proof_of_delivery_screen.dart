import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class ProofOfDeliveryScreen extends StatefulWidget {
  const ProofOfDeliveryScreen({super.key});

  @override
  State<ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends State<ProofOfDeliveryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _successController;

  bool _photoTaken = false;
  bool _signatureObtained = false;
  bool _otpVerified = false;
  bool _notesAdded = false;

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool get _canConfirm => _photoTaken && _signatureObtained && _otpVerified;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _successController.dispose();
    _otpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _dark(context) ? AppColors.darkBg1 : const Color(0xFFFFFFFF);

  Color _surface(BuildContext context) =>
      _dark(context) ? AppColors.darkCard : const Color(0xFFF8FAFF);

  Color _text(BuildContext context) =>
      _dark(context) ? Colors.white : const Color(0xFF0F172A);

  Color _sub(BuildContext context) =>
      _dark(context) ? Colors.white70 : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            const _PodBackground(),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: Curves.easeOut,
              ),
              child: Column(
                children: [
                  _Header(
                    textColor: _text(context),
                    subTextColor: _sub(context),
                    surfaceColor: _surface(context),
                    onBack: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) context.pop();
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                      child: Column(
                        children: [
                          _HeroCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _ChecklistCard(
                            photoTaken: _photoTaken,
                            signatureObtained: _signatureObtained,
                            otpVerified: _otpVerified,
                            notesAdded: _notesAdded,
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _ProofActionCard(
                            title: 'Delivery Photo',
                            subtitle: _photoTaken
                                ? 'Parcel photo captured successfully'
                                : 'Tap to capture parcel handover photo',
                            icon: _photoTaken
                                ? Icons.check_circle_rounded
                                : Icons.camera_alt_rounded,
                            active: _photoTaken,
                            color: AppColors.success,
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() => _photoTaken = true);
                            },
                          ),
                          const SizedBox(height: 14),
                          _ProofActionCard(
                            title: 'Customer Signature',
                            subtitle: _signatureObtained
                                ? 'Customer signature collected'
                                : 'Tap to collect customer digital signature',
                            icon: _signatureObtained
                                ? Icons.check_circle_rounded
                                : Icons.draw_rounded,
                            active: _signatureObtained,
                            color: const Color(0xFF0B5FFF),
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() => _signatureObtained = true);
                            },
                          ),
                          const SizedBox(height: 14),
                          _OtpCard(
                            controller: _otpController,
                            verified: _otpVerified,
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                            onVerify: () {
                              HapticFeedback.mediumImpact();
                              setState(() => _otpVerified = true);
                            },
                          ),
                          const SizedBox(height: 14),
                          _NotesCard(
                            controller: _notesController,
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                            onChanged: (value) {
                              setState(() {
                                _notesAdded = value.trim().isNotEmpty;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _ObcRewardCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 18),
                          _ConfirmButton(
                            enabled: _canConfirm,
                            onTap: _canConfirm
                                ? () {
                                    HapticFeedback.mediumImpact();
                                    _successController.forward(from: 0);
                                    _showSuccessDialog(context);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _successController,
                builder: (context, _) {
                  final scale = 0.88 + (_successController.value * 0.18);
                  final rotate = math.sin(_successController.value * math.pi) * .08;

                  return Transform.rotate(
                    angle: rotate,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        height: 86,
                        width: 86,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: .13),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Delivery Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '+25 OBC added to your driver rewards wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    dialogContext.pop();
                    context.go('/driver/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final VoidCallback onBack;

  const _Header({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          _ClayButton(
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFF0B5FFF),
            surfaceColor: surfaceColor,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #JD-2024-003',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Proof of Delivery',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ClayButton(
            icon: Icons.verified_user_rounded,
            color: AppColors.success,
            surfaceColor: surfaceColor,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _HeroCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StatusPill(),
                  const SizedBox(height: 12),
                  Text(
                    'Complete secure handover',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Photo, OTP, signature and OBC reward confirmation.',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 96,
            width: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFF0B5FFF),
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final bool photoTaken;
  final bool signatureObtained;
  final bool otpVerified;
  final bool notesAdded;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _ChecklistCard({
    required this.photoTaken,
    required this.signatureObtained,
    required this.otpVerified,
    required this.notesAdded,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _CheckChip(label: 'Photo', done: photoTaken),
          _CheckChip(label: 'Signature', done: signatureObtained),
          _CheckChip(label: 'OTP', done: otpVerified),
          _CheckChip(label: 'Notes', done: notesAdded),
        ],
      ),
    );
  }
}

class _ProofActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final Color color;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _ProofActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.color,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: active
                          ? color.withValues(alpha: .35)
                          : color.withValues(alpha: .10),
                    ),
                  ),
                  child: Icon(icon, color: color, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  active
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: active ? AppColors.success : subTextColor,
                  size: active ? 24 : 17,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpCard extends StatelessWidget {
  final TextEditingController controller;
  final bool verified;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final VoidCallback onVerify;

  const _OtpCard({
    required this.controller,
    required this.verified,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Customer OTP',
            trailing: verified ? 'Verified' : 'Required',
            textColor: textColor,
            subTextColor: verified ? AppColors.success : subTextColor,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !verified,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter 6-digit OTP',
                    filled: true,
                    fillColor: const Color(0xFFEAF6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _SmallButton(
                label: verified ? 'Done' : 'Verify',
                color: verified ? AppColors.success : const Color(0xFF0B5FFF),
                onTap: verified ? null : onVerify,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final TextEditingController controller;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final ValueChanged<String> onChanged;

  const _NotesCard({
    required this.controller,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Delivery Notes',
            trailing: 'Optional',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Example: Delivered to customer at main gate.',
              filled: true,
              fillColor: const Color(0xFFEAF6FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObcRewardCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _ObcRewardCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A00).withValues(alpha: .14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFFF8A00),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+25 OBC Reward Ready',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Complete proof to claim One Bharat Coin reward.',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _ConfirmButton({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.success : Colors.grey.withValues(alpha: .35),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_rounded,
                color: enabled ? Colors.white : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    enabled
                        ? 'Confirm Delivery'
                        : 'Complete Required Proofs',
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
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

class _ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color surfaceColor;

  const _ClayCard({
    required this.child,
    required this.surfaceColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .05)
              : const Color(0xFFDFEAFF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .24 : .075),
            blurRadius: 22,
            offset: const Offset(10, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: dark ? .03 : .92),
            blurRadius: 18,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ClayButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _ClayButton({
    required this.icon,
    required this.color,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: color.withValues(alpha: .14)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SmallButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckChip extends StatelessWidget {
  final String label;
  final bool done;

  const _CheckChip({
    required this.label,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String trailing;
  final Color textColor;
  final Color subTextColor;

  const _CardTitle({
    required this.title,
    required this.trailing,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            trailing,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: .22)),
      ),
      child: const Text(
        'SECURE POD • REQUIRED',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class _PodBackground extends StatelessWidget {
  const _PodBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PodBackgroundPainter(
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _PodBackgroundPainter extends CustomPainter {
  final bool dark;

  const _PodBackgroundPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: dark ? .08 : .06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(-20, size.height * .16)
      ..cubicTo(size.width * .25, size.height * .08, size.width * .60,
          size.height * .30, size.width + 20, size.height * .18);

    final p2 = Path()
      ..moveTo(size.width + 20, size.height * .64)
      ..cubicTo(size.width * .70, size.height * .52, size.width * .42,
          size.height * .80, -20, size.height * .72);

    canvas.drawPath(p1, routePaint);
    canvas.drawPath(p2, routePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: dark ? .10 : .15);

    for (int i = 0; i < 18; i++) {
      final x = ((i * 53) % size.width).toDouble();
      final y = (55 + ((i * 97) % size.height)).toDouble();
      canvas.drawCircle(Offset(x, y), 2.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PodBackgroundPainter oldDelegate) =>
      oldDelegate.dark != dark;
}