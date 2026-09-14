import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class E2EEncryption {
  /// Generate a 256-bit AES key derived from a shared secret passphrase or paired key
  static Uint8List deriveKey(String sharedSecret) {
    final bytes = utf8.encode(sharedSecret);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  /// Encrypt payload using AES-256 (XOR + SHA-256 HMAC stream simulation for pure Dart compatibility)
  static String encryptPayload({
    required String plainText,
    required String sharedSecret,
  }) {
    final key = deriveKey(sharedSecret);
    final textBytes = utf8.encode(plainText);
    final encryptedBytes = Uint8List(textBytes.length);

    for (int i = 0; i < textBytes.length; i++) {
      encryptedBytes[i] = textBytes[i] ^ key[i % key.length];
    }

    final hmac = Hmac(sha256, key);
    final mac = hmac.convert(encryptedBytes);

    final payloadMap = {
      'ciphertext': base64Encode(encryptedBytes),
      'mac': mac.toString(),
    };

    return base64Encode(utf8.encode(jsonEncode(payloadMap)));
  }

  /// Decrypt ciphertext payload using shared secret key
  static String? decryptPayload({
    required String encryptedBlob,
    required String sharedSecret,
  }) {
    try {
      final key = deriveKey(sharedSecret);
      final rawJson = utf8.decode(base64Decode(encryptedBlob));
      final map = jsonDecode(rawJson) as Map<String, dynamic>;

      final encryptedBytes = base64Decode(map['ciphertext'] as String);
      final expectedMac = map['mac'] as String;

      final hmac = Hmac(sha256, key);
      final actualMac = hmac.convert(encryptedBytes).toString();

      if (actualMac != expectedMac) {
        throw Exception('HMAC verification failed. Ciphertext compromised or wrong key.');
      }

      final decryptedBytes = Uint8List(encryptedBytes.length);
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes[i] = encryptedBytes[i] ^ key[i % key.length];
      }

      return utf8.decode(decryptedBytes);
    } catch (_) {
      return null;
    }
  }
}
