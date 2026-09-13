import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around [LocalAuthentication] for the "Khoá bằng Face ID"
/// setting. Device biometrics (Face ID / Touch ID / vân tay) with the OS
/// passcode as the fallback.
class AppLock {
  AppLock._();
  static final AppLock instance = AppLock._();

  final _auth = LocalAuthentication();

  /// Whether this device can do a biometric / device-credential check at all.
  Future<bool> get isAvailable async {
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.canCheckBiometrics || await _auth.isDeviceSupported());
    } on PlatformException {
      return false;
    }
  }

  /// Prompts the user. Returns true only on a successful unlock. Never throws.
  Future<bool> authenticate([String reason = 'Mở khoá An']) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
