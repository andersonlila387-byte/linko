import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/device_model.dart';

class LocalDiscoveryService {
  static const int discoveryPort = 53842;
  RawDatagramSocket? _udpSocket;
  Timer? _beaconTimer;
  final String localDeviceId;
  final String localDeviceName;
  final String platformName;
  final int tcpPort;

  final StreamController<DeviceModel> _discoveredDeviceController =
      StreamController<DeviceModel>.broadcast();

  Stream<DeviceModel> get onDeviceDiscovered => _discoveredDeviceController.stream;

  LocalDiscoveryService({
    required this.localDeviceId,
    required this.localDeviceName,
    required this.platformName,
    required this.tcpPort,
  });

  /// Start local UDP discovery broadcast & listener
  Future<void> startDiscovery() async {
    if (kIsWeb) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _discoveredDeviceController.add(DeviceModel(
          id: 'user_alex_pixel',
          name: '@alex_pixel',
          platform: 'android',
          ipAddress: '192.168.1.105',
          port: 53843,
          isOnline: true,
          isLocal: true,
          lastSeen: DateTime.now(),
        ));

        _discoveredDeviceController.add(DeviceModel(
          id: 'user_sarah_pc',
          name: '@sarah_pc',
          platform: 'windows',
          ipAddress: '192.168.1.120',
          port: 53843,
          isOnline: true,
          isLocal: false,
          lastSeen: DateTime.now(),
        ));
      });
      return;
    }
    try {
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: !Platform.isWindows,
      );

      _udpSocket!.broadcastEnabled = true;
      _udpSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpSocket!.receive();
          if (datagram != null) {
            _handleDatagram(datagram);
          }
        }
      });

      // Send heartbeat broadcast every 3 seconds
      _beaconTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _broadcastPresence();
      });

      if (kDebugMode) {
        print('[LocalDiscoveryService] Listening on UDP port $discoveryPort');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LocalDiscoveryService] Error starting UDP discovery: $e');
      }
    }
  }

  void _broadcastPresence() {
    if (_udpSocket == null) return;
    try {
      final payload = jsonEncode({
        'type': 'LINKO_BEACON',
        'id': localDeviceId,
        'name': localDeviceName,
        'platform': platformName,
        'tcp_port': tcpPort,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final bytes = utf8.encode(payload);
      _udpSocket!.send(bytes, InternetAddress('255.255.255.255'), discoveryPort);
    } catch (e) {
      if (kDebugMode) {
        print('[LocalDiscoveryService] Broadcast send failed: $e');
      }
    }
  }

  void _handleDatagram(Datagram datagram) {
    try {
      final raw = utf8.decode(datagram.data);
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data['type'] == 'LINKO_BEACON' && data['id'] != localDeviceId) {
        final device = DeviceModel(
          id: data['id'] as String,
          name: data['name'] as String,
          platform: data['platform'] as String,
          ipAddress: datagram.address.address,
          port: data['tcp_port'] as int,
          isOnline: true,
          isLocal: true,
          lastSeen: DateTime.now(),
        );

        _discoveredDeviceController.add(device);
      }
    } catch (_) {
      // Ignore malformed datagrams
    }
  }

  void stopDiscovery() {
    _beaconTimer?.cancel();
    _udpSocket?.close();
    _discoveredDeviceController.close();
  }
}
