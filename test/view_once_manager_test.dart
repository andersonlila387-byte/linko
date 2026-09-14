import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:linko/core/models/message_model.dart';
import 'package:linko/core/security/view_once_manager.dart';
import 'package:linko/core/database/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final List<MessageModel> messages = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> updateMessage(MessageModel message) async {
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }
  }

  @override
  Future<void> saveMessage(MessageModel message) async {
    messages.add(message);
  }
}

void main() {
  group('ViewOnceManager Unit Tests', () {
    late MockChatRepository mockRepo;
    late ViewOnceManager manager;

    setUp(() {
      mockRepo = MockChatRepository();
      manager = ViewOnceManager(mockRepo);
    });

    test('RAM Buffer is zero-filled upon consuming View Once message', () async {
      final msg = MessageModel(
        id: 'msg_1',
        senderDeviceId: 'dev_a',
        receiverDeviceId: 'dev_b',
        type: MessageType.text,
        content: 'SuperSecretPassword123',
        isViewOnce: true,
        timestamp: DateTime.now(),
      );

      final ramBuffer = Uint8List.fromList([83, 117, 112, 101, 114]); // "Super"

      expect(manager.canOpen(msg), isTrue);

      final result = await manager.consumeMessage(
        message: msg,
        ramBuffer: ramBuffer,
      );

      expect(result, isTrue);
      expect(msg.isConsumed, isTrue);
      expect(msg.transferState, equals(TransferState.opened));
      expect(manager.canOpen(msg), isFalse);

      // Verify RAM buffer zero-fill shredding
      for (var b in ramBuffer) {
        expect(b, equals(0));
      }
    });

    test('Non-view-once messages cannot be consumed', () async {
      final msg = MessageModel(
        id: 'msg_2',
        senderDeviceId: 'dev_a',
        receiverDeviceId: 'dev_b',
        type: MessageType.text,
        content: 'Normal message',
        isViewOnce: false,
        timestamp: DateTime.now(),
      );

      final result = await manager.consumeMessage(message: msg);
      expect(result, isFalse);
      expect(msg.isConsumed, isFalse);
    });
  });
}
