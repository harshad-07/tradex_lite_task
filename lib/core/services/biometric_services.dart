import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../app_enums/app_enums.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get isAvailable async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      debugPrint('Biometric availability: canCheck=$canCheck, isSupported=$isSupported');
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<AppBiometricType> get availableType async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      debugPrint('Available biometrics 2: $biometrics');
      if (biometrics.contains(BiometricType.fingerprint)) {
        return AppBiometricType.fingerprint;
      } else if (biometrics.contains(BiometricType.face)) {
        return AppBiometricType.face;
      } else if (biometrics.contains(BiometricType.strong)) {
        return AppBiometricType.fingerprint;
      }
      return AppBiometricType.none;
    } on PlatformException {
      return AppBiometricType.none;
    }
  }

  Future<AppAuthResult> authenticate({String reason = 'Authenticate to continue'}) async {
    try {
      final success = await _auth.authenticate(localizedReason: reason, options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false, useErrorDialogs: true));
      debugPrint('Authentication result: $success');
      return success ? AppAuthResult.success : AppAuthResult.cancelled;
    } on PlatformException catch (e) {
      debugPrint('Authentication error: ${e.code}, ${e.message}');
      return switch (e.code) {
        'LockedOut' => AppAuthResult.lockedOut,
        'PermanentlyLockedOut' => AppAuthResult.permanentlyLockedOut,
        'NotAvailable' || 'NotEnrolled' || 'OtherOperatingSystem' => AppAuthResult.failed,
        _ => AppAuthResult.failed,
      };
    }
  }
}
