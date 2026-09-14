import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/device_model.dart';
import '../database/chat_repository.dart';
import 'transport_client.dart';
import 'internet_relay_service.dart';

enum ConnectionTier {
  localWifi,
  cloudRelay,
  offline,
}

class ConnectionManager {
  final String deviceId;
  final ChatRepository chatRepository;
  late TransportClient _transportClient;
  late InternetRelayService _relayService;

  ConnectionTier currentTier = ConnectionTier.offline;

  final StreamController<MessageModel> _incomingMessageController =
      StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get onMessageReceived => _incomingMessageController.stream;

  ConnectionManager({
    required this.deviceId,
    required this.chatRepository,
  }) {
    _transportClient = TransportClient(chatRepository: chatRepository);
    _relayService = InternetRelayService(
      deviceId: deviceId,
      chatRepository: chatRepository,
    );

    // Listen for relay messages
    _relayService.onRelayMessageReceived.listen((msg) {
      _incomingMessageController.add(msg);
    });
  }

  /// Initialize Relay connection
  Future<void> initRelay(String relayUrl) async {
    final success = await _relayService.connect(relayUrl);
    if (success) {
      currentTier = ConnectionTier.cloudRelay;
    }
  }

  /// Smart Multi-Tier Message Router: Attempts local Wi-Fi direct socket first, then E2EE Internet Relay
  Future<bool> routeAndSendMessage({
    required DeviceModel targetDevice,
    required MessageModel message,
  }) async {
    final sharedSecret = 'linko_shared_secret_${targetDevice.id}';

    // 1. Attempt Tier 1: Local Wi-Fi Direct Socket
    if (targetDevice.isLocal) {
      final localSent = await _transportClient.sendMessage(
        targetIp: targetDevice.ipAddress,
        targetPort: targetDevice.port,
        message: message,
      );

      if (localSent) {
        currentTier = ConnectionTier.localWifi;
        return true;
      }
    }

    // 2. Fallback to Tier 2: E2EE Zero-Knowledge Internet Relay
    if (_relayService.isConnected) {
      final relaySent = await _relayService.sendRelayMessage(
        targetDeviceId: targetDevice.id,
        message: message,
        sharedSecret: sharedSecret,
      );

      if (relaySent) {
        currentTier = ConnectionTier.cloudRelay;
        return true;
      }
    }

    if (kDebugMode) {
      print('[ConnectionManager] All transport tiers failed for device ${targetDevice.name}');
    }
    return false;
  }

  void dispose() {
    _relayService.disconnect();
    _incomingMessageController.close();
  }
}
