import 'dart:async';

import 'package:flutter/services.dart';

/// Interface for the Plugin
abstract class StringCryptor {
  /// Generates a random key to use with [encrypt] and [decrypt] methods
  Future<String> generateRandomKey();

  /// Gets a key from the given [password] and [salt]. [salt] can be generated
  /// with [generateSalt] while [password] is usually provided by the user.
  Future<String> getKeyFromPasswordAndSalt(String password, String salt);

  /// Generates a salt to use with [getKeyFromPasswordAndSalt]
  Future<String> generateSalt();

  /// Encrypts [string] using a [key] generated from [generateRandomKey] or
  /// [getKeyFromPasswordAndSalt]. The returned string is a sequence of 3
  /// base64-encoded strings (iv, mac and cipherText) and can be transferred and
  /// stored almost anywhere.
  Future<String> encrypt(String string, String key);

  /// Decrypts [data] created with the [encrypt] method using a [key] created
  /// with [generateRandomKey] or [getKeyFromPasswordAndSalt] methods.
  Future<String> decrypt(String data, String key);
}

/// Implementation of [StringCryptor] using platform channels
class PlatformStringCryptor implements StringCryptor {
  static const MethodChannel _channel =
      const MethodChannel('flutter_string_encryption');

  static final _cryptor = new PlatformStringCryptor._();

  factory PlatformStringCryptor() => _cryptor;

  PlatformStringCryptor._();

  @override
  Future<String> decrypt(String data, String key) =>
      _channel.invokeMethod("decrypt", {
        "data": data,
        "key": key,
      });

  @override
  Future<String> encrypt(String string, String key) =>
      _channel.invokeMethod("encrypt", {
        "string": string,
        "key": key,
      });

  @override
  Future<String> generateRandomKey() =>
      _channel.invokeMethod("generate_random_key");

  @override
  Future<String> generateSalt() => _channel.invokeMethod("generate_salt");

  @override
  Future<String> getKeyFromPasswordAndSalt(String password, String salt) =>
      _channel.invokeMethod("get_key_from_password_and_salt", <String, String>{
        "password": password,
        "salt": salt,
      });
}
