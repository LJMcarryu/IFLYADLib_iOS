# 更新日志

本项目遵循语义化版本。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [6.0.3] - 2026-06-15

### 修复
- 伞头 `IFLYADLib.h` 的各格式头 import 改用 `#if __has_include(...)` 守卫：按广告形式部分安装（模型 A）时也可直接 `#import <IFLYADLib/IFLYADLib.h>`（此前部分安装用伞头会因缺少未安装格式的头而编译失败，只能 import 具体格式头）。全量 `Full` 行为不变。

### 说明
- 仅头文件变更：各模块二进制与 `6.0.2` 一致（`Core` 的 xcframework checksum 因伞头改动而变化，其余 6 个模块不变）。

## [6.0.2] - 2026-06-15

### 修复
- 模型 A 产物补齐 `PrivacyInfo.xcprivacy`（修复相对 6.0.0 单包的隐私清单回归）。静态库无法内嵌隐私清单，故随 `Core` 资源经 `IFLYADLibCoreResources` 资源 bundle 交付；SPM 接入方需手动包含（见 README「隐私清单」）。

### 说明
- 公开 API 与 `Full` 行为与 `6.0.1` / `6.0.0` 一致；SPM 各模块二进制与 `6.0.1` 字节一致（仅 CocoaPods 合并包新增隐私清单与资源）。

## [6.0.1] - 2026-06-15

### 新增
- 「按广告形式可组合接入」（模型 A）：CocoaPods subspec（`Core` 必选 + `Banner`/`Splash`/`Interstitial`/`NativeFeed`/`Reward` 按需，`VideoUI` 与资源自动带入）与 Swift Package Manager。
- 各模块独立 `xcframework`（含 device + simulator 切片，可在模拟器调试），托管于 GitHub Releases `6.0.1`。

### 说明
- 公开 API 与 `Full` 行为与 `6.0.0` 一致，业务代码无需改动。
- SPM 接入需在 App target 的 `OTHER_LDFLAGS` 添加 `-ObjC`；SPM 不携带资源 bundle（详见 README）。

## [6.0.0] - 2026-06-12

### 变更
- SDK API 大版本升级；公开 `IFLYSplashAd`、`IFLYBannerAd`、`IFLYInterstitialAd`、`IFLYNativeFeedAd`、`IFLYRewardVideoAd`。
- 统一请求配置 `IFLYAdRequestConfig` 与展示配置；重写媒体侧示例工程。
- 交付形态：单一 `IFLYADLib.framework`（仅真机 arm64，不含模拟器切片）。

## [5.5.1] - 2026-04-14

### 修复
- CAID 字段为空未过滤、CAID 缓存过期未生效。

## 更早版本

- `5.4.x`（2025-09 ~ 2025-11）：窗口获取、点击/回调、包体等优化。
- `5.0.0`（2025-03-07）：开始支持 CocoaPods 接入。
- 更早版本详见 git tag。

[6.0.3]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.3
[6.0.2]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.2
[6.0.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.1
[6.0.0]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.0
[5.5.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/5.5.1
