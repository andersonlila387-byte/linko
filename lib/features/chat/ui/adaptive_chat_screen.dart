import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/database/chat_repository.dart';
import '../../../core/network/local_discovery_service.dart';
import '../../../core/network/socket_server.dart';
import '../../../core/network/connection_manager.dart';
import '../../../core/security/view_once_manager.dart';
import 'chat_composer.dart';
import 'view_once_card.dart';
import 'message_status_indicator.dart';
import '../../call/ui/p2p_call_screen.dart';

const double largeScreenMinWidth = 650.0;

class AdaptiveChatScreen extends StatefulWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const AdaptiveChatScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  @override
  State<AdaptiveChatScreen> createState() => _AdaptiveChatScreenState();
}

class _AdaptiveChatScreenState extends State<AdaptiveChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  late ViewOnceManager _viewOnceManager;
  late SocketServer _socketServer;
  late ConnectionManager _connectionManager;
  LocalDiscoveryService? _discoveryService;

  final List<DeviceModel> _discoveredDevices = [];
  DeviceModel? _selectedDevice;
  List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _viewOnceManager = ViewOnceManager(_chatRepository);
    _socketServer = SocketServer(chatRepository: _chatRepository);
    _connectionManager = ConnectionManager(
      deviceId: widget.currentDeviceId,
      chatRepository: _chatRepository,
    );

    _initNetworking();
  }

  Future<void> _initNetworking() async {
    final platformName = Theme.of(context).platform.name;

    await _socketServer.startServer();

    // Listen for direct socket messages
    _socketServer.onMessageReceived.listen((msg) {
      if (_selectedDevice != null &&
          (msg.senderDeviceId == _selectedDevice!.id ||
              msg.receiverDeviceId == _selectedDevice!.id)) {
        _loadMessages();
      }
    });

    // Listen for long-distance relay messages
    _connectionManager.onMessageReceived.listen((msg) {
      _loadMessages();
    });

    // Start UDP discovery for local LAN peers
    _discoveryService = LocalDiscoveryService(
      localDeviceId: widget.currentDeviceId,
      localDeviceName: widget.currentDeviceName,
      platformName: platformName,
      tcpPort: 53843,
    );

    await _discoveryService!.startDiscovery();
    _discoveryService!.onDeviceDiscovered.listen((device) {
      setState(() {
        final existingIndex = _discoveredDevices.indexWhere((d) => d.id == device.id);
        if (existingIndex >= 0) {
          _discoveredDevices[existingIndex] = device;
        } else {
          _discoveredDevices.add(device);
          _selectedDevice ??= device;
        }
      });
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    if (_selectedDevice == null) return;
    final msgs = await _chatRepository.getMessagesForDevice(_selectedDevice!.id);
    setState(() {
      _messages = msgs;
    });
  }

  void _handleSendMessage({
    required String content,
    required MessageType type,
    required bool isViewOnce,
  }) async {
    if (_selectedDevice == null) return;

    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderDeviceId: widget.currentDeviceId,
      receiverDeviceId: _selectedDevice!.id,
      type: type,
      content: content,
      isViewOnce: isViewOnce,
      transferState: TransferState.sending,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(msg);
    });

    // Multi-tier transport selection (Local Wi-Fi direct socket -> E2EE Relay fallback)
    await _connectionManager.routeAndSendMessage(
      targetDevice: _selectedDevice!,
      message: msg,
    );

    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);

    return Scaffold(
      backgroundColor: bgBlack,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > largeScreenMinWidth;

            return Row(
              children: [
                // Desktop / Wide Screen Sidebar Device Drawer
                if (isWide)
                  Container(
                    width: 300,
                    decoration: const BoxDecoration(
                      color: cardBlack,
                      border: Border(right: BorderSide(color: borderStroke)),
                    ),
                    child: _buildDeviceListDrawer(accentCyan, borderStroke),
                  ),

                // Main WhatsApp Style Chat Window
                Expanded(
                  child: Column(
                    children: [
                      // 1. WhatsApp Style Header Bar
                      _buildWhatsAppHeader(accentCyan, borderStroke),

                      // Mobile device bar if narrow
                      if (!isWide && _discoveredDevices.isNotEmpty)
                        Container(
                          height: 52,
                          color: cardBlack,
                          child: _buildDeviceListHorizontal(accentCyan),
                        ),

                      // 2. Message Thread Wallpaper Area
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgBlack,
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.2,
                              colors: [
                                cardBlack.withValues(alpha: 0.5),
                                bgBlack,
                              ],
                            ),
                          ),
                          child: _selectedDevice == null
                              ? _buildEmptyChatPlaceholder(accentCyan)
                              : Column(
                                  children: [
                                    // WhatsApp Date Divider Pill
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBlack,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderStroke),
                                      ),
                                      child: const Text(
                                        'TODAY',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),

                                    // Message List Thread
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        itemCount: _messages.length,
                                        itemBuilder: (context, index) {
                                          final msg = _messages[index];
                                          final isMe = msg.senderDeviceId == widget.currentDeviceId;
                                          return _buildWhatsAppBubble(msg, isMe, accentCyan, borderStroke);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // 3. WhatsApp Style Bottom Composer
                      if (_selectedDevice != null)
                        ChatComposer(onSendMessage: _handleSendMessage),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWhatsAppHeader(Color accentCyan, Color borderStroke) {
    const Color cardBlack = Color(0xFF111118);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBlack,
        border: Border(bottom: BorderSide(color: borderStroke)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentCyan.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    _selectedDevice != null ? _selectedDevice!.name.substring(0, 1).toUpperCase() : 'L',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBlack, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDevice != null ? _selectedDevice!.name : 'Linko Direct Peer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedDevice != null
                      ? (_selectedDevice!.isLocal ? 'online • Local Wi-Fi Direct' : 'online • E2EE Relay')
                      : 'Scanning for local LAN peers...',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white70, size: 22),
            onPressed: () {
              final targetName = _selectedDevice?.name ?? 'Linko Peer';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => P2PCallScreen(
                    targetDeviceName: targetName,
                    isVideoCall: true,
                    currentDeviceId: widget.currentDeviceId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.white70, size: 20),
            onPressed: () {
              final targetName = _selectedDevice?.name ?? 'Linko Peer';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => P2PCallScreen(
                    targetDeviceName: targetName,
                    isVideoCall: false,
                    currentDeviceId: widget.currentDeviceId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppBubble(MessageModel msg, bool isMe, Color accentCyan, Color borderStroke) {
    final timeStr = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.isViewOnce)
              ViewOnceCard(
                message: msg,
                viewOnceManager: _viewOnceManager,
                onConsumed: () => _loadMessages(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF004D54) : const Color(0xFF1B1B26),
                  borderRadius: isMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topRight: Radius.circular(3),
                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.circular(3),
                        ),
                  border: Border.all(
                    color: isMe ? accentCyan.withValues(alpha: 0.3) : borderStroke,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          MessageStatusIndicator(
                            state: msg.transferState,
                            isViewOnce: msg.isViewOnce,
                            isConsumed: msg.isConsumed,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatPlaceholder(Color accentCyan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.forum_rounded, color: accentCyan, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a Device Peer to Begin Chatting',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'End-to-End Encrypted • Local Wi-Fi & Relay Transport',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListDrawer(Color accentCyan, Color borderStroke) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'PAIRED DEVICES',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        Expanded(
          child: _discoveredDevices.isEmpty
              ? const Center(
                  child: Text('Scanning network...', style: TextStyle(color: Colors.white38, fontSize: 12)),
                )
              : ListView.builder(
                  itemCount: _discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = _discoveredDevices[index];
                    final isSelected = device.id == _selectedDevice?.id;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: accentCyan.withValues(alpha: 0.1),
                      leading: CircleAvatar(
                        backgroundColor: device.isOnline ? Colors.greenAccent : Colors.grey,
                        radius: 5,
                      ),
                      title: Text(device.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text('${device.ipAddress}:${device.port}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      onTap: () {
                        setState(() => _selectedDevice = device);
                        _loadMessages();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDeviceListHorizontal(Color accentCyan) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = _discoveredDevices[index];
        final isSelected = device.id == _selectedDevice?.id;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: ChoiceChip(
            selected: isSelected,
            label: Text(device.name, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12)),
            selectedColor: accentCyan,
            backgroundColor: const Color(0xFF111118),
            onSelected: (_) {
              setState(() => _selectedDevice = device);
              _loadMessages();
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _socketServer.stopServer();
    _discoveryService?.stopDiscovery();
    super.dispose();
  }
}
