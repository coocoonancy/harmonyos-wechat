import { preferences } from '@kit.ArkData'
import {
  Record_Update_EventName,
  WeChat_ConnectKey,
  WeChat_CurrentUserKey,
  WeChat_StoreKey,
  WeChat_UserRecordKey
} from '../constants'
import { MessageInfoModel } from '../models/message'
import { CurrentUser, DefaultUserList, UserInfoModel } from '../models/user'
import { emitter } from '@kit.BasicServicesKit'
import { FileCommon } from './file_operations'

export class WeChatStore {
  static context: Context

  // 获取首选项的仓库
  static getWeChatStore() {
    return preferences.getPreferencesSync(WeChatStore.context || getContext(), {
      name: WeChat_StoreKey
    })
  }

  // 获取微信联系人
  static getWeChatConnect() {
    const store = WeChatStore.getWeChatStore()
    return JSON.parse(store.getSync(WeChat_ConnectKey, JSON.stringify(DefaultUserList)) as string) as UserInfoModel[]
  }

  // 获取当前用户
  static getCurrentUser() {
    const store = WeChatStore.getWeChatStore()
    return JSON.parse(store.getSync(WeChat_CurrentUserKey, JSON.stringify(CurrentUser)) as string) as UserInfoModel
  }

  // 获取我和某个人的聊天记录的仓库
  static getWeChatMessageStore(userId: string) {
    return preferences.getPreferencesSync(getContext(), {
      name: `${WeChat_UserRecordKey}_${userId}` // 仓库名称
    })
    // wechat_record_1:
    // wechat_record_2:
  }

  // 获取"我"和某个人的整个的聊天记录 userId 对话者的id
  // WeChat_UserRecordKey_对话者id => 所有的聊天记录
  static getWeChatMessage(userId: string) {
    const store = WeChatStore.getWeChatMessageStore(userId) // 我和某个人的仓库
    const allRecord = store.getAllSync() as object // 拿到我和某个人所有的记录
    if (allRecord) {
      // 需要的是列表的数组
      // { id_1: 消息, id_2: 消息， id_3: 消息  }
      const list = Object.values(allRecord).map((item: string) => JSON.parse(item) as MessageInfoModel)
      // list是我和某个人的所有的聊天记录 但是没有顺序
      list.sort((a: MessageInfoModel, b: MessageInfoModel) => a.sendTime - b.sendTime) // 按照正顺序排列
      return list
    }
    return []
  }

  // 删除“我”和某个人的整个的聊天记录
  static async delWeChatMessage(userId: string) {
    const list = WeChatStore.getWeChatMessage(userId)
    list.forEach(item => {
      if (item.sourceFilePath) {
        FileCommon.delFilePath(item.sourceFilePath)
      }
    })
    preferences.deletePreferences(getContext(), {
      name: `${WeChat_UserRecordKey}_${userId}`
    })
  }

  // 添加一条“我”和某个人的聊天记录
  static async addOneWeChatMessage(userId: string, message: MessageInfoModel) {
    const store = WeChatStore.getWeChatMessageStore(userId) // 我和某个人的仓库
    store.putSync(message.id, JSON.stringify(message)) // 添加记录
    // 消息是用uuid做的key { xx: 消息 }
    await store.flush()
    emitter.emit(Record_Update_EventName)
  }

  // 删除一条“我”和某个人的聊天记录
  static async delOneWeChatMessage(userId: string, messId: string) {
    const store = WeChatStore.getWeChatMessageStore(userId) // 我和某个人的仓库
    store.deleteSync(messId)
    await store.flush()
    emitter.emit(Record_Update_EventName)
  }

  // 获取所有人的聊天记录的最后一条的集合
  static getAllLastRecord() {
    // 现在不确定有有多少个聊天记录
    // 一定有个文件 记录当下有多少聊天记录 根据这个聊天记录去找所有的具体的聊天记录内容
    // 先把用户拿过来
    const users = WeChatStore.getWeChatConnect()
    const list: MessageInfoModel[] = []
    users.forEach(user => {
      // 拿到每一个用户
      const weMessage = WeChatStore.getWeChatMessage(user.user_id)
      if (weMessage && weMessage.length) {
        // 说明和这个人有聊天记录
        list.push(weMessage[weMessage.length - 1])
      }
    })
    // list就是所有人的最后一条记录
    list.sort((a: MessageInfoModel, b: MessageInfoModel) => b.sendTime - a.sendTime)
    return list
  }
}

