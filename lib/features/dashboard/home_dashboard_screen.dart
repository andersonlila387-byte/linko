import 'package:flutter/material.dart';
import '../chat/ui/adaptive_chat_screen.dart';
import '../files/file_share_screen.dart';
import '../games/night_game_screen.dart';
import '../settings/settings_screen.dart';
import '../vault/secret_vault_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const HomeDashboardScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showDiscoveryRadarModal() {
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
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.radar_rounded, color: Color(0xFF00F0FF), size: 24),
                SizedBox(width: 10),
                Text(
                  'LOCAL LAN DISCOVERY RADAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Broadcasting UDP packets on port 53843 to find active Android, Windows, and Web devices on your local network...',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            const LinearProgressIndicator(
              color: Color(0xFF00F0FF),
              backgroundColor: Color(0xFF22222E),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nearby Devices Status:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text('Scanning for LAN peers...', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);
    const Color accentPink = Color(0xFFFF007A);
    const Color accentPurple = Color(0xFF9D00FF);

    return Scaffold(
      backgroundColor: bgBlack,
      body: Stack(
        children: [
          // Background Glow Accents
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentCyan.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentPink.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 950),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentCyan.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.hub_rounded,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'LINKO HUB',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // User Tag Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cardBlack,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: borderStroke),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person_rounded, color: accentCyan, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.currentDeviceName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                                    onPressed: () => _navigateTo(
                                      SettingsScreen(
                                        currentDeviceId: widget.currentDeviceId,
                                        currentDeviceName: widget.currentDeviceName,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // 2. Hero Welcome & Network Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cardBlack,
                                  accentCyan.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderStroke),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Welcome back, ${widget.currentDeviceName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.greenAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'E2EE Active',
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Explore all your direct device features below. Fast, zero-memory, and end-to-end encrypted.',
                                  style: TextStyle(
                                    color: Color(0xFF888894),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Quick Network Stats Bar
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderStroke),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildQuickStat(
                                        icon: Icons.wifi_tethering_rounded,
                                        label: 'Local Wi-Fi',
                                        value: 'Ready',
                                        accent: accentCyan,
                                      ),
                                      Container(width: 1, height: 24, color: borderStroke),
                                      _buildQuickStat(
                                        icon: Icons.speed_rounded,
                                        label: 'Max Speed',
                                        value: '60 MB/s',
                                        accent: Colors.white,
                                      ),
                                      Container(width: 1, height: 24, color: borderStroke),
                                      _buildQuickStat(
                                        icon: Icons.lock_rounded,
                                        label: 'Protocol',
                                        value: 'E2EE Relay',
                                        accent: accentPink,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Section Title
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FEATURE DISCOVERY HUB',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              Text(
                                'Tap card to launch',
                                style: TextStyle(
                                  color: accentCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 3. Fancy Feature Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 3 : (constraints.maxWidth > 480 ? 2 : 1),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isWide ? 1.15 : (constraints.maxWidth > 480 ? 1.05 : 1.3),
                            children: [
                              // Card 1: Direct File Share
                              _buildFancyFeatureCard(
                                icon: Icons.offline_bolt_rounded,
                                tag: 'LOCAL WI-FI SPEED',
                                title: 'Direct File Share',
                                description: 'Ultra-fast offline device-to-device file & media transfer.',
                                buttonText: 'Open File Share',
                                accentColor: accentCyan,
                                cardBlack: cardBlack,
                                borderStroke: borderStroke,
                                onTap: () => _navigateTo(
                                  FileShareScreen(
                                    currentDeviceId: widget.currentDeviceId,
                                    currentDeviceName: widget.currentDeviceName,
                                  ),
                                ),
                              ),

                              // Card 2: Encrypted Chat
                              _buildFancyFeatureCard(
                                icon: Icons.forum_rounded,
                                tag: 'ZERO-KNOWLEDGE E2EE',
                                title: 'Encrypted Chat',
                                description: 'Direct socket and relay E2EE messaging with contacts.',
                                buttonText: 'Open Messages',
                                accentColor: Colors.blueAccent,
                                cardBlack: cardBlack,
                                borderStroke: borderStroke,
                                onTap: () => _navigateTo(
                                  AdaptiveChatScreen(
                                    currentDeviceId: widget.currentDeviceId,
                                    currentDeviceName: widget.currentDeviceName,
                                  ),
                                ),
                              ),

                              // Card 3: Night Game Arcade
                              _buildFancyFeatureCard(
                                icon: Icons.sports_esports_rounded,
                                tag: 'P2P MULTIPLAYER',
                                title: 'Night Game Arcade',
                                description: 'Play live turn-based multiplayer games with connected devices.',
                                buttonText: 'Play Arcade',
                                accentColor: accentPink,
                                cardBlack: cardBlack,
                                borderStroke: borderStroke,
                                onTap: () => _navigateTo(
                                  NightGameScreen(
                                    currentDeviceId: widget.currentDeviceId,
                                    currentDeviceName: widget.currentDeviceName,
                                  ),
                                ),
                              ),

                              // Card 4: View-Once Shredder
                              _buildFancyFeatureCard(
                                icon: Icons.lock_clock_rounded,
                                tag: 'ZERO MEMORY TRAIL',
                                title: 'View-Once Shredder',
                                description: 'Self-destructing text and media with RAM-only byte overwrite.',
                                buttonText: 'Launch Shredder',
                                accentColor: accentPurple,
                                cardBlack: cardBlack,
                                borderStroke: borderStroke,
                                onTap: () => _navigateTo(
                                  AdaptiveChatScreen(
                                    currentDeviceId: widget.currentDeviceId,
                                    currentDeviceName: widget.currentDeviceName,
                                  ),
                                ),
                              ),

                              // Card 5: Device Discovery Radar
                              _buildFancyFeatureCard(
                                icon: Icons.radar_rounded,
                                tag: 'UDP LAN SCANNER',
                                title: 'Discovery Radar',
                                description: 'Real-time UDP scanner discovering Android, Windows & Web peers.',
                                buttonText: 'Scan Network',
                                accentColor: Colors.greenAccent,
                                cardBlack: cardBlack,
                                borderStroke: borderStroke,
                                onTap: _showDiscoveryRadarModal,
                              ),

                              // Card 6: Secret Vault Safe
                              _buildFancyFeatureCard(
                                icon: Icons.lock_person_rounded,
                                tag: '4-DIGIT PIN SAFE',
                                title: 'Secret Vault Safe',
                                description: 'Local encrypted safe for hidden notes, passwords, and private files.',
                                buttonText: 'Unlock Safe',
                                accentColor: Colors.orangeAccent,
                                cardBlack: cardBlack,
                                borderStroke: borderStroke,
                                onTap: () => _navigateTo(
                                  SecretVaultScreen(
                                    currentDeviceId: widget.currentDeviceId,
                                    currentDeviceName: widget.currentDeviceName,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Footer Note
                          Center(
                            child: Text(
                              'Linko v0.2 • Connected as ${widget.currentDeviceName}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildFancyFeatureCard({
    required IconData icon,
    required String tag,
    required String title,
    required String description,
    required String buttonText,
    required Color accentColor,
    required Color cardBlack,
    required Color borderStroke,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBlack,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderStroke, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF888894),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  buttonText,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: accentColor,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
