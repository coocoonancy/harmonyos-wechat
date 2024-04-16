import { router } from '@kit.ArkUI'
import { generateBarcode, scanCore } from '@kit.ScanKit'

@Entry
@Component
struct PayQrCode {
  @State
  payParams: string = Math.random().toString()
  timer: number = -1
  @State
  barCodeImage: PixelMap | null = null

  aboutToAppear(): void {
    this.createQR()
    this.createBarQR()
  }

  createQR() {
    this.timer = setInterval(() => {
      this.payParams = Math.random().toString()
    }, 10000)
  }

  async createBarQR() {
    this.barCodeImage = await generateBarcode.createBarcode(this.payParams, {
      scanType: scanCore.ScanType.CODE128_CODE,
      height: 200,
      width: 800
    })
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Image($r('app.media.ic_public_arrow_left'))
            .width(30)
            .height(30)
            .fillColor($r("app.color.white"))
            .onClick(() => {
              router.back()
            })
            .zIndex(2)

          Text("收付款")
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor($r('app.color.white'))
        }
        .height(50)
      }
      .padding({
        left: 10,
        right: 10
      })

      Row() {
        Column() {
          Row({ space: 10 }) {
            Image($r("app.media.ic_public_scan"))
              .width(20)
              .height(20)
              .fillColor($r("app.color.pay_back"))
            Text("付款码")
              .fontColor($r("app.color.pay_back"))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .height(80)
          .border({
            width: {
              bottom: 0.5
            },
            color: $r("app.color.border_color")
          })

          Image(this.barCodeImage)
            .width('100%')
            .height(100)
            .objectFit(ImageFit.Contain)

          // 显示码
          Column({ space: 20 }) {
            Text("优先使用xx银行储蓄卡付款")
              .fontColor($r("app.color.text_second"))
              .fontSize(12)
            QRCode(this.payParams)
              .width(100)
              .height(100)
          }
          .margin({
            top: 10,
            bottom: 10
          })
        }
        .padding(10)
        .borderRadius(4)
        .width("100%")
        .backgroundColor($r("app.color.white"))
      }
      .padding({
        left: 20,
        right: 20
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.pay_back"))
  }
}

