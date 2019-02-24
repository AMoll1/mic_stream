package com.code.aaron.micstream;

import android.icu.text.IDNA;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** MicStreamPlugin
 *  In reference to from https://stackoverflow.com/questions/33403656/stream-microphone-to-speakers-android
 */
public class MicStreamPlugin implements MethodCallHandler {

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "mic_stream");
        channel.setMethodCallHandler(new MicStreamPlugin());
    }

    /** Variables **/
    private AudioRecord recorder;
    private int CHANNELS = AudioFormat.CHANNEL_CONFIGURATION_MONO;
    private int AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;
    private int SAMPLE_RATE;
    private int BUFFER_SIZE;

    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "initRecorder":
                recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLE_RATE, CHANNELS, AUDIO_FORMAT, BUFFER_SIZE);
                break;

            case "getPlatformVersion":
                result.success("Android $android.os.Build.VERSION.RELEASE");
                break;

            case "getBufferSize":
                result.success(BUFFER_SIZE);

            case "getByteArray":
                byte data[] = new byte[BUFFER_SIZE];
                recorder.read(data, 0, BUFFER_SIZE);
                result.success(data);
                break;

            case "setSampleRate":
                SAMPLE_RATE = call.argument("sampleRate");
                BUFFER_SIZE = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNELS, AUDIO_FORMAT);
                break;

            case "releaseRecorder":
                recorder.release();
                recorder = null;
                break;

            default:
                result.notImplemented();
        }
        result.success("Success");
    }
}