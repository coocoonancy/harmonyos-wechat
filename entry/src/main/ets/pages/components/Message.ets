import { WeChat_CurrentUserKey } from '../../constants'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../models/message'
import { UserInfo, UserInfoModel } from '../../models/user'
import { promptAction } from '@kit.ArkUI'
import { PopupItem } from '../../models/popup'
import { AudioRenderer } from '../../utils/audio_render'
import { FileCommon } from '../../utils/file_operations'

@Component
struct Message {
  delMessage: (messId: string) => void = () => {
  }
  previewImage: () => void = () => {
  }
  videoController: VideoController = new VideoController()
  @StorageProp(WeChat_CurrentUserKey)
  currentUser: UserInfoModel = new UserInfoModel({} as UserInfo)
  @Require
  @Prop
  currentMessage: MessageInfoModel = new MessageInfoModel({} as MessageInfo)
  @State
  isOwnMessage: boolean = this.currentUser.user_id === this.currentMessage?.sendUser?.user_id
  @State
  showPopup: boolean = false
  @State
  audioState: AnimationStatus = AnimationStatus.Initial
  @State
  popupList: PopupItem[] = [{
    title: '听筒播放',
    icon: $r("app.media.ic_public_ears")
  },
    {
      title: '收藏',
      icon: $r("app.media.ic_public_cube")
    }, {
      title: '转文字',
      icon: $r("app.media.ic_public_trans_text")
    }, {
      title: '删除',
      icon: $r("app.media.ic_public_cancel"),
      itemClick: () => {
        // 删除单条消息时，如果存在临时引用路径则直接删除
        if (this.currentMessage.sourceFilePath) {
          FileCommon.delFilePath(this.currentMessage.sourceFilePath)
        }
        this.delMessage(this.currentMessage.id)
      }
    }, {
      title: '多选',
      icon: $r("app.media.ic_public_multi_select")
    }, {
      title: '引用',
      icon: $r("app.media.ic_public_link")
    }, {
      title: '提醒',
      icon: $r("app.media.ic_public_warin")
    }]

  @Builder
  getPopup() {
    GridRow({ columns: 5 }) {
      ForEach(this.popupList, (item: PopupItem) => {
        GridCol() {
          Column({ space: 6 }) {
            Image(item.icon)
              .fillColor($r('app.color.white'))
              .width(18)
              .height(18)
            Text(item.title)
              .fontColor($r('app.color.white'))
              .fontSize(14)
          }.height(60).justifyContent(FlexAlign.Center)
        }
        .onClick(() => {
          item.itemClick && item.itemClick()
        })
      })
    }
    .width(300)
    .padding({
      left: 10,
      right: 10,
      top: 15,
      bottom: 15
    })
  }

  @Builder
  getContent() {
    if (this.currentMessage.messageType === MessageTypeEnum.TEXT) {
      this.getTextContent()
    }
    if (this.currentMessage.messageType === MessageTypeEnum.AUDIO) {
      this.getAudioContent()
    }
    if (this.currentMessage.messageType === MessageTypeEnum.IMAGE) {
      this.getImageContent()
    }
    if (this.currentMessage.messageType === MessageTypeEnum.VIDEO) {
      this.getVideoContent()
    }
  }

  @Builder
  getTextContent() {
    Text(this.currentMessage.messageContent)
      .backgroundColor(this.isOwnMessage ? $r("app.color.second_primary") : $r("app.color.white"))
      .fontColor($r("app.color.text_primary"))
      .padding(10)
      .margin({
        left: 10,
        right: 10
      })
      .borderRadius(4)
  }

  @Builder
  getAudioContent() {
    Row() {
      Text(`${this.currentMessage.sourceDuration}`)
      // Image($r("app.media.ic_public_recorder"))
      //   .width(20)
      //   .height(20)
      //   .rotate({
      //     angle: this.isOwnMessage ? 180 : 0
      //   })
      ImageAnimator()
        .images([
          {
            src: $r("app.media.ic_public_voice3")
          },
          {
            src: $r("app.media.ic_public_voice1")
          },
          {
            src: $r("app.media.ic_public_voice2")
          },
          {
            src: $r("app.media.ic_public_voice3")
          }
        ])
        .state(this.audioState)
        .iterations(-1)
        .width(20)
        .height(20)
        .rotate({
          angle: this.isOwnMessage ? 180 : 0
        })
    }
    .backgroundColor(this.isOwnMessage ? $r('app.color.chat_primary') : $r('app.color.white'))
    .justifyContent(this.isOwnMessage ? FlexAlign.End : FlexAlign.Start)
    .height(40)
    .padding({
      left: 10,
      right: 10
    })
    .margin({
      left: 10,
      right: 10
    })
    .borderRadius(4)
    .width(this.getAudioWidth())
    .direction(this.isOwnMessage ? Direction.Ltr : Direction.Rtl)
    .onClick(() => {
      AudioRenderer.start(this.currentMessage.sourceFilePath, () => {
        this.audioState = AnimationStatus.Stopped
      })
      this.audioState = AnimationStatus.Running
    })
  }

  getAudioWidth() {
    let minW: number = 20; // 百分比
    let maxW: number = 90; // 最长
    let calcW: number = minW + 100 * this.currentMessage.sourceDuration / 60;
    return calcW > maxW ? maxW + '%' : calcW + '%'
  }

  // 获取图片显示
  @Builder
  getImageContent() {
    Column() {
      Image("file://" + this.currentMessage.sourceFilePath)
        .borderRadius(4)
        .width('100%')
        .enabled(false)
    }
    .width('40%')
    .margin({
      left: 10,
      right: 10
    }).onClick(() => {
      this.previewImage()
    })

  }

  @Builder
  getVideoContent() {
    Stack() {
      Video({
        src: 'file://' + this.currentMessage.sourceFilePath,
        controller: this.videoController
      })
    }
  }

  build() {
    Row() {
      Image(this.currentMessage.sendUser.avatar)
        .width(40)
        .aspectRatio(1)
        .borderRadius(4)
      Row() {
        Column() {
          this.getContent()
        }.bindPopup(this.showPopup, {
          builder: this.getPopup,
          popupColor: $r('app.color.popup_back'),
          backgroundBlurStyle: BlurStyle.NONE,
          onStateChange: (e => {
            this.showPopup = e.isVisible
          })
        })

      }.justifyContent(this.isOwnMessage ? FlexAlign.End : FlexAlign.Start)
      .layoutWeight(6)
      .gesture(LongPressGesture().onAction(() => {
        this.showPopup = !this.showPopup
        promptAction.showToast({ message: '长按' })
      }))

      Text()
        .layoutWeight(1)
    }
    .padding({
      left: 20,
      right: 20
    })
    .direction(this.isOwnMessage ? Direction.Rtl : Direction.Ltr)
  }
}

export default Message