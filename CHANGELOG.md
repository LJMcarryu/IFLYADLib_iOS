# 更新日志

本项目遵循语义化版本。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [6.2.4] - 待发布

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`b0f745d582ce2bed5110702cff972be4153e5038`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`7b08118b43a0c4441de4c76a64f34fa54b3fe889`
- `candidateId`：`61f427469346615982e0225fad8187611794cc0a54c452da83073e89fd5ea1bd`
- 正式签名资产和 7 个 SwiftPM checksum 已冻结；`IFLYADLib-modelA-6.2.4.zip` 的冻结 SHA-256 为 `1ad521c06ad4c14909c9e1e816861f5898226e261c87d7e8ee4d4981c178791d`。Tag、Release 与匿名消费验证尚未完成，当前最新公开可用版仍为 `6.2.3`。
- Apple Review 扫描未执行且不是发布门禁：`requiredForRelease=false`、`statusAtFreeze=not-run`、`evidenceIncluded=false`。

### 修复

- NativeFeed 外部 CTA 的非 Cell 场景新增 window-local 归属，不再强制共同紧包 wrapper；同 window/scene、几何紧凑相邻且非页面级范围时允许绑定。
- 绑定时固化归属类型、结构锚点和双方祖先路径；运行中 reparent、共享、固定悬浮、离屏仍可点击、跨 window、远距离分散或页面级范围继续以 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）失败关闭。

## [6.2.3] - 2026-08-16

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`ea0240e620b57d7275e486199099c648f51de257`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`0f26b7647e6c1aadb32eca68b24f6845639a59c2`
- 正式签名资产和 7 个 SwiftPM checksum 已冻结并公开；`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `f6331ecf01aa902b5831a62ea8e205799c4301aa689f87bc216c0d1798e6f469`。[GitHub Release 6.2.3](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.3) 的 10 个资产已通过无 Token 匿名下载与正式消费 [Run 31939141466](https://github.com/LJMcarryu/IFLYADLib_iOS/actions/runs/31939141466) 验证。
- 本版本未执行主动 Apple Review 扫描，该扫描不属于发布门禁；冻结状态为 `requiredForRelease=false`、`statusAtFreeze=not-run`、`evidenceIncluded=false`，不得表述为通过。

### 新增

- NativeFeed Binder 新增 `allowsExternalClickViews`（默认 `NO`）。显式开启后仅接受同 window/scene 且归属可判定的同 Cell 或窄范围兄弟视图；共享、固定悬浮、离屏仍可点击或归属不明时失败关闭，并通过 `nativeFeedAd:didRejectClickWithError:` 返回 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）。
- NativeFeed 新增 `detachFromCurrentContainer` 固定单容器便利入口；6.2.2 的 Ad 级 attach 与容器级 detach 仍是通用主路径。

## [6.2.2] - 2026-08-10

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`a8ec925d3731d7d11734647aa02ca7d91d674965`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`eff78263c2d3f65b029f4114de1a9ed00f3827f3`
- 正式签名资产已从提交 A 构建、扫描并冻结；7 个 SwiftPM checksum 已回填，合并包 `IFLYADLib-modelA-6.2.2.zip` 的冻结 SHA-256 为 `f24cf6ea1d4e4319fbcef0fdb79a29aee5906f9bc35d81453052a6341379a673`。
- 不可变 annotated tag 指向 `d5caeb26794d8000e13e40d4356d2ff79706a3a9`；通用版 10 个资产已在 GitHub Release 正式公开，并通过无 Token 匿名下载、逐字节同源、SwiftPM、CocoaPods、`-ObjC`、Demo 编译链接和 `pod spec lint` 终验（[Run 31347794760](https://github.com/LJMcarryu/IFLYADLib_iOS/actions/runs/31347794760)）。
- 本版按确认范围保留并原样归档既有启发式残余风险，以 `failOn=high`、`failOnWarning=false`、`strict=false`、`requireManual=false` 发布；该发布不代表最终宿主合规、`Validate App` 或 Apple 审核通过。

### 新增

- NativeFeed 新增 Ad 级 `attachWithViewBinder:error:` 和容器级 `detachAdFromContainerView:`；SDK 内部管理会话、绑定代次、跨 Cell 串行迁移与同容器原子接管。
- 公开固定卡片与 `UITableView` 列表示例统一为 SDK 托管模式，CI 新增新 API 正向、旧 API 反向及 Demo 真实 `xcodebuild build` 门禁。

### 变更

- 数据层只持 `IFLYNativeFeedAd`，Cell 不再持 Session、Binding、Binding 集合或首次/复用状态。暂时离屏只 detach 容器，回屏使用原 Ad 重新 attach。
- 永久淘汰时 detach 已知容器并释放最后一个 Ad 强引用即可自动收口；`destroy` 只保留为仍持有 Ad 时的可选主动提前终止。
- 曝光、点击和视频节点继续按逻辑内容去重；曝光前迁移在新容器重新累计 `500ms`，视频进度与播放意图跨 detach/attach 保留。
- 同步带出 Base/S2S 在途 token gate 析构收口修复，并扩展点击回调丢弃灰度联调、S2S 测试环境保护、HTTP transport 测试、Server Bidding Demo 与正式二进制测试标记防污染门禁。

### 移除

- NativeFeed 公开头移除 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding`、`beginDisplaySessionWithError:`、`bindAdWithViewBinder:error:`、`unbindAd` 和 `endDisplaySession`。该版必须迁移媒体代码并重新编译。

## [6.2.1] - 2026-08-07

### 新增

- NativeFeed 新增 `IFLYNativeFeedDisplaySession` 与 `IFLYNativeFeedAdBinding`：数据层可按稳定 item ID 持有 `IFLYNativeFeedAd + DisplaySession`，Cell 只持当前 Binding，从而支持同一逻辑广告条目滚出后再回来继续展示原广告。
- 新增 `beginDisplaySessionWithError:`、`attachWithViewBinder:error:`、`detach` 和 `endDisplaySession` 完整列表生命周期；旧 `bindAdWithViewBinder:error:` / `unbindAd` 继续保留一次性固定卡片语义，两种模式不能在同一广告实例混用。
- 公开示例新增真实 `UITableView` 列表复用页面，覆盖稳定 item identity、`willDisplay` / `didEndDisplaying` 乱序、离屏 detach 与条目淘汰时 `endDisplaySession → destroy`。

### 变更

- 同一 DisplaySession 同时只允许一个活动 Binding；旧 Cell 的迟到 detach 由绑定 generation 隔离，不会误伤后来挂载的新 Cell。
- TTL 或视频投放截止时间在当前 Binding 活动期间到达时，`session.valid` 会变为 `NO`，但不会中途强拆当前展示；正常 detach 后不得再挂载，媒体应结束旧会话并请求新广告。
- 曝光前重新挂载会重新累计连续可见 `500ms`；已经曝光的逻辑广告不会因 Cell 复用重复曝光。视频进度与播放意图按逻辑条目保留，只有结束会话、关闭、销毁或过期后的 detach 才终止恢复能力。

## [6.2.0] - 2026-08-06

### 新增

- NativeFeed 统一公开 `reportMediaShakeTriggeredWithError:`。通用模型 A 仅保留统一 API 契约，不启用媒体摇一摇采样能力；调用会返回 `NO`，并通过 `IFLYAdErrorCodeNativeFeedMediaShakeUnavailable` 返回错误码 `71512`。

### 变更

- 收紧 ATT / IDFA 门控：iOS 14 及以上仅在 ATT 状态为 `authorized` 时读取、缓存或随普通请求及 S2S 请求发送 IDFA；用户撤销授权或 App 回到前台发现未授权时清除缓存。
- 未授权阶段通过 `IFLYAdRequestConfig.idfa` 或 `setParamValue:forKey:` 显式设置的 IDFA 会被丢弃，不跨授权状态保留；授权成功后如需显式 IDFA，媒体必须重新读取并设置。
- DeepLink 与自定义 scheme 跳转删除 `canOpenURL:` 预检，统一直接调用 `openURL:options:completionHandler:`，按系统 completion 判定成功并保留落地页 fallback。`jumpDirectly` 继续保留用于源码与二进制兼容，但设置值不再改变跳转行为，也不进入请求体。
- CocoaPods 的 `Core` 显式链接 `AdSupport`，并弱链接 `AppTrackingTransparency`；新二进制继续以 iOS 11.0 为最低系统，避免 iOS 11～13 因 ATT 框架强依赖而无法启动。

## [6.1.0] - 2026-07-31

### 新增

- NativeFeed `IFLYNativeFeedAdData` 新增 `appName`，对应服务端 `app_name`；仅 NativeFeed 暴露，空字符串和纯空白归一为 `nil`。
- NativeFeed Binder 支持 `Exposure` / `Unknown` 显式传空 `clickViews` 完成仅曝光绑定；补齐视频 start / pause / resume / finish / fail 回调驱动的封面状态示例。
- 公开示例新增单图、视频、多图三条直达路径；多图支持两至三张。

### 变更

- 五种广告格式通用响应字段严格收敛为 `bidInfo.price` 和 `bidInfo.dealId`；创意 ID 仅通过 NativeFeed 的 `adData.creativeId` 暴露。
- NativeFeed CTA 改为服务端原始 `ctaText`；`templateId/materialType` 统一为 `0=Unknown`、`1=SingleImage`、`2=Video`、`3=MultipleImages`，按 `video → img1+img2 → img/icon → Unknown` 推导。
- 多图最低要求由固定三张改为 `img1+img2`，`img3` 可选。绑定成功即消费广告实例；视图复用、替换广告或页面退出前须执行 `unbindAd → delegate=nil → destroy`。
- NativeFeed 视频由 SDK 在媒体提供的普通 `UIView` 内托管播放器、观察者和监测；媒体不自行创建 `AVPlayer`。SDK 不再向自渲染容器添加摇一摇提示 UI。
- SwiftPM 的 `Core` / `VideoUI` / `Reward` 伞 target 改为自动投递三域资源；所有 product 经 `Core` 自动携带 `PrivacyInfo.xcprivacy`，媒体不再手工复制资源。

### 移除

- 移除旧的 `ecpm`、`actionText`、`rawAdData`、`sponsored`、`ThreeImages` 和 `winNoticeAvailable` 公开 API。该版本需要业务代码迁移并重新编译，详见 README「从 6.0.14 升级到 6.1.0」。

## [6.0.14] - 2026-07-20

### 新增
- 插屏和激励视频素材同时包含图片时，视频播放结束后展示图片完播页；开屏仍按原语义在视频结束后关闭，不增加完播页。
- 请求链路补齐客户端竞价时间戳、曝光宏和设备调试状态字段。

### 变更
- SDK、公开 Podspec、Swift Package、示例工程与全部重新构建的 device / simulator 二进制最低系统统一为 iOS 11.0；历史 `6.0.13` 及更早产物不追溯扩大支持范围。
- 请求字段 `lts` 从顶层移入 `device` 对象；公开 API 签名不变。
- 7 个模块二进制按 iOS 11 重新构建；`Package.swift` 的 7 个 URL/checksum 与 `IFLYADLib.podspec` 合并 zip 源同步到 `6.0.14`。

## [6.0.13] - 2026-07-09

### 新增
- 自渲染信息流的「点击+摇一摇」广告绑定成功后，由 SDK 在容器右下角自动添加「摇一摇查看详情」提示，并避让关闭按钮。
- 自渲染素材校验失败时增加脱敏诊断日志；公开 API 签名不变。

## [6.0.12] - 2026-07-08

### 说明
- **版本对齐发版，标准版无行为变化**：公开 API、`Full` 行为、各格式能力、交付形态（模型 A 静态 xcframework + 三域资源 bundle）均与 `6.0.11` 一致。本版本随 YS 定制仓 `YSIFLYADLib 6.0.12`（交付形态动态 framework → 静态 framework）三仓对齐版本号发布。
- 7 个模块二进制随版本号重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.12`。

## [6.0.11] - 2026-07-08

### 修复
- **移除跳转黑名单中的 `itms-services` / `itms-apps` 字面量，改为 `itms` 前缀拦截**：自定义 scheme 跳转的危险 scheme 黑名单原以完整字面量列举 `itms` / `itms-apps` / `itms-services`（用于**拦截**这类 App Store / 企业分发（OTA）链接，SDK 自身从不构造、不调起），现改为按 `itms` 前缀统一拦截。效果：编译产物中不再出现 `itms-services` 完整字符串（避免被应用市场 / 审核的二进制静态扫描误判为企业分发 / 侧载），拦截行为完全不变且更严（覆盖整个 `itms` 家族）。公开 API、`Full` 行为、各格式能力均与 `6.0.10` 一致。

### 说明
- 7 个模块二进制相对 `6.0.10` 因该改动重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.11`。

## [6.0.10] - 2026-07-01

### 新增
- **自渲染信息流（NativeFeed）新增落地页关闭前回调 `nativeFeedAdWillDismissLandingPage:`**：在内嵌落地页关闭动画开始前**同步**回调，作为「落地页露出前的最后确认点」，供媒体在落地页收起、广告重新露出前做最后一次确认；随后仍会照常回调 `nativeFeedAdDidDismissLandingPage:`。该方法桥接 SDK 内部已有的落地页 dismiss-will-start 时机，是 `IFLYNativeFeedAdDelegate` 新增的**可选**方法。公开 API 其余部分、`Full` 行为、各格式能力均与 `6.0.9` 一致。

### 说明
- 仅 NativeFeed 暴露该回调；基类桥接对其它 4 格式为 no-op，公开头集合不变。7 个模块二进制相对 `6.0.9` 因新增回调重建；`Package.swift` 各 `binaryTarget` checksum 与 `IFLYADLib.podspec` 合并 zip 源已同步到 `6.0.10`。

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
