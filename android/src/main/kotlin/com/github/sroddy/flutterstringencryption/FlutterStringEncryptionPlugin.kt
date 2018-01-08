package com.github.sroddy.flutterstringencryption

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar

import com.tozny.crypto.android.AesCbcWithIntegrity.*

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
        val decrypted = decryptString(civ, keys(keyString))

        result.success(decrypted)
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
      else -> result.notImplemented()
    }
  }
}
