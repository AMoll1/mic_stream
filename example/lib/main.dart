import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mic_stream/mic_stream.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //Stream<List<int>> stream;
  //StreamSubscription<List<int>> listener;

  var stream;
  var listener;

  Icon _icon = Icon(Icons.keyboard_voice);
  Color _iconColor = Colors.white;
  Color _bgColor = Colors.cyan;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    print("==== Start Example ====");
  }

  void controlMicStream() async {

    if (!isRecording) {

      print("Start Streaming from the microphone...");
      stream = microphone(audioSource: 6, sampleRate: 48000);
      _updateButton();

      isRecording = true;

      print("Start Listening to the microphone");
      listener = stream.listen((samples) => samples);
    }
    else {
      print("Stop Listening to the microphone");
      listener.cancel();

      _updateButton();
    }
  }

  void _updateButton() {
    setState(() {
      _bgColor = (isRecording) ? Colors.cyan : Colors.red;
      _icon = (isRecording)  ? Icon(Icons.keyboard_voice) : Icon(Icons.stop);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    setState(() {});
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin: mic_stream :: Debug'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){controlMicStream();},
          child: _icon,
          foregroundColor: _iconColor,
          backgroundColor: _bgColor,
        ),
      ),
    );
  }
}
