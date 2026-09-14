import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../database/chat_repository.dart';

class SocketServer {
  final int port;
  final ChatRepository chatRepository;
  ServerSocket? _serverSocket;
  final StreamController<MessageModel> _incomingMessageController =
      StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get onMessageReceived => _incomingMessageController.stream;

  SocketServer({
    this.port = 53843,
    required this.chatRepository,
  });

  Future<void> startServer() async {
    if (kIsWeb) return;
    try {
      _serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );

      _serverSocket!.listen(_handleConnection);

      if (kDebugMode) {
        print('[SocketServer] Listening for TCP transfers on port $port');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SocketServer] Failed to bind TCP server: $e');
      }
    }
  }

  void _handleConnection(Socket clientSocket) {
    StringBuffer buffer = StringBuffer();

    clientSocket.listen(
      (Uint8List data) {
        buffer.write(utf8.decode(data));
        final content = buffer.toString();

        if (content.contains('\n')) {
          final lines = content.split('\n');
          for (int i = 0; i < lines.length - 1; i++) {
            if (lines[i].trim().isNotEmpty) {
              _processPacket(lines[i].trim(), clientSocket);
            }
          }
          buffer.clear();
          buffer.write(lines.last);
        }
      },
      onError: (error) {
        clientSocket.close();
      },
      onDone: () {
        clientSocket.close();
      },
    );
  }

  Future<void> _processPacket(String packetJson, Socket clientSocket) async {
    try {
      final map = jsonDecode(packetJson) as Map<String, dynamic>;
      final packetType = map['packet_type'] as String?;

      if (packetType == 'MESSAGE') {
        final messageMap = map['message'] as Map<String, dynamic>;
        final message = MessageModel.fromMap(messageMap);

        // Mark as Delivered upon successful socket receipt
        message.transferState = TransferState.delivered;
        await chatRepository.saveMessage(message);

        _incomingMessageController.add(message);

        // Send ACK back to sender
        final ack = jsonEncode({
          'packet_type': 'ACK',
          'message_id': message.id,
          'status': TransferState.delivered.name,
        });
        clientSocket.write('$ack\n');
        await clientSocket.flush();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SocketServer] Packet parsing error: $e');
      }
    }
  }

  void stopServer() {
    _serverSocket?.close();
    _incomingMessageController.close();
  }
}
