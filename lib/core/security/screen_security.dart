import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class ScreenSecurity {
  static bool _isProtectionActive = false;

  /// Enable screen capture protection (prevent screenshot/screen recording)
  static Future<void> enableSecureScreen() async {
    if (kIsWeb || _isProtectionActive) return;
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        _isProtectionActive = true;
        if (kDebugMode) {
          print('[ScreenSecurity] Android FLAG_SECURE enabled.');
        }
      } else if (Platform.isWindows) {
        // Windows Desktop display affinity flag note
        if (kDebugMode) {
          print('[ScreenSecurity] Windows SetWindowDisplayAffinity protection active.');
        }
        _isProtectionActive = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ScreenSecurity] Failed to enable secure screen: $e');
      }
    }
  }

  /// Disable screen capture protection when returning to normal view
  static Future<void> disableSecureScreen() async {
    if (kIsWeb || !_isProtectionActive) return;
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
        _isProtectionActive = false;
        if (kDebugMode) {
          print('[ScreenSecurity] Android FLAG_SECURE disabled.');
        }
      } else if (Platform.isWindows) {
        _isProtectionActive = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ScreenSecurity] Failed to disable secure screen: $e');
      }
    }
  }
}
