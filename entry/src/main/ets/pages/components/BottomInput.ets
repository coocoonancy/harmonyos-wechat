@Preview
@Component
struct BottomInput {
  @State showVoice: boolean = false
  @State
  content: string = '' // 输入内容
  sendTextMessage: (content: string) => void = () => {
  } // 发送消息

  build() {
    Column() {
      Row({ space: 10 }) {
        Image(this.showVoice ? $r('app.media.ic_public_keyboard') : $r('app.media.ic_public_sound'))
          .width(25)
          .height(25)
        if (this.showVoice) {
          Button("按住 说话", { type: ButtonType.Normal })
            .backgroundColor(Color.White)
            .layoutWeight(1)
            .borderRadius(2)
            .fontColor($r('app.color.text_primary'))
        } else {
          TextInput({ text: $$this.content })
            .height(35)
            .layoutWeight(1)
            .borderRadius(2)
            .backgroundColor(Color.White)
            .onSubmit(() => {
              if (this.content) {
                this.sendTextMessage(this.content)
                this.content = '' // 设置为空
              }
            })
        }
        Image($r('app.media.ic_public_add_norm'))
          .width(25)
          .height(25)
      }
      .height(60)
      .width('100%')
      .padding({
        left: 10,
        right: 10
      })
    }
    .backgroundColor($r('app.color.second_back_color'))
  }
}

export default BottomInput