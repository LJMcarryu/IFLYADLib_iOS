# 更新日志

## [6.5.1] - 发布说明

<!-- ifly-release-status: {"version":"6.5.1","status":"FAST_UNVERIFIED","distribution":"tos","releaseUrl":"https://download-adsdk.voiceads.cn/ios_sdk/6.5.1/general/fast-release-record.json"} -->

本版尚未完成安装、构建与广告展示验证，请先在宿主 App 中联调。

## [6.5.0] - 更新说明

> `6.5.0` 已验证 CocoaPods、SwiftPM 的安装、版本锁定与模拟器构建；真机广告展示需在宿主 App 中联调。



> 以下为历史版本记录，验收结论仅适用于各节明确列出的历史版本。

## [6.4.6] - TOS 分发

调整 SDK 下载分发，安装入口保持不变。

下载文件与校验值见[版本下载记录](https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/release-record.json)。


## [6.4.5] - 模块化静态框架

<a id="变更范围"></a>
<a id="验证边界"></a>

完善七模块静态 framework 的 Swift 接入。

Swift 使用 `import IFLYAdCore` 和所选格式模块；Objective-C 须将 `<IFLYADLib/...>` 改为对应模块头路径，见[迁移指南](docs/接入指南/Swift模块接入与头路径迁移.md)。


## [6.4.4] - 发布工程优化

<a id="变更"></a>

优化 SDK 分发。公开 API、广告形式和最低系统要求保持不变。


## [6.4.3] - 冻结与发布记录

<a id="变更-1"></a>
<a id="变更-2"></a>

优化日志处理。公开 API 和广告形式保持不变。


## [6.4.2] - 冻结与发布记录

更新 SDK 分发。


## [6.4.1] - 发布工程优化

<a id="变更-3"></a>

优化 SDK 分发。


## [6.4.0] - 冻结与发布记录

<a id="变更-4"></a>

优化多窗口场景下的广告展示与页面返回。

开屏 `customWindow` 须与宿主页面处于同一 Scene，并保持可见、尺寸有效。


## [6.3.5] - 冻结与发布记录

<a id="变更-5"></a>

优化广告加载、展示及视频播放。


## [6.3.1] - 2026-09-01

<a id="变更-6"></a>

优化广告加载与诊断信息。


## [6.3.0] - 2026-08-25

<a id="变更-7"></a>

优化 NativeFeed 视图绑定、点击交互与页面跳转。


## [6.2.4] - 2026-08-17

<a id="修复"></a>

优化 NativeFeed 视图绑定与点击处理。


## [6.2.3] - 2026-08-16

<a id="新增"></a>

NativeFeed 新增 `allowsExternalClickViews`，默认 `NO`；需要外部点击视图时显式开启。

新增 `detachFromCurrentContainer` 便利方法。


## [6.2.2] - 2026-08-10

<a id="新增-1"></a>
<a id="新增-2"></a>
<a id="变更-8"></a>
<a id="移除"></a>

NativeFeed 改用 Ad 级 `attachWithViewBinder:error:` 挂载、容器级 `detachAdFromContainerView:` 解绑；数据层持有 Ad，Cell 离屏或复用时解绑。

移除 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding`、`beginDisplaySessionWithError:`、`bindAdWithViewBinder:error:`、`unbindAd` 和 `endDisplaySession`。从旧版升级须替换相关调用并重新编译。


## [6.2.1] - 2026-08-07

<a id="新增-3"></a>
<a id="变更-9"></a>

NativeFeed 新增 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding` 及列表展示接口，支持 Cell 复用。

旧的 `bindAdWithViewBinder:error:` / `unbindAd` 用于固定卡片，两种接入方式不能在同一广告实例混用。


## [6.2.0] - 2026-08-06

<a id="新增-4"></a>
<a id="变更-10"></a>

优化请求与跳转处理。

`jumpDirectly` 保留兼容，设置该属性不再影响跳转行为。

iOS 14 及以上传入 IDFA 前须取得 ATT 授权；授权后需要显式传入 IDFA 时，请重新读取并设置。


## [6.1.0] - 2026-07-31

<a id="新增-5"></a>
<a id="变更-11"></a>
<a id="移除-1"></a>
<a id="移除-2"></a>

NativeFeed 新增 `appName`，完善单图、视频、多图示例及 SwiftPM 资源集成。

竞价信息改用 `bidInfo.price` / `bidInfo.dealId`；NativeFeed 按新版 `materialType`、`interactionType` 和 `ctaText` 接入。

移除 `ecpm`、`actionText`、`rawAdData`、`sponsored`、`ThreeImages` 和 `winNoticeAvailable` 等旧公开 API。升级须修改相关调用并重新编译，见 [6.1.0 接入说明](https://github.com/LJMcarryu/IFLYADLib_iOS/blob/6.1.0/README.md)。


## [6.0.14] - 2026-07-20

<a id="新增-6"></a>
<a id="变更-12"></a>

最低支持系统调整为 iOS 11.0。

完善视频完播页，优化广告请求。


## [6.0.13] - 2026-07-09

<a id="新增-7"></a>

优化 NativeFeed 展示与素材处理。


## [6.0.12] - 2026-07-08

<a id="说明"></a>

更新版本分发，公开 API 与广告能力保持不变。


## [6.0.11] - 2026-07-08

<a id="修复-1"></a>
<a id="修复-2"></a>
<a id="说明-1"></a>
<a id="说明-2"></a>

优化广告跳转。


## [6.0.10] - 2026-07-01

<a id="新增-8"></a>
<a id="说明-3"></a>

NativeFeed 新增可选回调 `nativeFeedAdWillDismissLandingPage:`，用于在落地页开始关闭前处理宿主页面；原有关闭完成回调保留。


## [6.0.9] - 2026-06-30

<a id="变更-13"></a>
<a id="说明-4"></a>

优化 NativeFeed 素材兼容性与竞价处理。


## [6.0.8] - 2026-06-22

<a id="变更-14"></a>
<a id="说明-5"></a>

优化日志处理。


## [6.0.7] - 2026-06-18

<a id="变更-15"></a>
<a id="说明-6"></a>

优化服务端竞价接入。


## [6.0.6] - 2026-06-17

<a id="变更-16"></a>
<a id="说明-7"></a>

优化日志处理。


## [6.0.5] - 2026-06-17

<a id="修复-3"></a>
<a id="变更-17"></a>

优化资源加载。


## [6.0.4] - 2026-06-16

<a id="变更-18"></a>
<a id="说明-8"></a>

调整日志输出。


## [6.0.3] - 2026-06-15

<a id="修复-4"></a>
<a id="说明-9"></a>

优化按广告形式安装时的头文件兼容性。


## [6.0.2] - 2026-06-15

<a id="修复-5"></a>
<a id="说明-10"></a>

完善隐私清单与资源交付。SwiftPM 接入须按该版本指南添加隐私清单。


## [6.0.1] - 2026-06-15

<a id="新增-9"></a>
<a id="说明-11"></a>

新增 CocoaPods 按广告形式安装与 SwiftPM 接入，提供真机和模拟器切片。

SwiftPM 接入须在 App target 添加 `-ObjC`，并按该版本指南加入资源。


## [6.0.0] - 2026-06-12

<a id="变更-19"></a>

升级广告 API，提供开屏、Banner、插屏、信息流与激励视频接口。

统一请求与展示配置，更新接入示例；该版本为真机 arm64 framework。


## [5.5.1] - 2026-04-14

<a id="修复-6"></a>

优化请求处理。


## 更早版本

`5.4.x`（2025-09 ~ 2025-11）：窗口获取、点击/回调、包体等优化。

`5.0.0`（2025-03-07）：开始支持 CocoaPods 接入。

更早版本详见 git tag。


[6.2.3]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.3
[6.2.2]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.2
[6.2.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.1
[6.2.0]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.0
[6.1.0]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.1.0
[6.0.14]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.14
[6.0.13]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.13
[6.0.12]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.12
[6.0.11]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.11
[6.0.10]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.10
[6.0.9]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.9
[6.0.8]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.8
[6.0.7]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.7
[6.0.6]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.6
[6.0.5]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.5
[6.0.4]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.4
[6.0.3]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.3
[6.0.2]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.2
[6.0.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.1
[6.0.0]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.0
[5.5.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/5.5.1
[6.3.5]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.5
[6.3.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.1
[6.3.0]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.0
[6.2.4]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.4
