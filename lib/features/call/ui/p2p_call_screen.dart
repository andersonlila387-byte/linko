import 'dart:async';
import 'package:flutter/material.dart';

class P2PCallScreen extends StatefulWidget {
  final String targetDeviceName;
  final bool isVideoCall;
  final String currentDeviceId;

  const P2PCallScreen({
    super.key,
    required this.targetDeviceName,
    required this.isVideoCall,
    required this.currentDeviceId,
  });

  @override
  State<P2PCallScreen> createState() => _P2PCallScreenState();
}

class _P2PCallScreenState extends State<P2PCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isCallConnected = false;
  int _callDurationSeconds = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    // Establish P2P stream connection
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isCallConnected = true;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color accentCyan = Color(0xFF00F0FF);

    return Scaffold(
      backgroundColor: bgBlack,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Call Surface
            if (widget.isVideoCall) ...[
              // Peer Video Stream Box
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF0A0A10),
                child: _isCameraOff
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: accentCyan.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: accentCyan, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  widget.targetDeviceName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.targetDeviceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Camera Turned Off',
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          // Simulated Peer Live Stream Overlay
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  color: accentCyan.withValues(alpha: 0.3),
                                  size: 80,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Encrypted P2P HD Stream • ${widget.targetDeviceName}',
                                  style: TextStyle(
                                    color: accentCyan.withValues(alpha: 0.7),
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Self Local Camera Preview Picture-in-Picture
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 110,
                              height: 150,
                              decoration: BoxDecoration(
                                color: cardBlack,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accentCyan.withValues(alpha: 0.5), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_rounded, color: Colors.white54, size: 28),
                                    SizedBox(height: 6),
                                    Text('You', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ] else ...[
              // Audio Call Surface
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile Avatar with Pulsing Audio Rings
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: accentCyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentCyan, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: accentCyan.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.targetDeviceName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Target Name
                    Text(
                      widget.targetDeviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Status Indicator
                    Text(
                      _isCallConnected
                          ? _formatDuration(_callDurationSeconds)
                          : 'Ringing P2P peer...',
                      style: TextStyle(
                        color: _isCallConnected ? accentCyan : Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Encryption Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded, color: accentCyan, size: 12),
                          SizedBox(width: 6),
                          Text(
                            'End-to-End Encrypted HD Voice',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Top Header Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    widget.isVideoCall ? 'P2P VIDEO CALL' : 'P2P VOICE CALL',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Bottom Action Control Bar
            Positioned(
              bottom: 36,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBlack.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white12, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Audio Toggle
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      isActive: _isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),

                    // Toggle Camera (if Video Call)
                    if (widget.isVideoCall)
                      _buildControlButton(
                        icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                        isActive: _isCameraOff,
                        onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                      ),

                    // Speakerphone Toggle
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                      isActive: _isSpeakerOn,
                      onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    ),

                    // End Call Button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent,
                              blurRadius: 16,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
