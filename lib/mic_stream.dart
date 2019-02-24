import 'dart:async';
import 'dart:typed_data';
import 'dart:developer';

import 'package:flutter/services.dart';

/* Class handling the microphone */
class Microphone implements StreamController {
  static const _platform = const MethodChannel('mic_stream');
  static const DEFAULT_SAMPLE_RATE = 16000;
  bool _isRecording = false;
  int _bufferSize;
  StreamController<Uint8List> _controller;
  DateTime _timestamp;

  // Implemented Constructors
  Microphone() : _controller = new StreamController();
  Microphone.broadcast() : _controller = new StreamController.broadcast();

  // Implemented methods:
  close() => _controller.close();
  noSuchMethod(Invocation invocation) => _controller.noSuchMethod(invocation);
  toString() => _controller.toString();

  // Starts and returns an audio stream from the microphone, which is given back as Uint8List; each element has the length of .bufferSize
  // Throws an ArgumentError if Sample Rate is not between 1 and 16000
  Future<Stream<Uint8List>> start({int sampleRate = DEFAULT_SAMPLE_RATE}) async {
    if (!_isRecording) {
      _isRecording = true;

      print("  Init timestamp");
      _timestamp = new DateTime.now();

      print("  Set sample rate");
      if (sampleRate <= 0 || sampleRate > 16000) throw(ArgumentError);
      await _platform.invokeMethod('setSampleRate', <String, int>{'sampleRate': sampleRate});

      print("  Init Audio Recorder");
      await _platform.invokeMethod('initRecorder');

      print("  Update buffer size");
      _bufferSize = await bufferSize;

      print("  Start recording:");
      _run();
    }
    return _controller.stream;
  }

  Duration stop() {
    _isRecording = false;
    _platform.invokeMethod('releaseRecorder');
    _controller.close();
    return duration;
  }

  // runs asynchronously in a loop and stores data to the stream
  void _run() async {
    print("    Testing...");
    while(isRecording) {
      print("    ...test...");
      try {
        _controller.add(await _platform.invokeMethod('getByteArray'));
      }
      finally {}
    }
  }

  // Changes the sample rate (only necessary for changing while recording - might cause unintended behaviour)
  set sampleRate(int sampleRate) {
    _platform.invokeMethod('setSampleRate', <String, int>{'sampleRate': sampleRate});
  }

  bool get isRecording => _isRecording;

  // Returns the duration since first start
  Duration get duration =>_timestamp.difference(DateTime.now());

  // Returns the amount of bytes per element (the length of one Uint8List)
  Future<int> get bufferSize async {
    _bufferSize = await _platform.invokeMethod('getBufferSize');
    return _bufferSize;
  }


  // Returns the platform version
  static Future<String> get platformVersion async {
    return await _platform.invokeMethod('getPlatformVersion');
  }
}
