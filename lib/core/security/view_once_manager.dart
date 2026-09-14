import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../database/chat_repository.dart';

class ViewOnceManager {
  final ChatRepository _chatRepository;

  ViewOnceManager(this._chatRepository);

  /// Securely consume a View Once message.
  /// Enforces RAM zero-filling, temporary file shredding, and database mutation.
  Future<bool> consumeMessage({
    required MessageModel message,
    Uint8List? ramBuffer,
    String? tempFilePath,
  }) async {
    if (!message.isViewOnce || message.isConsumed) {
      return false;
    }

    try {
      // 1. Zero-fill RAM Buffer if provided
      if (ramBuffer != null && ramBuffer.isNotEmpty) {
        ramBuffer.fillRange(0, ramBuffer.length, 0);
        if (kDebugMode) {
          print('[ViewOnceManager] RAM byte buffer zero-filled.');
        }
      }

      // 2. Shred temporary local disk copy / file cache if present
      if (tempFilePath != null && !kIsWeb) {
        final file = File(tempFilePath);
        if (await file.exists()) {
          final length = await file.length();
          // Overwrite with zeroes before unlinking
          final zeroes = Uint8List(length);
          await file.writeAsBytes(zeroes, flush: true);
          await file.delete();
          if (kDebugMode) {
            print('[ViewOnceManager] Temp file shredded and unlinked: $tempFilePath');
          }
        }
      }

      // 3. Mutate message state to Consumed in Database
      message.isConsumed = true;
      message.consumedAt = DateTime.now();
      message.transferState = TransferState.opened;
      await _chatRepository.updateMessage(message);

      if (kDebugMode) {
        print('[ViewOnceManager] Message ${message.id} marked as consumed.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[ViewOnceManager] Error consuming View Once payload: $e');
      }
      return false;
    }
  }

  /// Checks if a message can be opened. Returns false if already consumed.
  bool canOpen(MessageModel message) {
    if (message.isViewOnce && message.isConsumed) {
      return false;
    }
    return true;
  }
}
