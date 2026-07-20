# IFLYADLibSimple — IFLYADLib 接入示例

面向媒体接入方的最小示例，仅使用公开 API，演示开屏 / Banner / 插屏 / 自渲染信息流 / 激励视频五种广告的加载与展示。基于 `IFLYADLib 6.0.14`，最低支持 iOS 11.0。

## 运行

```bash
pod install --repo-update     # 拉取 IFLYADLib 6.0.14
open IFLYADLibSimple.xcworkspace
```

- `6.0.14` 含 device + simulator 切片，可直接在**模拟器**运行；**真机**运行请在「Signing & Capabilities」选择你自己的开发者 Team（示例的 `DEVELOPMENT_TEAM` 已置空）。
- 若 `pod install` 报找不到 `6.0.14`（CocoaPods CDN 索引尚未同步），按 `Podfile` 注释里的 `:podspec` 直连写法接入，或稍后重试 `pod install --repo-update`。

## 演示内容

| 目录 | 广告形式 |
| --- | --- |
| [`biz/splash`](IFLYADLibSimple/biz/splash) | 开屏 |
| [`biz/banner`](IFLYADLibSimple/biz/banner) | Banner |
| [`biz/interstitial`](IFLYADLibSimple/biz/interstitial) | 插屏 |
| [`biz/native`](IFLYADLibSimple/biz/native) | 自渲染信息流 |
| [`biz/reward`](IFLYADLibSimple/biz/reward) | 激励视频 |

S2S 服务端竞价、Header Bidding 仅在仓库根 README 文档说明，本示例未内置端到端演示（端到端需媒体服务端配合下发 `rspToken`）。

## 切换接入方案（按广告形式可组合 / 模型 A）

示例默认使用全量 `Full`。若只需部分广告形式，可改 `Podfile`（见其注释），并注意**导入头文件**的区别：

- `6.0.3` 起统一用伞头 `#import <IFLYADLib/IFLYADLib.h>` 即可（`__has_include` 守卫，全量与部分安装均可用）；也可按需 import 具体格式头，如 `#import <IFLYADLib/IFLYSplashAd.h>`。

CocoaPods subspec / SPM / `:podspec` 直连等完整说明见**仓库根 [README](../README.md)** 的「按广告形式可组合接入（模型 A）」。
