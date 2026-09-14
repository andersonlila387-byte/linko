import 'package:flutter_test/flutter_test.dart';
import 'package:linko/core/models/message_model.dart';

void main() {
  group('MessageModel Serialization Tests', () {
    test('MessageModel converts to and from map correctly', () {
      final now = DateTime.now();
      final message = MessageModel(
        id: '101',
        senderDeviceId: 'phone_01',
        receiverDeviceId: 'pc_01',
        type: MessageType.clipboard,
        content: 'https://example.com/private-page',
        isViewOnce: true,
        transferState: TransferState.delivered,
        timestamp: now,
      );

      final map = message.toMap();
      expect(map['id'], equals('101'));
      expect(map['type'], equals('clipboard'));
      expect(map['is_view_once'], equals(1));
      expect(map['transfer_state'], equals('delivered'));

      final restored = MessageModel.fromMap(map);
      expect(restored.id, equals(message.id));
      expect(restored.type, equals(MessageType.clipboard));
      expect(restored.isViewOnce, isTrue);
      expect(restored.transferState, equals(TransferState.delivered));
    });
  });
}
