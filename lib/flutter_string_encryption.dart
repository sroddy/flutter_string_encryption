import 'dart:async';

import 'package:flutter/services.dart';

/// Interface for the Plugin
abstract class StringCryptor {
  /// Generates a random key to use with [encrypt] and [decrypt] methods
  Future<String> generateRandomKey();

  /// Gets a key from the given [password] and [salt]. [salt] can be generated
  /// with [generateSalt] while [password] is usually provided by the user.
  Future<String> generateKeyFromPassword(String password, String salt);

  /// Generates a salt to use with [generateKeyFromPassword]
  Future<String> generateSalt();

  /// Encrypts [string] using a [key] generated from [generateRandomKey] or
  /// [generateKeyFromPassword]. The returned string is a sequence of 3
  /// base64-encoded strings (iv, mac and cipherText) and can be transferred and
  /// stored almost anywhere.
  Future<String> encrypt(String string, String key);

  /// Decrypts [data] created with the [encrypt] method using a [key] created
  /// with [generateRandomKey] or [generateKeyFromPassword] methods.
  /// In case the [key] is wrong or the [data] has been forged, a
  /// [MacMismatchException] is thrown
  Future<String> decrypt(String data, String key);
}

/// Implementation of [StringCryptor] using platform channels
class PlatformStringCryptor implements StringCryptor {
  static const MethodChannel _channel = const MethodChannel('flutter_string_encryption');

  @override
  Future<String> decrypt(String data, String key) async {
    try {
      final decrypted = await _channel.invokeMethod("decrypt", {
        "data": data,
        "key": key,
      });
      return decrypted;
    } on PlatformException catch (e) {
      switch (e.code) {
        case "mac_mismatch":
          throw new MacMismatchException();
        default:
          rethrow;
      }
    }
  }

  @override
  Future<String> encrypt(String string, String key) async =>
      await _channel.invokeMethod("encrypt", {
        "string": string,
        "key": key,
      });

  @override
  Future<String> generateRandomKey() async => await _channel.invokeMethod("generate_random_key");

  @override
  Future<String> generateSalt() async => await _channel.invokeMethod("generate_salt");

  @override
  Future<String> generateKeyFromPassword(String password, String salt) async =>
      await _channel.invokeMethod("generate_key_from_password", <String, String>{
        "password": password,
        "salt": salt,
      });
}

class MacMismatchException implements Exception {
  final String message =
      "Mac don't match, either the password is wrong, or the message has been forged.";
}
