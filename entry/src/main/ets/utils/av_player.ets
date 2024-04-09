import { media } from '@kit.MediaKit'

export class AvPlayer {
  avPlayer: media.AVPlayer | null = null

  async init() {
    this.avPlayer = await media.createAVPlayer()
    this.watchPlayer()
  }

  watchPlayer() {
    this.avPlayer?.on('stateChange', (state: string) => {
      switch (state) {
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayer state initialized called.');
          this.avPlayer?.prepare()
          break;
        case 'prepared': // prepare调用成功后上报该状态机cesi
          console.info('AVPlayer state prepared called.');
          this.avPlayer?.play()
          break;
        case 'playing': // play成功调用后触发该状态机上报
          console.info('AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          console.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          this.avPlayer?.reset(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          console.info('AVPlayer state stopped called.');
          this.avPlayer?.reset(); //调用播放结束接口
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          this.avPlayer?.reset(); //调用播放结束接口
          break;
        case 'error':
          console.error('AVPlayer state error called.')
          this.avPlayer?.reset(); //调用播放结束接口
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  async play(fileSrc: string) {
    // 资源管理器获取文件的方法
    let fileDesc = await getContext().resourceManager.getRawFd(fileSrc)
    let fdSrc: media.AVFileDescriptor = {
      fd: fileDesc.fd,
      offset: fileDesc.offset,
      length: fileDesc.length
    }
    this.avPlayer!.fdSrc = fdSrc
  }

  async stop() {
    await this.avPlayer?.stop()
  }

  async release() {
    await this.avPlayer?.release()
  }
}