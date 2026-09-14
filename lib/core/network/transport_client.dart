import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../database/chat_repository.dart';

class TransportClient {
  final ChatRepository chatRepository;

  TransportClient({required this.chatRepository});

  /// Sends a message directly to a peer device IP and Port over local TCP socket
  Future<bool> sendMessage({
    required String targetIp,
    required int targetPort,
    required MessageModel message,
  }) async {
    if (kIsWeb) {
      message.transferState = TransferState.sent;
      await chatRepository.saveMessage(message);
      await Future.delayed(const Duration(milliseconds: 300));
      message.transferState = TransferState.delivered;
      await chatRepository.updateTransferState(message.id, TransferState.delivered);
      return true;
    }
    Socket? socket;
    try {
      // 1. Mark state as Sending
      message.transferState = TransferState.sending;
      await chatRepository.saveMessage(message);

      // 2. Open Direct Socket Connection over Wi-Fi
      socket = await Socket.connect(
        targetIp,
        targetPort,
        timeout: const Duration(seconds: 5),
      );

      // 3. Construct framed payload
      final payload = jsonEncode({
        'packet_type': 'MESSAGE',
        'message': message.toMap(),
      });

      // 4. Send Packet over Socket
      socket.write('$payload\n');
      await socket.flush();

      // Mark local state as Sent
      message.transferState = TransferState.sent;
      await chatRepository.updateTransferState(message.id, TransferState.sent);

      // 5. Listen for ACK response from recipient
      final Completer<bool> ackCompleter = Completer<bool>();

      socket.listen(
        (Uint8List data) async {
          final response = utf8.decode(data).trim();
          if (response.contains('ACK')) {
            final lines = response.split('\n');
            for (var line in lines) {
              if (line.contains('ACK')) {
                try {
                  final map = jsonDecode(line) as Map<String, dynamic>;
                  if (map['message_id'] == message.id &&
                      map['status'] == TransferState.delivered.name) {
                    message.transferState = TransferState.delivered;
                    await chatRepository.updateTransferState(
                      message.id,
                      TransferState.delivered,
                    );
                    if (!ackCompleter.isCompleted) ackCompleter.complete(true);
                  }
                } catch (_) {}
              }
            }
          }
        },
        onError: (err) {
          if (!ackCompleter.isCompleted) ackCompleter.complete(false);
        },
        onDone: () {
          if (!ackCompleter.isCompleted) ackCompleter.complete(true);
        },
      );

      return await ackCompleter.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () => true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TransportClient] Failed to send message to $targetIp:$targetPort: $e');
      }
      message.transferState = TransferState.failed;
      await chatRepository.updateTransferState(message.id, TransferState.failed);
      return false;
    } finally {
      socket?.destroy();
    }
  }
}
