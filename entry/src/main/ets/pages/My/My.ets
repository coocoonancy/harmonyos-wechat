import { WeChat_CurrentUserKey } from '../../constants'
import { UserInfo, UserInfoModel } from '../../models/user'

@Entry
@Component
struct My {
  @StorageProp(WeChat_CurrentUserKey)
  currentUser: UserInfoModel = new UserInfoModel({} as UserInfo)

  @Builder
  getRenderItem(left: string, rightClick?: () => void) {
    Row() {
      Text(left)
      Image($r("app.media.ic_public_right"))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20
    })
    .backgroundColor($r("app.color.white"))
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      color: $r("app.color.border_color"),
      width: {
        bottom: 0.5
      }
    })
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Row({ space: 10 }) {
          Image(this.currentUser.avatar)
            .width(60)
            .height(60)
            .borderRadius(6)
          Column({ space: 10 }) {
            Text(this.currentUser.username).fontSize(18).fontColor($r('app.color.text_primary'))
            Text(`微信号：${this.currentUser.user_id}`).fontColor($r('app.color.text_second')).fontSize(14)
          }.alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)

        Image($r("app.media.ic_public_right"))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_second'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(30)
      .width('100%')
      .backgroundColor($r("app.color.white"))

      Row().height(10)
      this.getRenderItem("服务")
      Row().height(10)
      this.getRenderItem("收藏")
      this.getRenderItem("朋友圈")
      this.getRenderItem("卡包")
      this.getRenderItem("表情")
      Row().height(10)
      this.getRenderItem("设置")
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.back_color'))
  }
}

export default My