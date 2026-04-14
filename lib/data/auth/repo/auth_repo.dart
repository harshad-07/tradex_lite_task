import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';

class AuthRepository {
  static const _boxName = 'auth_session';

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  bool get hasSession => _box?.get(keyLoggedIn, defaultValue: false) == true;

  bool get isBiometricSaved => _box?.get(keyBiometric, defaultValue: false) == true;

  String? get savedEmail => _box?.get(keyEmail) as String?;

  Future<void> saveSession({required String email, required bool biometricEnabled}) async {
    await _box?.put(keyLoggedIn, true);
    await _box?.put(keyEmail, email);
    await saveBiometricPreference(biometricEnabled);
  }

  Future<void> saveBiometricPreference(bool enabled) async => await _box?.put(keyBiometric, enabled);

  Future<void> clearSession() async {
    await _box?.put(keyLoggedIn, false);
    await _box?.delete(keyEmail);
    await saveBiometricPreference(false);
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return email.trim().toLowerCase() == validEmail && password == validPassword;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await clearSession();
  }
}
