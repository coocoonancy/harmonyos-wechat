import { preferences } from '@kit.ArkData'
import { WeChat_ConnectKey, WeChat_CurrentUserKey, WeChat_StoreKey, WeChat_UserRecordKey } from '../constants'
import { MessageInfoModel } from '../models/message'
import { CurrentUser, DefaultUserList, UserInfoModel } from '../models/user'

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

  //获取用户聊天记录
  static getWeChatMessage(userId: string) {
    const store = WeChatStore.getWeChatStore()
    return JSON.parse(store.getSync(`${WeChat_UserRecordKey}_${userId}`, "[]") as string) as MessageInfoModel[]
  }

  static async addOneWeChatMessage(userId: string, message: MessageInfoModel) {
    const store = WeChatStore.getWeChatStore()
    const list = await WeChatStore.getWeChatMessage(userId)
    list.push(message)
    store.putSync(`${WeChat_UserRecordKey}_${userId}`, JSON.stringify(list))
    await store.flush()
  }

  // 获取所有聊天记录的最后一天的集合
  static async getAllLastRecord() {
    const store = await WeChatStore.getWeChatStore()
    const result = store.getAllSync() as object
    let list: MessageInfoModel[] = []
    Object.keys(result).map(key => {
      if (key.includes(WeChat_UserRecordKey)) {
        // 如果包含记录的key
        if (result[key]) {
          let recordList = JSON.parse(result[key]) as MessageInfoModel[]
          if (recordList.length) {
            // 添加最后一条记录
            list.push(recordList[recordList.length - 1])
          }
        }
      }
    })
    // 对list进行排序
    list.sort((a: MessageInfoModel, b: MessageInfoModel) => {
      return b.sendTime - a.sendTime
    })
    return list
  }
}

