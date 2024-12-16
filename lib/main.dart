import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _textureId;
  final MethodChannel _methodChannel =
      const MethodChannel("flutter_example_texture");

  @override
  void initState() {
    _methodChannel.invokeMethod("createTexture").then((val) {
      _textureId = val as int;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _textureId == null
            ? const CircularProgressIndicator()
            : Texture(textureId: _textureId!),
      ),
    );
  }
}
