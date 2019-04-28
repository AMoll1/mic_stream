import 'dart:async';

import 'package:permission/permission.dart';

import 'package:flutter/services.dart';

// Adapts the official sensors plugin
// https://github.com/flutter/plugins/tree/master/packages/sensors

enum AudioSource {DEFAULT, MIC, VOICE_UPLINK, VOICE_DOWNLINK, VOICE_CALL, CAMCORDER, VOICE_RECOGNITION, VOICE_COMMUNICATION, REMOTE_SUBMIX, UNPROCESSED, VOICE_PERFORMANCE}
enum ChannelConfig {CHANNEL_IN_MONO, CHANNEL_IN_STEREO}
enum AudioFormat {ENCODING_PCM_8BIT/*, ENCODING_PCM_16BIT*/}

const AudioSource _DEFAULT_AUDIO_SOURCE = AudioSource.DEFAULT;
const ChannelConfig _DEFAULT_CHANNELS_CONFIG = ChannelConfig.CHANNEL_IN_MONO;
const AudioFormat _DEFAULT_AUDIO_FORMAT = AudioFormat.ENCODING_PCM_8BIT;
const int _DEFAULT_SAMPLE_RATE = 16000;

const int _MIN_SAMPLE_RATE = 1;
const int _MAX_SAMPLE_RATE = 100000;

const EventChannel _microphoneEventChannel = EventChannel('aaron.code.com/mic_stream');

Permissions _permission;
Stream<dynamic> _microphone;

Future<bool> get permissionStatus async {
  _permission = (await Permission.getPermissionsStatus([PermissionName.Microphone])).first;
  if (_permission.permissionStatus != PermissionStatus.allow) _permission = (await Permission.requestPermissions([PermissionName.Microphone])).first;
  return (_permission.permissionStatus == PermissionStatus.allow);
}

Stream<dynamic> microphone({AudioSource audioSource: _DEFAULT_AUDIO_SOURCE, int sampleRate: _DEFAULT_SAMPLE_RATE, ChannelConfig channelConfig: _DEFAULT_CHANNELS_CONFIG, AudioFormat audioFormat: _DEFAULT_AUDIO_FORMAT}) async* {
  if (sampleRate < _MIN_SAMPLE_RATE || sampleRate > _MAX_SAMPLE_RATE) throw (RangeError.range(sampleRate, _MIN_SAMPLE_RATE, _MAX_SAMPLE_RATE));
  if (!(await permissionStatus)) throw (PlatformException);
  if (_microphone == null) _microphone = _microphoneEventChannel
      .receiveBroadcastStream([audioSource.index, sampleRate, channelConfig == ChannelConfig.CHANNEL_IN_MONO ? 16 : 12, audioFormat == AudioFormat.ENCODING_PCM_8BIT ? 3 : 2]);
  yield* (audioFormat == AudioFormat.ENCODING_PCM_8BIT) ? _microphone : _squashBytes(_microphone);
}

// TODO: Fix 16 Bit PCM
// Currently not needed
Stream<List<int>> _squashBytes(Stream audio) {
  return audio.map((samples) => _squashList(samples));
}

List<int> _squashList(List byteSamples) {
  List<int> shortSamples;
  bool isFirstElement = true;
  int sum = 0;
  for (var sample in byteSamples) {
    sum += sample;
    if (!isFirstElement) {
      shortSamples.add(sum);
      sum = 0;
    }
    isFirstElement = isFirstElement == true;
  }
  return shortSamples;
}