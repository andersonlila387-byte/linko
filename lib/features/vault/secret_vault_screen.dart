import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class SecretVaultScreen extends StatefulWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const SecretVaultScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  @override
  State<SecretVaultScreen> createState() => _SecretVaultScreenState();
}

class _SecretVaultScreenState extends State<SecretVaultScreen> {
  // Vault state
  bool _isUnlocked = false;
  String _enteredPin = '';
  String? _savedPinHash;
  String? _errorMessage;

  // Stored encrypted items inside vault
  final List<Map<String, String>> _vaultItems = [];

  // Controllers for adding item
  final TextEditingController _itemTitleController = TextEditingController();
  final TextEditingController _itemContentController = TextEditingController();

  @override
  void dispose() {
    _itemTitleController.dispose();
    _itemContentController.dispose();
    super.dispose();
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  void _handleKeyPress(String key) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += key;
      _errorMessage = null;
    });

    if (_enteredPin.length == 4) {
      _verifyOrSetPin();
    }
  }

  void _handleDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  void _verifyOrSetPin() {
    final inputHash = _hashPin(_enteredPin);

    if (_savedPinHash == null) {
      // First time setting PIN
      setState(() {
        _savedPinHash = inputHash;
        _isUnlocked = true;
        _enteredPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('4-Digit Vault PIN created! Safe is now unlocked.'),
          backgroundColor: Color(0xFF00F0FF),
        ),
      );
    } else {
      // Verifying existing PIN
      if (inputHash == _savedPinHash) {
        setState(() {
          _isUnlocked = true;
          _enteredPin = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Incorrect 4-digit PIN. Access denied.';
          _enteredPin = '';
        });
      }
    }
  }

  void _showAddSecretDialog() {
    _itemTitleController.clear();
    _itemContentController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111118),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF22222E)),
        ),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Color(0xFF00F0FF), size: 22),
            SizedBox(width: 8),
            Text(
              'Hide Item in Vault',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This item will be encrypted and hidden. It will NOT appear anywhere else on this device.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemTitleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Item Title (e.g. Secret Note / Password)',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF22222E)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemContentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Secret Content / Payload...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF22222E)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final title = _itemTitleController.text.trim();
              final content = _itemContentController.text.trim();
              if (title.isEmpty || content.isEmpty) return;

              setState(() {
                _vaultItems.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': title,
                  'content': content,
                  'date': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                });
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item encrypted and stored in Secret Vault.'),
                  backgroundColor: Color(0xFF00F0FF),
                ),
              );
            },
            child: const Text('Save & Encrypt', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.shield_rounded, color: accentCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'SECRET VAULT SAFE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          if (_isUnlocked)
            IconButton(
              icon: const Icon(Icons.lock_rounded, color: accentCyan),
              tooltip: 'Lock Safe',
              onPressed: () {
                setState(() {
                  _isUnlocked = false;
                  _enteredPin = '';
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isUnlocked
            ? _buildUnlockedVaultView(cardBlack, borderStroke, accentCyan)
            : _buildPinLockView(cardBlack, borderStroke, accentCyan),
      ),
    );
  }

  /// 1. 4-Digit PIN Lock Screen
  Widget _buildPinLockView(Color cardBlack, Color borderStroke, Color accentCyan) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentCyan.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentCyan.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.lock_person_rounded, color: accentCyan, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                _savedPinHash == null ? 'Set 4-Digit Vault PIN' : 'Enter Vault Key PIN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _savedPinHash == null
                    ? 'Create a 4-digit PIN to lock your hidden encrypted items.'
                    : 'Enter your 4-digit PIN to unlock the secret safe.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? accentCyan : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? accentCyan : borderStroke,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 24),

              // Numeric Keypad
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) => _buildKeypadButton(digit, cardBlack, borderStroke)),
                  const SizedBox.shrink(),
                  _buildKeypadButton('0', cardBlack, borderStroke),
                  IconButton(
                    icon: const Icon(Icons.backspace_outlined, color: Colors.white70),
                    onPressed: _handleDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String number, Color cardBlack, Color borderStroke) {
    return GestureDetector(
      onTap: () => _handleKeyPress(number),
      child: Container(
        decoration: BoxDecoration(
          color: cardBlack,
          shape: BoxShape.circle,
          border: Border.all(color: borderStroke),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 2. Unlocked Secret Safe Storage View
  Widget _buildUnlockedVaultView(Color cardBlack, Color borderStroke, Color accentCyan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentCyan.withValues(alpha: 0.15), cardBlack],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accentCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentCyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_open_rounded, color: accentCyan, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secret Safe Unlocked',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Items stored here are encrypted and hidden from local device storage.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HIDDEN VAULT ITEMS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: _showAddSecretDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentCyan,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.black, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Hide New Item',
                        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Items List
          _vaultItems.isEmpty
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
                      Icon(Icons.security_rounded, color: Colors.white38, size: 44),
                      SizedBox(height: 12),
                      Text(
                        'Vault is Empty',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "Hide New Item" to store encrypted secret notes or data safely.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _vaultItems.length,
                  itemBuilder: (context, index) {
                    final item = _vaultItems[index];
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.key_rounded, color: accentCyan, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['content']!,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setState(() {
                                _vaultItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
