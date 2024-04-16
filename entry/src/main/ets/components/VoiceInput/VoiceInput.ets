import { VoiceRecordEnum } from '../../models/voice'
import { emitter } from '@kit.BasicServicesKit'

@Component
struct VoiceInput {
  @Consume
  voiceState: VoiceRecordEnum
  @Consume
  asrResult: string
  @State
  list: number[] = []

  aboutToAppear(): void {
    emitter.on('onBuffer', res => {
      this.calcHeight(res.data!.buffer as ArrayBuffer)
    })
  }

  aboutToDisappear(): void {
    emitter.off('onBuffer')
  }

  // 算出20个高度给list
  calcHeight(buffer: ArrayBuffer) {
    try {
      // 计算每个均分区间的大小
      const sampleSize = Math.floor(buffer.byteLength / 30);
      const view = new DataView(buffer);
      const amplitudes: number[] = [];
      // 遍历缓冲区，计算每个样本的振幅并转换为高度
      // 遍历原始缓冲区，提取每个均分区间的振幅
      for (let i = 0; i < buffer.byteLength; i += sampleSize) {
        let sum = 0;
        // 计算当前均分区间内所有振幅的平均值
        // 假设每个样本占据 2 字节
        for (let j = i; j < i + sampleSize; j += 2) {
          const sample = view.getInt16(j, true);
          sum += Math.abs(sample);
        }
        // 假设每个样本占据 2 字节
        const averageAmplitude = 150 * sum / (sampleSize / 2) / 32767;
        amplitudes.push(averageAmplitude < 10 ? 10 : averageAmplitude);
        animateTo({ duration: 100 }, () => {
          this.list = amplitudes
        })
      }
    } catch (e) {
      AlertDialog.show({ message: e.message })
    }

  }

  @Builder
  getDisplayContent() {
    if (this.voiceState === VoiceRecordEnum.Cancel) {
      // 取消
      Row() {

      }
      .width(100)
      .height(80)
      .borderRadius(20)
      .backgroundColor($r("app.color.danger"))
      .margin({
        left: 30
      })
    }
    else if (this.voiceState === VoiceRecordEnum.RecordIng) {
      // 正在录音
      Row({ space: 2 }) {
        ForEach(this.list, (height: number) => {
          Row()
            .height(height)
            .width(2)
            .borderRadius(1)
            .backgroundColor($r("app.color.animate_voice_color"))
        })

      }
      .width(180)
      .height(80)
      .borderRadius(20)
      .backgroundColor($r("app.color.chat_primary"))
    }
    else if (this.voiceState === VoiceRecordEnum.Transfer) {
      // 转化文本
      Row() {
        Text(this.asrResult)
          .fontSize(20)
          .fontColor($r("app.color.text_primary"))
      }
      .width(280)
      .height(120)
      .borderRadius(20)
      .backgroundColor($r("app.color.chat_primary"))
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 显示三个不同的内容
        // 取消 红色取消区域
        // 录音 中间声音波峰- 计算buffer -
        // 语音转文本  pcm封装音频转文本 speeach
        this.getDisplayContent()
        // 显示关闭和文本
        // 显示关闭和文本
        Row() {
          Row() {
            Image($r("app.media.ic_public_cancel"))
              .width(30)
              .height(30)
              .fillColor(this.voiceState === VoiceRecordEnum.Cancel ?
              $r("app.color.text_primary")
                : $r("app.color.voice_round_font_color"))
          }
          .width(70)
          .aspectRatio(1)
          .borderRadius(35)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.voiceState === VoiceRecordEnum.Cancel ?
          $r("app.color.bottom_color")
            : $r("app.color.voice_round_color"))
          .rotate({
            angle: -10
          })
          .scale({
            x: this.voiceState === VoiceRecordEnum.Cancel ? 1.2 : 1,
            y: this.voiceState === VoiceRecordEnum.Cancel ? 1.2 : 1
          })

          Row() {
            Text("文")
              .fontSize(24)
              .textAlign(TextAlign.Center)
              .fontColor(this.voiceState === VoiceRecordEnum.Transfer ?
              $r("app.color.text_primary")
                : $r("app.color.voice_round_font_color"))
          }
          .scale({
            x: this.voiceState === VoiceRecordEnum.Transfer ? 1.2 : 1,
            y: this.voiceState === VoiceRecordEnum.Transfer ? 1.2 : 1
          })
          .width(70)
          .aspectRatio(1)
          .borderRadius(35)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.voiceState === VoiceRecordEnum.Transfer ?
          $r("app.color.bottom_color")
            : $r("app.color.voice_round_color"))
          .rotate({
            angle: 10
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 40,
          right: 40
        })
        .margin({
          bottom: 30
        })

        Stack() {
          Image($r("app.media.ic_public_output"))
            .width('100%')
            .height(120)
            .fillColor(this.voiceState === VoiceRecordEnum.RecordIng ?
            $r("app.color.bottom_color")
              : $r("app.color.voice_round_color"))
            .scale({
              x: 1.2
            })
          Image($r("app.media.ic_public_recorder"))
            .width(30)
            .height(30)
            .fillColor(this.voiceState === VoiceRecordEnum.RecordIng ?
            $r("app.color.voice_round_color")
              : $r("app.color.bottom_color"))
        }
        .width('100%')
      }
    }
    .height('100%')
    .backgroundColor($r("app.color.voice_back_color"))

  }
}

export default VoiceInput