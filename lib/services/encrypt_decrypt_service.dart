import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static String hashPassword(String password) {
    final salt = 'your-secret-salt-here';
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateSecureSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  static Encrypted encryptAES(String plainText, String keyString) {
    final key = Key.fromUtf8(keyString);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(plainText, iv: iv);
  }

  static String decryptAES(Encrypted encrypted, String keyString) {
    final key = Key.fromUtf8(keyString);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
