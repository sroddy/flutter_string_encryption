import 'dart:async';

import 'package:flutter/services.dart';

/// Interface for the Plugin
abstract class StringCryptor {
  /// Generates a random key to use with [encrypt] and [decrypt] methods
  Future<String> generateRandomKey();

  Future<String> encrypt(String string, String key);
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
}
