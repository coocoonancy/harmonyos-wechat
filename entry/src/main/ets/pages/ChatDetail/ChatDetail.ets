import { WeChat_CurrentUserKey } from '../../constants'
import { UserInfo, UserInfoModel } from '../../models/user'
import { router } from '@kit.ArkUI'
import { MessageInfo, MessageInfoModel } from '../../models/message'
import { WeChatStore } from '../../utils/chat_store'
import Message from '../components/Message'
import BottomInput from '../components/BottomInput'
import { requestMessage } from '../../utils/request'

@Entry
@Component
struct ChatDetail {
  @StorageProp(WeChat_CurrentUserKey)
  currentUser: UserInfoModel = new UserInfoModel({} as UserInfo)
  @Provide
  talkUser: UserInfoModel = new UserInfoModel({} as UserInfo)
  @State
  talkUserInputIng: boolean = false // 对方正在输入
  @State
  messList: MessageInfoModel[] = []
  scroller: Scroller = new Scroller() // 控制消息的滚动条

  getAllRecord() {
    this.messList = WeChatStore.getWeChatMessage(this.talkUser.user_id)
    this.scroller.scrollEdge(Edge.Bottom)
  }

  aboutToAppear(): void {
    this.getTalkUser()
  }

  async getTalkUser() {
    this.talkUser = router.getParams() as UserInfoModel
    this.getAllRecord()
  }

  // 发送文本消息
  async sendTextMessage(content: string) {
    let message = new MessageInfoModel({
      messageContent: content,
      sendUser: this.currentUser,
      connectUser: this.talkUser,
    } as MessageInfo)
    this.messList.push(message) // 添加到信息的底部
    WeChatStore.addOneWeChatMessage(this.talkUser.user_id, message)
    this.scroller.scrollEdge(Edge.Bottom)
    await this.getResponseMessage(content)
  }

  async getResponseMessage(content: string) {
    this.talkUserInputIng = true
    const result = await requestMessage(content)
    let message = new MessageInfoModel({
      messageContent: result.data?.info?.text,
      sendUser: this.talkUser,
      connectUser: this.talkUser,
    } as MessageInfo)
    this.messList.push(message) // 添加到信息的底部
    WeChatStore.addOneWeChatMessage(this.talkUser.user_id, message)
    this.talkUserInputIng = false
    this.scroller.scrollEdge(Edge.Bottom)
  }

  delMessage(messId: string) {
    const index = this.messList.findIndex(item => item.id === messId)
    if (index > -1) {
      this.messList.splice(index, 1)
      WeChatStore.delOneWeChatMessage(this.talkUser.user_id, messId)
    }
  }

  build() {
    Column() {
      Stack({
        alignContent: Alignment.Start
      }) {
        Image($r("app.media.ic_public_arrow_left"))
          .width(30)
          .height(30)
          .zIndex(2)
          .onClick(() => {
            router.back()
          })
        Text(this.talkUserInputIng ? "对方正在输入" : this.talkUser.username)
          .fontColor($r("app.color.text_primary"))
          .width('100%')
          .textAlign(TextAlign.Center)

      }
      .padding({
        left: 10,
        right: 10
      })
      .height(50)
      .width("100%")

      List({ space: 20, scroller: this.scroller }) {
        ForEach(this.messList, (item: MessageInfoModel) => {
          ListItem() {
            Message({
              currentMessage: item, delMessage: () => {
                this.delMessage(item.id)
              }
            })
          }
        })
      }
      .layoutWeight(1)
      .padding({
        top: 10,
        bottom: 10
      })
      .backgroundColor($r("app.color.back_color"))
      .onAppear(() => {
        this.scroller.scrollEdge(Edge.Bottom)
      })

      // 底部内容
      BottomInput({
        sendTextMessage: (content: string) => {
          this.sendTextMessage(content)
        }
      })
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}