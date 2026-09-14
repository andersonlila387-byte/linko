import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/welcome/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LinkoApp());
}

class LinkoApp extends StatelessWidget {
  const LinkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String deviceId;
    final String deviceName;

    if (kIsWeb) {
      deviceId = 'web_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      deviceName = 'Linko Web Device';
    } else {
      deviceId = '${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      deviceName = Platform.isAndroid ? 'Android Phone' : (Platform.isWindows ? 'Windows PC' : 'Linko Device');
    }

    return MaterialApp(
      title: 'Linko Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080C),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: WelcomeScreen(
        currentDeviceId: deviceId,
        currentDeviceName: deviceName,
      ),
    );
  }
}
