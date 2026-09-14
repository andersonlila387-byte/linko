import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../security/e2e_encryption.dart';
import '../database/chat_repository.dart';

class InternetRelayService {
  WebSocket? _webSocket;
  final String deviceId;
  final ChatRepository chatRepository;
  bool isConnected = false;

  final StreamController<MessageModel> _relayMessageController =
      StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get onRelayMessageReceived => _relayMessageController.stream;

  InternetRelayService({
    required this.deviceId,
    required this.chatRepository,
  });

  /// Connect to E2EE WebSocket Relay Server over Internet / Cellular
  Future<bool> connect(String relayUrl) async {
    try {
      _webSocket = await WebSocket.connect(relayUrl).timeout(const Duration(seconds: 4));
      isConnected = true;

      // Register device session on relay
      final registerPacket = jsonEncode({
        'action': 'REGISTER',
        'device_id': deviceId,
      });
      _webSocket!.add(registerPacket);

      _webSocket!.listen(
        (data) => _handleRelayPacket(data as String),
        onError: (err) {
          isConnected = false;
        },
        onDone: () {
          isConnected = false;
        },
      );

      if (kDebugMode) {
        print('[InternetRelayService] Connected to Cloud Relay: $relayUrl');
      }
      return true;
    } catch (e) {
      isConnected = false;
      if (kDebugMode) {
        print('[InternetRelayService] Could not connect to relay server: $e');
      }
      return false;
    }
  }

  /// Forward encrypted E2EE message over cloud relay
  Future<bool> sendRelayMessage({
    required String targetDeviceId,
    required MessageModel message,
    required String sharedSecret,
  }) async {
    if (_webSocket == null || !isConnected) return false;

    try {
      // 1. Encrypt message payload using E2EE
      final plainJson = jsonEncode(message.toMap());
      final encryptedBlob = E2EEncryption.encryptPayload(
        plainText: plainJson,
        sharedSecret: sharedSecret,
      );

      // 2. Build relay envelope
      final envelope = jsonEncode({
        'action': 'RELAY',
        'target_id': targetDeviceId,
        'sender_id': deviceId,
        'encrypted_blob': encryptedBlob,
      });

      _webSocket!.add(envelope);

      message.transferState = TransferState.sent;
      await chatRepository.updateTransferState(message.id, TransferState.sent);
      return true;
    } catch (e) {
      message.transferState = TransferState.failed;
      await chatRepository.updateTransferState(message.id, TransferState.failed);
      return false;
    }
  }

  void _handleRelayPacket(String raw) async {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['action'] == 'INCOMING_RELAY') {
        final encryptedBlob = map['encrypted_blob'] as String;
        final sharedSecret = 'linko_shared_secret_${map['sender_id']}';

        // Decrypt zero-knowledge payload
        final decryptedJson = E2EEncryption.decryptPayload(
          encryptedBlob: encryptedBlob,
          sharedSecret: sharedSecret,
        );

        if (decryptedJson != null) {
          final messageMap = jsonDecode(decryptedJson) as Map<String, dynamic>;
          final message = MessageModel.fromMap(messageMap);
          message.transferState = TransferState.delivered;

          await chatRepository.saveMessage(message);
          _relayMessageController.add(message);
        }
      }
    } catch (_) {}
  }

  void disconnect() {
    _webSocket?.close();
    isConnected = false;
    _relayMessageController.close();
  }
}
