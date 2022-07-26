import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  static Future<bool> deviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      return <BiometricType>[];
    }
  }

  static Future<Either<String, bool>> authenticate() async {
    final hasAuth = await deviceSupported();
    final isAvailable = await hasBiometrics();
    print("isAuthenticated22************* ${!isAvailable && !hasAuth}");
    if (!isAvailable && !hasAuth) return const Right(false);

    try {
      return Right(await _auth.authenticate(
          localizedReason: 'Scan Fingerprint to Authenticate',
          options: const AuthenticationOptions(sensitiveTransaction: true,
              useErrorDialogs: true, stickyAuth: true)));
    } on PlatformException catch (e) {
      return Left(e.code);
    }
  }
}
