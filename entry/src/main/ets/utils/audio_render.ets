import { audio } from '@kit.AudioKit'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'

export class AudioRenderer {
  static renderModel: audio.AudioRenderer
  // 采样配置
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
    channels: audio.AudioChannel.CHANNEL_1, // 通道
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
  }
  static audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_MOVIE, // 音频流使用类型
    rendererFlags: 0 // 音频渲染器标志
  }
  static audioRenderOptions: audio.AudioRendererOptions = {
    streamInfo: AudioRenderer.audioStreamInfo,
    rendererInfo: AudioRenderer.audioRendererInfo
  }

  static async init() {
    if (!AudioRenderer.renderModel) {
      AudioRenderer.renderModel = await audio.createAudioRenderer(AudioRenderer.audioRenderOptions)
    }
  }

  static async stop() {
    if (AudioRenderer.renderModel) {
      await AudioRenderer.renderModel.stop()
    }
  }

  static async release() {
    if (AudioRenderer.renderModel) {
      await AudioRenderer.renderModel.release()
    }
  }

  static async start(filePath: string, callback?: () => void) {
    if (AudioRenderer.renderModel && filePath) {
      try {
        const state = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_STOPPED, audio.AudioState.STATE_PAUSED]
        if (!state.includes((AudioRenderer.renderModel as audio.AudioRenderer).state.valueOf())) {
          promptAction.showToast({ message: '状态不正确' })
          return
        }
        // 开始播放
        await AudioRenderer.renderModel.start()
        const bufferSize = await AudioRenderer.renderModel!.getBufferSize()
        // buffer读取 读完关闭 停止播放
        const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
        // 详细信息
        const stat = fileIo.statSync(file.fd)
        // 创建缓冲区对象 长度是音频采集器的长度
        let buffer = new ArrayBuffer(bufferSize)
        let totalSize = 0
        while (totalSize < stat.size) {
          fileIo.readSync(file.fd, buffer, {
            offset: totalSize,
            length: bufferSize
          })
          // 往音频采集器写入内容
          await AudioRenderer.renderModel.write(buffer)
          if (AudioRenderer.renderModel!.state.valueOf() === audio.AudioState.STATE_RELEASED) {
            fileIo.close(file)
          }
          totalSize += bufferSize
        }
        // 关闭文件
        fileIo.closeSync(file.fd)
        // 停止播放
        AudioRenderer.stop()
        callback && callback()
      } catch (error) {
        AlertDialog.show({
          message: JSON.stringify(error)
        })
      }

    }
  }
}