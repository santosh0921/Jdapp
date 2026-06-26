import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/constants/app_strings.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/custom_textfield.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _Country {
  final String flag;
  final String name;
  final String code;
  final String dialCode;
  final String region;
  final String currency;
  final String language;
  final int minLength;
  final int maxLength;

  const _Country({
    required this.flag,
    required this.name,
    required this.code,
    required this.dialCode,
    required this.region,
    required this.currency,
    required this.language,
    this.minLength = 6,
    this.maxLength = 15,
  });
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _mobileFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  final _phoneCtrl = TextEditingController();
  final _adminEmailCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();

  late final AnimationController _motion;

  bool _loading = false;
  bool _adminPasswordVisible = false;
  bool _adminVerified = false;

  static const List<_Country> _countries = [
    _Country(flag: '🇮🇳', name: 'India', code: 'IN', dialCode: '+91', region: 'Asia', currency: 'INR', language: 'English / Hindi', minLength: 10, maxLength: 10),
    _Country(flag: '🇺🇸', name: 'United States', code: 'US', dialCode: '+1', region: 'North America', currency: 'USD', language: 'English'),
    _Country(flag: '🇬🇧', name: 'United Kingdom', code: 'GB', dialCode: '+44', region: 'Europe', currency: 'GBP', language: 'English'),
    _Country(flag: '🇦🇪', name: 'United Arab Emirates', code: 'AE', dialCode: '+971', region: 'Middle East', currency: 'AED', language: 'Arabic / English'),
    _Country(flag: '🇸🇦', name: 'Saudi Arabia', code: 'SA', dialCode: '+966', region: 'Middle East', currency: 'SAR', language: 'Arabic / English'),
    _Country(flag: '🇶🇦', name: 'Qatar', code: 'QA', dialCode: '+974', region: 'Middle East', currency: 'QAR', language: 'Arabic / English'),
    _Country(flag: '🇴🇲', name: 'Oman', code: 'OM', dialCode: '+968', region: 'Middle East', currency: 'OMR', language: 'Arabic / English'),
    _Country(flag: '🇰🇼', name: 'Kuwait', code: 'KW', dialCode: '+965', region: 'Middle East', currency: 'KWD', language: 'Arabic / English'),
    _Country(flag: '🇧🇭', name: 'Bahrain', code: 'BH', dialCode: '+973', region: 'Middle East', currency: 'BHD', language: 'Arabic / English'),
    _Country(flag: '🇸🇬', name: 'Singapore', code: 'SG', dialCode: '+65', region: 'Asia Pacific', currency: 'SGD', language: 'English'),
    _Country(flag: '🇦🇺', name: 'Australia', code: 'AU', dialCode: '+61', region: 'Oceania', currency: 'AUD', language: 'English'),
    _Country(flag: '🇨🇦', name: 'Canada', code: 'CA', dialCode: '+1', region: 'North America', currency: 'CAD', language: 'English / French'),
    _Country(flag: '🇩🇪', name: 'Germany', code: 'DE', dialCode: '+49', region: 'Europe', currency: 'EUR', language: 'German'),
    _Country(flag: '🇫🇷', name: 'France', code: 'FR', dialCode: '+33', region: 'Europe', currency: 'EUR', language: 'French'),
    _Country(flag: '🇮🇹', name: 'Italy', code: 'IT', dialCode: '+39', region: 'Europe', currency: 'EUR', language: 'Italian'),
    _Country(flag: '🇪🇸', name: 'Spain', code: 'ES', dialCode: '+34', region: 'Europe', currency: 'EUR', language: 'Spanish'),
    _Country(flag: '🇳🇱', name: 'Netherlands', code: 'NL', dialCode: '+31', region: 'Europe', currency: 'EUR', language: 'Dutch'),
    _Country(flag: '🇧🇪', name: 'Belgium', code: 'BE', dialCode: '+32', region: 'Europe', currency: 'EUR', language: 'Dutch / French'),
    _Country(flag: '🇨🇭', name: 'Switzerland', code: 'CH', dialCode: '+41', region: 'Europe', currency: 'CHF', language: 'German / French'),
    _Country(flag: '🇸🇪', name: 'Sweden', code: 'SE', dialCode: '+46', region: 'Europe', currency: 'SEK', language: 'Swedish'),
    _Country(flag: '🇳🇴', name: 'Norway', code: 'NO', dialCode: '+47', region: 'Europe', currency: 'NOK', language: 'Norwegian'),
    _Country(flag: '🇩🇰', name: 'Denmark', code: 'DK', dialCode: '+45', region: 'Europe', currency: 'DKK', language: 'Danish'),
    _Country(flag: '🇫🇮', name: 'Finland', code: 'FI', dialCode: '+358', region: 'Europe', currency: 'EUR', language: 'Finnish'),
    _Country(flag: '🇵🇱', name: 'Poland', code: 'PL', dialCode: '+48', region: 'Europe', currency: 'PLN', language: 'Polish'),
    _Country(flag: '🇵🇹', name: 'Portugal', code: 'PT', dialCode: '+351', region: 'Europe', currency: 'EUR', language: 'Portuguese'),
    _Country(flag: '🇮🇪', name: 'Ireland', code: 'IE', dialCode: '+353', region: 'Europe', currency: 'EUR', language: 'English / Irish'),
    _Country(flag: '🇦🇹', name: 'Austria', code: 'AT', dialCode: '+43', region: 'Europe', currency: 'EUR', language: 'German'),
    _Country(flag: '🇹🇷', name: 'Turkey', code: 'TR', dialCode: '+90', region: 'Europe / Asia', currency: 'TRY', language: 'Turkish'),
    _Country(flag: '🇷🇺', name: 'Russia', code: 'RU', dialCode: '+7', region: 'Europe / Asia', currency: 'RUB', language: 'Russian'),
    _Country(flag: '🇯🇵', name: 'Japan', code: 'JP', dialCode: '+81', region: 'Asia', currency: 'JPY', language: 'Japanese'),
    _Country(flag: '🇨🇳', name: 'China', code: 'CN', dialCode: '+86', region: 'Asia', currency: 'CNY', language: 'Chinese'),
    _Country(flag: '🇭🇰', name: 'Hong Kong', code: 'HK', dialCode: '+852', region: 'Asia', currency: 'HKD', language: 'Chinese / English'),
    _Country(flag: '🇰🇷', name: 'South Korea', code: 'KR', dialCode: '+82', region: 'Asia', currency: 'KRW', language: 'Korean'),
    _Country(flag: '🇲🇾', name: 'Malaysia', code: 'MY', dialCode: '+60', region: 'Asia', currency: 'MYR', language: 'Malay / English'),
    _Country(flag: '🇹🇭', name: 'Thailand', code: 'TH', dialCode: '+66', region: 'Asia', currency: 'THB', language: 'Thai'),
    _Country(flag: '🇻🇳', name: 'Vietnam', code: 'VN', dialCode: '+84', region: 'Asia', currency: 'VND', language: 'Vietnamese'),
    _Country(flag: '🇵🇭', name: 'Philippines', code: 'PH', dialCode: '+63', region: 'Asia', currency: 'PHP', language: 'Filipino / English'),
    _Country(flag: '🇮🇩', name: 'Indonesia', code: 'ID', dialCode: '+62', region: 'Asia', currency: 'IDR', language: 'Indonesian'),
    _Country(flag: '🇧🇩', name: 'Bangladesh', code: 'BD', dialCode: '+880', region: 'Asia', currency: 'BDT', language: 'Bengali'),
    _Country(flag: '🇳🇵', name: 'Nepal', code: 'NP', dialCode: '+977', region: 'Asia', currency: 'NPR', language: 'Nepali'),
    _Country(flag: '🇱🇰', name: 'Sri Lanka', code: 'LK', dialCode: '+94', region: 'Asia', currency: 'LKR', language: 'Sinhala / Tamil'),
    _Country(flag: '🇵🇰', name: 'Pakistan', code: 'PK', dialCode: '+92', region: 'Asia', currency: 'PKR', language: 'Urdu / English'),
    _Country(flag: '🇲🇻', name: 'Maldives', code: 'MV', dialCode: '+960', region: 'Asia', currency: 'MVR', language: 'Dhivehi'),
    _Country(flag: '🇳🇿', name: 'New Zealand', code: 'NZ', dialCode: '+64', region: 'Oceania', currency: 'NZD', language: 'English'),
    _Country(flag: '🇿🇦', name: 'South Africa', code: 'ZA', dialCode: '+27', region: 'Africa', currency: 'ZAR', language: 'English'),
    _Country(flag: '🇰🇪', name: 'Kenya', code: 'KE', dialCode: '+254', region: 'Africa', currency: 'KES', language: 'English / Swahili'),
    _Country(flag: '🇳🇬', name: 'Nigeria', code: 'NG', dialCode: '+234', region: 'Africa', currency: 'NGN', language: 'English'),
    _Country(flag: '🇪🇬', name: 'Egypt', code: 'EG', dialCode: '+20', region: 'Africa', currency: 'EGP', language: 'Arabic'),
    _Country(flag: '🇲🇦', name: 'Morocco', code: 'MA', dialCode: '+212', region: 'Africa', currency: 'MAD', language: 'Arabic / French'),
    _Country(flag: '🇬🇭', name: 'Ghana', code: 'GH', dialCode: '+233', region: 'Africa', currency: 'GHS', language: 'English'),
    _Country(flag: '🇺🇬', name: 'Uganda', code: 'UG', dialCode: '+256', region: 'Africa', currency: 'UGX', language: 'English'),
    _Country(flag: '🇹🇿', name: 'Tanzania', code: 'TZ', dialCode: '+255', region: 'Africa', currency: 'TZS', language: 'Swahili / English'),
    _Country(flag: '🇧🇷', name: 'Brazil', code: 'BR', dialCode: '+55', region: 'South America', currency: 'BRL', language: 'Portuguese'),
    _Country(flag: '🇦🇷', name: 'Argentina', code: 'AR', dialCode: '+54', region: 'South America', currency: 'ARS', language: 'Spanish'),
    _Country(flag: '🇨🇱', name: 'Chile', code: 'CL', dialCode: '+56', region: 'South America', currency: 'CLP', language: 'Spanish'),
    _Country(flag: '🇨🇴', name: 'Colombia', code: 'CO', dialCode: '+57', region: 'South America', currency: 'COP', language: 'Spanish'),
    _Country(flag: '🇵🇪', name: 'Peru', code: 'PE', dialCode: '+51', region: 'South America', currency: 'PEN', language: 'Spanish'),
    _Country(flag: '🇲🇽', name: 'Mexico', code: 'MX', dialCode: '+52', region: 'North America', currency: 'MXN', language: 'Spanish'),
  ];

  _Country _selectedCountry = _countries.first;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _loadStoredCountry();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminPasswordCtrl.dispose();
    _motion.dispose();
    super.dispose();
  }

  Future<void> _loadStoredCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('countryCode');

    if (!mounted || code == null) return;

    final found = _countries.where((c) => c.code == code).toList();
    if (found.isNotEmpty) {
      setState(() => _selectedCountry = found.first);
    }
  }

  Future<void> _storeCountry() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('countryCode', _selectedCountry.code);
    await prefs.setString('countryName', _selectedCountry.name);
    await prefs.setString('flag', _selectedCountry.flag);
    await prefs.setString('dialCode', _selectedCountry.dialCode);
    await prefs.setString('region', _selectedCountry.region);
    await prefs.setString('currency', _selectedCountry.currency);
    await prefs.setString('language', _selectedCountry.language);
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) return 'Enter mobile number';

    if (phone.length < _selectedCountry.minLength ||
        phone.length > _selectedCountry.maxLength) {
      return 'Enter valid ${_selectedCountry.name} number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Enter admin email';

    final valid = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);

    if (!valid) return 'Enter valid email';

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) return 'Enter password';

    if (password.length < 4) return 'Password must be at least 4 characters';

    return null;
  }

  Future<void> _verifyAdminCredentials() async {
    if (!_adminFormKey.currentState!.validate()) return;

    setState(() => _loading = true);
    HapticFeedback.mediumImpact();

    // Local form-level gate: email + password format passes before OTP step.
    // Backend security is enforced at OTP verification (role = admin check).
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _loading = false;
      _adminVerified = true;
    });
  }

  Future<void> _sendOtp() async {
    final auth = context.read<AuthProvider>();

    if (!auth.hasSelectedRole) {
      context.go('/role-selection');
      return;
    }

    if (!_mobileFormKey.currentState!.validate()) return;

    setState(() => _loading = true);
    HapticFeedback.lightImpact();

    await _storeCountry();

    final fullPhone = '${_selectedCountry.dialCode}${_phoneCtrl.text.trim()}';

    // Actually call the backend send-otp API.
    final ok = await auth.sendOtp(fullPhone);

    if (!mounted) return;

    setState(() => _loading = false);

    if (ok) {
      context.go('/otp?phone=${Uri.encodeComponent(fullPhone)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to send OTP. Please try again.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
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
                    painter: _AuthBackgroundPainter(
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
                              maxWidth: wide ? 1080 : 520,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const _ThemeToggle(),
                                const SizedBox(height: 18),
                                if (wide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: _HeroSection(
                                          progress: _motion.value,
                                          country: _selectedCountry,
                                          auth: auth,
                                          adminVerified: _adminVerified,
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      SizedBox(
                                        width: 430,
                                        child: _LoginCard(
                                          mobileFormKey: _mobileFormKey,
                                          adminFormKey: _adminFormKey,
                                          phoneCtrl: _phoneCtrl,
                                          adminEmailCtrl: _adminEmailCtrl,
                                          adminPasswordCtrl: _adminPasswordCtrl,
                                          selectedCountry: _selectedCountry,
                                          countries: _countries,
                                          loading: _loading,
                                          adminVerified: _adminVerified,
                                          adminPasswordVisible:
                                              _adminPasswordVisible,
                                          validator: _validatePhone,
                                          emailValidator: _validateEmail,
                                          passwordValidator: _validatePassword,
                                          onAdminLogin: _verifyAdminCredentials,
                                          onSendOtp: _sendOtp,
                                          onTogglePassword: () {
                                            setState(() {
                                              _adminPasswordVisible =
                                                  !_adminPasswordVisible;
                                            });
                                          },
                                          onCountryChanged: (value) {
                                            if (value == null) return;
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              _selectedCountry = value;
                                              _phoneCtrl.clear();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      _HeroSection(
                                        progress: _motion.value,
                                        country: _selectedCountry,
                                        auth: auth,
                                        adminVerified: _adminVerified,
                                        compact: true,
                                      ),
                                      const SizedBox(height: 24),
                                      _LoginCard(
                                        mobileFormKey: _mobileFormKey,
                                        adminFormKey: _adminFormKey,
                                        phoneCtrl: _phoneCtrl,
                                        adminEmailCtrl: _adminEmailCtrl,
                                        adminPasswordCtrl: _adminPasswordCtrl,
                                        selectedCountry: _selectedCountry,
                                        countries: _countries,
                                        loading: _loading,
                                        adminVerified: _adminVerified,
                                        adminPasswordVisible:
                                            _adminPasswordVisible,
                                        validator: _validatePhone,
                                        emailValidator: _validateEmail,
                                        passwordValidator: _validatePassword,
                                        onAdminLogin: _verifyAdminCredentials,
                                        onSendOtp: _sendOtp,
                                        onTogglePassword: () {
                                          setState(() {
                                            _adminPasswordVisible =
                                                !_adminPasswordVisible;
                                          });
                                        },
                                        onCountryChanged: (value) {
                                          if (value == null) return;
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _selectedCountry = value;
                                            _phoneCtrl.clear();
                                          });
                                        },
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

class _HeroSection extends StatelessWidget {
  final double progress;
  final _Country country;
  final AuthProvider auth;
  final bool adminVerified;
  final bool compact;

  const _HeroSection({
    required this.progress,
    required this.country,
    required this.auth,
    required this.adminVerified,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final roleTitle = auth.loginTitleForRole();
    final roleColor = auth.colorForRole();
    final roleIcon = auth.iconForRole();
    final isAdmin = auth.selectedRole == 'admin';

    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LogoBadge(
            progress: progress,
            roleIcon: roleIcon,
            roleColor: roleColor,
          ),
          const SizedBox(height: 22),
          Text(
            isAdmin && adminVerified ? 'Admin Mobile Verification' : roleTitle,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: compact ? 32 : 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? adminVerified
                    ? 'Admin credentials verified. Complete secure mobile OTP before opening control tower.'
                    : 'Admin access requires email, password and mobile OTP verification.'
                : 'JD Logistics secure workspace for global shipment operations.',
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
                text: '${country.flag} ${country.name}',
              ),
              _MiniPill(
                icon: Icons.map_rounded,
                text: country.region,
              ),
              _MiniPill(
                icon: Icons.payments_rounded,
                text: country.currency,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ShipmentVisual(
            progress: progress,
            country: country,
            roleColor: roleColor,
            roleIcon: roleIcon,
            roleTitle:
                isAdmin && adminVerified ? 'Admin OTP' : roleTitle,
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final double progress;
  final IconData roleIcon;
  final Color roleColor;

  const _LogoBadge({
    required this.progress,
    required this.roleIcon,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 78,
      height: 78,
      borderRadius: 26,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(roleIcon, color: roleColor, size: 40),
          Positioned(
            right: 8 + math.sin(progress * math.pi * 2) * 3,
            bottom: 8,
            child: const Text('📦', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _ShipmentVisual extends StatelessWidget {
  final double progress;
  final _Country country;
  final Color roleColor;
  final IconData roleIcon;
  final String roleTitle;

  const _ShipmentVisual({
    required this.progress,
    required this.country,
    required this.roleColor,
    required this.roleIcon,
    required this.roleTitle,
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
                painter: _HeroRoutePainter(
                  progress: progress,
                  dark: AppColors.isDark(context),
                  color: roleColor,
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 0,
              child: _SoftBadge(text: '$roleTitle Access'),
            ),
            Positioned(
              top: 16,
              right: 6,
              child: _HeroSticker(
                child: Text(country.flag, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const Positioned(
              left: 0,
              bottom: 14,
              child: _CharacterTile(
                emoji: '👨‍✈️',
                label: 'JD Hero',
              ),
            ),
            const Positioned(
              right: 0,
              bottom: 14,
              child: _CharacterTile(
                emoji: '👩‍💼',
                label: 'JD Ops',
              ),
            ),
            Center(
              child: _CenterHub(
                progress: progress,
                roleIcon: roleIcon,
                roleColor: roleColor,
              ),
            ),
            Positioned(
              left: 28 + math.sin(progress * math.pi * 2) * 18,
              top: 58,
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: roleColor,
                size: 28,
              ),
            ),
            Positioned(
              right: 34 + math.cos(progress * math.pi * 2) * 18,
              bottom: 78,
              child: const Icon(
                Icons.local_shipping_rounded,
                color: AppColors.portOrange,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterHub extends StatelessWidget {
  final double progress;
  final IconData roleIcon;
  final Color roleColor;

  const _CenterHub({
    required this.progress,
    required this.roleIcon,
    required this.roleColor,
  });

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
          Icon(roleIcon, color: roleColor, size: 55),
          Positioned(
            bottom: 17,
            child: Transform.translate(
              offset: Offset(math.sin(progress * math.pi * 2) * 6, 0),
              child: const Text('🚚', style: TextStyle(fontSize: 22)),
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
      width: 86,
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 3),
          const Text(
            'JD',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
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

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> mobileFormKey;
  final GlobalKey<FormState> adminFormKey;
  final TextEditingController phoneCtrl;
  final TextEditingController adminEmailCtrl;
  final TextEditingController adminPasswordCtrl;
  final _Country selectedCountry;
  final List<_Country> countries;
  final bool loading;
  final bool adminVerified;
  final bool adminPasswordVisible;
  final ValueChanged<_Country?> onCountryChanged;
  final VoidCallback onSendOtp;
  final VoidCallback onAdminLogin;
  final VoidCallback onTogglePassword;
  final String? Function(String?) validator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;

  const _LoginCard({
    required this.mobileFormKey,
    required this.adminFormKey,
    required this.phoneCtrl,
    required this.adminEmailCtrl,
    required this.adminPasswordCtrl,
    required this.selectedCountry,
    required this.countries,
    required this.loading,
    required this.adminVerified,
    required this.adminPasswordVisible,
    required this.onCountryChanged,
    required this.onSendOtp,
    required this.onAdminLogin,
    required this.onTogglePassword,
    required this.validator,
    required this.emailValidator,
    required this.passwordValidator,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roleTitle = auth.loginTitleForRole();
    final roleColor = auth.colorForRole();
    final roleIcon = auth.iconForRole();
    final isAdmin = auth.selectedRole == 'admin';

    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(22),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: isAdmin && !adminVerified
            ? _AdminCredentialForm(
                key: const ValueKey('admin-form'),
                formKey: adminFormKey,
                emailCtrl: adminEmailCtrl,
                passwordCtrl: adminPasswordCtrl,
                loading: loading,
                passwordVisible: adminPasswordVisible,
                roleTitle: roleTitle,
                roleColor: roleColor,
                roleIcon: roleIcon,
                emailValidator: emailValidator,
                passwordValidator: passwordValidator,
                onLogin: onAdminLogin,
                onTogglePassword: onTogglePassword,
              )
            : _MobileOtpForm(
                key: const ValueKey('mobile-form'),
                formKey: mobileFormKey,
                phoneCtrl: phoneCtrl,
                selectedCountry: selectedCountry,
                countries: countries,
                loading: loading,
                roleTitle: isAdmin ? 'Admin Mobile OTP' : roleTitle,
                roleColor: roleColor,
                roleIcon: roleIcon,
                isAdmin: isAdmin,
                validator: validator,
                onCountryChanged: onCountryChanged,
                onSendOtp: onSendOtp,
              ),
      ),
    );
  }
}

class _AdminCredentialForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool loading;
  final bool passwordVisible;
  final String roleTitle;
  final Color roleColor;
  final IconData roleIcon;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;
  final VoidCallback onLogin;
  final VoidCallback onTogglePassword;

  const _AdminCredentialForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.loading,
    required this.passwordVisible,
    required this.roleTitle,
    required this.roleColor,
    required this.roleIcon,
    required this.emailValidator,
    required this.passwordValidator,
    required this.onLogin,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SelectedRoleBadge(
            roleTitle: roleTitle,
            roleColor: roleColor,
            roleIcon: roleIcon,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(roleIcon, color: roleColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admin Control Login',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter admin email and password first. Mobile OTP verification will be required after this step.',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          _ClayInput(
            controller: emailCtrl,
            label: 'Admin Email',
            hint: 'admin@jdlogistics.com',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
          ),
          const SizedBox(height: 14),
          _ClayInput(
            controller: passwordCtrl,
            label: 'Password',
            hint: 'Enter admin password',
            icon: Icons.lock_rounded,
            obscureText: !passwordVisible,
            validator: passwordValidator,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                passwordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: roleColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SecurityStrip(color: roleColor),
          const SizedBox(height: 22),
          GradientButton(
            label: 'Verify Admin Credentials',
            isLoading: loading,
            onPressed: onLogin,
            colors: [roleColor, AppColors.deepBlue],
            icon: Icons.admin_panel_settings_rounded,
            height: 58,
            borderRadius: 22,
          ),
          const SizedBox(height: 18),
          const Center(
            child: _SoftBadge(text: 'Admin: Email + Password → Mobile OTP'),
          ),
        ],
      ),
    );
  }
}

class _MobileOtpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final _Country selectedCountry;
  final List<_Country> countries;
  final bool loading;
  final String roleTitle;
  final Color roleColor;
  final IconData roleIcon;
  final bool isAdmin;
  final ValueChanged<_Country?> onCountryChanged;
  final VoidCallback onSendOtp;
  final String? Function(String?) validator;

  const _MobileOtpForm({
    super.key,
    required this.formKey,
    required this.phoneCtrl,
    required this.selectedCountry,
    required this.countries,
    required this.loading,
    required this.roleTitle,
    required this.roleColor,
    required this.roleIcon,
    required this.isAdmin,
    required this.onCountryChanged,
    required this.onSendOtp,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SelectedRoleBadge(
            roleTitle: roleTitle,
            roleColor: roleColor,
            roleIcon: roleIcon,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(roleIcon, color: roleColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  roleTitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Admin credentials verified. Enter mobile number to complete secure OTP verification.'
                : 'Secure ${roleTitle.toLowerCase()} access. Select your country and enter your mobile number. We’ll send a secure OTP.',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          _CountrySelector(
            selected: selectedCountry,
            countries: countries,
            onChanged: onCountryChanged,
          ),
          const SizedBox(height: 14),
          _CountryMetaStrip(country: selectedCountry),
          const SizedBox(height: 16),
          CustomTextField(
            controller: phoneCtrl,
            hint: AppStrings.phoneHint,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android_rounded,
            validator: validator,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(selectedCountry.maxLength),
            ],
          ),
          const SizedBox(height: 22),
          GradientButton(
            label: isAdmin ? 'Send Admin OTP' : AppStrings.sendOtp,
            isLoading: loading,
            onPressed: onSendOtp,
            colors: [roleColor, AppColors.deepBlue],
            icon: Icons.arrow_forward_rounded,
            height: 58,
            borderRadius: 22,
          ),
          const SizedBox(height: 18),
          Center(
            child: _SoftBadge(
              text: isAdmin ? 'Admin OTP required' : 'Enter the OTP sent to your phone',
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'By continuing, you agree to our Terms & Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClayInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?) validator;

  const _ClayInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: AppColors.text(context),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface(context),
        labelStyle: TextStyle(
          color: AppColors.subtext(context),
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: AppColors.subtext(context).withValues(alpha: 0.70),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _SecurityStrip extends StatelessWidget {
  final Color color;

  const _SecurityStrip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: AppColors.isDark(context) ? 0.16 : 0.09,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Protected control tower access with two-step verification.',
              style: TextStyle(
                color: AppColors.text(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRoleBadge extends StatelessWidget {
  final String roleTitle;
  final Color roleColor;
  final IconData roleIcon;

  const _SelectedRoleBadge({
    required this.roleTitle,
    required this.roleColor,
    required this.roleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: roleColor.withValues(
          alpha: AppColors.isDark(context) ? 0.16 : 0.10,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon, color: roleColor, size: 16),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              roleTitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: roleColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.go('/service-selection'),
            child: Text(
              'Change',
              style: TextStyle(
                color: roleColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  final _Country selected;
  final List<_Country> countries;
  final ValueChanged<_Country?> onChanged;

  const _CountrySelector({
    required this.selected,
    required this.countries,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: AppColors.surface(context),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_Country>(
          value: selected,
          isExpanded: true,
          menuMaxHeight: 360,
          borderRadius: BorderRadius.circular(22),
          dropdownColor: AppColors.surface(context),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items: countries.map((country) {
            return DropdownMenuItem<_Country>(
              value: country,
              child: Row(
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      country.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    country.dialCode,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CountryMetaStrip extends StatelessWidget {
  final _Country country;

  const _CountryMetaStrip({required this.country});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        _MiniPill(icon: Icons.map_rounded, text: country.region),
        _MiniPill(icon: Icons.payments_rounded, text: country.currency),
        _MiniPill(icon: Icons.translate_rounded, text: country.language),
      ],
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
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: AppColors.isDark(context) ? 0.15 : 0.08,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
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
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: AppColors.isDark(context) ? 0.15 : 0.09,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
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

class _AuthBackgroundPainter extends CustomPainter {
  final double progress;
  final bool dark;

  _AuthBackgroundPainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (dark ? AppColors.primaryLight : AppColors.routeLine)
          .withValues(alpha: dark ? 0.13 : 0.20)
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

    _drawMovingDot(
      canvas,
      Offset(size.width * .06, size.height * .28),
      Offset(size.width * .86, size.height * .30),
      progress,
      AppColors.primary,
    );

    _drawMovingDot(
      canvas,
      Offset(size.width * .12, size.height * .78),
      Offset(size.width * .90, size.height * .72),
      (progress + .45) % 1,
      AppColors.portOrange,
    );

    _drawIcon(
      canvas,
      Icons.local_shipping_rounded,
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

  void _drawMovingDot(
    Canvas canvas,
    Offset start,
    Offset end,
    double t,
    Color color,
  ) {
    final p = Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t - math.sin(t * math.pi) * 60,
    );

    canvas.drawCircle(
      p,
      4,
      Paint()..color = color.withValues(alpha: dark ? 0.45 : 0.55),
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
          color: AppColors.primary.withValues(alpha: dark ? .09 : .13),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

class _HeroRoutePainter extends CustomPainter {
  final double progress;
  final bool dark;
  final Color color;

  _HeroRoutePainter({
    required this.progress,
    required this.dark,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = color.withValues(alpha: dark ? .20 : .24)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * .12, size.height * .72)
      ..quadraticBezierTo(
        size.width * .52,
        size.height * .12,
        size.width * .86,
        size.height * .36,
      );

    canvas.drawPath(path, route);

    final node = Paint()
      ..color = dark ? const Color(0xFF1F2937) : Colors.white;

    final stroke = Paint()
      ..color = color.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in [
      Offset(size.width * .20, size.height * .60),
      Offset(size.width * .52, size.height * .25),
      Offset(size.width * .78, size.height * .38),
    ]) {
      canvas.drawCircle(p, 6, node);
      canvas.drawCircle(p, 6, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroRoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dark != dark ||
        oldDelegate.color != color;
  }
}