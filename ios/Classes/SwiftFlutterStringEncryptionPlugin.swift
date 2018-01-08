import Flutter
import UIKit
import SCrypto

public class SwiftFlutterStringEncryptionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_string_encryption", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterStringEncryptionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "decrypt":
      guard let args = call.arguments as? [String: String] else {
        fatalError("args are formatted badly")
      }
      let data = args["data"]!
      let keyString = args["key"]!

      let civ = CipherIvMac(base64IvAndCiphertext: data)
      let keys = AESHMACKeys(base64AESAndHMAC: keyString)
      do {
        let decrypted = try keys.decryptToString(data: civ)

        result(decrypted)
      } catch (CryptoError.macMismatch) {
        result(FlutterError(code: "mac_mismatch", message: "mac don't match", details: nil))
      } catch {
        fatalError("\(error)")
      }

    case "encrypt":
      guard let args = call.arguments as? [String: String] else {
        fatalError("args are formatted badly")
      }
      let string = args["string"]!
      let keyString = args["key"]!

      let keys = AESHMACKeys(base64AESAndHMAC: keyString)
      let encrypted = keys.encrypt(string: string)

      result(encrypted.base64EncodedString)

    case "generate_random_key":
      let key = AESHMACKeys.random()
      let keyString = key.base64EncodedString

      result(keyString)

    case "generate_salt":
      let salt = AESHMACKeys.generateSalt()

      result(salt)

    case "generate_key_from_password":
      guard let args = call.arguments as? [String: String] else {
        fatalError("args are formatted badly")
      }
      let password = args["password"]!
      let salt = args["salt"]!

      let key = AESHMACKeys(password: password, salt: salt)

      result(key.base64EncodedString)

    default: result(FlutterMethodNotImplemented)
    }
  }
}

struct CipherIvMac {
  let iv: Data
  let mac: Data
  let cipher: Data

  var base64EncodedString: String {
    let ivString = self.iv.base64EncodedString()
    let cipherString = self.cipher.base64EncodedString()
    let macString = self.mac.base64EncodedString()
    return "\(ivString):\(macString):\(cipherString)"
  }

  init(iv: Data, mac: Data, cipher: Data) {
    self.iv = iv
    self.mac = mac
    self.cipher = cipher
  }

  init(base64IvAndCiphertext: String) {
    let civArray = base64IvAndCiphertext.split(separator: ":")
    guard civArray.count == 3 else {
      fatalError("Cannot parse iv:ciphertext:mac")
    }
    self.iv = Data(base64Encoded: String(civArray[0]))!
    self.mac = Data(base64Encoded: String(civArray[1]))!
    self.cipher = Data(base64Encoded: String(civArray[2]))!
  }

  static func ivCipherConcat(iv: Data, cipher: Data) -> Data {
    var copy = iv
    copy.append(cipher)

    return copy
  }

  var ivCipherConcat: Data {
    return CipherIvMac.ivCipherConcat(iv: self.iv, cipher: self.cipher)
  }
}

struct AESHMACKeys {
  static let aesKeyLengthBits = 128
  static let ivLengthBytes = 16
  static let hmacKeyLengthBits = 256
  static let pbeSaltLenghtBits = aesKeyLengthBits // same size as key output
  static let pbeIterationCount: UInt32 = 10000

  let aes: Data
  let hmac: Data

  init(base64AESAndHMAC: String) {
    let array = base64AESAndHMAC.split(separator: ":")
    self.aes = Data(base64Encoded: String(array[0]))!
    self.hmac = Data(base64Encoded: String(array[1]))!
  }

  init(password: String, salt: String) {
    let password = password.data(using: String.Encoding.utf8)!
    let salt = Data(base64Encoded: salt)!
    let keyLength = AESHMACKeys.aesKeyLengthBits / 8 + AESHMACKeys.hmacKeyLengthBits / 8
    let derivedKey = try! password.derivedKey(
      salt,
      pseudoRandomAlgorithm: .sha1,
      rounds: AESHMACKeys.pbeIterationCount,
      derivedKeyLength: keyLength
    )

    // Split the random bytes into two parts:
    self.aes = derivedKey.subdata(in: 0..<AESHMACKeys.aesKeyLengthBits / 8)
    self.hmac = derivedKey.subdata(in: AESHMACKeys.aesKeyLengthBits / 8..<keyLength)
  }

  init(aes: Data, hmac: Data) {
    self.aes = aes
    self.hmac = hmac
  }

  static func random() -> AESHMACKeys {
    let aes = try! Data.random(AESHMACKeys.aesKeyLengthBits / 8)
    let hmac = try! Data.random(AESHMACKeys.hmacKeyLengthBits / 8)

    return .init(aes: aes, hmac: hmac)
  }

  static func generateSalt() -> String {
    let salt = try! Data.random(pbeSaltLenghtBits / 8)
    return salt.base64EncodedString()
  }

  func encrypt(string: String) -> CipherIvMac {
    let data = string.data(using: .utf8)!

    return self.encrypt(data: data)
  }

  func encrypt(data: Data) -> CipherIvMac {
    let iv = try! Data.random(AESHMACKeys.ivLengthBytes)
    let cipher = try! data.encrypt(.aes, options: .PKCS7Padding, key: self.aes, iv: iv)
    let concat = CipherIvMac.ivCipherConcat(iv: iv, cipher: cipher)
    let integrity = concat.hmac(.sha256, key: self.hmac)

    return CipherIvMac(iv: iv, mac: integrity, cipher: cipher)
  }

  func decrypt(data: CipherIvMac) throws -> Data {
    let concat = data.ivCipherConcat
    let hmac = concat.hmac(.sha256, key: self.hmac)

    // TODO: undestand if this is a constant time equality check
    if hmac != data.mac {
      throw CryptoError.macMismatch
    }
    let decrypted = try data.cipher.decrypt(.aes, options: .PKCS7Padding, key: self.aes, iv: data.iv)

    return decrypted
  }

  func decryptToString(data: CipherIvMac, encoding: String.Encoding = .utf8) throws -> String {
    let data = try self.decrypt(data: data)
    return String(data: data, encoding: encoding)!
  }

  var base64EncodedString: String {
    let aesString = self.aes.base64EncodedString()
    let hmacString = self.hmac.base64EncodedString()
    return "\(aesString):\(hmacString)"
  }
}

enum CryptoError: Error {
  case macMismatch
}
