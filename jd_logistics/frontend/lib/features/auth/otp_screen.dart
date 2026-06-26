import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';


class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({
    super.key,
    required this.phone,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _CountryInfo {
  final String countryCode;
  final String countryName;
  final String flag;
  final String dialCode;
  final String region;
  final String currency;
  final String language;

  const _CountryInfo({
    required this.countryCode,
    required this.countryName,
    required this.flag,
    required this.dialCode,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final TextEditingController _otpCtrl = TextEditingController();
  final FocusNode _otpNode = FocusNode();

  Timer? _timer;
  int _seconds = 30;

  bool _verifying = false;
  bool _celebrating = false;
  bool _navigating = false;
  String? _errorMessage;

  _CountryInfo _countryInfo = const _CountryInfo(
    countryCode: 'IN',
    countryName: 'India',
    flag: '🇮🇳',
    dialCode: '+91',
    region: 'Asia',
    currency: 'INR',
    language: 'English / Hindi',

    
  );

  late final AnimationController _motion;
  late final AnimationController _shakeCtrl;
  late final AnimationController _celebrationCtrl;
  late final AnimationController _tickCtrl;

  late final Animation<double> _shake;
  late final Animation<double> _tickScale;

  @override
  void initState() {
    super.initState();

    _loadCountryInfo();
    _startTimer();

    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _celebrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _shake = CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut);

    _tickScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tickCtrl, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _otpNode.dispose();
    _motion.dispose();
    _shakeCtrl.dispose();
    _celebrationCtrl.dispose();
    _tickCtrl.dispose();
    super.dispose();
  }
Future<void> _resendOtp() async {
  HapticFeedback.lightImpact();

  _otpCtrl.clear();
  setState(() => _errorMessage = null);

  // Actually call the backend to send a fresh OTP.
  final phone = Uri.decodeComponent(widget.phone);
  final auth = context.read<AuthProvider>();
  await auth.sendOtp(phone);

  if (!mounted) return;

  _startTimer();
  _otpNode.requestFocus();
}
  String get _otp => _otpCtrl.text.trim();

  Future<void> _loadCountryInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _countryInfo = _CountryInfo(
        countryCode: prefs.getString('countryCode') ?? 'IN',
        countryName: prefs.getString('countryName') ?? 'India',
        flag: prefs.getString('flag') ?? '🇮🇳',
        dialCode: prefs.getString('dialCode') ?? '+91',
        region: prefs.getString('region') ?? 'Asia',
        currency: prefs.getString('currency') ?? 'INR',
        language: prefs.getString('language') ?? 'English / Hindi',
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (mounted) setState(() => _seconds = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_seconds <= 0) {
        timer.cancel();
        return;
      }

      setState(() => _seconds--);
    });
  }

  void _onOtpChanged(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = cleaned.length > 6 ? cleaned.substring(0, 6) : cleaned;

    if (_otpCtrl.text != limited) {
      _otpCtrl.value = TextEditingValue(
        text: limited,
        selection: TextSelection.collapsed(offset: limited.length),
      );
      return;
    }

    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    } else {
      setState(() {});
    }

    HapticFeedback.selectionClick();

    if (limited.length == 6) _verify();
  }

  Future<void> _verify() async {
    if (_otp.length != 6 || _verifying || _navigating) return;

    setState(() {
      _verifying = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final phone = Uri.decodeComponent(widget.phone);
    final ok = await auth.verifyOtp(phone, _otp);

    if (!mounted) return;

    setState(() => _verifying = false);

    if (ok) {
      await _playCelebration();
    } else {
      setState(() {
        _errorMessage = auth.error ?? 'Incorrect OTP. Please try again.';
      });
      _shakeCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _playCelebration() async {
    if (_navigating) return;

    _navigating = true;
    _timer?.cancel();

    setState(() => _celebrating = true);

    HapticFeedback.heavyImpact();

    _tickCtrl.forward(from: 0);
    _celebrationCtrl.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 2100));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final role = auth.selectedRole ?? 'courier_customer';

    // Admin always goes to dashboard.
    if (role == 'admin') {
      context.go('/admin/dashboard');
      return;
    }

    // Returning users who already have a name skip profile-setup.
    final hasProfile = (auth.user?.name ?? '').isNotEmpty;
    if (hasProfile) {
      context.go(auth.dashboardRouteForRole(role));
    } else {
      context.go('/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = Uri.decodeComponent(widget.phone);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _motion,
                  builder: (_, __) => CustomPaint(
                    painter: _OtpBackgroundPainter(
                      progress: _motion.value,
                      dark: AppColors.isDark(context),
                    ),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      wide ? 28 : 18,
                      18,
                      wide ? 28 : 18,
                      28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: wide ? 1080 : 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _BackButtonCard(
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/login');
                                    }
                                  },
                                ),
                                const _ThemeToggle(),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: _OtpHero(
                                      progress: _motion.value,
                                      countryInfo: _countryInfo,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  SizedBox(
                                    width: 430,
                                    child: _OtpFormCard(
                                      phone: phone,
                                      countryInfo: _countryInfo,
                                      otpCtrl: _otpCtrl,
                                      otpNode: _otpNode,
                                      otp: _otp,
                                      errorMessage: _errorMessage,
                                      verifying: _verifying,
                                      seconds: _seconds,
                                      shake: _shake,
                                      onOtpChanged: _onOtpChanged,
                                      onVerify: _verify,
                                      onResend: _resendOtp,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _OtpHero(
                                    progress: _motion.value,
                                    countryInfo: _countryInfo,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 24),
                                  _OtpFormCard(
                                    phone: phone,
                                    countryInfo: _countryInfo,
                                    otpCtrl: _otpCtrl,
                                    otpNode: _otpNode,
                                    otp: _otp,
                                    errorMessage: _errorMessage,
                                    verifying: _verifying,
                                    seconds: _seconds,
                                    shake: _shake,
                                    onOtpChanged: _onOtpChanged,
                                    onVerify: _verify,
                                    onResend: _resendOtp,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_celebrating)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _celebrationCtrl,
                    _tickCtrl,
                  ]),
                  builder: (context, _) {
                    return _SuccessCelebration(
                      progress: _celebrationCtrl.value,
                      tickScale: _tickScale.value,
                    );
                  },
                ),
            ],
          ),
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

class _BackButtonCard extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButtonCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 48,
      height: 48,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: AppColors.primary,
        size: 19,
      ),
    );
  }
}

class _OtpHero extends StatelessWidget {
  final double progress;
  final _CountryInfo countryInfo;
  final bool compact;

  const _OtpHero({
    required this.progress,
    required this.countryInfo,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LogoBadge(),
          const SizedBox(height: 22),
          Text(
            'Secure Shipment Verification',
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: compact ? 30 : 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify your mobile number to activate JD Logistics access.',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                icon: Icons.flag_rounded,
                text: '${countryInfo.flag} ${countryInfo.countryName}',
              ),
              _MiniPill(
                icon: Icons.map_rounded,
                text: countryInfo.region,
              ),
              _MiniPill(
                icon: Icons.payments_rounded,
                text: countryInfo.currency,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _OtpVisual(progress: progress, countryInfo: countryInfo),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 78,
      height: 78,
      borderRadius: 26,
      padding: EdgeInsets.zero,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Text('🔐', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );
  }
}

class _OtpVisual extends StatelessWidget {
  final double progress;
  final _CountryInfo countryInfo;

  const _OtpVisual({
    required this.progress,
    required this.countryInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OtpRoutePainter(
                  progress: progress,
                  dark: AppColors.isDark(context),
                ),
              ),
            ),
            const Positioned(
              top: 4,
              left: 0,
              child: _SoftBadge(text: 'Secure Verification'),
            ),
            Positioned(
              top: 12,
              right: 8,
              child: _HeroSticker(
                child: Text(
                  countryInfo.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const Positioned(
              bottom: 16,
              left: 0,
              child: _CharacterTile(
                emoji: '👩‍💼',
                label: 'JD Ops',
              ),
            ),
            const Positioned(
              bottom: 16,
              right: 0,
              child: _CharacterTile(
                emoji: '👨‍✈️',
                label: 'JD Hero',
              ),
            ),
            Center(child: _CenterKey(progress: progress)),
          ],
        ),
      ),
    );
  }
}

class _CenterKey extends StatelessWidget {
  final double progress;

  const _CenterKey({required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 112,
      height: 112,
      borderRadius: 36,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.vpn_key_rounded,
            color: AppColors.primary,
            size: 52,
          ),
          Positioned(
            bottom: 17,
            child: Transform.translate(
              offset: Offset(math.sin(progress * math.pi * 2) * 6, 0),
              child: const Text('✈️', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterTile extends StatelessWidget {
  final String emoji;
  final String label;

  const _CharacterTile({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 84,
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSticker extends StatelessWidget {
  final Widget child;

  const _HeroSticker({required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 48,
      height: 48,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      child: child,
    );
  }
}

class _OtpFormCard extends StatelessWidget {
  final String phone;
  final _CountryInfo countryInfo;
  final TextEditingController otpCtrl;
  final FocusNode otpNode;
  final String otp;
  final String? errorMessage;
  final bool verifying;
  final int seconds;
  final Animation<double> shake;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpFormCard({
    required this.phone,
    required this.countryInfo,
    required this.otpCtrl,
    required this.otpNode,
    required this.otp,
    required this.errorMessage,
    required this.verifying,
    required this.seconds,
    required this.shake,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhone = phone.isEmpty ? 'your mobile number' : phone;

    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter verification code',
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit OTP to $displayPhone',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _CountryInfoStrip(countryInfo: countryInfo),
          const SizedBox(height: 18),
          _VerificationStepper(otp: otp),
          const SizedBox(height: 22),
          _OtpInputArea(
            otpCtrl: otpCtrl,
            otpNode: otpNode,
            otp: otp,
            errorMessage: errorMessage,
            shake: shake,
            onChanged: onOtpChanged,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            child: errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: verifying ? 'Verifying...' : 'Verify OTP',
            isLoading: verifying,
            onPressed: otp.length == 6 ? onVerify : null,
            colors: AppColors.primaryGradient,
            icon: Icons.verified_rounded,
            height: 58,
            borderRadius: 22,
          ),
          const SizedBox(height: 16),
          Center(
            child: seconds > 0
                ? Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        'Resend OTP in',
                        style: TextStyle(
                          color: AppColors.subtext(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _CountdownBadge(seconds: seconds),
                    ],
                  )
                : TextButton.icon(
                    onPressed: onResend,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 13,
                  color: AppColors.subtext(context),
                ),
                Text(
                  'Secured with encrypted logistics identity verification',
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _CountryInfoStrip extends StatelessWidget {
  final _CountryInfo countryInfo;

  const _CountryInfoStrip({required this.countryInfo});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        _MiniPill(
          icon: Icons.flag_rounded,
          text: '${countryInfo.flag} ${countryInfo.countryName}',
        ),
        _MiniPill(
          icon: Icons.phone_rounded,
          text: countryInfo.dialCode,
        ),
        _MiniPill(
          icon: Icons.map_rounded,
          text: countryInfo.region,
        ),
        _MiniPill(
          icon: Icons.payments_rounded,
          text: countryInfo.currency,
        ),
      ],
    );
  }
}

class _VerificationStepper extends StatelessWidget {
  final String otp;

  const _VerificationStepper({required this.otp});

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _StepData('Phone', 'Registered', Icons.phone_android_rounded, true),
      const _StepData('OTP', 'Sent', Icons.sms_rounded, true),
      _StepData(
        'Identity',
        'Verifying',
        Icons.verified_user_rounded,
        otp.length >= 6,
      ),
      const _StepData('Profile', 'Activate', Icons.person_pin_rounded, false),
    ];

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      color: AppColors.surface(context),
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];

          return Expanded(
            child: Row(
              children: [
                Expanded(child: _StepItem(step: step)),
                if (index != steps.length - 1)
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: AppColors.subtext(context),
                    size: 18,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepData {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;

  const _StepData(this.title, this.subtitle, this.icon, this.active);
}

class _StepItem extends StatelessWidget {
  final _StepData step;

  const _StepItem({required this.step});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: step.active
                  ? AppColors.primary.withOpacity(
                      AppColors.isDark(context) ? 0.16 : 0.10,
                    )
                  : AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: step.active ? AppColors.primary : AppColors.border(context),
              ),
            ),
            child: Icon(
              step.icon,
              color: step.active ? AppColors.primary : AppColors.subtext(context),
              size: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            step.subtitle,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpInputArea extends StatelessWidget {
  final TextEditingController otpCtrl;
  final FocusNode otpNode;
  final String otp;
  final String? errorMessage;
  final Animation<double> shake;
  final ValueChanged<String> onChanged;

  const _OtpInputArea({
    required this.otpCtrl,
    required this.otpNode,
    required this.otp,
    required this.errorMessage,
    required this.shake,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shake,
      builder: (context, child) {
        final offset =
            math.sin(shake.value * math.pi * 5) * 9 * (1 - shake.value);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: GestureDetector(
        onTap: () => otpNode.requestFocus(),
        child: Stack(
          children: [
            Opacity(
              opacity: 0.01,
              child: TextField(
                controller: otpCtrl,
                focusNode: otpNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: onChanged,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 6.0;
                final boxWidth =
                    ((constraints.maxWidth - (spacing * 5)) / 6).clamp(34.0, 54.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final hasValue = index < otp.length;
                    final isFocused = index == otp.length && otp.length < 6;
                    final value = hasValue ? otp[index] : '';

                    return Padding(
                      padding: EdgeInsets.only(right: index == 5 ? 0 : spacing),
                      child: _OtpBox(
                        width: boxWidth,
                        value: value,
                        hasValue: hasValue,
                        isFocused: isFocused,
                        hasError: errorMessage != null,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final double width;
  final String value;
  final bool hasValue;
  final bool isFocused;
  final bool hasError;

  const _OtpBox({
    required this.width,
    required this.value,
    required this.hasValue,
    required this.isFocused,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.error
        : isFocused || hasValue
            ? AppColors.primary
            : AppColors.border(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: isFocused || hasValue ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayHighlightColor(context),
            offset: const Offset(-5, -5),
            blurRadius: 12,
          ),
          BoxShadow(
            color: AppColors.clayShadowColor(context).withOpacity(0.70),
            offset: const Offset(5, 5),
            blurRadius: 14,
          ),
        ],
      ),
      child: AnimatedScale(
        scale: hasValue ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: Text(
          value,
          style: TextStyle(
            color: hasError ? AppColors.error : AppColors.text(context),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final int seconds;

  const _CountdownBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return _SoftBadge(text: '${seconds}s');
  }
}

class _SuccessCelebration extends StatelessWidget {
  final double progress;
  final double tickScale;

  const _SuccessCelebration({
    required this.progress,
    required this.tickScale,
  });

  @override
  Widget build(BuildContext context) {
    final fade =
        progress < 0.84 ? 1.0 : (1 - ((progress - 0.84) / 0.16)).clamp(0.0, 1.0);

    return IgnorePointer(
      child: Opacity(
        opacity: fade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.background(context),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CelebrationPainter(
                    progress: progress,
                    dark: AppColors.isDark(context),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Transform.scale(
                      scale: 0.92 + (tickScale * 0.08),
                      child: GlassCard(
                        borderRadius: 42,
                        padding: const EdgeInsets.all(26),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: tickScale,
                              child: GlassCard(
                                width: 108,
                                height: 108,
                                borderRadius: 54,
                                padding: EdgeInsets.zero,
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.success,
                                  size: 66,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Verification Successful',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Preparing JD Logistics Workspace',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.subtext(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 9,
                              runSpacing: 9,
                              alignment: WrapAlignment.center,
                              children: const [
                                _MiniPill(
                                  icon: Icons.flight_takeoff_rounded,
                                  text: 'Air Cargo',
                                ),
                                _MiniPill(
                                  icon: Icons.local_shipping_rounded,
                                  text: 'Ground Freight',
                                ),
                                _MiniPill(
                                  icon: Icons.directions_boat_filled_rounded,
                                  text: 'Ocean Logistics',
                                ),
                                _MiniPill(
                                  icon: Icons.warehouse_rounded,
                                  text: 'Warehouse Network',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(AppColors.isDark(context) ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 15),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text(context),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final String text;

  const _SoftBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(AppColors.isDark(context) ? 0.15 : 0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.16),
        ),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OtpBackgroundPainter extends CustomPainter {
  final double progress;
  final bool dark;

  _OtpBackgroundPainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (dark ? AppColors.primaryLight : AppColors.routeLine)
          .withOpacity(dark ? 0.13 : 0.20)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paths = [
      Path()
        ..moveTo(size.width * .06, size.height * .28)
        ..quadraticBezierTo(
          size.width * .45,
          size.height * .08,
          size.width * .86,
          size.height * .30,
        ),
      Path()
        ..moveTo(size.width * .12, size.height * .78)
        ..quadraticBezierTo(
          size.width * .48,
          size.height * .55,
          size.width * .90,
          size.height * .72,
        ),
    ];

    for (final path in paths) {
      canvas.drawPath(path, routePaint);
    }

    _drawIcon(
      canvas,
      Icons.sms_rounded,
      Offset(
        (size.width + 80) * progress - 40,
        size.height * .32 + math.sin(progress * math.pi * 2) * 8,
      ),
    );

    _drawIcon(
      canvas,
      Icons.flight_takeoff_rounded,
      Offset(
        size.width - ((size.width + 90) * progress),
        size.height * .18 + math.cos(progress * math.pi * 2) * 8,
      ),
    );
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 26,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: AppColors.primary.withOpacity(dark ? .09 : .13),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _OtpBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

class _OtpRoutePainter extends CustomPainter {
  final double progress;
  final bool dark;

  _OtpRoutePainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = (dark ? AppColors.primaryLight : AppColors.routeLine)
          .withOpacity(dark ? .20 : .24)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * .14, size.height * .70)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .18,
        size.width * .84,
        size.height * .36,
      );

    canvas.drawPath(path, route);

    final node = Paint()
      ..color = dark ? AppColors.darkCard : Colors.white;

    final stroke = Paint()
      ..color = AppColors.primary.withOpacity(.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in [
      Offset(size.width * 0.22, size.height * 0.61),
      Offset(size.width * 0.48, size.height * 0.24),
      Offset(size.width * 0.72, size.height * 0.40),
    ]) {
      canvas.drawCircle(p, 6, node);
      canvas.drawCircle(p, 6, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _OtpRoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

class _CelebrationPainter extends CustomPainter {
  final double progress;
  final bool dark;

  _CelebrationPainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primary.withOpacity(dark ? .12 : .14)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final routes = [
      Path()
        ..moveTo(size.width * 0.10, size.height * 0.40)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.22,
          size.width * 0.90,
          size.height * 0.42,
        ),
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.68)
        ..quadraticBezierTo(
          size.width * 0.46,
          size.height * 0.52,
          size.width * 0.84,
          size.height * 0.62,
        ),
    ];

    for (final path in routes) {
      canvas.drawPath(path, routePaint);
    }

    _drawIcon(
      canvas,
      Icons.local_shipping_rounded,
      Offset(size.width * progress, size.height * 0.42),
    );

    _drawIcon(
      canvas,
      Icons.flight_takeoff_rounded,
      Offset(size.width * (1 - progress), size.height * 0.26),
    );
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 26,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: AppColors.primary.withOpacity(dark ? .14 : .18),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}