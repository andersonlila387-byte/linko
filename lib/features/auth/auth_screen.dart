import 'package:flutter/material.dart';
import '../../core/database/chat_repository.dart';
import '../../core/models/user_model.dart';
import '../dashboard/home_dashboard_screen.dart';

enum AccountStatus {
  empty,
  tooShort,
  existingUser,
  newUser,
  checking,
  deviceLocked,
}

class AuthScreen extends StatefulWidget {
  final String defaultDeviceId;
  final String defaultDeviceName;

  const AuthScreen({
    super.key,
    required this.defaultDeviceId,
    required this.defaultDeviceName,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _usernameController = TextEditingController();

  AccountStatus _accountStatus = AccountStatus.empty;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _onUsernameChanged() async {
    final name = _usernameController.text.trim();
    if (name.isEmpty) {
      if (mounted) setState(() => _accountStatus = AccountStatus.empty);
      return;
    }

    if (name.length < 3) {
      if (mounted) setState(() => _accountStatus = AccountStatus.tooShort);
      return;
    }

    if (mounted) setState(() => _accountStatus = AccountStatus.checking);

    final existingUser = await _chatRepository.getUserByUsername(name);
    if (mounted) {
      setState(() {
        if (existingUser == null) {
          _accountStatus = AccountStatus.newUser;
        } else if (existingUser.boundDeviceId.isNotEmpty &&
            existingUser.boundDeviceId != widget.defaultDeviceId) {
          _accountStatus = AccountStatus.deviceLocked;
        } else {
          _accountStatus = AccountStatus.existingUser;
        }
      });
    }
  }

  Future<void> _handleAuthentication() async {
    final username = _usernameController.text.trim();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Username must be at least 3 characters long.';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingUser = await _chatRepository.getUserByUsername(username);

      if (existingUser != null) {
        if (existingUser.boundDeviceId.isNotEmpty &&
            existingUser.boundDeviceId != widget.defaultDeviceId) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage =
                  '@$username is registered to another trusted device. Device hijacking blocked.';
            });
          }
          return;
        }

        // Log in existing username (owned by current device)
        if (mounted) {
          setState(() {
            _successMessage = 'Device verified. Welcome back, @$username!';
          });
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToDashboard(
          deviceId: existingUser.boundDeviceId.isNotEmpty
              ? existingUser.boundDeviceId
              : widget.defaultDeviceId,
          deviceName: '@${existingUser.username}',
        );
      } else {
        // Create new username bound to this device
        final newUser = UserModel(
          id: widget.defaultDeviceId,
          username: username,
          passwordHash: '',
          createdAt: DateTime.now(),
          boundDeviceId: widget.defaultDeviceId,
        );

        await _chatRepository.createUser(newUser);

        if (mounted) {
          setState(() {
            _successMessage = 'Welcome, @$username! Identity bound to this device.';
          });
        }

        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToDashboard(
          deviceId: widget.defaultDeviceId,
          deviceName: '@$username',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error setting username: ${e.toString()}';
        });
      }
    }
  }

  void _navigateToDashboard({required String deviceId, required String deviceName}) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeDashboardScreen(
          currentDeviceId: deviceId,
          currentDeviceName: deviceName,
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

    return Scaffold(
      backgroundColor: bgBlack,
      body: Stack(
        children: [
          // Background ambient light
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 380,
              height: 380,
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

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button & Brand Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            'USERNAME IDENTITY',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // User Icon Header Badge
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accentCyan.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentCyan.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentCyan.withValues(alpha: 0.2),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: accentCyan,
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Screen Title
                      const Text(
                        'Set Your Username',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter a username to identify yourself to peers on local Wi-Fi and relay networks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF888894),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBlack,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: borderStroke, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username Label
                            const Text(
                              'YOUR USERNAME',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Username TextField
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              autofocus: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.alternate_email_rounded,
                                    color: accentCyan, size: 20),
                                hintText: 'Enter username (e.g. alex)',
                                hintStyle: const TextStyle(color: Colors.white24),
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.3),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: borderStroke),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: borderStroke),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: accentCyan, width: 1.5),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Dynamic Live Username Status Badge
                            _buildLiveStatusBadge(accentCyan),

                            const SizedBox(height: 20),

                            // Error Message Banner
                            if (_errorMessage != null) ...[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.redAccent.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: Colors.redAccent, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Success Message Banner
                            if (_successMessage != null) ...[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.greenAccent.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded,
                                        color: Colors.greenAccent, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Action Submit Button
                            GestureDetector(
                              onTap: _isLoading ? null : _handleAuthentication,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentCyan.withValues(alpha: 0.25),
                                      blurRadius: 18,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _accountStatus == AccountStatus.existingUser
                                                  ? 'Continue to App'
                                                  : 'Set Username & Continue',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.black,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Privacy Security Note Footer
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, color: Colors.white38, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'No password required • Instant username identity',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusBadge(Color accentCyan) {
    switch (_accountStatus) {
      case AccountStatus.empty:
        return const Text(
          'Enter any username to identify yourself to peers.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        );
      case AccountStatus.tooShort:
        return const Text(
          'Username must be at least 3 characters.',
          style: TextStyle(color: Colors.orangeAccent, fontSize: 11),
        );
      case AccountStatus.checking:
        return const Row(
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
            ),
            SizedBox(width: 6),
            Text('Checking username status...',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        );
      case AccountStatus.existingUser:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.person_rounded, color: Colors.blueAccent, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Existing User — Tap continue to enter',
                  style: TextStyle(
                      color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      case AccountStatus.deviceLocked:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.redAccent, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Registered to another device — Access Locked',
                  style: TextStyle(
                      color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      case AccountStatus.newUser:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accentCyan.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentCyan.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: accentCyan, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'New Username — Tap continue to set identity',
                  style: TextStyle(color: accentCyan, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
    }
  }
}
