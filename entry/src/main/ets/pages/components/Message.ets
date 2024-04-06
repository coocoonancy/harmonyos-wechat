import { WeChat_CurrentUserKey } from '../../constants'
import { MessageInfo, MessageInfoModel } from '../../models/message'
import { UserInfo, UserInfoModel } from '../../models/user'
import { promptAction } from '@kit.ArkUI'
import { PopupItem } from '../../models/popup'

@Component
struct Message {
  delMessage: (messId: string) => void = () => {
  }
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

  build() {
    Row() {
      Image(this.currentMessage.sendUser.avatar)
        .width(40)
        .aspectRatio(1)
        .borderRadius(4)
      Row() {
        Text(this.currentMessage.messageContent)
          .backgroundColor(this.isOwnMessage ? $r("app.color.second_primary") : $r("app.color.white"))
          .fontColor($r("app.color.text_primary"))
          .padding(10)
          .margin({
            left: 10,
            right: 10
          })
          .borderRadius(4)
          .bindPopup(this.showPopup, {
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