# IFLYADLibSimple — IFLYADLib 接入示例

面向媒体接入方的最小示例，仅使用公开 API，演示开屏 / Banner / 插屏 / 自渲染信息流 / 激励视频五种广告的加载与展示。示例基于正式版本 `IFLYADLib 6.2.0`，最低支持 iOS 11.0。

## 运行

```bash
pod install                   # 通过固定到 6.2.0 tag 的 :podspec 拉取
open IFLYADLibSimple.xcworkspace
```

- `6.2.0` 正式资产含 arm64 真机与 arm64/x86_64 模拟器切片，可直接在**模拟器**运行；**真机**运行请在「Signing & Capabilities」选择你自己的开发者 Team（示例的 `DEVELOPMENT_TEAM` 已置空）。
- 示例 `Podfile` 已固定到 `6.2.0` tag 的 `:podspec`；当前尚未进入 CocoaPods trunk，无需等待 CDN 索引。

## 演示内容

| 目录 | 广告形式 |
| --- | --- |
| [`biz/splash`](IFLYADLibSimple/biz/splash) | 开屏 |
| [`biz/banner`](IFLYADLibSimple/biz/banner) | Banner |
| [`biz/interstitial`](IFLYADLibSimple/biz/interstitial) | 插屏 |
| [`biz/native`](IFLYADLibSimple/biz/native) | 自渲染信息流：单图、视频、多图，展示 `appName` / `ctaText`，按行为类型配置 Binder |
| [`biz/reward`](IFLYADLibSimple/biz/reward) | 激励视频 |

S2S 服务端竞价、Header Bidding 仅在仓库根 README 文档说明，本示例未内置端到端演示（端到端需媒体服务端配合下发 `rspToken`）。

自渲染信息流示例延续 `6.1.0` 起的一次性绑定语义：视图复用或加载下一条广告前执行 `unbindAd`，再断开代理并 `destroy`。只有 `Redirect` / `Download` 传入点击视图；`Exposure` / `Unknown` 显式传 `@[]`。视频只传普通 `UIView` 给 Binder，播放器与播放监测由 SDK 管理。

## 从 6.1.0 升级到 6.2.0

- iOS 14+ 只有 ATT `authorized` 时 SDK 才接受和发送 IDFA。示例已在授权完成后读取系统 IDFA；不要在授权前预置，未授权阶段设置的显式值会被丢弃且授权后必须重新设置。
- SDK 跳转链路不再调用 `canOpenURL:` 预检，改按 `openURL:options:completionHandler:` 结果执行落地页 fallback。`jumpDirectly` 已是兼容 no-op；禁用 DeepLink 仍使用 `deepLinkDisabled`。
- `IFLYNativeFeedAd` 新增 `reportMediaShakeTriggeredWithError:`，但通用模型 A 固定返回 `NO` / `71512`，不会触发采样、点击或跳转；本通用示例不调用该方法。
- Core 显式链接 `AdSupport` 并弱链接 `AppTrackingTransparency`，继续支持 iOS 11；接入方仍应覆盖 iOS 11～13 启动和 iOS 14+ ATT 回归。

## 切换接入方案（按广告形式可组合 / 模型 A）

示例默认使用全量 `Full`。若只需部分广告形式，可改 `Podfile`（见其注释），并注意**导入头文件**的区别：

- `6.0.3` 起统一用伞头 `#import <IFLYADLib/IFLYADLib.h>` 即可（`__has_include` 守卫，全量与部分安装均可用）；也可按需 import 具体格式头，如 `#import <IFLYADLib/IFLYSplashAd.h>`。

CocoaPods subspec / SPM / `:podspec` 直连等完整说明见**仓库根 [README](../README.md)** 的「按广告形式可组合接入（模型 A）」。
