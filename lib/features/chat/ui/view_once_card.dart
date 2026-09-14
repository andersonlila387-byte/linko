import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/message_model.dart';
import '../../../core/security/view_once_manager.dart';
import '../../../core/security/screen_security.dart';

class ViewOnceCard extends StatefulWidget {
  final MessageModel message;
  final ViewOnceManager viewOnceManager;
  final VoidCallback onConsumed;

  const ViewOnceCard({
    super.key,
    required this.message,
    required this.viewOnceManager,
    required this.onConsumed,
  });

  @override
  State<ViewOnceCard> createState() => _ViewOnceCardState();
}

class _ViewOnceCardState extends State<ViewOnceCard> {
  bool _isClearingClipboard = false;

  void _openViewOnceDialog(BuildContext context) async {
    if (!widget.viewOnceManager.canOpen(widget.message)) return;

    // Enable native screenshot & screen capture protection
    await ScreenSecurity.enableSecureScreen();

    final ramBuffer = Uint8List.fromList(utf8.encode(widget.message.content));

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false, // Force explicit close action
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'View Once Content',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  widget.message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (widget.message.type == MessageType.clipboard) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(_isClearingClipboard ? 'Copied (Auto-clears in 30s)' : 'Copy Clipboard'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.message.content));
                    setState(() {
                      _isClearingClipboard = true;
                    });
                    // Auto-clear system clipboard after 30 seconds
                    Future.delayed(const Duration(seconds: 30), () {
                      Clipboard.setData(const ClipboardData(text: ''));
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],
              const Text(
                'Closing this view will permanently destroy and shred this payload.',
                style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Dismiss & Shred'),
            ),
          ],
        );
      },
    );

    // Secure Shredding & Zero-Filling upon exit
    await widget.viewOnceManager.consumeMessage(
      message: widget.message,
      ramBuffer: ramBuffer,
    );

    await ScreenSecurity.disableSecureScreen();
    widget.onConsumed();
  }

  @override
  Widget build(BuildContext context) {
    final isConsumed = widget.message.isConsumed;

    if (isConsumed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey, size: 18),
            SizedBox(width: 8),
            Text(
              'Opened — Content no longer available.',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openViewOnceDialog(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A3C), Color(0xFF1E1E2A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  'View Once ${widget.message.type.name.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to reveal',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
