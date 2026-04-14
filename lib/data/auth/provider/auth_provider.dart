import 'package:flutter/foundation.dart';

import '../../../core/app_enums/app_enums.dart';
import '../../../core/services/biometric_services.dart';
import '../repo/auth_repo.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final BiometricService _bio = BiometricService();

  ///VARS
  AuthStatus _status = AuthStatus.splash;
  String? _errorMessage;
  bool _biometricEnabled = false;
  AppBiometricType _availableBiometric = AppBiometricType.none;
  bool _obscurePassword = true;

  ///GETTERS
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isSplash => _status == AuthStatus.splash;
  bool get isPendingBiometric => _status == AuthStatus.pendingBiometric;
  bool get isLoading => _status == AuthStatus.loading;
  bool get biometricEnabled => _biometricEnabled;
  AppBiometricType get availableBiometric => _availableBiometric;
  bool get obscurePassword => _obscurePassword;

  ///
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  ///FUNCS OR METHODS
  Future<void> init() async {
    await _repo.init();
    await checkBiometricAvailability();
    _biometricEnabled = _repo.isBiometricSaved;
  }

  Future<void> checkSavedSession() async {
    if (!_repo.hasSession) {
      _status = AuthStatus.initial;
      notifyListeners();
      return;
    }
    _status = AuthStatus.loading;
    notifyListeners();

    if (_biometricEnabled && _availableBiometric != AppBiometricType.none) {
      final res = await _bio.authenticate(reason: 'Verify to continue as ${_repo.savedEmail ?? 'user'}');
      _status = res == AppAuthResult.success ? AuthStatus.authenticated : AuthStatus.initial; // failed/cancelled → force re-login
    } else {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> checkBiometricAvailability() async {
    final available = await _bio.isAvailable;
    if (available) {
      _availableBiometric = await _bio.availableType;
    } else {
      _availableBiometric = AppBiometricType.none;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final success = await _repo.login(email, password);

    if (success) {
      if (_availableBiometric != AppBiometricType.none && !_biometricEnabled) {
        _status = AuthStatus.pendingBiometric;
      } else {
        await _repo.saveSession(email: email, biometricEnabled: _biometricEnabled);
        _status = AuthStatus.authenticated;
      }
    } else {
      _status = AuthStatus.error;
      _errorMessage = 'Invalid email or password';
    }
    notifyListeners();
    return success;
  }

  Future<void> completeLogin({String? email}) async {
    await _repo.saveSession(email: email ?? _repo.savedEmail ?? '', biometricEnabled: _biometricEnabled);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> enableBiometric() async {
    final res = await _bio.authenticate(reason: 'Verify your identity to enable biometric login');
    _biometricEnabled = res == AppAuthResult.success;
    await _repo.saveBiometricPreference(_biometricEnabled);
    notifyListeners();
  }

  Future<void> disableBiometric() async {
    _biometricEnabled = false;
    await _repo.saveBiometricPreference(false);
    notifyListeners();
  }

  Future<bool> biometricLogin() async {
    if (!_biometricEnabled) return false;

    _status = AuthStatus.loading;
    notifyListeners();

    final res = await _bio.authenticate(reason: 'Log in to TradeX Lite');

    if (res == AppAuthResult.success) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.initial;
    }
    notifyListeners();
    return res == AppAuthResult.success;
  }

  Future<bool> verifyIdentity({String reason = 'Verify your identity'}) async {
    if (!_biometricEnabled || _availableBiometric == AppBiometricType.none) {
      return false;
    }
    final res = await _bio.authenticate(reason: reason);
    return res == AppAuthResult.success;
  }

  Future<void> logout() async {
    await _repo.logout();
    _biometricEnabled = false;
    _status = AuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
