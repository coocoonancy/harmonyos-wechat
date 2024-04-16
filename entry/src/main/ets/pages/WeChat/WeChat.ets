import { MessageInfoModel } from '../../models/message';
import { router } from '@kit.ArkUI';
import { WeChatStore } from '../../utils/chat_store';
import { emitter } from '@kit.BasicServicesKit';
import { Record_Update_EventName } from '../../constants';
import { PopupItem } from '../../models/popup';
import { scanBarcode, scanCore } from '@kit.ScanKit';

@Entry
@Component
struct WeChat {
  @State list: MessageInfoModel[] = []
  @State dropShow: boolean = false
  @State popList: PopupItem[] = [
    {
      title: '发起群聊',
      icon: $r('app.media.ic_public_message')
    },
    {
      title: '添加朋友',
      icon: $r('app.media.ic_public_add_friend')
    },
    {
      title: '扫一扫',
      icon: $r('app.media.ic_public_scan'),
      itemClick: () => {
        this.scanCode()
      }
    },
    {
      title: '收付款',
      icon: $r('app.media.ic_public_receive'),
      itemClick: () => {
        router.pushUrl({
          url: 'pages/PayQrCode/PayQrCode'
        })
      }
    }
  ]

  aboutToAppear(): void {
    this.getAllRecord()
  }

  async getAllRecord() {
    this.list = await WeChatStore.getAllLastRecord()
    emitter.on(Record_Update_EventName, async () => {
      this.list = await WeChatStore.getAllLastRecord()
    })
  }

  transTime(timeStamp: number) {
    const sendTime = new Date(timeStamp)
    if (sendTime.getDate() === new Date().getDate()) {
      // 等于今天 显示时分
      return sendTime.getHours().toString().padStart(2, "0") + ":" + sendTime.getMinutes().toString().padStart(2, "0")
    } else {
      // 显示月和日
      return (sendTime.getMonth() + 1).toString().padStart(2, "0") + "月" + sendTime.getDate()
        .toString()
        .padStart(2, "0") + "日"
    }
  }


  async scanCode() {
    const res = await scanBarcode.startScanForResult(getContext(), {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    })
    AlertDialog.show({ message: res.originalValue })
  }


  @Builder
  getEnd(userId: string) {
    Row() {
      Text("删除")
        .fontColor($r('app.color.white'))
        .width(100)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          if (userId) {
            // 先删除组件中数据
            let index = this.list.findIndex(item => item.connectUser.user_id === userId)
            if (index > -1) {
              this.list.splice(index, 1)
            }
            // 再移除首选项
            WeChatStore.delWeChatMessage(userId)
          }
        })
    }.height(70)
    .padding({
      left: 20,
      right: 20
    })
    .backgroundColor($r('app.color.danger'))
  }

  @Builder
  getDrop() {
    Column() {
      ForEach(this.popList, (item: PopupItem) => {
        Row({ space: 5 }) {
          Image(item.icon)
            .fillColor($r('app.color.white'))
            .width(20)
            .height(20)
          Text(item.title)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .padding({
          left: 10,
          right: 10
        })
        .onClick(() => {
          item.itemClick && item.itemClick()
        })

      })
    }
    .width(120)
  }

  build() {
    Column() {
      Row() {
        Text('微信')
        Image($r('app.media.ic_public_add_norm'))
          .width(20)
          .height(20)
          .fillColor($r('app.color.text_primary'))
          .position({
            x: '100%'
          })
          .translate({
            x: -40,
            y: 15
          })
          .bindPopup(this.dropShow, {
            builder: this.getDrop,
            placement: Placement.Bottom,
            onStateChange: (event) => {
              this.dropShow = event.isVisible
            },
            popupColor: $r("app.color.popup_back"),
            backgroundBlurStyle: BlurStyle.NONE
          })
          .onClick(() => {
            this.dropShow = true
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(50)

      List({ space: 10 }) {
        ForEach(this.list, (item: MessageInfoModel) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(item.connectUser.avatar)
                .width(50)
                .height(50)
                .borderRadius(4)

              Column() {
                Text(item.connectUser.username)
                  .fontColor($r("app.color.text_primary"))
                Text(item.messageContent)
                  .fontColor($r("app.color.text_second"))
                  .fontSize(14)
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .height(50)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .padding({
                top: 4,
                bottom: 4
              })
              .layoutWeight(1)

              // 时间
              Text(this.transTime(item.sendTime))
                .fontColor($r("app.color.text_second"))
                .fontSize(14)
                .width(60)
            }
            .padding({
              left: 10,
              right: 10
            })
            .width('100%')
          }
          .width('100%')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ChatDetail/ChatDetail',
              params: item.connectUser
            })
          })
          .swipeAction({
            end: () => {
              this.getEnd(item.connectUser.user_id)
            }
          })
        })
      }
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        color: $r("app.color.back_color")
      })

    }
    .width('100%')
    .height('100%')
  }
}

export default WeChat