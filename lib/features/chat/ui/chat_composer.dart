import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';

class ChatComposer extends StatefulWidget {
  final Function({
    required String content,
    required MessageType type,
    required bool isViewOnce,
  }) onSendMessage;

  const ChatComposer({super.key, required this.onSendMessage});

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _textController = TextEditingController();
  bool _isViewOnce = false;

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final isUrl = Uri.tryParse(text)?.hasAbsolutePath ?? false;
    final type = isUrl ? MessageType.link : MessageType.text;

    widget.onSendMessage(
      content: text,
      type: type,
      isViewOnce: _isViewOnce,
    );

    _textController.clear();
  }

  void _showWhatsAppAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111118),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SHARE CONTENT & MEDIA',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWhatsAppAttachIcon(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Document',
                  color: const Color(0xFF5157E0),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Document picker opened. Select document to send.'),
                        backgroundColor: Color(0xFF00F0FF),
                      ),
                    );
                  },
                ),
                _buildWhatsAppAttachIcon(
                  icon: Icons.image_rounded,
                  label: 'Photos & Media',
                  color: const Color(0xFFEC407A),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gallery opened. Select photos or video to send.'),
                        backgroundColor: Color(0xFF00F0FF),
                      ),
                    );
                  },
                ),
                _buildWhatsAppAttachIcon(
                  icon: Icons.lock_clock_rounded,
                  label: _isViewOnce ? 'View Once (ON)' : 'View Once (OFF)',
                  color: _isViewOnce ? Colors.amber : const Color(0xFF00E676),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _isViewOnce = !_isViewOnce);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppAttachIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.black.withValues(alpha: 0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode Indicator Chip if View Once active
          if (_isViewOnce)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_clock_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'View Once Mode Active',
                    style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isViewOnce = false),
                    child: const Icon(Icons.close_rounded, color: Colors.amber, size: 14),
                  ),
                ],
              ),
            ),

          // WhatsApp Style Floating Input Bar
          Row(
            children: [
              // Left Input Pill Container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cardBlack,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: borderStroke),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white54, size: 22),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Message...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _sendTextMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded, color: Colors.white54, size: 22),
                        onPressed: _showWhatsAppAttachmentMenu,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Right Circular Send Button (WhatsApp Style)
              GestureDetector(
                onTap: _sendTextMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isViewOnce ? Colors.amber : accentCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isViewOnce ? Colors.amber : accentCyan).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
