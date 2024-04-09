import { VoiceRecordEnum } from '../../models/voice'

@Component
struct VoiceInput {
  @Consume
  voiceState: VoiceRecordEnum

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
      Row() {

      }
      .width(180)
      .height(80)
      .borderRadius(20)
      .backgroundColor($r("app.color.chat_primary"))
    }
    else if (this.voiceState === VoiceRecordEnum.Transfer) {
      // 转化文本
      Row() {

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