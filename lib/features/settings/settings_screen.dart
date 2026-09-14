import 'package:flutter/material.dart';
import '../welcome/welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const SettingsScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111118),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out of this session? Local cryptographic keys will be safely stored.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => WelcomeScreen(
                    currentDeviceId: currentDeviceId,
                    currentDeviceName: currentDeviceName,
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);

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
            Icon(Icons.tune_rounded, color: accentCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'SETTINGS & KEY VAULT',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBlack,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderStroke),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentCyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentCyan, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: accentCyan, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentDeviceName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $currentDeviceId',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'SECURITY & ENCRYPTION',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              _buildSettingTile(
                icon: Icons.key_rounded,
                title: 'E2EE Key Manager',
                subtitle: 'X25519 Elliptic Curve Key Pair active',
                trailing: const Icon(Icons.verified_user_rounded, color: accentCyan, size: 20),
              ),

              _buildSettingTile(
                icon: Icons.shield_moon_rounded,
                title: 'View-Once Shredder RAM Buffer',
                subtitle: 'Automatic zero-fill memory wiping enabled',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: accentCyan,
                ),
              ),

              _buildSettingTile(
                icon: Icons.wifi_tethering_rounded,
                title: 'Local Wi-Fi Auto Discovery',
                subtitle: 'Broadcasting on UDP port 53843',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: accentCyan,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'ACCOUNT CONTROL',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _handleLogout(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out of Session',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF22222E)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00F0FF), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
