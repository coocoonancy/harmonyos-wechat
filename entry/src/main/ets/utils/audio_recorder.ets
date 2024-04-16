import { audio } from '@kit.AudioKit'
import { fileIo } from '@kit.CoreFileKit'

export class FileOptions {
  offset: number = 0;
  length: number = 0
}

export class AudioRecorder {
  static audioCapture: audio.AudioCapturer
  // 采样配置
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }
  // 录音配置
  static audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC, // 音源类型
    capturerFlags: 0 // 音频采集器标志
  }
  // 总体配置
  static audioCaptureOptions: audio.AudioCapturerOptions = {
    streamInfo: AudioRecorder.audioStreamInfo,
    capturerInfo: AudioRecorder.audioCapturerInfo
  }
  static recording: boolean = false

  // 初始化音频
  static async init() {
    if (!AudioRecorder.audioCapture) {
      AudioRecorder.audioCapture = await audio.createAudioCapturer(AudioRecorder.audioCaptureOptions)
    }
  }

  //  开始录音
  static async start(filePath: string) {
    try {
      if (!AudioRecorder.audioCapture) return
      // 开始录音
      AudioRecorder.recording = true
      // 收集录音
      await AudioRecorder.audioCapture.start()
      // 把声音 输出的一段buffer写入到一个固定文件中，或者直接播出这个buffer 如果不存在就创建文件
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      // 录音要一段段的去写  每次产生一段buffer buffer写入到file中去 最终完成文件的录制
      // 文件标识
      const fd = file.fd
      const statFile = fileIo.statSync(fd)
      // 原有文件的buffer的长度 是一个写入文件的基准点
      let bufferSize = statFile.size
      // 只要这个标记为开始 一直采集一直写入文件
      while (AudioRecorder.recording) {
        // 获取缓冲区的长度
        const size = await AudioRecorder.audioCapture.getBufferSize()
        // 当前录音的一段内容
        const buffer = await AudioRecorder.audioCapture.read(size, true)
        if (buffer) {
          const options: FileOptions = {
            // 偏移量
            offset: bufferSize,
            length: buffer.byteLength
          };
          fileIo.writeSync(fd, buffer, options)
          bufferSize += buffer.byteLength
        }
      }
    }
    catch (error) {
      AlertDialog.show({
        message: JSON.stringify(error)
      })
    }
  }

  //  结束录音
  static async stop() {
    AudioRecorder.recording = false
    if (AudioRecorder.audioCapture && (AudioRecorder.audioCapture.state === audio.AudioState.STATE_RUNNING || AudioRecorder.audioCapture.state === audio.AudioState.STATE_PAUSED)) {
      await AudioRecorder.audioCapture.release()
    }
  }

  //  释放录音
  static async release() {
    AudioRecorder.recording = false
    if (AudioRecorder.audioCapture) {
      await AudioRecorder.audioCapture.release()
    }
  }
}