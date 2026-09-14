import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';

class MessageStatusIndicator extends StatelessWidget {
  final TransferState state;
  final bool isViewOnce;
  final bool isConsumed;

  const MessageStatusIndicator({
    super.key,
    required this.state,
    this.isViewOnce = false,
    this.isConsumed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isViewOnce && isConsumed) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_open, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            'Opened',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    switch (state) {
      case TransferState.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        );
      case TransferState.sent:
        return const Icon(Icons.check, size: 16, color: Colors.grey);
      case TransferState.delivered:
        return const Icon(Icons.done_all, size: 16, color: Colors.grey);
      case TransferState.opened:
        return const Icon(Icons.done_all, size: 16, color: Colors.blueAccent);
      case TransferState.failed:
        return const Icon(Icons.error_outline, size: 16, color: Colors.redAccent);
      case TransferState.queued:
        return const Icon(Icons.access_time, size: 14, color: Colors.orangeAccent);
    }
  }
}
