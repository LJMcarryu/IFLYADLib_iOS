# IFLYADLib iOS SDK 接入说明

`IFLYADLib` 是讯飞广告 iOS SDK，提供开屏、Banner、插屏、自渲染信息流、激励视频等广告能力。

## 6.2.3 发布状态

当前最新公开正式版仍为 `IFLYADLib 6.2.2`；`main` 正在准备全渠道共享优化版 `6.2.3`，示例工程见 [IFLYADLibSimple](./IFLYADLibSimple)。

> **发布状态**：[`6.2.2`](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.2) 已于 2026-08-10 正式发布。不可变 annotated tag 指向 `d5caeb26794d8000e13e40d4356d2ff79706a3a9`；10 个 Release 资产已完成无 Token 匿名下载、逐字节同源、SwiftPM、CocoaPods、`-ObjC`、Demo 编译链接和 `pod spec lint` 终验，证据见 [Run 31347794760](https://github.com/LJMcarryu/IFLYADLib_iOS/actions/runs/31347794760)。

> **6.2.3 冻结边界**：正式签名资产已从提交 A 构建、冻结并完成本地校验；`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `f6331ecf01aa902b5831a62ea8e205799c4301aa689f87bc216c0d1798e6f469`。tag、Release 与匿名消费验证尚未完成，仍待编排器执行，当前 URL 不可用于生产依赖。

> **风险边界**：`6.2.3` 不沿用 `6.2.2` 的启发式风险授权。本候选未执行主动 Apple Review 扫描，该扫描不属于发布门禁；如另行执行，固定使用 `failOn=high`、`failOnWarning=true`、`strict=true`、`requireManual=true` 且接受名单为空。`not-run` 不得表述为通过，也不代表最终宿主合规、`Validate App` 或 Apple 审核通过。

<!-- 供发布 CI 机器校验的两提交 provenance；正式回填时 README、CHANGELOG、RELEASING 必须保持一致。 -->
- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`ea0240e620b57d7275e486199099c648f51de257`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`0f26b7647e6c1aadb32eca68b24f6845639a59c2`

`releaseState=FORMAL` 只表示本版正式资产与发布元数据已冻结，不表示 tag、Release 或匿名消费验证已完成。

> 文档以中文为主。如需用英文反馈问题，请直接在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交。

仓库地址：[https://github.com/LJMcarryu/IFLYADLib_iOS](https://github.com/LJMcarryu/IFLYADLib_iOS)

## 版本记录

| 版本 | 日期 | 说明 |
| --- | --- | --- |
| 6.2.3 | 待发布 | 全渠道共享优化：NativeFeed 新增受限外部 CTA 适配，默认关闭；媒体显式设置 Binder 的 `allowsExternalClickViews=YES` 后，仅接受同 window/scene 且归属可判定的同 Cell 或窄范围兄弟视图。共享、固定悬浮、广告离屏后仍可点击或归属不明时失败关闭，并通过 `nativeFeedAd:didRejectClickWithError:` 返回 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）。新增 `detachFromCurrentContainer` 固定单容器便利入口，不改变 6.2.2 的 attach/容器 detach 主路径。 |
| 6.2.2 | 2026-08-10 | NativeFeed 改为 SDK 托管挂载：数据层只持 Ad，Cell 不持 Session/Binding 或首次/复用状态；进屏调用 Ad 级 `attachWithViewBinder:error:`，离屏/复用/切普通内容按容器调用 `detachAdFromContainerView:`。释放最后一个 Ad 强引用自动终止，`destroy` 仅作可选的主动提前终止；旧 DisplaySession/Binding 契约从公开 API 移除。 |
| 6.2.1 | 2026-08-07 | NativeFeed 新增 `IFLYNativeFeedDisplaySession` 与 `IFLYNativeFeedAdBinding`，支持同一稳定逻辑条目跨复用 Cell 串行恢复原广告；数据层持有 Ad + Session，Cell 只持 Binding，离屏 detach，淘汰 `endDisplaySession → destroy`。TTL 在活动 Binding 期间到达不强拆当前展示，detach 后结束旧会话并请求新广告。 |
| 6.2.0 | 2026-08-06 | 全渠道共享基线优化：iOS 14+ 仅在 ATT `authorized` 时读取、缓存和发送 IDFA，未授权阶段显式传入的 IDFA 直接丢弃且授权后须重新设置；跳转链路删除 `canOpenURL:` 预检并按系统 completion 保留落地页 fallback，`jumpDirectly` 降为兼容 no-op；NativeFeed 新增统一方法 `reportMediaShakeTriggeredWithError:`，通用模型 A 固定返回 `71512` 表示能力未启用；Core 显式链接 `AdSupport` 并弱链接 `AppTrackingTransparency`，继续支持 iOS 11。 |
| 6.1.0 | 2026-07-31 | 收紧广告响应公开边界：五种格式通用竞价信息仅保留 `bidInfo.price/dealId`，创意与渲染字段仅由 NativeFeed 的裁剪模型提供；NativeFeed 新增 `appName`，CTA 改为 `ctaText`，素材枚举归一为单图/视频/多图并支持两至三图；完善 Binder 的仅曝光空点击区、一次性绑定/解绑和 SDK 托管视频生命周期。SwiftPM 同时自动投递三域资源与 Core 隐私清单。该版本含破坏性 API 迁移，升级前必须阅读本文末尾迁移说明。 |
| 6.0.14 | 2026-07-20 | 最低系统版本由 iOS 13.0 下调为 iOS 11.0，7 个模块的 device / simulator 二进制全部重建并通过最低版本门禁；插屏和激励视频在服务端同时下发图片时于视频完播后展示图片完播页（开屏保持原关闭语义）；请求字段 `lts` 移入 `device`，并补齐客户端竞价时间戳、曝光宏和设备调试状态字段。公开 API 签名不变。 |
| 6.0.13 | 2026-07-09 | 自渲染信息流（NativeFeed）新增摇一摇提示控件：交互类型为「点击+摇一摇」的广告在 `bindAdWithViewBinder:error:` 成功后，由 SDK 自动在容器右下角添加「摇一摇查看详情」提示（避让关闭按钮、放不下则不添加、非独立点击区域，普通点击广告不展示）；自渲染素材校验失败（71501）新增 error 级诊断日志（template_id / 素材类型 / 图片数 / videoURL 有无）。公开 API 签名不变，其它格式与 `Full` 行为不变。 |
| 6.0.12 | 2026-07-08 | 版本对齐发版（公开 API 与各格式行为不变，二进制随版本号重建）：本仓（标准版模型 A，静态 xcframework，交付形态不变）随 YS 定制仓 6.0.12（交付形态动态→静态）三仓对齐版本号。 |
| 6.0.11 | 2026-07-08 | 移除跳转黑名单中 `itms-services` / `itms-apps` 字面量，改为 `itms` 前缀拦截：编译产物不再出现 `itms-services` 完整字符串（避免应用市场 / 审核静态扫描误判为企业分发 / 侧载），拦截行为不变且更严；公开 API 与各格式行为不变，二进制因该改动重建。 |
| 6.0.10 | 2026-07-01 | 自渲染信息流（NativeFeed）新增可选回调 `nativeFeedAdWillDismissLandingPage:`：内嵌落地页关闭动画开始前**同步**回调，作为「落地页露出前的最后确认点」，随后仍照常回调 `nativeFeedAdDidDismissLandingPage:`。仅 NativeFeed 暴露、公开头集合不变；其它格式与 `Full` 行为不变，二进制因新增回调重建。 |
| 6.0.9 | 2026-06-30 | 自渲染信息流（NativeFeed）放宽素材完整性：广告标题、视频封面均**非必填**，仅要求核心素材齐备（单图 ≥1 图 / 视频含可播放地址 / 三图 ≥3 图），与其它格式视频素材口径对齐；S2S 测试环境域名对齐 `sdk-adx`。公开 API 与各格式行为不变，二进制因素材判定改动重建。 |
| 6.0.8 | 2026-06-22 | SDK 内部日志整体清除，仅保留关键节点 `error`（移除 `info`/`warn`/调试/JSON 日志，杜绝日志外泄内部类名等）；公开 API 与各格式行为不变，二进制因日志改动重建。 |
| 6.0.7 | 2026-06-18 | 服务端竞价（S2S）正式环境域名切换为 `sdk-adx.voiceads.cn`（`/ad/sdk-s2s/bid`、`/ad/sdk-s2s/load`）；`PrivacyInfo.xcprivacy` 新增该域。公开 API 与各格式行为不变，二进制因地址改动重建。 |
| 6.0.6 | 2026-06-17 | SDK 内部日志精简（约 322→181 条，删冗余追踪/调试日志）+ 日志输出彻底去 IFLY 字眼（移除类名 / 裸 NSError 域名打印）；公开 API 与各格式行为不变，二进制因日志改动重建。 |
| 6.0.5 | 2026-06-17 | 资源加载器跨域兜底修复（按格式分包域内缺图）+ SDK 版本号常量对齐发版号。 |
| 6.0.4 | 2026-06-16 | 运行期日志前缀去品牌 `[IFLYAd]`→`[AdSDK]`（合规去名）；公开 API 与 `Full` 行为不变，二进制相对 6.0.3 仅日志字符串变化。 |
| 6.0.3 | 2026-06-15 | 伞头 `IFLYADLib.h` 改用 `__has_include` 守卫，**按格式部分安装也可直接用伞头**（此前部分安装须 import 具体格式头）；二进制与 6.0.2 一致。 |
| 6.0.2 | 2026-06-15 | 模型 A 各模块产物随 `Core` 资源补齐 `PrivacyInfo.xcprivacy`（修复相对 6.0.0 单包的隐私清单回归）；公开 API 与 `Full` 行为不变，SPM 二进制与 6.0.1 一致。 |
| 6.0.1 | 2026-06-15 | 新增「按广告形式可组合接入」（模型 A）：CocoaPods subspec + Swift Package Manager，产物（各模块独立 xcframework）托管于 GitHub Releases `6.0.1`；`Full` 行为与 6.0.0 一致。 |
| 6.0.0 | 2026-06-12 | SDK API 大版本升级；公开 `IFLYSplashAd`、`IFLYBannerAd`、`IFLYInterstitialAd`、`IFLYNativeFeedAd`、`IFLYRewardVideoAd`；统一请求配置 `IFLYAdRequestConfig` 和展示配置；重写媒体侧示例工程。 |
| 5.5.1 | 2026-04-14 | 修复 CAID 字段为空未过滤、CAID 缓存过期未生效问题。 |
| 5.4.x | 2025-09-24 ~ 2025-11-21 | 优化窗口获取、点击/回调、包体等旧版能力。 |
| 5.0.0 | 2025-03-07 | 开始支持 CocoaPods 接入。 |

## 环境要求

- iOS 11.0 及以上；`6.2.2` 正式二进制已重新通过最低版本门禁。
- Xcode 15.0 及以上（`Package.swift` 使用 Swift tools 5.9）；正式资产固定使用 Xcode 26.2 构建。
- 模型 A 继续交付 7 个静态 `xcframework`，每个必须包含 arm64 真机及 arm64/x86_64 模拟器切片。
- 统一入口头：`#import <IFLYADLib/IFLYADLib.h>`。

## CocoaPods 接入

> 下列 `6.2.3` 地址仅为发布准备，正式 tag/Release 与资产不存在；生产项目继续固定已发布的 `6.2.2`。

```ruby
source 'https://cdn.cocoapods.org/'

platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  # 默认 Full；也可改成 IFLYADLib/NativeFeed 等按格式 subspec。
  pod 'IFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.2.3/IFLYADLib.podspec'
end
```

CocoaPods 的 `Core` 会显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`；podspec 同时向 Pod target 和最终 aggregate/user target 传播 `-ObjC`。正式发布后，二进制从 `IFLYADLib-modelA-6.2.3.zip` 下载；不要用 `:git` 或 `:path` 绕过 Release zip。

可选 subspec：`Core`、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward`、`Full`（默认）。`Splash/Interstitial/Reward` 会自动带入 `VideoUI`。

## Swift Package Manager

正式 Release 创建后，在 Xcode「Add Packages」添加 `https://github.com/LJMcarryu/IFLYADLib_iOS` 并选择 `6.2.3`，按需勾选 `Core/Banner/Splash/Interstitial/NativeFeed/Reward/Full`。

- 消费方 App target 的 `OTHER_LDFLAGS` 必须添加 `-ObjC`。
- 7 个远程 `binaryTarget` 分别承载模块代码；Core、VideoUI、Reward 伞 target 自动投递三域资源和 `PrivacyInfo.xcprivacy`。
- `Package.swift` 的 7 个 checksum 已与冻结资产逐项核对；Release 创建后仍须复验匿名下载件。
- 通用 Release 固定为 10 个资产：7 个模块 zip、1 个合并 zip、`checksums.txt`、`binary-targets.remote.swift`。

## 权限与隐私配置

### 隐私清单（PrivacyInfo.xcprivacy）

SDK 自带 Apple 隐私清单，声明以下隐私特征。**接入方须在 App Store Connect 的隐私「营养标签」中如实合并声明这些数据收集，并据 `NSPrivacyTracking = YES` 提供 ATT 授权（见下）。**

- **追踪**：`NSPrivacyTracking = YES`；追踪域名：`voiceads.cn`、`bjimp.voiceads.cn`、`ai.voiceads.cn`、`msdk.voiceads.cn`、`sdk-adx.voiceads.cn`、`caid-api.adn-plus.com.cn`。
- **收集的数据类型**：设备 ID（DeviceID）、产品交互（ProductInteraction）、广告数据（AdvertisingData）——均关联用户且用于追踪，用途为第三方广告与分析；其他诊断数据（OtherDiagnosticData）——不关联、不用于追踪，用途为 App 功能与分析。
- **Required Reason API**：UserDefaults（`CA92.1`）、文件时间戳（`C617.1`）、系统启动时间（`35F9.1`）、磁盘可用空间（`E174.1`）。

CocoaPods 接入会经 `IFLYADLibCoreResources` 自动带入该清单；Swift Package Manager 会经所有 product 共同依赖的 `Core` 资源 target 自动带入。两种接入方式均无需媒体手工复制 `PrivacyInfo.xcprivacy`，但媒体仍须在 App Store Connect 隐私标签中合并披露 SDK 的实际行为。

### ATT 与 IDFA

iOS 14 及以上读取 IDFA 前必须先请求 App Tracking Transparency 权限。宿主 App 需要在 `Info.plist` 中添加：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>用于获取广告标识符 IDFA，以便请求和展示相关广告。</string>
```

建议在 App 进入前台后请求 ATT，再发起广告加载：

```objc
#import <AppTrackingTransparency/AppTrackingTransparency.h>

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (@available(iOS 14, *)) {
        if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                NSLog(@"ATT status: %ld", (long)status);
            }];
        }
    }
}
```

媒体侧如需显式传入真实 IDFA，可在授权后读取系统 IDFA，并写入 `IFLYAdRequestConfig.idfa`：

```objc
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

- (NSString *)currentIDFAString {
    if (@available(iOS 14, *)) {
        if (ATTrackingManager.trackingAuthorizationStatus != ATTrackingManagerAuthorizationStatusAuthorized) {
            return nil;
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (!ASIdentifierManager.sharedManager.advertisingTrackingEnabled) {
            return nil;
        }
#pragma clang diagnostic pop
    }

    NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
    if (idfa.length == 0 || [[idfa lowercaseString] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        return nil;
    }
    return idfa;
}
```

注意：

- `6.2.0` 起，iOS 14 及以上只有 ATT 状态为 `authorized` 时，SDK 才会读取、缓存或在普通请求与 S2S 请求中发送 IDFA；其他三种状态均按无 IDFA 处理。
- 未授权阶段通过 `IFLYAdRequestConfig.idfa` 或 `setParamValue:forKey:` 显式传入的 IDFA 会被立即丢弃，不会留到授权后复用。授权完成后如需显式 IDFA，必须重新读取并设置，再创建本次请求配置。
- 用户撤销 ATT 授权，或 App 回到前台时 SDK 发现状态已不再允许，既有 IDFA 缓存会被清除。媒体仍应在每次请求前按当前授权状态获取值。
- ATT 已允许不等于请求参数里一定有 IDFA。需要在授权完成后再读取系统 IDFA。
- 请勿在正式媒体 App 中使用固定测试 IDFA。
- 若用户在系统设置中关闭“允许 App 请求跟踪”，IDFA 仍可能为空或全零。

### 个性化与日志开关

在广告请求前设置 SDK 全局配置：

```objc
#import <IFLYADLib/IFLYADLib.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [IFLYAdConfig setPersonalizedEnabled:YES];
    [IFLYAdConfig setLogEnabled:NO];
    return YES;
}
```

`setPersonalizedEnabled:` 当前用于记录媒体侧个性化状态，不会自行改写 CAID、UA、设备信息、广告填充、展示、点击或监测行为，也不能替代 ATT。`6.2.0` 的 IDFA 授权门控独立生效，媒体不能用个性化开关绕过。正式上线建议关闭 SDK 日志，仅在问题排查时临时开启。

> 自 `6.0.11` 起，SDK 内部日志仅保留**关键节点 `error`**（请求 / 渲染 / 播放 / 监测失败等）；`info` / `warn` / 调试 / JSON 日志已整体移除——即便 `setLogEnabled:YES` 也只会输出 `error`（前缀 `[AdSDK]`），且不打印内部类名或裸 `NSError`。

## 统一请求配置

五类广告都可以使用 `IFLYAdRequestConfig` 传入请求期参数：

```objc
- (IFLYAdRequestConfig *)requestConfig {
    IFLYAdRequestConfig *config = [[IFLYAdRequestConfig alloc] init];
    config.settleType = @1;          // 0=固定价格，1=RTB
    config.bidFloor = @0.01;         // 单位 CNY 元/千次展示
    config.interactStatus = @1;      // 1=开启互动，2=关闭互动
    config.requestTimeout = @5;      // 秒
    config.appName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    config.appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    config.idfa = [self currentIDFAString];
    return config;
}
```

常用字段：

| 字段 | 说明 |
| --- | --- |
| `requestId` | 广告请求 ID；不设置时 SDK 自动生成。 |
| `settleType` | 交易方式：`0` 固定价格，`1` RTB。 |
| `bidFloor` | 竞价底价，单位 CNY 元/千次展示。 |
| `interactStatus` | 广告位互动状态：`1` 开启，`2` 关闭。 |
| `pmpDeals` | PMP 订单信息数组。 |
| `appName` / `appVersion` | 宿主 App 名称和版本号。 |
| `requestTimeout` | 请求超时时间，单位秒。 |
| `userAgent` | 自定义浏览器 User-Agent。 |
| `idfa` | 媒体侧显式传入的 IDFA；`6.2.0` 起 iOS 14+ 仅在 ATT `authorized` 时接受，未授权传入值会被丢弃且授权后须重新设置。 |
| `caidList` | 媒体侧显式传入的 CAID 列表。 |
| `deepLinkDisabled` | 是否禁用 DeepLink。 |

加载广告时调用：

```objc
[ad loadAdWithRequestConfig:[self requestConfig]];
```

若请求参数未被 `IFLYAdRequestConfig` 覆盖，可使用基类扩展方法：

```objc
[ad setParamValue:value forKey:IFLYAdKeyIDFA];
```

主流程建议优先使用 `IFLYAdRequestConfig`。

### 跳转兼容行为

`6.2.0` 起，SDK 不再以 `canOpenURL:` 预检 DeepLink 或自定义 scheme，而是直接调用系统 `openURL:options:completionHandler:`，根据 completion 判定成功；系统打开失败时仍按广告响应回退到允许的落地页。媒体无需为 SDK 维护 `LSApplicationQueriesSchemes` 探测清单，也不应根据广告响应 URL 自行探测已安装 App。

`IFLYAdRequestConfig.jumpDirectly` 与 `IFLYAdKeyJumpDirectly` 为兼容既有源码和二进制继续保留，但现在是 no-op：无论设置 `YES`、`NO` 还是不设置，都不改变上述统一跳转与 fallback 行为，字段也不会进入广告请求体。迁移时删除依赖该值控制跳转分支的业务逻辑；真正禁用 DeepLink 请继续使用 `deepLinkDisabled`。

## 开屏广告

典型流程：创建实例 -> 设置 `delegate` -> `loadAdWithRequestConfig:` -> 等待 `splashAdDidReady:` -> `showAdFromRootViewController:config:` -> `destroy`。

```objc
@interface SplashViewController () <IFLYSplashAdDelegate>
@property (nonatomic, strong) IFLYSplashAd *splashAd;
@end

- (void)loadSplash {
    IFLYSplashAd *ad = [[IFLYSplashAd alloc] initWithAdUnitId:@"YOUR_SPLASH_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.splashAd = ad;

    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)splashAdDidReady:(IFLYSplashAd *)ad {
    if (![ad isAdValid]) {
        return;
    }

    IFLYSplashAdConfig *config = [[IFLYSplashAdConfig alloc] init];
    config.traceDuration = 5;
    config.mediumBottomView = [self logoBottomView];
    config.muteOnStart = YES;

    [ad showAdFromRootViewController:self config:config];
}

- (void)splashAd:(IFLYSplashAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Splash failed: %d %@", error.errorCode, error.errorDescription);
}

- (void)dealloc {
    [self.splashAd destroy];
}
```

常用回调：

- `splashAdDidLoad:`：广告响应解析成功，素材可能仍在下载。
- `splashAdDidReady:`：主素材就绪，可展示。
- `splashAdDidShow:` / `splashAdDidExpose:` / `splashAdDidClick:`：展示、曝光、点击。
- `splashAdDidClose:` / `splashAdDidSkip:`：关闭或跳过。
- `splashAd:didFailWithError:`：加载或展示失败。

## Banner 广告

典型流程：创建实例 -> 设置 `delegate` -> `loadAdWithRequestConfig:` -> 等待 `bannerAdDidReady:` -> `showInView:`。

```objc
@interface BannerViewController () <IFLYBannerAdDelegate>
@property (nonatomic, strong) IFLYBannerAd *bannerAd;
@property (nonatomic, strong) UIView *bannerContainer;
@end

- (void)loadBanner {
    IFLYBannerAd *ad = [[IFLYBannerAd alloc] initWithAdUnitId:@"YOUR_BANNER_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.closeButtonVisible = YES;
    self.bannerAd = ad;

    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)bannerAdDidReady:(IFLYBannerAd *)ad {
    if ([ad isAdValid]) {
        [ad showInView:self.bannerContainer];
    }
}

- (void)bannerAd:(IFLYBannerAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Banner failed: %d %@", error.errorCode, error.errorDescription);
}
```

`showInView:` 需要传入有效容器视图。容器宽度必须大于 0；高度为 0 时 SDK 会按素材比例自适应。

## 插屏广告

典型流程：创建实例 -> 设置 `delegate` -> `loadAdWithRequestConfig:` -> 等待 `interstitialAdDidReady:` -> `showAdFromRootViewController:config:`。

```objc
@interface InterstitialViewController () <IFLYInterstitialAdDelegate>
@property (nonatomic, strong) IFLYInterstitialAd *interstitialAd;
@end

- (void)loadInterstitial {
    IFLYInterstitialAd *ad = [[IFLYInterstitialAd alloc] initWithAdUnitId:@"YOUR_INTERSTITIAL_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.interstitialAd = ad;

    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)interstitialAdDidReady:(IFLYInterstitialAd *)ad {
    if (![ad isAdValid]) {
        return;
    }

    IFLYInterstitialAdConfig *config = [[IFLYInterstitialAdConfig alloc] init];
    config.presentationStyle = IFLYInterstitialPresentationStyleHalfScreen;
    config.muteOnStart = YES;

    [ad showAdFromRootViewController:self config:config];
}

- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Interstitial failed: %d %@", error.errorCode, error.errorDescription);
}
```

`IFLYInterstitialPresentationStyleHalfScreen` 为半屏，`IFLYInterstitialPresentationStyleFullScreen` 为全屏。单个插屏实例为一次性使用，展示或关闭后请重新创建实例。

## 自渲染信息流广告

信息流广告由媒体根据 `ad.adData` 渲染 UI，再用 `IFLYNativeFeedAdViewBinder` 提交容器、点击视图、关闭按钮和视频承载视图。只有 NativeFeed 暴露 `adData`；其他四种广告格式只暴露通用 `bidInfo.price/dealId`。

`6.2.2` 由 Ad 内部托管展示会话和绑定资源。媒体必须提交的视图生命周期动作只有：

```objc
// Cell 配置或固定卡片渲染完成后，在主线程挂载。
IFLYAdError *error = nil;
BOOL attached = [ad attachWithViewBinder:binder error:&error];

// Cell 离屏、复用、切换普通内容，或重建 Binder 子视图前，按容器反注册。
[IFLYNativeFeedAd detachAdFromContainerView:containerView];
```

同一 Ad/同一容器重复 attach 为幂等成功；同一 Ad 可在有效期内串行迁移到新 Cell，同一容器可由新 Ad 在预检成功后原子接管。媒体不维护 Session、Binding、Binding 集合或“首次/复用”状态。

`6.2.3` 新增两个可选入口：

- 已知实例且业务保证单活动容器时，可调用 `-[IFLYNativeFeedAd detachFromCurrentContainer]`；常规 Cell 生命周期仍优先使用 `+[IFLYNativeFeedAd detachAdFromContainerView:]`，避免迟到回调误解绑。
- `clickViews` 默认仍必须位于 `containerView` 内。只有外部 CTA 与广告同生共灭且媒体无法改变视图层级时，才可显式设置 `binder.allowsExternalClickViews = YES`。SDK 仅接受同 window/scene 且归属可判定的同 Cell 或窄范围兄弟视图；共享、固定悬浮、广告离屏后仍可点击或归属不明会失败关闭。attach 时能判定的错误直接返回；运行中失效通过 delegate `nativeFeedAd:didRejectClickWithError:` 通知，错误为 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）。

固定卡片的最小生命周期：

```objc
@interface NativeFeedViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UIView *adContainer;
@end

- (void)loadNativeFeed {
    [self clearNativeFeed];

    IFLYNativeFeedAd *ad =
        [[IFLYNativeFeedAd alloc] initWithAdUnitId:@"YOUR_NATIVE_FEED_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    self.nativeAd = ad;
    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd || !ad.adData.isMaterialComplete) {
        return;
    }

    // 先根据 ad.adData 完成标题、图片/视频容器、CTA 等媒体 UI，再组装 Binder。
    IFLYNativeFeedAdViewBinder *binder = [self binderForAdData:ad.adData];
    IFLYAdError *error = nil;
    if (![ad attachWithViewBinder:binder error:&error]) {
        NSLog(@"Native attach failed: %d %@", error.errorCode, error.errorDescription);
        [self clearNativeFeed];
    }
}

- (void)clearNativeFeed {
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainer];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil; // 最后一个 Ad 强引用释放后，SDK 自动进入资源终态。
}

- (void)terminateNativeFeedEarly {
    IFLYNativeFeedAd *ad = self.nativeAd;
    [self clearNativeFeed];
    [ad destroy]; // 可选：仍希望持有 Ad 时主动提前取消/终止。
}
```

列表接入的数据层只持 Ad，Cell 只持媒体 UI：

```objc
@interface NativeFeedItem : NSObject
@property (nonatomic, copy) NSString *itemID; // 稳定业务 ID，不以 indexPath 充当身份
@property (nonatomic, strong) IFLYNativeFeedAd *ad;
@end

@implementation NativeFeedCell

- (BOOL)configureWithAd:(IFLYNativeFeedAd *)ad error:(IFLYAdError **)error {
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainerView];
    [self renderAdData:ad.adData];

    IFLYNativeFeedAdViewBinder *binder = [self binderForAdData:ad.adData];
    if (![ad attachWithViewBinder:binder error:error]) {
        [IFLYNativeFeedAd detachAdFromContainerView:self.adContainerView];
        [self resetAdPresentation];
        return NO;
    }
    return YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainerView];
    [self resetAdPresentation];
}

@end

- (void)didEndDisplayingCell:(NativeFeedCell *)cell {
    // 不依赖可能已过时的 indexPath；只反注册回调 Cell 自己的容器。
    [IFLYNativeFeedAd detachAdFromContainerView:cell.adContainerView];
    [cell resetAdPresentation];
}

- (void)evictItem:(NativeFeedItem *)item visibleCell:(NativeFeedCell *)cell {
    [IFLYNativeFeedAd detachAdFromContainerView:cell.adContainerView];
    [cell resetAdPresentation];
    item.ad.delegate = nil;
    item.ad = nil; // 正常永久淘汰不要求 destroy。
}
```

生命周期边界：

| 时机 | 媒体动作 | 结果 |
| --- | --- | --- |
| `nativeFeedAdDidLoad:` | 数据项保存 Ad，渲染 UI | 未挂载视图 |
| Cell 配置/进屏 | 组 Binder，主线程调用 Ad 级 attach | SDK 完成幂等、迁移或容器接管 |
| Cell 离屏/`prepareForReuse`/切普通内容 | 按 `containerView` detach，再清理媒体 UI | 只反注册视图，同一 Ad 可回屏恢复 |
| 条目暂时滑出 | 继续持有同一 Ad，不调用 `destroy` | 回屏直接用原 Ad attach |
| 条目永久删除/页面退出 | detach 已知容器，`delegate=nil`，释放 Ad | 最后引用释放时自动终止并清理 |
| 主动提前终止 | 可选调用 `destroy` | 即使仍持有 Ad，也立即失去恢复能力 |

素材与 Binder 约束：

- `materialType/templateId`：`Unknown=0`、`SingleImage=1`、`Video=2`、`MultipleImages=3`，推导优先级为 `video → img1+img2 → img/icon → Unknown`；多图为两至三张。
- `interactionType` 为 `Redirect/Download` 时传可点击视图；`Exposure/Unknown` 必须显式传 `@[]`，因为 `clickViews == nil` 会回退为整容器可点。
- 视频素材只把普通 `UIView` 作为 `videoView` 交给 SDK，媒体不自行创建 `AVPlayer`。
- 如果重建 Binder 引用的子视图，必须先 detach 旧容器；新 attach 失败时清空或恢复媒体 UI。
- 曝光前迁移会在新容器重新累计连续可见 `500ms`；曝光后回屏不重复曝光。视频进度与播放意图随同一 Ad 保留，`pausePlay/stopPlay` 后只有显式 `resumePlay/startPlay` 才恢复。
- TTL 或视频截止时间到达不会中途强拆当前活动容器；正常 detach 后若再次 attach 失败，应释放旧 Ad 并请求新广告。
- 媒体不要根据落地页、DeepLink 或下载 URL 自行跳转；点击监测与跳转由 SDK Binder 链路统一处理。

### NativeFeed 媒体摇一摇统一接口

`6.2.0` 的 `IFLYNativeFeedAd` 新增统一公开方法：

```objc
IFLYAdError *error = nil;
BOOL accepted = [ad reportMediaShakeTriggeredWithError:&error];
```

通用模型 A 不启用媒体摇一摇被动采样能力，调用固定返回 `NO`，`error.errorCode` 为 `IFLYAdErrorCodeNativeFeedMediaShakeUnavailable`（`71512`）；不会订阅传感器、产生点击或执行跳转。该方法仅用于保持不同分发变体的公开 API 一致，通用接入方不要把它当作普通点击或 SDK 自主摇一摇入口。

常用只读字段包括：`creativeId`、`title`、`desc`、`content`、`ctaText`、`brand`、`appName`、`adSourceMark`、`adSourceIconURL`、`icon`、`mainImage`、`imageList`、`videoURL`、`videoCoverURL`、`videoDuration`、`videoSize`、`targetURL`、`deeplinkURL`、`marketURL`、`downloadURL`、`packageName`、`closeIconURL`。`IFLYAdRequestConfig.appName` 表示媒体宿主 App 名称，`IFLYNativeFeedAdData.appName` 才是广告响应中的下载类应用名称。

## 激励视频广告

典型流程：创建实例 -> 设置 `delegate` -> `loadAdWithRequestConfig:` -> 等待 `rewardVideoAdDidReady:` -> `showAdFromRootViewController:config:` -> 监听发奖回调。

```objc
@interface RewardViewController () <IFLYRewardVideoAdDelegate>
@property (nonatomic, strong) IFLYRewardVideoAd *rewardAd;
@end

- (void)loadRewardVideo {
    IFLYRewardVideoAd *ad = [[IFLYRewardVideoAd alloc] initWithAdUnitId:@"YOUR_REWARD_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.rewardAd = ad;

    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)rewardVideoAdDidReady:(IFLYRewardVideoAd *)ad {
    if (![ad isAdValid]) {
        return;
    }

    IFLYRewardVideoAdConfig *config = [[IFLYRewardVideoAdConfig alloc] init];
    config.muteOnStart = YES;

    [ad showAdFromRootViewController:self config:config];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didRewardEffective:(NSDictionary *)info {
    NSLog(@"Reward effective: %@", info);
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Reward failed: %d %@", error.errorCode, error.errorDescription);
}
```

激励发放以 `rewardVideoAd:didRewardEffective:` 为准。展示关闭回调 `rewardVideoAdDidClose:` 不能等同于发奖。

## S2S 服务端竞价

SDK 支持生成 S2S SDK token：

```objc
NSError *error = nil;
NSString *sdkToken = [IFLYAdSDK getSdkTokenWithAdUnitId:@"YOUR_AD_UNIT_ID" error:&error];
if (!sdkToken) {
    NSLog(@"getSdkToken failed: %@", error);
}
```

媒体服务端完成竞价并返回 `rspToken` 后，客户端可使用：

```objc
[splashAd loadAdWithServerBiddingToken:rspToken];
[bannerAd loadAdWithServerBiddingToken:rspToken];
[interstitialAd loadAdWithServerBiddingToken:rspToken];
[nativeAd loadAdWithServerBiddingToken:rspToken];
[rewardAd loadAdWithServerBiddingToken:rspToken];
```

`rspToken` 为空、无效、过期、重复使用或未竞胜时，会通过对应广告类型的失败回调返回错误。

## Header Bidding 结果通知

广告加载成功后，五种广告格式统一从只读 `bidInfo` 获取竞价信息：

```objc
NSNumber *price = ad.bidInfo.price;
NSString *dealId = ad.bidInfo.dealId;

// 仅在双方竞价协议明确要求客户端通知时调用。
[ad sendBidResultWithType:IFLYAdBidResultTypeWin reason:@"win"];
// 竞败示例：
// [ad sendBidResultWithType:IFLYAdBidResultTypeLoseBidLower reason:@"loss"];
```

`IFLYAdBidInfo` 对外严格只包含 `price` 和 `dealId`，二者均可能为 `nil`；S2S Load 成功时 `price` 固定为 `0`。SDK 不公开竞价通知 URL 或“是否存在通知 URL”字段；没有可用通知地址时，`sendBidResultWithType:reason:` 由 SDK 内部安全忽略。

`sendBidResultWithType:reason:` 是 SDK 响应内的竞价通知接口，不等同于媒体服务端 S2S 流程中的 `wurl/lurl`。生产 S2S 默认由媒体服务端负责 Bid、统一比价和 `wurl/lurl`，客户端仅接收竞胜后的 `rspToken` 并调用 `loadAdWithServerBiddingToken:`。具体是否还需要客户端通知、通知时机和原因字段，以双方确认的协议为准。

## 错误处理

所有广告类型都会通过 `IFLYAdError` 返回失败信息：

```objc
- (void)splashAd:(IFLYSplashAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"errorCode=%d desc=%@", error.errorCode, error.errorDescription);
}
```

常见问题：

| 现象 | 排查建议 |
| --- | --- |
| `pod install` 找不到 `6.2.2` | 确认使用不可变 `6.2.2` tag、网络可访问 Release 合并 zip，并清理旧 CocoaPods 缓存；不要把 `main` 当作版本依赖。 |
| 模拟器无法运行 | 确认已固定到正式 `6.2.2` tag、下载本版 Release zip，且本地未复用旧缓存；正式模型 A 资产必须含模拟器切片。 |
| IDFA 为空 | 确认 `NSUserTrackingUsageDescription` 已配置、用户已允许 ATT，并在授权完成后重新读取和设置 IDFA；未授权阶段预置的显式值已被丢弃，不能自动延续到授权后。过滤全零 UUID。 |
| `reportMediaShakeTriggeredWithError:` 返回 `71512` | 通用模型 A 未启用媒体摇一摇上报能力，这是预期结果；不要重试或用该方法代替普通点击。 |
| `isAdValid` 为 NO | 确认已收到 `DidReady` 回调；广告未过期、未展示过、实例未销毁。 |
| NativeFeed 回屏 attach 返回 `71506` | 原 Ad 已过期；不强拆尚在展示的容器。容器正常 detach 后，释放旧 Ad 并请求新广告。 |
| 展示失败 | 确认 `rootViewController` 已在 window 上，当前没有正在 present 的控制器。 |
| Banner 不展示 | 确认容器宽度大于 0，布局已完成后再调用 `showInView:`。 |
| 信息流绑定失败 | 确认 `containerView` 非空且在 window 层级中；仅 `Redirect/Download` 传非空点击视图，`Exposure/Unknown` 传 `@[]`；视频素材传普通 `videoView`；绑定在主线程执行。 |

## 示例工程说明

`IFLYADLibSimple` 是面向媒体接入方的基础示例，仅使用公开 API：

- [AppDelegate.m](./IFLYADLibSimple/IFLYADLibSimple/AppDelegate.m)：SDK 全局配置与 ATT 请求。
- [IFLYADUtil.m](./IFLYADLibSimple/IFLYADLibSimple/Supporting%20Files/IFLYADUtil.m)：统一请求配置、真实 IDFA 读取、日志工具。
- [biz/splash](./IFLYADLibSimple/IFLYADLibSimple/biz/splash)：开屏广告。
- [biz/banner](./IFLYADLibSimple/IFLYADLibSimple/biz/banner)：Banner 广告。
- [biz/interstitial](./IFLYADLibSimple/IFLYADLibSimple/biz/interstitial)：插屏广告。
- [biz/native](./IFLYADLibSimple/IFLYADLibSimple/biz/native)：自渲染信息流固定卡片与 SDK 托管挂载列表复用。
- [biz/reward](./IFLYADLibSimple/IFLYADLibSimple/biz/reward)：激励视频广告。

运行前请先执行：

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

> 说明：示例 Podfile 已固定到 `6.2.2` tag；默认 `Full`（五种广告全开），工程最低版本为 iOS 11.0。NativeFeed 固定卡片与列表页均使用 SDK 托管挂载。

## 接入建议

- 广告对象请由页面或管理对象强持有，避免请求过程中提前释放。
- `delegate` 回调均按广告实例生命周期触发。NativeFeed 页面退出时先按容器 detach、置空 delegate 并释放 Ad；`destroy` 只在需要主动提前终止时调用。
- 展示类广告通常在 `DidReady` 后再展示，不要在 `DidLoad` 里直接展示。
- 单个广告实例通常为一次性消费，展示/关闭/销毁后请重新创建实例。
- NativeFeed 只允许同一稳定逻辑条目在复用 Cell 间串行迁移，不能把同一 Ad 当作另一条广告使用。
- 正式上线前请替换为平台分配的真实广告位 ID，并关闭排查用日志。

## 从 6.2.2 升级到 6.2.3

`6.2.3` 不改变 6.2.2 的 SDK 托管 attach/容器 detach 主路径。只有确需容器外 CTA 时才开启 `allowsExternalClickViews`，并处理 `nativeFeedAd:didRejectClickWithError:`；无法保证 CTA 与广告同生共灭、同 window/scene 且归属唯一时，应调整媒体视图层级而不是绕过门禁。固定单容器页面可按需改用 `detachFromCurrentContainer`。

## 从 6.2.1 升级到 6.2.2（历史）

`6.2.2` 是 NativeFeed 不兼容公开 API 调整，不能只替换二进制：

| `6.2.1` | `6.2.2` | 迁移动作 |
| --- | --- | --- |
| 数据层持 `Ad + DisplaySession` | 数据层只持 Ad | 删除 DisplaySession 属性和创建/结束逻辑。 |
| Cell 持 Binding | Cell 不持 SDK 生命周期对象 | 删除 Binding 属性、集合和首次/复用标记。 |
| Session 级 attach，Binding 级 detach | Ad 级 `attachWithViewBinder:error:`，容器级 `detachAdFromContainerView:` | 覆盖进屏、离屏、复用和切换普通内容路径。 |
| 永久淘汰必须 end + destroy | detach 已知容器后释放最后一个 Ad 引用 | `destroy` 只保留为可选的主动提前终止。 |

升级时必须清理 `6.2.1` 头文件/二进制缓存并用 `6.2.2` 重新编译宿主。验收覆盖曝光前/后回屏、乱序 detach、同容器新 Ad 接管、视频进度/播放意图、过期边界和最后引用释放。

> 以下章节只记录历史版本迁移，不是 `6.2.2` 现行接入方式。

## 从 6.2.0 升级到 6.2.1（历史）

`6.2.1` 新增 NativeFeed DisplaySession 列表契约；既有固定卡片代码可保持一次性接口不变。需要列表恢复能力时按下表迁移：

| `6.2.0` | `6.2.1` | 迁移动作 |
| --- | --- | --- |
| Cell 复用只能销毁旧 Ad 并请求新广告 | 同一稳定逻辑条目可跨 Cell 串行恢复原广告 | 数据层按稳定 item ID 持有 `Ad + DisplaySession`，不要按 indexPath 保存。 |
| Cell 持有或间接操作 Ad | Cell 只持 `IFLYNativeFeedAdBinding` | `willDisplay` attach；`didEndDisplaying` / `prepareForReuse` 对具体 Binding 调用 `detach`。 |
| 解绑与淘汰都走 `unbindAd → destroy` | 普通离屏只 detach，逻辑条目淘汰才结束会话 | 淘汰严格执行 `endDisplaySession → delegate=nil → destroy`。 |
| 到期后直接清空当前广告 UI | 活动 Binding 到期不强拆，detach 后不可恢复 | `session.valid=NO && (binding.active || session.attached)` 时保持当前展示；正常 detach 后请求新广告。 |

升级验收至少覆盖：同一条目曝光前/曝光后滚出回屏、快速复用导致的 `willDisplay(new) → didEnd(old)` 乱序、旧 Cell 迟到 detach、暂停/停止视频后的回屏播放意图、活动 Binding 的 TTL 边界，以及条目永久淘汰。

## 从 6.1.0 升级到 6.2.0（历史）

`6.2.0` 的主要变化是全渠道共享的合规门控和跳转语义收敛，并新增一个统一公开方法。现有五种广告加载与展示入口不变，但接入方必须重新编译并检查以下行为：

| `6.1.0` | `6.2.0` | 迁移动作 |
| --- | --- | --- |
| iOS 14+ 未对所有 IDFA 来源实施统一的 ATT `authorized` 门控 | 普通请求与 S2S 请求共用门控；未授权不读取、不缓存、不发送 IDFA，撤权后清缓存 | 保证 ATT 完成后再创建请求配置；不要在授权前预置真实或测试 IDFA。 |
| 未授权阶段显式设置的 IDFA 可能留在请求配置中 | `IFLYAdRequestConfig.idfa` 和 `setParamValue:forKey:` 的未授权值会被丢弃 | 授权成功后重新读取系统 IDFA 并重新设置；不能指望授权前的值延续生效。 |
| DeepLink / 自定义 scheme 先经 `canOpenURL:` 预检 | 直接调用 `openURL:options:completionHandler:`，按系统 completion 决定成功或落地页 fallback | 删除依赖 `LSApplicationQueriesSchemes` 探测结果的业务判断，按 SDK 跳转回调验证成功与 fallback。 |
| `jumpDirectly` 可能参与跳转分支 | `jumpDirectly` 仅兼容保留，设置值不改变行为且不进入请求体 | 删除对该字段的逻辑依赖；禁用 DeepLink 使用 `deepLinkDisabled`。 |
| 通用 `IFLYNativeFeedAd` 无媒体摇一摇统一方法 | 公开 `reportMediaShakeTriggeredWithError:`，但通用模型 A 固定返回 `NO` / `71512` | 如共用多变体代码，可处理能力不可用错误；通用接入不要调用或失败重试。 |
| 系统广告框架依赖由产物间接表达 | CocoaPods `Core` 显式链接 `AdSupport`、弱链接 `AppTrackingTransparency` | 不要在宿主侧把 ATT 改为强链接；在 iOS 11、iOS 13 与 iOS 14+ 分别做启动和授权回归。 |

升级验收至少覆盖：

- iOS 14+ 的 `notDetermined`、`denied`、`restricted` 和 `authorized` 四种 ATT 状态，以及授权后撤销并回到前台；普通请求和 S2S 请求不得出现门控差异。
- 授权前显式设置 IDFA、授权后不重设、授权后重新设置三条路径；只有最后一条可按当前系统值发送。
- 自定义 scheme 成功与失败、Universal Link 失败、危险 scheme 拒绝、HTTP(S) 落地页 fallback；宿主不依赖 `canOpenURL:` 预检。
- `jumpDirectly=YES`、`NO` 与未设置三种配置的跳转结果一致；`deepLinkDisabled` 仍按原语义生效。
- 通用模型 A 调用 `reportMediaShakeTriggeredWithError:` 稳定返回 `71512`，且不产生传感器、点击或跳转副作用。
- CocoaPods / SPM 依赖更新到 `6.2.0`，清除旧二进制缓存后使用正式 Release 资产重新编译。

## 从 6.0.14 升级到 6.1.0（历史）

`6.1.0` 包含公开 API 的破坏性调整，不能只替换二进制。升级工程必须按下表修改并重新编译：

| `6.0.14` | `6.1.0` | 迁移动作 |
| --- | --- | --- |
| `data.actionText` | `data.ctaText` | 使用服务端原始 CTA；兜底文案由媒体 UI 决定。 |
| `NSNumber *data.templateId` | `IFLYNativeFeedAdMaterialType data.templateId` | 改用枚举名，不读取 `integerValue` 或写死旧数值。 |
| `ThreeImages=2`，固定三张 | `Video=2`、`MultipleImages=3`，两至三张 | 多图要求 `image1+image2`，`image3` 可选。 |
| `data.rawAdData` | 已移除 | 仅使用 `IFLYNativeFeedAdData` 公开白名单字段。 |
| `data.sponsored` | 已移除 | 按 UI 语义选择 `brand` 或 `adSourceMark`，二者都不是旧字段的一一替代。 |
| `data.ecpm` / `[ad ecpm]` | `ad.bidInfo.price` | 通用竞价信息同时可读取 `ad.bidInfo.dealId`。 |
| `ad.bidInfo.winNoticeAvailable` | 已移除 | 不探测通知 URL；仅按双方协议调用 `sendBidResultWithType:reason:`，无地址时 SDK 内部安全忽略。 |
| 基类创意 ID | 已移除 | 只有 NativeFeed 可读取 `ad.adData.creativeId`。 |
| 无公开广告应用名称 | `data.appName` | 对应响应 `app_name`；仅 NativeFeed 暴露，空白值归一为 `nil`。 |

升级验收至少覆盖：

- 单图、视频、两图、三图和 `Unknown` 均按新 `materialType/templateId` 选择正确布局。
- `Exposure/Unknown` 隐藏 CTA 并显式使用空 `clickViews`；`Redirect/Download` 传入有效点击区域。
- 视频只把普通 `UIView` 交给 Binder；start/resume 隐藏封面，pause/finish/fail 恢复封面。
- 页面退出、Cell 复用和替换广告时执行 `unbindAd → delegate=nil → destroy`，不重复绑定已消费实例。
- CocoaPods / SPM 依赖更新到 `6.1.0`，最终使用正式 Release 产物重新编译，不复用 `6.0.14` 缓存。

## 问题反馈与支持

- 本仓库是 IFLYADLib 的**对外分发与接入文档仓**（不含 SDK 源码），**不接受外部代码 PR**。
- **使用问题 / Bug**：请在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交，并附 SDK 版本、iOS / Xcode 版本、接入方式（CocoaPods / SPM）、复现步骤与日志。
- **安全漏洞**：请勿在公开 Issue 披露，按 [SECURITY.md](./SECURITY.md) 私密上报。
- **商务合作 / 广告位申请**：请通过讯飞广告官方渠道联系。
