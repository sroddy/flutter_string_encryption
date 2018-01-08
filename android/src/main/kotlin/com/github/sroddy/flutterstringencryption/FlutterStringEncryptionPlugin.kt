package com.github.sroddy.flutterstringencryption

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar

import com.tozny.crypto.android.AesCbcWithIntegrity.*
import java.security.GeneralSecurityException

class FlutterStringEncryptionPlugin(): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "flutter_string_encryption")
      channel.setMethodCallHandler(FlutterStringEncryptionPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "decrypt" -> {
        val data = call.argument<String>("data")
        val keyString = call.argument<String>("key")

        val civ = CipherTextIvMac(data)
        try {
          val decrypted = decryptString(civ, keys(keyString))
          result.success(decrypted)
        } catch (e: GeneralSecurityException) {
          print(e)
          result.error("mac_mismatch", "Mac don't match", null)
        }
      }
      "encrypt" -> {
        val string = call.argument<String>("string")
        val keyString = call.argument<String>("key")

        val encrypted = encrypt(string, keys(keyString))

        result.success(encrypted.toString())
      }
      "generate_random_key" -> {
        val key = generateKey()
        val keyString = keyString(key)

        result.success(keyString)
      }
      "generate_salt" -> {
        val salt = generateSalt()
        val base64Salt = saltString(salt)

        result.success(base64Salt)
      }
      "generate_key_from_password" -> {
        val password = call.argument<String>("password")
        val salt = call.argument<String>("salt")

        val key = generateKeyFromPassword(password, salt)
        val keyString = keyString(key)

        result.success(keyString)
      }
      else -> result.notImplemented()
    }
  }
}
