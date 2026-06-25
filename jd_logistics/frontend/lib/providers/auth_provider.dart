import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/auth/token_manager.dart';
import 'package:jd_style_logistics/models/user_model.dart';
import 'package:jd_style_logistics/services/auth_service.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';
import 'package:jd_style_logistics/core/storage/secure_storage_service.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Roles used throughout the app.
/// courier_customer  — domestic parcel customer
/// courier_driver    — delivery driver (courier only)
/// logistics_customer — import/export freight customer
/// admin             — full control tower
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // The role the user selected before / during login.
  String? _selectedRole;
  // Last known role (survives logout so the screen can pre-select it).
  String? _lastRole;
  // Which top-level service the user chose: courier | logistics | admin
  String? _selectedServiceType;

  // ── Getters ──────────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String? get selectedRole => _selectedRole;
  String? get lastRole => _lastRole;
  String? get selectedServiceType => _selectedServiceType;

  /// The effective role to use for routing decisions.
  String? get userRole => _user?.role ?? _selectedRole ?? _lastRole;

  bool get hasSelectedRole => _selectedRole != null && _selectedRole!.isNotEmpty;

  bool get isCourierCustomer => userRole == 'courier_customer';
  bool get isCourierDriver => userRole == 'courier_driver';
  bool get isLogisticsCustomer => userRole == 'logistics_customer';
  bool get isAdmin => userRole == 'admin';

  // Backward-compat helpers used by existing screens.
  bool get isCustomer => isCourierCustomer || isLogisticsCustomer;
  bool get isDriver => isCourierDriver;
  bool get isWarehouse => false; // warehouse is no longer a login role

  // ── Constructor ───────────────────────────────────────────────────────────────

  StreamSubscription<String>? _sessionSub;

  AuthProvider() {
    _init();
    // Trigger safe logout whenever the JWT interceptor signals expiry.
    _sessionSub = TokenManager.sessionExpiredStream.listen((_) {
      logoutAndChooseRole();
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  // ── Init (called on app start) ────────────────────────────────────────────────

  Future<void> _init() async {
    _status = AuthStatus.unknown;
    notifyListeners();

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final role = await SecureStorageService.instance.getUserRole();

      _lastRole = role != null ? _normalizeRole(role) : null;
      _selectedRole = _lastRole;
      _selectedServiceType = _serviceTypeForRole(_lastRole);

      if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
        try {
          final data = await AuthService.instance.getProfile();
          _user = UserModel.fromJson(data['data'] as Map<String, dynamic>);
          _selectedRole = _normalizeRole(_user?.role ?? role);
          _lastRole = _selectedRole;
          _status = AuthStatus.authenticated;
        } catch (_) {
          _user = null;
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // ── Service type ──────────────────────────────────────────────────────────────

  Future<void> setServiceType(String type) async {
    _selectedServiceType = type;
    notifyListeners();
  }

  // ── Role selection (before login) ─────────────────────────────────────────────

  Future<void> selectLoginRole(String role) async {
    final normalizedRole = _normalizeRole(role);

    _selectedRole = normalizedRole;
    _lastRole = normalizedRole;
    _selectedServiceType = _serviceTypeForRole(normalizedRole);
    _error = null;

    await SecureStorageService.instance.saveUserRole(normalizedRole);

    notifyListeners();
  }

  Future<void> clearSelectedRole() async {
    _selectedRole = null;
    _error = null;
    notifyListeners();
  }

  // ── OTP flow ──────────────────────────────────────────────────────────────────

  Future<bool> sendOtp(String phone) async {
    if (!hasSelectedRole) {
      _error = 'Please select your role first';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      await AuthService.instance.sendOtp(phone);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    if (!hasSelectedRole) {
      _error = 'Please select your role first';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final data = await AuthService.instance.verifyOtp(phone, otp);
      final payload = data['data'] as Map<String, dynamic>;

      final token = payload['token'] as String;
      final user = UserModel.fromJson(payload['user'] as Map<String, dynamic>);

      // Backend returns generic 'customer' for new users — preserve _selectedRole.
      final backendRole = _normalizeRole(user.role.isNotEmpty ? user.role : 'courier_customer');
      final finalRole = (backendRole == 'courier_customer' && _selectedRole != null)
          ? _normalizeRole(_selectedRole!)
          : backendRole;

      await SecureStorageService.instance.saveAccessToken(token);
      await SecureStorageService.instance.saveUserId(user.id);
      await SecureStorageService.instance.saveUserRole(finalRole);
      await SecureStorageService.instance.savePhone(phone);

      _user = user;
      _selectedRole = finalRole;
      _lastRole = finalRole;
      _selectedServiceType = _serviceTypeForRole(finalRole);
      _status = AuthStatus.authenticated;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Profile setup ─────────────────────────────────────────────────────────────

  Future<bool> setupProfile({
    required String name,
    String? email,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await AuthService.instance.setupProfile(name, email);
      final rawUser = UserModel.fromJson(data['data'] as Map<String, dynamic>);

      // Same logic as verifyOtp: backend 'customer' → defer to _selectedRole.
      final rawRole = _normalizeRole(
        rawUser.role.isNotEmpty ? rawUser.role : 'courier_customer',
      );
      final role = (rawRole == 'courier_customer' && _selectedRole != null)
          ? _normalizeRole(_selectedRole!)
          : rawRole.isNotEmpty
              ? rawRole
              : _normalizeRole(_lastRole ?? 'courier_customer');

      _user = rawUser;
      await SecureStorageService.instance.saveUserRole(role);

      _selectedRole = role;
      _lastRole = role;
      _selectedServiceType = _serviceTypeForRole(role);
      _status = AuthStatus.authenticated;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final previousRole = _selectedRole ?? _lastRole;

    await SecureStorageService.instance.clearAll();

    _user = null;
    _selectedRole = previousRole;
    _lastRole = previousRole;
    _status = AuthStatus.unauthenticated;
    _error = null;

    if (previousRole != null && previousRole.isNotEmpty) {
      await SecureStorageService.instance.saveUserRole(previousRole);
    }

    notifyListeners();
  }

  Future<void> logoutAndChooseRole() async {
    await SecureStorageService.instance.clearAll();

    _user = null;
    _selectedRole = null;
    _lastRole = null;
    _selectedServiceType = null;
    _status = AuthStatus.unauthenticated;
    _error = null;

    notifyListeners();
  }

  // ── Helpers used by UI ────────────────────────────────────────────────────────

  void updateUser(UserModel user) {
    _user = user;
    final role = _normalizeRole(user.role);
    _selectedRole = role;
    _lastRole = role;
    _selectedServiceType = _serviceTypeForRole(role);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Returns the dashboard route for the given (or current) role.
  String dashboardRouteForRole([String? role]) {
    final value = _normalizeRole(role ?? userRole ?? 'courier_customer');

    switch (value) {
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

  String loginTitleForRole([String? role]) {
    final value = _normalizeRole(role ?? selectedRole ?? 'courier_customer');
    switch (value) {
      case 'courier_driver':
        return 'Courier Driver Login';
      case 'logistics_customer':
        return 'Logistics Customer Login';
      case 'admin':
        return 'Admin Login';
      case 'courier_customer':
      default:
        return 'Courier Customer Login';
    }
  }

  String profileTitleForRole([String? role]) {
    final value = _normalizeRole(role ?? selectedRole ?? 'courier_customer');
    switch (value) {
      case 'courier_driver':
        return 'Driver Profile Setup';
      case 'logistics_customer':
        return 'Logistics Profile Setup';
      case 'admin':
        return 'Admin Setup';
      case 'courier_customer':
      default:
        return 'Customer Profile Setup';
    }
  }

  IconData iconForRole([String? role]) {
    final value = _normalizeRole(role ?? selectedRole ?? 'courier_customer');
    switch (value) {
      case 'courier_driver':
        return Icons.delivery_dining_rounded;
      case 'logistics_customer':
        return Icons.directions_boat_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'courier_customer':
      default:
        return Icons.person_rounded;
    }
  }

  Color colorForRole([String? role]) {
    final value = _normalizeRole(role ?? selectedRole ?? 'courier_customer');
    switch (value) {
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

  // ── Private helpers ───────────────────────────────────────────────────────────

  /// Normalises any role string to the canonical 4-role set.
  String _normalizeRole(String role) {
    final v = role.trim().toLowerCase();
    switch (v) {
      case 'courier_driver':
      case 'driver':
        return 'courier_driver';
      case 'logistics_customer':
        return 'logistics_customer';
      case 'admin':
        return 'admin';
      // warehouse is no longer a login role — fall through to courier_customer
      case 'warehouse':
      case 'courier_customer':
      case 'customer':
      default:
        return 'courier_customer';
    }
  }

  String? _serviceTypeForRole(String? role) {
    if (role == null) return null;
    switch (role) {
      case 'courier_customer':
      case 'courier_driver':
        return 'courier';
      case 'logistics_customer':
        return 'logistics';
      case 'admin':
        return 'admin';
      default:
        return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
