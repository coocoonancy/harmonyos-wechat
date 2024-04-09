import { util } from '@kit.ArkTS'
import { fileIo } from '@kit.CoreFileKit'

export class FileCommon {
  // 创建一个音频文件 并返回路径
  static createAudioFile() {
    const filePath = getContext().filesDir + '/' + util.generateRandomUUID() + '.wav'
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE)
    fileIo.closeSync(file)
    return filePath
  }

  static delFilePath(filePath: string) {
    if (filePath) {
      fileIo.unlinkSync(filePath)
    }
  }
}