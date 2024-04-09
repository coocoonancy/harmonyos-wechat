import { display, promptAction } from '@kit.ArkUI'
import VoiceInput from '../../components/VoiceInput/VoiceInput'
import { VoiceRecordEnum } from '../../models/voice'
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit'
import { AudioRecorder } from '../../utils/audio_recorder'
import { FileCommon } from '../../utils/file_operations'
import { UserInfo, UserInfoModel } from '../../models/user'
import { WeChat_CurrentUserKey } from '../../constants'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../models/message'
import { PopupItem } from '../../models/popup'

@Preview
@Component
struct BottomInput {
  @Consume
  talkUser: UserInfoModel
  @StorageProp(WeChat_CurrentUserKey)
  currentUser: UserInfoModel = new UserInfoModel({} as UserInfo)
  @State
  showVoice: boolean = false // 是否显示语音输入
  @State
  content: string = "" // 输入内容
  // 发送文本
  sendTextMessage: (content: string) => void = () => {
  }
  // 发送语音
  sendAudioMessage: (mess: MessageInfoModel) => void = () => {
  }
  @State
  showVoiceCom: boolean = false
  tempAudioPath: string = ''
  // 计算计时器
  duration: number = 0 // 秒
  timer: number = -1 // 定时器标记
  // 当前的组件的状态
  @Provide
  voiceState: VoiceRecordEnum = VoiceRecordEnum.RecordIng
  // 需要知道整体屏幕的宽度
  screenWidth: number = 0 // 记录整体的宽度
  screenHeight: number = 0 // 记录整体高度
  @State
  bottomList: PopupItem[] = [{
    icon: $r('app.media.ic_public_photo'),
    title: '照片',
  }, {
    icon: $r('app.media.ic_public_carema'),
    title: '拍摄',

  }, {
    icon: $r('app.media.ic_statusbar_gps'),
    title: '位置',

  }, {
    icon: $r('app.media.ic_public_voice'),
    title: '语音输入',

  }, {
    icon: $r("app.media.ic_public_collect"),
    title: '收藏',

  }, {
    icon: $r("app.media.ic_public_contacts_filled"),
    title: '个人名片',

  }, {
    icon: $r("app.media.ic_public_folder_filled"),
    title: '文件',

  }, {
    icon: $r("app.media.ic_public_music_filled"),
    title: '音乐',
  }]
  @State
  showBottomCard: boolean = false // 显示底部
  textInputController: TextInputController = new TextInputController()

  aboutToAppear(): void {
    this.getScreenWidth()
    AudioRecorder.init()
  }

  aboutToDisappear(): void {
    AudioRecorder.release()
  }

  // 显示语音输入组件
  @Builder
  getVoiceCom() {
    // 实现语音输入组件
    // Builder函数不能在根组件直接使用自定义组件
    Column() {
      VoiceInput()

    }
  }

  // 检查权限
  async checkPermission() {
    const manager = abilityAccessCtrl.createAtManager()
    try {
      const bundler = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      const status = manager.checkAccessTokenSync(bundler.appInfo?.accessTokenId, 'ohos.permission.MICROPHONE')
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        const context = getContext() as common.UIAbilityContext
        context.startAbility({
          bundleName: 'com.huawei.hmos.settings',
          abilityName: 'com.huawei.hmos.settings.MainAbility',
          uri: "application_info_entry",
          parameters: {
            pushParams: bundler.name
          }
        })
      } else {
        this.showVoiceCom = true
        this.beginCollectAudio()
      }
    }
    catch {
    }
  }

  async getScreenWidth() {
    const result = await display.getAllDisplays()
    if (result && result.length) {
      this.screenWidth = px2vp(result[0].width) // 记录宽度
      this.screenHeight = px2vp(result[0].height) // 记录高度
    }
  }

  beginCollectAudio() {
    this.tempAudioPath = FileCommon.createAudioFile()
    this.startTime()
    AudioRecorder.start(this.tempAudioPath)
  }

  stopCollectVoice() {
    AudioRecorder.stop()
    this.endTime()
  }

  releaseFinger() {
    this.showVoiceCom = false
    AudioRecorder.stop()
    if (this.voiceState === VoiceRecordEnum.Cancel) {
      // 如果松手时，是取消状态 不管录的语音怎么样 直接删除
      FileCommon.delFilePath(this.tempAudioPath) // 删除路径
    } else if (this.voiceState === VoiceRecordEnum.Transfer) {
      // 如果是转化文本类
    }
    else if (this.voiceState === VoiceRecordEnum.RecordIng) {
      // 录制声音时间太短
      if (this.duration < 1) {
        promptAction.showToast({ message: '录制声音时间太短' })
        FileCommon.delFilePath(this.tempAudioPath)
      }
      // 如果是正常录音 发送语音信息
      this.sendAudio()
    }
    this.voiceState = VoiceRecordEnum.RecordIng
  }

  // 开始计时
  startTime() {
    this.timer = setInterval(() => {
      this.duration++
    }, 1000)
  }

  // 结束计时
  endTime() {
    clearInterval(this.timer)
  }

  // 发送语音消息
  sendAudio() {
    let mess = new MessageInfoModel({
      sourceDuration: this.duration,
      messageContent: `[语音]${this.duration}"`,
      connectUser: this.talkUser,
      sendUser: this.currentUser,
      messageType: MessageTypeEnum.AUDIO,
      sourceFilePath: this.tempAudioPath
    } as MessageInfo)
    this.sendAudioMessage(mess)
    this.tempAudioPath = "" // 清空临时路径
    this.duration = 0 // 时长归零
  }

  @Builder
  getBottomCard(item: PopupItem) {
    Column() {
      Column() {
        Image(item.icon)
          .width(30)
          .height(30)
          .fillColor("#4c4c4c")
      }
      .backgroundColor(Color.White)
      .width(56)
      .aspectRatio(1)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text(item.title)
        .fontSize(12)
        .fontColor($r('app.color.text_second'))
        .margin({
          top: 10
        })
    }.layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      item.itemClick && item.itemClick()
    })
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Image(this.showVoice ? $r("app.media.ic_public_keyboard") : $r("app.media.ic_public_sound"))
          .width(25)
          .width(25)
          .onClick(() => {
            this.showVoice = !this.showVoice
            if (this.showVoice) {
              animateTo({ duration: 100 }, () => {
                this.showBottomCard = false
              })
            }
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
                    this.checkPermission()
                  })
                  .onActionEnd(() => {
                    // this.showVoiceCom = false
                    this.releaseFinger()
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
          TextInput({ text: $$this.content, controller: this.textInputController })
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
            .onClick(() => {
              animateTo({ duration: 100 }, () => {
                this.showBottomCard = false
              })
            })
        }

        Image($r("app.media.ic_public_add_norm"))
          .width(25)
          .width(25)
          .onClick(() => {
            animateTo({ duration: 100 }, () => {
              this.showBottomCard = !this.showBottomCard
            })
          })


      }
      .height(60)
      .width('100%')
      .backgroundColor($r("app.color.second_back_color"))
      .padding({
        left: 10, right: 10
      })
      .bindContentCover(
        $$this.showVoiceCom,
        this.getVoiceCom,
        { modalTransition: ModalTransition.NONE }
      )

      if (this.showBottomCard) {
        Column() {
          // 底部结构
          GridRow({ columns: 4 }) {
            ForEach(this.bottomList, (item: PopupItem) => {
              GridCol() {
                this.getBottomCard(item)
              }.height(100)
            })
          }
          .width('100%')
          .transition({
            type: TransitionType.All,
            translate: {
              y: '100%'
            }
          })
        }
        .backgroundColor($r('app.color.second_back_color'))
      }

    }
  }
}

export default BottomInput