import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/constants/app_strings.dart';
import 'package:jd_style_logistics/core/utils/validators.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/custom_textfield.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _CountryData {
  final String countryCode;
  final String countryName;
  final String flag;
  final String dialCode;
  final String region;
  final String currency;
  final String language;

  const _CountryData({
    required this.countryCode,
    required this.countryName,
    required this.flag,
    required this.dialCode,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _vehicleNumberCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _operatingCityCtrl = TextEditingController();

  final _employeeIdCtrl = TextEditingController();
  final _warehouseCodeCtrl = TextEditingController();
  final _warehouseLocationCtrl = TextEditingController();

  // Logistics customer fields
  final _companyNameCtrl = TextEditingController();
  final _preferredPortCtrl = TextEditingController();
  String _businessType = 'Importer';
  String _cargoType = 'General Cargo';

  late final AnimationController _motion;

  bool _international = false;
  String _accountType = 'Personal';

  String _vehicleType = 'Bike';
  String _driverShift = 'Flexible';

  String _warehouseShift = 'Morning';
  String _warehouseDepartment = 'Inbound';

  static const List<_CountryData> _countries = [
    _CountryData(countryCode: 'IN', countryName: 'India', flag: '🇮🇳', dialCode: '+91', region: 'Asia', currency: 'INR', language: 'English / Hindi'),
    _CountryData(countryCode: 'US', countryName: 'United States', flag: '🇺🇸', dialCode: '+1', region: 'North America', currency: 'USD', language: 'English'),
    _CountryData(countryCode: 'GB', countryName: 'United Kingdom', flag: '🇬🇧', dialCode: '+44', region: 'Europe', currency: 'GBP', language: 'English'),
    _CountryData(countryCode: 'AE', countryName: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971', region: 'Middle East', currency: 'AED', language: 'Arabic / English'),
    _CountryData(countryCode: 'SA', countryName: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966', region: 'Middle East', currency: 'SAR', language: 'Arabic / English'),
    _CountryData(countryCode: 'QA', countryName: 'Qatar', flag: '🇶🇦', dialCode: '+974', region: 'Middle East', currency: 'QAR', language: 'Arabic / English'),
    _CountryData(countryCode: 'OM', countryName: 'Oman', flag: '🇴🇲', dialCode: '+968', region: 'Middle East', currency: 'OMR', language: 'Arabic / English'),
    _CountryData(countryCode: 'KW', countryName: 'Kuwait', flag: '🇰🇼', dialCode: '+965', region: 'Middle East', currency: 'KWD', language: 'Arabic / English'),
    _CountryData(countryCode: 'SG', countryName: 'Singapore', flag: '🇸🇬', dialCode: '+65', region: 'Asia Pacific', currency: 'SGD', language: 'English'),
    _CountryData(countryCode: 'MY', countryName: 'Malaysia', flag: '🇲🇾', dialCode: '+60', region: 'Asia', currency: 'MYR', language: 'Malay / English'),
    _CountryData(countryCode: 'TH', countryName: 'Thailand', flag: '🇹🇭', dialCode: '+66', region: 'Asia', currency: 'THB', language: 'Thai'),
    _CountryData(countryCode: 'VN', countryName: 'Vietnam', flag: '🇻🇳', dialCode: '+84', region: 'Asia', currency: 'VND', language: 'Vietnamese'),
    _CountryData(countryCode: 'PH', countryName: 'Philippines', flag: '🇵🇭', dialCode: '+63', region: 'Asia', currency: 'PHP', language: 'Filipino / English'),
    _CountryData(countryCode: 'ID', countryName: 'Indonesia', flag: '🇮🇩', dialCode: '+62', region: 'Asia', currency: 'IDR', language: 'Indonesian'),
    _CountryData(countryCode: 'JP', countryName: 'Japan', flag: '🇯🇵', dialCode: '+81', region: 'Asia', currency: 'JPY', language: 'Japanese'),
    _CountryData(countryCode: 'CN', countryName: 'China', flag: '🇨🇳', dialCode: '+86', region: 'Asia', currency: 'CNY', language: 'Chinese'),
    _CountryData(countryCode: 'HK', countryName: 'Hong Kong', flag: '🇭🇰', dialCode: '+852', region: 'Asia', currency: 'HKD', language: 'Chinese / English'),
    _CountryData(countryCode: 'KR', countryName: 'South Korea', flag: '🇰🇷', dialCode: '+82', region: 'Asia', currency: 'KRW', language: 'Korean'),
    _CountryData(countryCode: 'BD', countryName: 'Bangladesh', flag: '🇧🇩', dialCode: '+880', region: 'Asia', currency: 'BDT', language: 'Bengali'),
    _CountryData(countryCode: 'NP', countryName: 'Nepal', flag: '🇳🇵', dialCode: '+977', region: 'Asia', currency: 'NPR', language: 'Nepali'),
    _CountryData(countryCode: 'LK', countryName: 'Sri Lanka', flag: '🇱🇰', dialCode: '+94', region: 'Asia', currency: 'LKR', language: 'Sinhala / Tamil'),
    _CountryData(countryCode: 'PK', countryName: 'Pakistan', flag: '🇵🇰', dialCode: '+92', region: 'Asia', currency: 'PKR', language: 'Urdu / English'),
    _CountryData(countryCode: 'AU', countryName: 'Australia', flag: '🇦🇺', dialCode: '+61', region: 'Oceania', currency: 'AUD', language: 'English'),
    _CountryData(countryCode: 'NZ', countryName: 'New Zealand', flag: '🇳🇿', dialCode: '+64', region: 'Oceania', currency: 'NZD', language: 'English'),
    _CountryData(countryCode: 'CA', countryName: 'Canada', flag: '🇨🇦', dialCode: '+1', region: 'North America', currency: 'CAD', language: 'English / French'),
    _CountryData(countryCode: 'DE', countryName: 'Germany', flag: '🇩🇪', dialCode: '+49', region: 'Europe', currency: 'EUR', language: 'German'),
    _CountryData(countryCode: 'FR', countryName: 'France', flag: '🇫🇷', dialCode: '+33', region: 'Europe', currency: 'EUR', language: 'French'),
    _CountryData(countryCode: 'IT', countryName: 'Italy', flag: '🇮🇹', dialCode: '+39', region: 'Europe', currency: 'EUR', language: 'Italian'),
    _CountryData(countryCode: 'ES', countryName: 'Spain', flag: '🇪🇸', dialCode: '+34', region: 'Europe', currency: 'EUR', language: 'Spanish'),
    _CountryData(countryCode: 'NL', countryName: 'Netherlands', flag: '🇳🇱', dialCode: '+31', region: 'Europe', currency: 'EUR', language: 'Dutch'),
    _CountryData(countryCode: 'CH', countryName: 'Switzerland', flag: '🇨🇭', dialCode: '+41', region: 'Europe', currency: 'CHF', language: 'German / French'),
    _CountryData(countryCode: 'SE', countryName: 'Sweden', flag: '🇸🇪', dialCode: '+46', region: 'Europe', currency: 'SEK', language: 'Swedish'),
    _CountryData(countryCode: 'NO', countryName: 'Norway', flag: '🇳🇴', dialCode: '+47', region: 'Europe', currency: 'NOK', language: 'Norwegian'),
    _CountryData(countryCode: 'DK', countryName: 'Denmark', flag: '🇩🇰', dialCode: '+45', region: 'Europe', currency: 'DKK', language: 'Danish'),
    _CountryData(countryCode: 'FI', countryName: 'Finland', flag: '🇫🇮', dialCode: '+358', region: 'Europe', currency: 'EUR', language: 'Finnish'),
    _CountryData(countryCode: 'ZA', countryName: 'South Africa', flag: '🇿🇦', dialCode: '+27', region: 'Africa', currency: 'ZAR', language: 'English'),
    _CountryData(countryCode: 'KE', countryName: 'Kenya', flag: '🇰🇪', dialCode: '+254', region: 'Africa', currency: 'KES', language: 'English / Swahili'),
    _CountryData(countryCode: 'NG', countryName: 'Nigeria', flag: '🇳🇬', dialCode: '+234', region: 'Africa', currency: 'NGN', language: 'English'),
    _CountryData(countryCode: 'EG', countryName: 'Egypt', flag: '🇪🇬', dialCode: '+20', region: 'Africa', currency: 'EGP', language: 'Arabic'),
    _CountryData(countryCode: 'BR', countryName: 'Brazil', flag: '🇧🇷', dialCode: '+55', region: 'South America', currency: 'BRL', language: 'Portuguese'),
    _CountryData(countryCode: 'MX', countryName: 'Mexico', flag: '🇲🇽', dialCode: '+52', region: 'North America', currency: 'MXN', language: 'Spanish'),
  ];

  _CountryData _selectedCountry = _countries.first;

  @override
  void initState() {
    super.initState();

    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _loadStoredCountry();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _licenseCtrl.dispose();
    _experienceCtrl.dispose();
    _operatingCityCtrl.dispose();
    _employeeIdCtrl.dispose();
    _warehouseCodeCtrl.dispose();
    _warehouseLocationCtrl.dispose();
    _companyNameCtrl.dispose();
    _preferredPortCtrl.dispose();
    _motion.dispose();
    super.dispose();
  }

  Future<void> _loadStoredCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('countryCode');

    if (!mounted || code == null) return;

    final match = _countries.where((country) => country.countryCode == code);
    if (match.isNotEmpty) {
      setState(() => _selectedCountry = match.first);
    }
  }

  String _role(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return auth.selectedRole ?? auth.userRole ?? 'courier_customer';
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'courier_driver':
        return AppColors.driverColor;
      case 'logistics_customer':
        return const Color(0xFF0D9488);
      case 'admin':
        return AppColors.adminColor;
      case 'courier_customer':
      default:
        return AppColors.primary;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'courier_driver':
        return Icons.delivery_dining_rounded;
      case 'logistics_customer':
        return Icons.directions_boat_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'courier_customer':
      default:
        return Icons.person_pin_rounded;
    }
  }

  String _roleTitle(String role) {
    switch (role) {
      case 'courier_driver':
        return 'Driver Profile Setup';
      case 'logistics_customer':
        return 'Logistics Profile Setup';
      case 'admin':
        return 'Admin Profile Setup';
      case 'courier_customer':
      default:
        return 'Customer Profile Setup';
    }
  }

  String _dashboardRoute(String role) {
    switch (role) {
      case 'courier_driver':
        return '/driver/home';
      case 'logistics_customer':
        return '/logistics/home';
      case 'admin':
        return '/admin/dashboard';
      case 'courier_customer':
      default:
        return '/customer/home';
    }
  }

  Future<void> _saveRoleProfile(String role) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profileRole', role);
    await prefs.setString('countryCode', _selectedCountry.countryCode);
    await prefs.setString('countryName', _selectedCountry.countryName);
    await prefs.setString('flag', _selectedCountry.flag);
    await prefs.setString('dialCode', _selectedCountry.dialCode);
    await prefs.setString('region', _selectedCountry.region);
    await prefs.setString('currency', _selectedCountry.currency);
    await prefs.setString('language', _selectedCountry.language);

    await prefs.setString('fullName', _nameCtrl.text.trim());
    await prefs.setString('email', _emailCtrl.text.trim());

    if (role == 'courier_customer') {
      await prefs.setString(
        'shippingMode',
        _international ? 'International' : 'Domestic',
      );
      await prefs.setString('accountType', _accountType);
    }

    if (role == 'courier_driver') {
      await prefs.setString('vehicleType', _vehicleType);
      await prefs.setString('vehicleNumber', _vehicleNumberCtrl.text.trim());
      await prefs.setString('licenseNumber', _licenseCtrl.text.trim());
      await prefs.setString('driverExperience', _experienceCtrl.text.trim());
      await prefs.setString('operatingCity', _operatingCityCtrl.text.trim());
      await prefs.setString('driverShift', _driverShift);
    }

    if (role == 'logistics_customer') {
      await prefs.setString('companyName', _companyNameCtrl.text.trim());
      await prefs.setString('businessType', _businessType);
      await prefs.setString('cargoType', _cargoType);
      await prefs.setString('preferredPort', _preferredPortCtrl.text.trim());
    }
  }

  Future<void> _save() async {
    final role = _role(context);

    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final auth = context.read<AuthProvider>();

    try {
      await auth.setupProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      );
    } catch (_) {}

    await _saveRoleProfile(role);

    if (!mounted) return;

    context.go(_dashboardRoute(role));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.selectedRole ?? auth.userRole ?? 'customer';
    final roleColor = _roleColor(role);
    final roleIcon = _roleIcon(role);
    final roleTitle = _roleTitle(role);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: GradientBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ProfileBackgroundPainter(
                        progress: _motion.value,
                        dark: AppColors.isDark(context),
                        color: roleColor,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;

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
                            constraints: BoxConstraints(
                              maxWidth: wide ? 1120 : 540,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const _ThemeToggle(),
                                  const SizedBox(height: 18),
                                  if (wide)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: _ProfileHero(
                                            progress: _motion.value,
                                            selectedCountry: _selectedCountry,
                                            role: role,
                                            roleTitle: roleTitle,
                                            roleColor: roleColor,
                                            roleIcon: roleIcon,
                                            international: _international,
                                            accountType: _accountType,
                                            vehicleType: _vehicleType,
                                            warehouseDepartment: _warehouseDepartment,
                                          ),
                                        ),
                                        const SizedBox(width: 28),
                                        SizedBox(
                                          width: 440,
                                          child: _ProfileFormCard(
                                            nameCtrl: _nameCtrl,
                                            emailCtrl: _emailCtrl,
                                            vehicleNumberCtrl: _vehicleNumberCtrl,
                                            licenseCtrl: _licenseCtrl,
                                            experienceCtrl: _experienceCtrl,
                                            operatingCityCtrl: _operatingCityCtrl,
                                            employeeIdCtrl: _employeeIdCtrl,
                                            warehouseCodeCtrl: _warehouseCodeCtrl,
                                            warehouseLocationCtrl: _warehouseLocationCtrl,
                                            companyNameCtrl: _companyNameCtrl,
                                            preferredPortCtrl: _preferredPortCtrl,
                                            countries: _countries,
                                            selectedCountry: _selectedCountry,
                                            role: role,
                                            roleTitle: roleTitle,
                                            roleColor: roleColor,
                                            roleIcon: roleIcon,
                                            international: _international,
                                            accountType: _accountType,
                                            vehicleType: _vehicleType,
                                            driverShift: _driverShift,
                                            warehouseShift: _warehouseShift,
                                            warehouseDepartment: _warehouseDepartment,
                                            businessType: _businessType,
                                            cargoType: _cargoType,
                                            isLoading: auth.isLoading,
                                            onCountryChanged: (country) {
                                              if (country == null) return;
                                              HapticFeedback.selectionClick();
                                              setState(() => _selectedCountry = country);
                                            },
                                            onInternationalChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _international = value);
                                            },
                                            onAccountTypeChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _accountType = value);
                                            },
                                            onVehicleTypeChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _vehicleType = value);
                                            },
                                            onDriverShiftChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _driverShift = value);
                                            },
                                            onWarehouseShiftChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _warehouseShift = value);
                                            },
                                            onWarehouseDepartmentChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _warehouseDepartment = value);
                                            },
                                            onBusinessTypeChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _businessType = value);
                                            },
                                            onCargoTypeChanged: (value) {
                                              HapticFeedback.selectionClick();
                                              setState(() => _cargoType = value);
                                            },
                                            onSave: _save,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Column(
                                      children: [
                                        _ProfileHero(
                                          progress: _motion.value,
                                          selectedCountry: _selectedCountry,
                                          role: role,
                                          roleTitle: roleTitle,
                                          roleColor: roleColor,
                                          roleIcon: roleIcon,
                                          international: _international,
                                          accountType: _accountType,
                                          vehicleType: _vehicleType,
                                          warehouseDepartment: _warehouseDepartment,
                                          compact: true,
                                        ),
                                        const SizedBox(height: 22),
                                        _ProfileFormCard(
                                          nameCtrl: _nameCtrl,
                                          emailCtrl: _emailCtrl,
                                          vehicleNumberCtrl: _vehicleNumberCtrl,
                                          licenseCtrl: _licenseCtrl,
                                          experienceCtrl: _experienceCtrl,
                                          operatingCityCtrl: _operatingCityCtrl,
                                          employeeIdCtrl: _employeeIdCtrl,
                                          warehouseCodeCtrl: _warehouseCodeCtrl,
                                          warehouseLocationCtrl: _warehouseLocationCtrl,
                                          companyNameCtrl: _companyNameCtrl,
                                          preferredPortCtrl: _preferredPortCtrl,
                                          countries: _countries,
                                          selectedCountry: _selectedCountry,
                                          role: role,
                                          roleTitle: roleTitle,
                                          roleColor: roleColor,
                                          roleIcon: roleIcon,
                                          international: _international,
                                          accountType: _accountType,
                                          vehicleType: _vehicleType,
                                          driverShift: _driverShift,
                                          warehouseShift: _warehouseShift,
                                          warehouseDepartment: _warehouseDepartment,
                                          businessType: _businessType,
                                          cargoType: _cargoType,
                                          isLoading: auth.isLoading,
                                          onCountryChanged: (country) {
                                            if (country == null) return;
                                            HapticFeedback.selectionClick();
                                            setState(() => _selectedCountry = country);
                                          },
                                          onInternationalChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _international = value);
                                          },
                                          onAccountTypeChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _accountType = value);
                                          },
                                          onVehicleTypeChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _vehicleType = value);
                                          },
                                          onDriverShiftChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _driverShift = value);
                                          },
                                          onWarehouseShiftChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _warehouseShift = value);
                                          },
                                          onWarehouseDepartmentChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _warehouseDepartment = value);
                                          },
                                          onBusinessTypeChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _businessType = value);
                                          },
                                          onCargoTypeChanged: (value) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _cargoType = value);
                                          },
                                          onSave: _save,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
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
      onTap: () {
        HapticFeedback.selectionClick();
        theme.toggleTheme();
      },
      child: Icon(
        dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: dark ? AppColors.portOrange : AppColors.primary,
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final double progress;
  final _CountryData selectedCountry;
  final String role;
  final String roleTitle;
  final Color roleColor;
  final IconData roleIcon;
  final bool international;
  final String accountType;
  final String vehicleType;
  final String warehouseDepartment;
  final bool compact;

  const _ProfileHero({
    required this.progress,
    required this.selectedCountry,
    required this.role,
    required this.roleTitle,
    required this.roleColor,
    required this.roleIcon,
    required this.international,
    required this.accountType,
    required this.vehicleType,
    required this.warehouseDepartment,
    this.compact = false,
  });

  String get subtitle {
    switch (role) {
      case 'courier_driver':
        return 'Set vehicle, license and operating details before accepting deliveries.';
      case 'logistics_customer':
        return 'Set company, business type, cargo and preferred port for logistics operations.';
      default:
        return 'Set country, shipping mode and account identity for JD Logistics.';
    }
  }

  String get badge {
    switch (role) {
      case 'courier_driver':
        return vehicleType;
      case 'logistics_customer':
        return warehouseDepartment; // reused for cargo type display
      default:
        return accountType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroScene(
            progress: progress,
            selectedCountry: selectedCountry,
            roleIcon: roleIcon,
            roleColor: roleColor,
            role: role,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.public_rounded,
                  value: selectedCountry.region,
                  label: 'Region',
                  color: roleColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.payments_rounded,
                  value: selectedCountry.currency,
                  label: 'Currency',
                  color: AppColors.portOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RouteStrip(
            progress: progress,
            color: roleColor,
            vehicle: role == 'courier_driver'
                ? '🚚'
                : role == 'logistics_customer'
                    ? '🚢'
                    : international
                        ? '✈️'
                        : '🚚',
          ),
          const SizedBox(height: 22),
          Text(
            roleTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: compact ? 28 : 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                icon: Icons.flag_rounded,
                text: '${selectedCountry.flag} ${selectedCountry.countryName}',
                color: roleColor,
              ),
              _MiniPill(
                icon: roleIcon,
                text: roleTitle.replaceAll(' Profile Setup', ''),
                color: roleColor,
              ),
              _MiniPill(
                icon: Icons.badge_rounded,
                text: badge,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroScene extends StatelessWidget {
  final double progress;
  final _CountryData selectedCountry;
  final IconData roleIcon;
  final Color roleColor;
  final String role;

  const _HeroScene({
    required this.progress,
    required this.selectedCountry,
    required this.roleIcon,
    required this.roleColor,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 255,
      borderRadius: 34,
      padding: EdgeInsets.zero,
      color: AppColors.surface(context),
      child: Stack(
        clipBehavior: Clip.none,
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
            left: 16,
            bottom: 16,
            child: _CharacterCard(
              emoji: role == 'warehouse' ? '📦' : '👨‍✈️',
              label: role == 'warehouse' ? 'Parcel' : 'JD Hero',
              color: roleColor,
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: _CharacterCard(
              emoji: role == 'warehouse' ? '🏭' : '👩‍💼',
              label: role == 'warehouse' ? 'Hub' : 'JD Ops',
              color: AppColors.primary,
            ),
          ),
          Center(
            child: _ClayAvatar(
              flag: selectedCountry.flag,
              icon: roleIcon,
              color: roleColor,
            ),
          ),
          Positioned(
            left: 22,
            top: 26,
            child: Transform.translate(
              offset: Offset(math.sin(progress * math.pi * 2) * 10, 0),
              child: Icon(
                role == 'warehouse'
                    ? Icons.inventory_2_rounded
                    : Icons.flight_takeoff_rounded,
                color: roleColor,
                size: 27,
              ),
            ),
          ),
          Positioned(
            right: 34,
            bottom: 28,
            child: Transform.translate(
              offset: Offset(math.cos(progress * math.pi * 2) * 10, 0),
              child: Icon(
                role == 'warehouse'
                    ? Icons.warehouse_rounded
                    : Icons.local_shipping_rounded,
                color: AppColors.portOrange,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClayAvatar extends StatelessWidget {
  final String flag;
  final IconData icon;
  final Color color;

  const _ClayAvatar({
    required this.flag,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 118,
      height: 118,
      borderRadius: 38,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: color, size: 58),
          Positioned(
            right: 18,
            bottom: 17,
            child: Text(flag, style: const TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _CharacterCard({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 88,
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.14 : 0.08),
      borderColor: color.withValues(alpha: 0.22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 4),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 96,
      borderRadius: 24,
      padding: const EdgeInsets.all(14),
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.14 : 0.07),
      borderColor: color.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStrip extends StatelessWidget {
  final double progress;
  final Color color;
  final String vehicle;

  const _RouteStrip({
    required this.progress,
    required this.color,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 76,
      borderRadius: 25,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface(context),
      child: Row(
        children: [
          Icon(Icons.person_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: CustomPaint(
              painter: _DashedRoutePainter(
                progress: progress,
                dark: AppColors.isDark(context),
                color: color,
                vehicle: vehicle,
              ),
              child: const SizedBox(height: 36),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.verified_rounded, color: color),
        ],
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController vehicleNumberCtrl;
  final TextEditingController licenseCtrl;
  final TextEditingController experienceCtrl;
  final TextEditingController operatingCityCtrl;
  final TextEditingController employeeIdCtrl;
  final TextEditingController warehouseCodeCtrl;
  final TextEditingController warehouseLocationCtrl;
  final TextEditingController companyNameCtrl;
  final TextEditingController preferredPortCtrl;
  final List<_CountryData> countries;
  final _CountryData selectedCountry;
  final String role;
  final String roleTitle;
  final Color roleColor;
  final IconData roleIcon;
  final bool international;
  final String accountType;
  final String vehicleType;
  final String driverShift;
  final String warehouseShift;
  final String warehouseDepartment;
  final String businessType;
  final String cargoType;
  final bool isLoading;
  final ValueChanged<_CountryData?> onCountryChanged;
  final ValueChanged<bool> onInternationalChanged;
  final ValueChanged<String> onAccountTypeChanged;
  final ValueChanged<String> onVehicleTypeChanged;
  final ValueChanged<String> onDriverShiftChanged;
  final ValueChanged<String> onWarehouseShiftChanged;
  final ValueChanged<String> onWarehouseDepartmentChanged;
  final ValueChanged<String> onBusinessTypeChanged;
  final ValueChanged<String> onCargoTypeChanged;
  final VoidCallback onSave;

  const _ProfileFormCard({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.vehicleNumberCtrl,
    required this.licenseCtrl,
    required this.experienceCtrl,
    required this.operatingCityCtrl,
    required this.employeeIdCtrl,
    required this.warehouseCodeCtrl,
    required this.warehouseLocationCtrl,
    required this.companyNameCtrl,
    required this.preferredPortCtrl,
    required this.countries,
    required this.selectedCountry,
    required this.role,
    required this.roleTitle,
    required this.roleColor,
    required this.roleIcon,
    required this.international,
    required this.accountType,
    required this.vehicleType,
    required this.driverShift,
    required this.warehouseShift,
    required this.warehouseDepartment,
    required this.businessType,
    required this.cargoType,
    required this.isLoading,
    required this.onCountryChanged,
    required this.onInternationalChanged,
    required this.onAccountTypeChanged,
    required this.onVehicleTypeChanged,
    required this.onDriverShiftChanged,
    required this.onWarehouseShiftChanged,
    required this.onWarehouseDepartmentChanged,
    required this.onBusinessTypeChanged,
    required this.onCargoTypeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 36,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoleHeader(
            title: roleTitle,
            color: roleColor,
            icon: roleIcon,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: nameCtrl,
            label: role == 'warehouse' ? 'Employee Name' : AppStrings.fullName,
            hint: role == 'warehouse' ? 'Warehouse employee name' : 'Santosh Maskar',
            prefixIcon: Icons.person_outline_rounded,
            validator: Validators.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: emailCtrl,
            label: '${AppStrings.emailAddress} (optional)',
            hint: 'name@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          _CountrySelector(
            countries: countries,
            selectedCountry: selectedCountry,
            onChanged: onCountryChanged,
            color: roleColor,
          ),
          const SizedBox(height: 16),
          _CountryMetaCard(
            selectedCountry: selectedCountry,
            color: roleColor,
          ),
          const SizedBox(height: 18),
          if (role == 'courier_customer')
            _CustomerFields(
              international: international,
              accountType: accountType,
              color: roleColor,
              onInternationalChanged: onInternationalChanged,
              onAccountTypeChanged: onAccountTypeChanged,
            ),
          if (role == 'courier_driver')
            _DriverFields(
              vehicleNumberCtrl: vehicleNumberCtrl,
              licenseCtrl: licenseCtrl,
              experienceCtrl: experienceCtrl,
              operatingCityCtrl: operatingCityCtrl,
              vehicleType: vehicleType,
              driverShift: driverShift,
              color: roleColor,
              onVehicleTypeChanged: onVehicleTypeChanged,
              onDriverShiftChanged: onDriverShiftChanged,
            ),
          if (role == 'logistics_customer')
            _LogisticsCustomerFields(
              companyNameCtrl: companyNameCtrl,
              preferredPortCtrl: preferredPortCtrl,
              businessType: businessType,
              cargoType: cargoType,
              color: roleColor,
              onBusinessTypeChanged: onBusinessTypeChanged,
              onCargoTypeChanged: onCargoTypeChanged,
            ),
          const SizedBox(height: 24),
          GradientButton(
            label: AppStrings.continueText,
            isLoading: isLoading,
            onPressed: onSave,
            colors: [roleColor, AppColors.deepBlue],
            icon: Icons.arrow_forward_rounded,
            height: 58,
            borderRadius: 22,
          ),
          const SizedBox(height: 16),
          _SecurityNote(role: role, color: roleColor),
        ],
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;

  const _RoleHeader({
    required this.title,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniPill(icon: icon, text: title, color: color),
        const SizedBox(height: 14),
        Text(
          'Profile details',
          style: TextStyle(
            color: AppColors.text(context),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete this setup to open your JD Logistics workspace.',
          style: TextStyle(
            color: AppColors.subtext(context),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _CustomerFields extends StatelessWidget {
  final bool international;
  final String accountType;
  final Color color;
  final ValueChanged<bool> onInternationalChanged;
  final ValueChanged<String> onAccountTypeChanged;

  const _CustomerFields({
    required this.international,
    required this.accountType,
    required this.color,
    required this.onInternationalChanged,
    required this.onAccountTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SegmentTitle(text: 'Shipping preference'),
        const SizedBox(height: 10),
        _ModeSwitcher(
          left: 'Domestic',
          right: 'International',
          value: international,
          color: color,
          leftIcon: Icons.home_work_rounded,
          rightIcon: Icons.public_rounded,
          onChanged: onInternationalChanged,
        ),
        const SizedBox(height: 18),
        const _SegmentTitle(text: 'Account type'),
        const SizedBox(height: 10),
        _TwoOptionSwitcher(
          left: 'Personal',
          right: 'Business',
          value: accountType,
          color: color,
          leftIcon: Icons.person_rounded,
          rightIcon: Icons.storefront_rounded,
          onChanged: onAccountTypeChanged,
        ),
      ],
    );
  }
}

class _DriverFields extends StatelessWidget {
  final TextEditingController vehicleNumberCtrl;
  final TextEditingController licenseCtrl;
  final TextEditingController experienceCtrl;
  final TextEditingController operatingCityCtrl;
  final String vehicleType;
  final String driverShift;
  final Color color;
  final ValueChanged<String> onVehicleTypeChanged;
  final ValueChanged<String> onDriverShiftChanged;

  const _DriverFields({
    required this.vehicleNumberCtrl,
    required this.licenseCtrl,
    required this.experienceCtrl,
    required this.operatingCityCtrl,
    required this.vehicleType,
    required this.driverShift,
    required this.color,
    required this.onVehicleTypeChanged,
    required this.onDriverShiftChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SegmentTitle(text: 'Vehicle type'),
        const SizedBox(height: 10),
        _ChipSelector(
          values: const ['Bike', 'Van', 'Truck', 'Tempo'],
          selected: vehicleType,
          color: color,
          onChanged: onVehicleTypeChanged,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: vehicleNumberCtrl,
          label: 'Vehicle Number',
          hint: 'MH 01 AB 1234',
          prefixIcon: Icons.local_shipping_rounded,
          textCapitalization: TextCapitalization.characters,
          validator: _requiredValidator('Enter vehicle number'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: licenseCtrl,
          label: 'Driving License Number',
          hint: 'DL-XXXX-XXXX',
          prefixIcon: Icons.badge_rounded,
          textCapitalization: TextCapitalization.characters,
          validator: _requiredValidator('Enter license number'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: experienceCtrl,
          label: 'Experience',
          hint: '3 years',
          prefixIcon: Icons.timeline_rounded,
          validator: _requiredValidator('Enter experience'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: operatingCityCtrl,
          label: 'Operating City',
          hint: 'Mumbai',
          prefixIcon: Icons.location_city_rounded,
          validator: _requiredValidator('Enter operating city'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 18),
        const _SegmentTitle(text: 'Availability'),
        const SizedBox(height: 10),
        _ChipSelector(
          values: const ['Flexible', 'Morning', 'Evening', 'Night'],
          selected: driverShift,
          color: color,
          onChanged: onDriverShiftChanged,
        ),
      ],
    );
  }
}

class _LogisticsCustomerFields extends StatelessWidget {
  final TextEditingController companyNameCtrl;
  final TextEditingController preferredPortCtrl;
  final String businessType;
  final String cargoType;
  final Color color;
  final ValueChanged<String> onBusinessTypeChanged;
  final ValueChanged<String> onCargoTypeChanged;

  const _LogisticsCustomerFields({
    required this.companyNameCtrl,
    required this.preferredPortCtrl,
    required this.businessType,
    required this.cargoType,
    required this.color,
    required this.onBusinessTypeChanged,
    required this.onCargoTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: companyNameCtrl,
          label: 'Company Name',
          hint: 'ABC Trading Co. Ltd.',
          prefixIcon: Icons.business_rounded,
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator('Enter company name'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: preferredPortCtrl,
          label: 'Preferred Port / City',
          hint: 'Mumbai JNPT, Chennai, Delhi ICD',
          prefixIcon: Icons.anchor_rounded,
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator('Enter preferred port or city'),
        ),
        const SizedBox(height: 18),
        const _SegmentTitle(text: 'Business Type'),
        const SizedBox(height: 10),
        _ChipSelector(
          values: const ['Importer', 'Exporter', 'Both'],
          selected: businessType,
          color: color,
          onChanged: onBusinessTypeChanged,
        ),
        const SizedBox(height: 18),
        const _SegmentTitle(text: 'Cargo Type'),
        const SizedBox(height: 10),
        _ChipSelector(
          values: const ['General Cargo', 'Hazardous', 'Perishable', 'Oversized'],
          selected: cargoType,
          color: color,
          onChanged: onCargoTypeChanged,
        ),
      ],
    );
  }
}

String? Function(String?) _requiredValidator(String message) {
  return (value) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  };
}

class _CountrySelector extends StatelessWidget {
  final List<_CountryData> countries;
  final _CountryData selectedCountry;
  final ValueChanged<_CountryData?> onChanged;
  final Color color;

  const _CountrySelector({
    required this.countries,
    required this.selectedCountry,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: AppColors.surface(context),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_CountryData>(
          value: selectedCountry,
          isExpanded: true,
          menuMaxHeight: 340,
          borderRadius: BorderRadius.circular(22),
          dropdownColor: AppColors.surface(context),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: color,
          ),
          items: countries.map((country) {
            return DropdownMenuItem<_CountryData>(
              value: country,
              child: Row(
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      country.countryName,
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
                    style: TextStyle(
                      color: color,
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

class _CountryMetaCard extends StatelessWidget {
  final _CountryData selectedCountry;
  final Color color;

  const _CountryMetaCard({
    required this.selectedCountry,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetaItem(Icons.map_rounded, 'Region', selectedCountry.region),
      _MetaItem(Icons.payments_rounded, 'Currency', selectedCountry.currency),
      _MetaItem(Icons.translate_rounded, 'Language', selectedCountry.language),
      _MetaItem(Icons.phone_rounded, 'Dial', selectedCountry.dialCode),
    ];

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(14),
      color: AppColors.surface(context),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items
            .map(
              (item) => _MiniPill(
                icon: item.icon,
                text: '${item.label}: ${item.value}',
                color: color,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MetaItem {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem(this.icon, this.label, this.value);
}

class _SegmentTitle extends StatelessWidget {
  final String text;

  const _SegmentTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.text(context),
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final String left;
  final String right;
  final IconData leftIcon;
  final IconData rightIcon;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ModeSwitcher({
    required this.left,
    required this.right,
    required this.leftIcon,
    required this.rightIcon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ToggleShell(
      children: [
        Expanded(
          child: _ToggleOption(
            active: !value,
            icon: leftIcon,
            label: left,
            color: color,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ToggleOption(
            active: value,
            icon: rightIcon,
            label: right,
            color: color,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _TwoOptionSwitcher extends StatelessWidget {
  final String left;
  final String right;
  final String value;
  final Color color;
  final IconData leftIcon;
  final IconData rightIcon;
  final ValueChanged<String> onChanged;

  const _TwoOptionSwitcher({
    required this.left,
    required this.right,
    required this.value,
    required this.color,
    required this.leftIcon,
    required this.rightIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ToggleShell(
      children: [
        Expanded(
          child: _ToggleOption(
            active: value == left,
            icon: leftIcon,
            label: left,
            color: color,
            onTap: () => onChanged(left),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ToggleOption(
            active: value == right,
            icon: rightIcon,
            label: right,
            color: color,
            onTap: () => onChanged(right),
          ),
        ),
      ],
    );
  }
}

class _ToggleShell extends StatelessWidget {
  final List<Widget> children;

  const _ToggleShell({required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(7),
      color: AppColors.surface(context),
      child: Row(children: children),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.active,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.01 : 1,
      duration: const Duration(milliseconds: 180),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          alignment: Alignment.center,
          decoration: active
              ? BoxDecoration(
                  color: color.withValues(
                    alpha: AppColors.isDark(context) ? 0.15 : 0.09,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withValues(alpha: 0.22),
                  ),
                )
              : BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: active ? color : AppColors.subtext(context),
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? AppColors.text(context) : AppColors.subtext(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _ChipSelector extends StatelessWidget {
  final List<String> values;
  final String selected;
  final Color color;
  final ValueChanged<String> onChanged;

  const _ChipSelector({
    required this.values,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: values.map((value) {
        final active = selected == value;

        return InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(99),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.10)
                  : AppColors.surface(context),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: active ? color.withValues(alpha: 0.30) : AppColors.border(context),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: active ? color : AppColors.subtext(context),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  final String role;
  final Color color;

  const _SecurityNote({
    required this.role,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = role == 'courier_driver'
        ? 'Driver profile is used for delivery assignment, route tracking, rewards and payouts.'
        : role == 'logistics_customer'
            ? 'Logistics profile is used for import/export shipments, customs, containers and freight bookings.'
            : 'Customer profile is used for orders, tracking, invoices, payments and OBC rewards.';

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      color: AppColors.surface(context),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
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

class _ProfileBackgroundPainter extends CustomPainter {
  final double progress;
  final bool dark;
  final Color color;

  _ProfileBackgroundPainter({
    required this.progress,
    required this.dark,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = color.withValues(alpha: dark ? .13 : .20)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routes = [
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

    for (final path in routes) {
      canvas.drawPath(path, routePaint);
    }

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

    _drawIcon(
      canvas,
      Icons.warehouse_rounded,
      Offset(size.width * .75, size.height * .76),
    );
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 25,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color.withValues(alpha: dark ? .09 : .13),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ProfileBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dark != dark ||
        oldDelegate.color != color;
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
      ..color = dark ? AppColors.darkCard : Colors.white;

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

class _DashedRoutePainter extends CustomPainter {
  final double progress;
  final bool dark;
  final Color color;
  final String vehicle;

  _DashedRoutePainter({
    required this.progress,
    required this.dark,
    required this.color,
    required this.vehicle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: dark ? .65 : .82)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double x = -(progress * 28);
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + 12, y), paint);
      x += 28;
    }

    final nodeFill = Paint()
      ..color = dark ? AppColors.darkCard : Colors.white;

    final nodeStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final dx in [
      size.width * .28,
      size.width * .58,
      size.width * .84,
    ]) {
      canvas.drawCircle(Offset(dx, y), 6, nodeFill);
      canvas.drawCircle(Offset(dx, y), 6, nodeStroke);
    }

    final painter = TextPainter(
      text: TextSpan(
        text: vehicle,
        style: const TextStyle(fontSize: 17),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset((size.width + 36) * progress - 18, y - 26),
    );
  }

  @override
  bool shouldRepaint(covariant _DashedRoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dark != dark ||
        oldDelegate.color != color ||
        oldDelegate.vehicle != vehicle;
  }
}