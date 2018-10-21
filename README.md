# flutter_string_encryption

Cross-platform string encryption using common best-practices
(AES/CBC/PKCS5/Random IVs/HMAC-SHA256 Integrity Check).

It uses the format described in [this article](https://tozny.com/blog/encrypting-strings-in-android-lets-make-better-mistakes/).

It currently uses Native Platform implementations, which are (we all hope)
constantly vetted and updated by Apple and Google, with some really tiny
library wrappers to ease some of the tedious work.

For the Android side, I used the following library (coming from the same
authors of the article above):
https://github.com/tozny/java-aes-crypto

For the iOS side, I implemented the format described in the article
directly inside the native plugin, and used the following library to
help me with Apple's CommonCrypto functions which are not really easy to
interact with otherwise:
https://github.com/sgl0v/SCrypto

## Support
In order to work on iOS, you need to bump the iOS support version up to
9.0. This can be done inside your ios project Podfile by uncommenting
the very first line of the file:
```
# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
```

## Usage

```dart
final cryptor = new PlatformStringCryptor();
```

## Generate A Secret Key
### Randomly
Generate it and store it in a safe place - e.g. the Keychain/KeyStore
```dart
final String key = await cryptor.generateRandomKey();
```

### Password-Based
Generate and (safely) store the salt, and then generate the key with a user-provided
password before encrypting/decrypting your strings.
```dart
final password = "user_provided_password";
final String salt = await cryptor.generateSalt();
final String key = await cryptor.generateKeyFromPassword(password, salt);
```

## Encrypt A String
```dart
final String encrypted = await cryptor.encrypt("A string to encrypt.", key);
```

## Decrypt A String
```dart
try {
  final String decrypted = await cryptor.decrypt(encrypted, key);
  print(decrypted); // - A string to encrypt.
} on MacMismatchException {
  // unable to decrypt (wrong key or forged data)
}
```

# License
MIT (both this plugin and the used helper libraries).
