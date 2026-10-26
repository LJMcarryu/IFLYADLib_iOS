# IFLYADLib iOS SDK

## 6.4.4 候选

<!-- ifly-release-candidate: {"schemaVersion":1,"version":"6.4.4","releaseState":"CANDIDATE","publicationState":"UNPUBLISHED","repository":"LJMcarryu/IFLYADLib_iOS","currentFormalVersion":"6.4.3"} -->

`6.4.4` 为候选，尚未发布；当前公开正式版和生产依赖保持 `6.4.3`。历史 Tag、Release 和资产保持不可变。


面向 iOS 应用的广告 SDK，提供开屏、Banner、插屏、自渲染信息流和激励视频，支持按广告形式组合接入。本仓库提供安装清单、接入指南和 Objective-C 示例。

当前正式版本：[`6.4.3`](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.4.3)。生产项目请固定具体版本，升级前查看[更新记录](CHANGELOG.md)。

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.4.3","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.4.3"} -->

[运行示例](IFLYADLibSimple/README.md) · [安装与分包](docs/接入指南/安装与分包.md) · [配置与隐私](docs/接入指南/配置与隐私.md) · [常见问题](docs/接入指南/常见问题.md)

## 能力矩阵

| 广告形式 | 公开入口 | 接入指南 | 示例代码 |
| --- | --- | --- | --- |
| 开屏 | `IFLYSplashAd` | [图片与视频开屏](docs/接入指南/开屏广告.md) | [开屏页面](IFLYADLibSimple/IFLYADLibSimple/biz/splash/IFLYSplashViewController.m) |
| Banner | `IFLYBannerAd` | [容器内展示](docs/接入指南/Banner广告.md) | [Banner 页面](IFLYADLibSimple/IFLYADLibSimple/biz/banner/IFLYBannerViewController.m) |
| 插屏 | `IFLYInterstitialAd` | [半屏与全屏](docs/接入指南/插屏广告.md) | [插屏页面](IFLYADLibSimple/IFLYADLibSimple/biz/interstitial/IFLYInterstitialViewController.m) |
| 自渲染信息流 | `IFLYNativeFeedAd` | [图文、视频与列表复用](docs/接入指南/自渲染信息流.md) | [基础卡片](IFLYADLibSimple/IFLYADLibSimple/biz/native/IFLYNativeViewController.m)、[列表复用](IFLYADLibSimple/IFLYADLibSimple/biz/native/IFLYNativeFeedListViewController.m) |
| 激励视频 | `IFLYRewardVideoAd` | [展示与奖励回调](docs/接入指南/激励视频广告.md) | [激励页面](IFLYADLibSimple/IFLYADLibSimple/biz/reward/IFLYRewardVideoViewController.m) |

开屏、Banner、插屏和激励视频由 SDK 展示 UI；NativeFeed 由媒体绘制 UI，SDK 负责广告交互和视频播放。

## 环境要求

| 项目 | 说明 |
| --- | --- |
| 系统 | iOS 11.0 及以上 |
| CocoaPods | `IFLYADLib`，默认安装 `Full`；也可选择格式 subspec |
| SwiftPM | `Core`、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward`、`Full` product；清单要求 Swift tools 5.9 |
| Objective-C 导入 | `#import <IFLYADLib/IFLYADLib.h>` |
| 模块与资源 | `IFLYAdCore` 等按格式拆分模块；资源按 Core、VideoUI、Reward 投递，依赖关系见[安装指南](docs/接入指南/安装与分包.md) |
| 链接 | 静态 XCFramework，选择 **Do Not Embed**；最终 App target 需要 `$(inherited) -ObjC` |
| 共存 | 同一 App 选择一种安装方式；通用版与优酷定制版不能同时链接，其他渠道也不承诺共存 |

## 安装

首次接入可使用 CocoaPods，按完整 Podspec URL 安装固定版本：

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!
  pod 'IFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.4.3/IFLYADLib.podspec'
end
```

```bash
pod install
open YourApp.xcworkspace
```

该写法安装全部五种格式，CocoaPods 自动配置资源和 `-ObjC`。当前通过 GitHub 分发，请保留 Podspec URL。仅需部分格式时替换为对应 subspec；Core 本身不包含广告形式。

- [按格式组合 CocoaPods 依赖](docs/接入指南/安装与分包.md#cocoapods)
- [Swift Package Manager](docs/接入指南/安装与分包.md#swift-package-manager)：添加本仓地址，选择 **Exact Version** `6.4.3` 和所需 product；在 App target 添加 `-ObjC`。
- [下载与手动集成](docs/接入指南/安装与分包.md#下载与手动集成)：使用同版完整包，按格式链接依赖并复制资源及隐私清单。

## 首次使用

1. 取得与当前 App、广告形式匹配的广告位，完成宿主隐私流程及所需的系统授权；SDK 无需额外的全局初始化实例。
2. 创建具体广告对象，设置 delegate 与展示控制器，并由业务强持有。
3. 调用 `loadAd` 或 `loadAdWithRequestConfig:`。开屏、Banner、插屏、激励视频等待 `DidReady`；NativeFeed 在 `DidLoad` 后渲染素材并 attach。
4. 在主线程检查对象有效性及宿主页面状态，再展示。失败、超时或放弃本次机会时继续宿主流程；下一次广告机会创建新实例。

完整流程见上方各格式指南。`DidLoad` 表示响应解析成功，不代表内置素材已就绪；展示与有效曝光是不同事件。激励奖励只依据 `didRewardEffective` 回调，由宿主做幂等处理。

## 初始化、隐私和请求配置

请求前的授权、IDFA、个性化状态、ATS 和展示窗口要求见[配置与隐私](docs/接入指南/配置与隐私.md)。个性化设置用于记录媒体选择，宿主应独立管理同意流程与 SDK 使用时机。

### 请求配置

常用字段、普通加载方式和示例辅助方法见[请求配置](docs/接入指南/配置与隐私.md#请求配置)。交易参数按平台约定设置。

## 开屏广告

见[开屏广告指南](docs/接入指南/开屏广告.md)。包含加载、窗口要求、跳过、关闭与失败后的业务收尾。

## Banner 广告

见[Banner 广告指南](docs/接入指南/Banner广告.md)。在已布局的媒体容器中展示。

## 插屏广告

见[插屏广告指南](docs/接入指南/插屏广告.md)。在业务合适时机选择半屏或全屏展示。

## 激励视频广告

见[激励视频广告指南](docs/接入指南/激励视频广告.md)。区分奖励、播放完成与广告关闭。

## 自渲染信息流

见[自渲染信息流指南](docs/接入指南/自渲染信息流.md)。列表离屏按具体容器同步 detach，保留数据层 Ad 以便回屏恢复；永久移除时清理引用。通用版不支持媒体摇一摇上报，相关调用返回 `71512`。

## S2S 和 Header Bidding

已开通竞价的媒体按[竞价接入指南](docs/接入指南/竞价接入.md)处理 Token、加载和竞价结果通知；普通接入使用前述加载方式。

## 错误处理与生命周期

见[生命周期与清理](docs/接入指南/常见问题.md#生命周期)。将加载、素材、展示和交互失败分开处理，避免无间隔重试。

## 示例工程

[`IFLYADLibSimple`](IFLYADLibSimple/README.md) 提供五种格式、六个页面。指南包含下载运行、广告位配置、页面操作与预期结果。示例依赖固定为 `6.4.3`，移入生产 App 时保留自己的隐私流程和业务生命周期。

## 常见问题

找不到头文件、重复符号、资源缺失、未就绪和无填充等问题见[常见问题](docs/接入指南/常见问题.md#常见问题)。完整接口和错误码以所安装版本的公开头为准。

## 反馈与支持

接入问题请在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提供 SDK/iOS/Xcode 版本、安装方式、广告形式、操作步骤和错误码。日志与截图先去除 Token、设备标识和业务敏感信息。

[更新记录](CHANGELOG.md) · [使用许可](LICENSE) · [安全问题报告](SECURITY.md#报告安全漏洞)
