enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  file,
  link,
  code,
  clipboard,
}

enum TransferState {
  sending,
  sent,
  delivered,
  opened,
  failed,
  queued,
}

class MessageModel {
  final String id;
  final String senderDeviceId;
  final String receiverDeviceId;
  final MessageType type;
  final String content; // Text, URL, Code, or raw file path/binary payload ref
  final String? fileName;
  final int? fileSize;
  final bool isViewOnce;
  TransferState transferState;
  final DateTime timestamp;
  bool isConsumed;
  DateTime? consumedAt;

  MessageModel({
    required this.id,
    required this.senderDeviceId,
    required this.receiverDeviceId,
    required this.type,
    required this.content,
    this.fileName,
    this.fileSize,
    this.isViewOnce = false,
    this.transferState = TransferState.sending,
    required this.timestamp,
    this.isConsumed = false,
    this.consumedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_device_id': senderDeviceId,
      'receiver_device_id': receiverDeviceId,
      'type': type.name,
      'content': content,
      'file_name': fileName,
      'file_size': fileSize,
      'is_view_once': isViewOnce ? 1 : 0,
      'transfer_state': transferState.name,
      'timestamp': timestamp.toIso8601String(),
      'is_consumed': isConsumed ? 1 : 0,
      'consumed_at': consumedAt?.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      senderDeviceId: map['sender_device_id'] as String,
      receiverDeviceId: map['receiver_device_id'] as String,
      type: MessageType.values.byName(map['type'] as String),
      content: map['content'] as String,
      fileName: map['file_name'] as String?,
      fileSize: map['file_size'] as int?,
      isViewOnce: (map['is_view_once'] as int) == 1,
      transferState: TransferState.values.byName(map['transfer_state'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isConsumed: (map['is_consumed'] as int) == 1,
      consumedAt: map['consumed_at'] != null ? DateTime.parse(map['consumed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel.fromMap(json);
}
