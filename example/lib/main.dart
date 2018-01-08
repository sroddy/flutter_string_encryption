import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _randomKey = 'Unknown';
  String _string = "Unknown";
  String _encrypted = "Unknown";

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final cryptor = new PlatformStringCryptor();

    final key = await cryptor.generateRandomKey();
    final string = "here is the string, here is the string.";
    final encrypted = await cryptor.encrypt(string, key);
    final decrypted = await cryptor.decrypt(encrypted, key);

    assert(decrypted == string);

    setState(() {
      _randomKey = key;
      _string = string;
      _encrypted = encrypted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text(
            'Random key: $_randomKey\n\nString: $_string\n\nEncrypted: $_encrypted'),
        ),
      ),
    );
  }
}
