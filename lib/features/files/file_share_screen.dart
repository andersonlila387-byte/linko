import 'package:flutter/material.dart';

class FileShareScreen extends StatefulWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const FileShareScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  @override
  State<FileShareScreen> createState() => _FileShareScreenState();
}

class _FileShareScreenState extends State<FileShareScreen> {
  final List<Map<String, dynamic>> _transferHistory = [];
  String _selectedCategory = 'All Files';
  final List<String> _categories = ['All Files', 'Images', 'Documents', 'Media', 'Shredded'];

  // Simulated discovery list of available users
  final List<String> _availablePeers = [
    '@alex_pixel',
    '@sarah_laptop',
    '@windows_desktop',
  ];

  void _handleInitiateFileTransfer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111118),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SELECT RECEIVER USER',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select which online peer user should receive this file over Wi-Fi direct socket:',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _availablePeers.length,
              itemBuilder: (context, index) {
                final peerName = _availablePeers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF22222E)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF00F0FF), size: 20),
                    ),
                    title: Text(peerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Online • Local Wi-Fi Direct (53843)', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    trailing: const Icon(Icons.send_rounded, color: Color(0xFF00F0FF), size: 18),
                    onTap: () {
                      Navigator.pop(ctx);
                      _executeFileTransfer(peerName);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _executeFileTransfer(String receiverName) {
    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    final newTransfer = {
      'id': transferId,
      'name': 'Shared_Document_${transferId.substring(7)}.pdf',
      'size': '12.4 MB',
      'type': 'documents',
      'sender': widget.currentDeviceName,
      'receiver': receiverName,
      'status': 'Sending (54 MB/s)...',
      'isIncoming': false,
      'time': 'Just now',
    };

    setState(() {
      _transferHistory.insert(0, newTransfer);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File transfer started -> Sent to $receiverName over Wi-Fi.'),
        backgroundColor: const Color(0xFF00F0FF),
      ),
    );

    // Simulate completion after socket stream finishes
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        final idx = _transferHistory.indexWhere((item) => item['id'] == transferId);
        if (idx >= 0) {
          _transferHistory[idx]['status'] = 'Completed';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);

    final filteredHistory = _transferHistory.where((item) {
      if (_selectedCategory == 'All Files') return true;
      return item['type'].toString().toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: cardBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.offline_bolt_rounded, color: accentCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'FILE SHARE EXPRESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High Speed Drop Zone Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentCyan.withValues(alpha: 0.15),
                      cardBlack,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentCyan.withValues(alpha: 0.3), width: 1.2),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: accentCyan.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.cloud_upload_rounded, color: accentCyan, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Drop or Select Files to Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sending as ${widget.currentDeviceName} • Local Wi-Fi Socket',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _handleInitiateFileTransfer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: accentCyan.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.black, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Select Receiver & Send File',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Filter Category Chips
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? accentCyan : cardBlack,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? accentCyan : borderStroke,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Recent Transfers Section Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRANSFER HISTORY',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'P2P Direct Socket',
                    style: TextStyle(
                      color: accentCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Empty State or Transfer History
              filteredHistory.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: cardBlack,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderStroke),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.folder_open_rounded, color: Colors.white38, size: 44),
                          SizedBox(height: 12),
                          Text(
                            'No File Transfers Yet',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap "Select Receiver & Send File" above to send documents, photos, or media over local Wi-Fi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];
                        final isIncoming = item['isIncoming'] as bool;
                        final isCompleted = item['status'] == 'Completed';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBlack,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderStroke),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isIncoming
                                      ? Colors.blueAccent.withValues(alpha: 0.15)
                                      : accentCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  isIncoming ? Icons.download_rounded : Icons.upload_rounded,
                                  color: isIncoming ? Colors.blueAccent : accentCyan,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isIncoming
                                          ? 'From ${item['sender']} • ${item['size']}'
                                          : 'To ${item['receiver']} • ${item['size']}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : accentCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['status'] as String,
                                  style: TextStyle(
                                    color: isCompleted ? Colors.greenAccent : accentCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
