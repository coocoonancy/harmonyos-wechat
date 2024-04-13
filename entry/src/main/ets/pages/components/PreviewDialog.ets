import { MessageTypeEnum } from '../../models/message'

@CustomDialog
@Component
struct PreviewDialog {
  controller: CustomDialogController
  url: string = ''
  mediaType: MessageTypeEnum = MessageTypeEnum.IMAGE

  build() {
    Column() {
      if (this.mediaType === MessageTypeEnum.IMAGE) {
        Image(this.url)
          .width('100%')
      }
      if (this.mediaType === MessageTypeEnum.VIDEO) {
        Video({ src: this.url })
          .autoPlay(true)
          .loop(true)
          .controls(false)
          .width('100%')
          .height("100%")
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height("100%")
    .onClick(() => {
      this.controller.close()
    })
    .backgroundColor($r("app.color.black"))
  }
}

export default PreviewDialog