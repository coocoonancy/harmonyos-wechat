import { display, promptAction } from '@kit.ArkUI'
import VoiceInput from '../../components/VoiceInput/VoiceInput'
import { VoiceRecordEnum } from '../../models/voice'

@Preview
@Component
struct BottomInput {
  @State
  showVoice: boolean = false // 是否显示语音输入
  @State
  content: string = "" // 输入内容
  sendTextMessage: (content: string) => void = () => {
  }
  @State
  showVoiceCom: boolean = false
  // 当前的组件的状态
  @Provide
  voiceState: VoiceRecordEnum = VoiceRecordEnum.RecordIng
  // 需要知道整体屏幕的宽度
  screenWidth: number = 0 // 记录整体的宽度
  screenHeight: number = 0 // 记录整体高度

  // 显示语音输入组件
  @Builder
  getVoiceCom() {
    // 实现语音输入组件
    // Builder函数不能在根组件直接使用自定义组件
    Column() {
      VoiceInput()

    }
  }

  aboutToAppear(): void {
    this.getScreenWidth()
  }

  async getScreenWidth() {
    const result = await display.getAllDisplays()
    if (result && result.length) {
      this.screenWidth = px2vp(result[0].width) // 记录宽度
      this.screenHeight = px2vp(result[0].height) // 记录高度
    }
  }

  build() {
    Row({ space: 10 }) {
      Image(this.showVoice ? $r("app.media.ic_public_keyboard") : $r("app.media.ic_public_sound"))
        .width(25)
        .width(25)
        .onClick(() => {
          this.showVoice = !this.showVoice
        })
      if (this.showVoice) {
        Button("按住说话")
          .type(ButtonType.Normal)
          .height(35)
          .borderRadius(2)
          .backgroundColor($r("app.color.white"))
          .layoutWeight(1)
          .fontColor($r("app.color.text_primary"))
          .gesture(
            GestureGroup(GestureMode.Parallel,
              LongPressGesture()
                .onAction(() => {
                  this.showVoiceCom = true
                })
                .onActionEnd(() => {
                  this.showVoiceCom = false
                }),
              PanGesture()
                .onActionUpdate((event) => {
                  // event.fingerList[0].globalX
                  if (event.fingerList[0].globalY > this.screenHeight - 120) {
                    // 说明没有出录音区
                    this.voiceState = VoiceRecordEnum.RecordIng
                  } else {
                    // 小于屏幕一半说明在左侧 否则在右侧
                    if (event.fingerList[0].globalX < this.screenWidth / 2) {
                      this.voiceState = VoiceRecordEnum.Cancel
                    } else {
                      this.voiceState = VoiceRecordEnum.Transfer
                    }
                  }

                })
            )

          )
      } else {
        TextInput({ text: $$this.content })
          .height(35)
          .borderRadius(2)
          .backgroundColor($r("app.color.white"))
          .layoutWeight(1)
          .onSubmit(() => {
            // 触发
            if (this.content) {
              // 发送
              this.sendTextMessage(this.content)
              this.content = "" // 输入框清空
            }
          })
      }

      Image($r("app.media.ic_public_add_norm"))
        .width(25)
        .width(25)
    }
    .height(60)
    .width('100%')
    .backgroundColor($r("app.color.second_back_color"))
    .padding({
      left: 10, right: 10
    })
    .bindContentCover(
      $$this.showVoiceCom,
      this.getVoiceCom, {
      modalTransition: ModalTransition.NONE
    }
    )
  }
}

export default BottomInput