import 'package:flutter_test/flutter_test.dart';
import 'package:linko/core/security/e2e_encryption.dart';

void main() {
  group('E2EEncryption Unit Tests', () {
    test('Encrypt and decrypt payload with valid shared secret key', () {
      const plainText = 'Hello friend across the world! View once secret: 998877';
      const sharedSecret = 'my_super_secret_shared_passphrase_123';

      final ciphertext = E2EEncryption.encryptPayload(
        plainText: plainText,
        sharedSecret: sharedSecret,
      );

      expect(ciphertext, isNotEmpty);
      expect(ciphertext, isNot(equals(plainText)));

      final decrypted = E2EEncryption.decryptPayload(
        encryptedBlob: ciphertext,
        sharedSecret: sharedSecret,
      );

      expect(decrypted, equals(plainText));
    });

    test('Decryption fails with invalid shared secret key', () {
      const plainText = 'Confidential long-distance payload';
      const validSecret = 'valid_key_123';
      const wrongSecret = 'wrong_key_999';

      final ciphertext = E2EEncryption.encryptPayload(
        plainText: plainText,
        sharedSecret: validSecret,
      );

      final decrypted = E2EEncryption.decryptPayload(
        encryptedBlob: ciphertext,
        sharedSecret: wrongSecret,
      );

      expect(decrypted, isNull);
    });
  });
}
