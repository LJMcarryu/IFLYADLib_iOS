# IFLYADLib iOS SDK 接入说明

`IFLYADLib` 是讯飞广告 iOS SDK，提供开屏、Banner、插屏、自渲染信息流、激励视频等广告能力。

当前文档覆盖 `IFLYADLib 6.1.0`（推荐，按广告形式可组合并最低支持 iOS 11）与 `6.0.0`（历史单包 Full）；示例工程见 [IFLYADLibSimple](./IFLYADLibSimple)。

> 文档以中文为主。如需用英文反馈问题，请直接在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交。

仓库地址：[https://github.com/LJMcarryu/IFLYADLib_iOS](https://github.com/LJMcarryu/IFLYADLib_iOS)

## 版本记录

| 版本 | 日期 | 说明 |
| --- | --- | --- |
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

- iOS 11.0 及以上（`6.1.0` 的真机与模拟器二进制均按该最低版本重新构建；历史 `6.0.13` 及更早二进制不追溯扩大支持范围）。
- Xcode 15.0 及以上（`Package.swift` 使用 Swift tools 5.9）；6.1.0 正式二进制使用 Xcode 26.2 构建。
- 交付形态：`6.1.0` 为各模块 `xcframework`（含 **arm64 真机 + arm64/x86_64 模拟器**切片，可在模拟器调试，见「按广告形式可组合接入（模型 A）」）；`6.0.0` 为单一 `IFLYADLib.framework`（仅真机 arm64、不含模拟器切片）。
- 统一入口头文件：`#import <IFLYADLib/IFLYADLib.h>`。

## CocoaPods 接入

> **推荐使用最新 `6.1.0`**（按广告形式可组合、含模拟器切片、最低支持 iOS 11）——见「[按广告形式可组合接入（模型 A）](#按广告形式可组合接入模型-a)」。下面的 `6.0.0` 为历史单包 `Full`（仅真机 arm64）。

`6.1.0` 当前尚未发布到 CocoaPods trunk，请使用 tag 固定的 `:podspec` 直连本仓 Release；不要指向 `main` 分支。

```ruby
source 'https://cdn.cocoapods.org/'

platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  pod 'IFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.1.0/IFLYADLib.podspec'
end
```

安装：

```bash
pod install
```

示例工程的 Podfile 已固定到 `IFLYADLib 6.1.0`：

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

## 按广告形式可组合接入（模型 A）

`6.0.1` 起支持「按广告形式可组合」接入：`Core` 必选，`Banner` / `Splash` / `Interstitial` / `NativeFeed` / `Reward` 各格式按需选用，`VideoUI` 由依赖图自动带入。只接入需要的格式可减小包体。当前 `6.1.0` 产物为各模块独立 `xcframework`（含 device + simulator 切片），最低支持 iOS 11.0。

> **资源依赖**：CocoaPods 经 `resource_bundles`、Swift Package Manager 经 `Core` / `VideoUI` / `Reward` 伞 target 的受版本控制资源规则自动带入所需资源。所有 SwiftPM product 都经 `Core` 依赖闭包携带 `PrivacyInfo.xcprivacy`。

> `Full`（默认）等价于五种广告全开，行为与 6.0.0 单包一致。

### CocoaPods（可组合 subspec）

> `6.1.0` 尚未进入 CocoaPods trunk。当前请使用下方 `:podspec` 直连；待 trunk 发布完成后，才可改用标准版本号写法。

**当前接入方式（免 trunk）：**

```ruby
platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  pod 'IFLYADLib/Splash',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.1.0/IFLYADLib.podspec'
end
```

**发布到 trunk 后的标准写法：**

```ruby
platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  # 例：只接开屏 + Banner（VideoUI/Core 自动带入）
  pod 'IFLYADLib/Splash', '6.1.0'
  pod 'IFLYADLib/Banner', '6.1.0'

  # 或全量：
  # pod 'IFLYADLib', '6.1.0'
end
```

> 二进制照常从本仓库 Release 的合并 zip 下载，subspec 选择照常生效；URL 请钉死到 tag `6.1.0`（勿指向分支）。**不要改用 `:git` / `:path`** —— 二进制在 Release zip、不在 git 仓代码里，这两种外部源会跳过 zip 下载导致缺 `xcframework`。

可选 subspec：`Core`（必选，自动带入）、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward`、`Full`（默认）。其中 `Splash` / `Interstitial` / `Reward` 会自动带入 `VideoUI`。

> **导入头文件**：统一用伞头 `#import <IFLYADLib/IFLYADLib.h>` 即可——`6.0.3` 起伞头用 `__has_include` 守卫，在全量 `Full` 与按格式部分安装下都能正常编译（自动只导入已安装格式的入口类）。也可按需直接 import 具体格式头（如 `<IFLYADLib/IFLYSplashAd.h>`）。注：`6.0.2` 及更早版本，部分安装须用具体格式头、不能用伞头。

### Swift Package Manager

在 Xcode「Add Packages」填入仓库地址 `https://github.com/LJMcarryu/IFLYADLib_iOS`，选 `6.1.0`，按需勾选 product：`Core` / `Banner` / `Splash` / `Interstitial` / `NativeFeed` / `Reward` / `Full`。

> ⚠️ **SPM 接入方需在 App target 的 Other Linker Flags（`OTHER_LDFLAGS`）添加 `-ObjC`**，否则静态库中的 Objective-C category 可能被链接器剥离。CocoaPods 的 podspec 已内置 `-ObjC`，无需手动添加。
>
> **SPM 资源自动投递**：7 个远程 `binaryTarget` 只承载代码；同一 Package 中的 `Core` / `VideoUI` / `Reward` 伞 target 分别投递交互、播放器和激励资源。`Banner` / `NativeFeed` 自动带入 Core，`Splash` / `Interstitial` 自动带入 Core + VideoUI，`Reward` 自动带入三域，媒体无需手工复制 `.bundle`。

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

`setPersonalizedEnabled:` 当前用于记录媒体侧个性化状态，不会自动过滤或改写 IDFA、CAID、UA、设备信息、广告填充、展示、点击或监测行为。正式上线建议关闭 SDK 日志，仅在问题排查时临时开启。

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
| `idfa` | 媒体侧显式传入的 IDFA。 |
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

信息流广告由媒体侧根据 `ad.adData` 自行渲染 UI，再通过 `IFLYNativeFeedAdViewBinder` 把容器、点击视图、关闭按钮和视频承载视图交给 SDK。只有 NativeFeed 暴露 `adData`；其他四种广告格式只暴露通用 `bidInfo.price/dealId`。

```objc
@interface NativeFeedViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSArray<UIView *> *multipleImageViews; // 当前广告实际渲染的 2 或 3 个视图
@property (nonatomic, strong) UIView *videoCoverView;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

- (void)disposeNativeFeed {
    IFLYNativeFeedAd *ad = self.nativeAd;
    self.nativeAd = nil;
    [ad unbindAd];
    ad.delegate = nil;
    [ad destroy];
}

- (void)loadNativeFeed {
    [self disposeNativeFeed];

    IFLYNativeFeedAd *ad = [[IFLYNativeFeedAd alloc] initWithAdUnitId:@"YOUR_NATIVE_FEED_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    self.nativeAd = ad;

    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    IFLYNativeFeedAdData *data = ad.adData;
    if (!data || !data.isMaterialComplete ||
        data.materialType == IFLYNativeFeedAdMaterialTypeUnknown) {
        [self disposeNativeFeed];
        return;
    }

    self.titleLabel.text = data.title ?: data.appName ?: data.brand ?: @"";
    self.descLabel.text = data.desc ?: data.content;
    BOOL clickable =
        data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
        data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    self.ctaButton.hidden = !clickable;
    [self.ctaButton setTitle:(clickable ? (data.ctaText ?: @"查看详情") : nil)
                    forState:UIControlStateNormal];

    // 先按 data.materialType 渲染媒体 UI：
    // SingleImage 使用 data.mainImage/data.icon；
    // MultipleImages 遍历 data.imageList（2 或 3 张）；
    // Video 只提供普通 UIView 作为 videoView，不自行创建 AVPlayer。
    // 图片为异步下载时，须在下载完成并确认 ad 仍为当前实例后再执行下方 Binder 代码。

    BOOL isVideo = data.materialType == IFLYNativeFeedAdMaterialTypeVideo;
    NSArray<UIView *> *mediaViews =
        data.materialType == IFLYNativeFeedAdMaterialTypeMultipleImages
            ? self.multipleImageViews
            : @[isVideo ? self.videoView : self.imageView];
    NSMutableArray<UIView *> *renderViews = [mediaViews mutableCopy];
    [renderViews addObjectsFromArray:@[self.titleLabel, self.descLabel, self.closeButton]];
    if (clickable) [renderViews addObject:self.ctaButton];

    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    binder.renderViews = renderViews.copy;
    binder.clickViews = clickable ? @[self.adContainer] : @[];
    binder.closeView = self.closeButton;
    binder.videoView = isVideo ? self.videoView : nil;
    binder.titleView = self.titleLabel;
    binder.descView = self.descLabel;
    binder.imageView = isVideo ? nil : mediaViews.firstObject;
    binder.ctaView = clickable ? self.ctaButton : nil;

    IFLYAdError *error = nil;
    if (![ad bindAdWithViewBinder:binder error:&error]) {
        NSLog(@"Native bind failed: %d %@", error.errorCode, error.errorDescription);
        [self disposeNativeFeed];
    }
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    if (ad == self.nativeAd && ad.hasVideoTemplate) {
        [ad startPlay];
    }
}

- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad {
    if (ad == self.nativeAd) {
        [self disposeNativeFeed];
        // 同时清空或移除媒体自己创建的广告 UI。
    }
}

- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad {
    if (ad == self.nativeAd) self.videoCoverView.hidden = YES;
}

- (void)nativeFeedAdDidPausePlay:(IFLYNativeFeedAd *)ad {
    if (ad == self.nativeAd) self.videoCoverView.hidden = NO;
}

- (void)nativeFeedAdDidResumePlay:(IFLYNativeFeedAd *)ad {
    if (ad == self.nativeAd) self.videoCoverView.hidden = YES;
}

- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad {
    if (ad == self.nativeAd) self.videoCoverView.hidden = NO;
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToPlayWithError:(IFLYAdError *)error {
    if (ad == self.nativeAd) self.videoCoverView.hidden = NO;
}
```

素材类型和最低要求：

| `materialType` / `templateId` | 值 | 最低要求 |
| --- | ---: | --- |
| `IFLYNativeFeedAdMaterialTypeUnknown` | 0 | 无可用视频、多图、主图或图标；不渲染、不绑定。 |
| `IFLYNativeFeedAdMaterialTypeSingleImage` | 1 | 有效 `img`，缺失时允许 `icon` 兜底。 |
| `IFLYNativeFeedAdMaterialTypeVideo` | 2 | `videoURL` 有效；封面可选。 |
| `IFLYNativeFeedAdMaterialTypeMultipleImages` | 3 | `image1`、`image2` 有效；`image3` 可选。 |

推导优先级固定为 `video → img1+img2 → img/icon → Unknown`。不要读取服务端原始模板号，也不要写死旧枚举数值。

行为与 Binder 约束：

- `action_type=1 → Exposure`、`2 → Redirect`、`3/4 → Download`；其他值（含当前不支持的 `9`）归一为 `Unknown`。
- `interact=1 → Click`、`2 → ClickAndShake`、`3 → ClickAndSlide`、`4 → ClickShakeAndSlide`；其他值（含当前不支持的 `5/6/7`）归一为 `Unknown`。
- `interactionType` 为 `Redirect` / `Download` 时显式传可点击视图；`Exposure` / `Unknown` 必须显式传 `@[]`。`clickViews == nil` 会回退为整个 `containerView` 可点。
- CTA 只在 `Redirect` / `Download` 时显示，使用服务端原始 `ctaText`；`Exposure` / `Unknown` 不得兜底成可点击。
- `interactType` 可识别点击、摇一摇和上滑组合，但当前 NativeFeed 不安装上滑手势；不要展示不可执行的“上滑查看”提示。
- 媒体不要根据 `deeplinkURL/targetURL/marketURL/downloadURL` 自行调用 `openURL`；点击监测、DeepLink、落地页和下载兜底均由 Binder 后的 SDK 点击链路处理。
- 视频素材必须传普通 `UIView` 作为 `videoView`。SDK 只添加和移除自己的播放器宿主并负责播放监测；媒体不得自行创建 `AVPlayer`。
- `UITableViewCell` / `UICollectionViewCell` 复用、替换广告或页面退出前按 `unbindAd → delegate=nil → destroy` 清理。绑定成功即视为实例已消费，解绑后也不能再次绑定。

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
| `pod install` 找不到 `6.1.0` | `6.1.0` 尚未进入 CocoaPods trunk；使用 `:podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.1.0/IFLYADLib.podspec'` 直连本仓 Release。 |
| 模拟器无法运行 | `6.1.0`（模型 A）含模拟器切片，可直接在模拟器调试；仅旧 `6.0.0` 单包不含模拟器切片需真机。 |
| IDFA 为空 | 确认 `NSUserTrackingUsageDescription` 已配置；用户已允许 ATT；在授权完成后再读取 `ASIdentifierManager`；过滤全零 UUID。 |
| `isAdValid` 为 NO | 确认已收到 `DidReady` 回调；广告未过期、未展示过、实例未销毁。 |
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
- [biz/native](./IFLYADLibSimple/IFLYADLibSimple/biz/native)：自渲染信息流。
- [biz/reward](./IFLYADLibSimple/IFLYADLibSimple/biz/reward)：激励视频广告。

运行前请先执行：

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

> 说明：示例当前通过 tag 固定的 `:podspec` 接入 `IFLYADLib 6.1.0`，默认 `Full`（五种广告全开），为模型 A 可组合的 `xcframework`、含模拟器切片且工程最低版本为 iOS 11.0。如需体验按广告形式部分接入（如 `pod 'IFLYADLib/Splash'`）或 SPM，参见「按广告形式可组合接入（模型 A）」。示例覆盖五种广告的基础用法；S2S 服务端竞价与 Header Bidding 仅在本文档说明，示例工程未内置端到端演示（端到端需媒体服务端配合下发 `rspToken`）。真机运行请在 Xcode「Signing & Capabilities」选择你自己的开发者 Team（示例已置空 `DEVELOPMENT_TEAM`）。

## 接入建议

- 广告对象请由页面或管理对象强持有，避免请求过程中提前释放。
- `delegate` 回调均按广告实例生命周期触发，页面销毁时建议置空 delegate 并调用 `destroy`。
- 展示类广告通常在 `DidReady` 后再展示，不要在 `DidLoad` 里直接展示。
- 单个广告实例通常为一次性消费，展示/关闭/销毁后请重新创建实例。
- 正式上线前请替换为平台分配的真实广告位 ID，并关闭排查用日志。

## 从 6.0.14 升级到 6.1.0

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
