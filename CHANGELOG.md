# 更新日志

本项目遵循语义化版本。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [6.0.9] - 2026-06-30

### 变更
- **自渲染信息流（NativeFeed）放宽素材完整性判定**：广告标题、视频封面图均改为**非必填**；`isMaterialComplete` 仅按素材类型校验核心素材（单图 ≥1 张图 / 视频含可播放 `videoURL` / 三图 ≥3 张图），与开屏 / 插屏 / Banner / 激励的原生视频素材口径对齐。缺标题或缺视频封面的素材不再被判为不完整而加载失败。公开 API、`Full` 行为、各格式能力均与 `6.0.8` 一致。
- **服务端竞价（S2S）测试环境域名对齐**：测试环境（`IFLYAd_TEST_ENVIRONMENT`）`/ad/sdk-s2s/bid`、`/ad/sdk-s2s/load` 由 `sdk-grey.voiceads.cn` 对齐为 `sdk-adx.voiceads.cn`；生产环境本就为 `sdk-adx.voiceads.cn`，故发布二进制无变化。

### 说明
- 7 个模块二进制相对 `6.0.8` 因素材判定改动重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.9`。

## [6.0.8] - 2026-06-22

### 变更
- **SDK 内部日志整体清除，仅保留关键节点 `error`**：`info` / `warn` / 调试 / JSON 日志宏整体置为无操作（不再产生任何输出），仅保留各失败关键节点的 `error` 日志（请求 / 渲染 / 播放 / 监测失败等）；`error` 日志内容仅含错误码与脱敏文案，不打印内部类名（`NSStringFromClass`）或裸 `NSError`。彻底杜绝运行期日志外泄内部符号。公开 API、`Full` 行为、各格式能力均与 `6.0.7` 一致。

### 说明
- 7 个模块二进制相对 `6.0.7` 因日志改动重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.8`。

## [6.0.7] - 2026-06-18

### 变更
- **服务端竞价（S2S）正式环境域名切换**：生产环境 `/ad/sdk-s2s/bid`、`/ad/sdk-s2s/load` 地址由 `msdk.voiceads.cn` 切换为 `sdk-adx.voiceads.cn`；灰度调试地址 `sdk-grey.voiceads.cn` 不变。`PrivacyInfo.xcprivacy` 的 `NSPrivacyTrackingDomains` 新增 `sdk-adx.voiceads.cn`。公开 API、`Full` 行为、各格式能力均与 `6.0.6` 一致。

### 说明
- 7 个模块二进制相对 `6.0.6` 因 S2S 生产地址改动重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.7`。

## [6.0.6] - 2026-06-17

### 变更
- **SDK 内部日志精简**：删除调试级与冗余追踪日志（约 322 → 181 条），保留全部 `error` / `warn` 与关键业务里程碑（请求 / 展示 / 点击 / 关闭 / 发奖 / 竞价）。
- **日志输出彻底去 IFLY 字眼**：移除日志中打印内部类名（`NSStringFromClass`）与裸 `NSError`（域名合成串）的路径；运行期日志前缀 `[AdSDK]`、模块名与文案均无品牌名。公开 API、`Full` 行为、各格式能力均与 `6.0.5` 一致。

### 说明
- 7 个模块二进制相对 `6.0.5` 因日志改动重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.6`。

## [6.0.5] - 2026-06-17

### 修复
- **资源加载器跨域兜底**：请求域未命中时回退其余域 bundle，修复边界资产（`IFLYFPlayer_slider` 归 VideoUI 域却经 Core 交互域请求）在按广告形式分包（模型 A）下的"域内缺图"。
- 开屏交互图标改用统一资源加载器（按域定位 + 密度选择），替换裸文件路径加载。

### 变更
- SDK 版本号常量（随广告请求上报的 `sdk_ver`）由 `6.0.1` 对齐到发版号 `6.0.5`（此前 6.0.2–6.0.4 为打包型发版，未同步该常量）。
- 7 个模块二进制相对 `6.0.4` 重新构建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.5`。

## [6.0.4] - 2026-06-16

### 变更
- 运行期日志行前缀去品牌：`[IFLYAd <时间戳>]` → `[AdSDK <时间戳>]`（合规去名）。仅日志输出文本变化，公开 API、`Full` 行为、各格式能力均与 `6.0.3` 一致。

### 说明
- 7 个模块二进制相对 `6.0.3` 均因日志字符串改动而重建，`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 的合并 zip 源已同步更新到 `6.0.4`。

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

[6.0.9]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.9
[6.0.8]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.8
[6.0.7]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.7
[6.0.6]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.6
[6.0.5]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.5
[6.0.3]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.3
[6.0.2]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.2
[6.0.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.1
[6.0.0]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.0.0
[5.5.1]: https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/5.5.1
