import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:personal_app/services/encrypt_decrypt_service.dart';

class SecureStorageService {
  static final storage = FlutterSecureStorage();
  static final _encryptionKey = 'your-32-char-encryption-key-here';

  static Future<void> storeEncryptedPassword(
    String key,
    String password,
  ) async {
    final encrypted = EncryptionService.encryptAES(password, _encryptionKey);
    await storage.write(key: key, value: encrypted.base64);
  }

  static Future<String?> getDecryptedPassword(String key) async {
    final encryptedBase64 = await storage.read(key: key);
    if (encryptedBase64 != null) {
      final encrypted = Encrypted.fromBase64(encryptedBase64);
      return EncryptionService.decryptAES(encrypted, _encryptionKey);
    }
    return null;
  }

  static Future<void> storeHashedPassword(String key, String password) async {
    final hashed = EncryptionService.hashPassword(password);
    await storage.write(key: key, value: hashed);
  }

  static Future<bool> verifyHashedPassword(String key, String password) async {
    final storedHash = await storage.read(key: key);
    final currentHash = EncryptionService.hashPassword(password);
    return storedHash == currentHash;
  }
}
