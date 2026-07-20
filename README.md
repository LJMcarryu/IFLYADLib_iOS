# IFLYADLib iOS SDK 接入说明

`IFLYADLib` 是讯飞广告 iOS SDK，提供开屏、Banner、插屏、自渲染信息流、激励视频等广告能力。

当前文档覆盖 `IFLYADLib 6.0.14`（推荐，按广告形式可组合并最低支持 iOS 11）与 `6.0.0`（历史单包 Full）；示例工程见 [IFLYADLibSimple](./IFLYADLibSimple)。

> 文档以中文为主。如需用英文反馈问题，请直接在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交。

仓库地址：[https://github.com/LJMcarryu/IFLYADLib_iOS](https://github.com/LJMcarryu/IFLYADLib_iOS)

## 版本记录

| 版本 | 日期 | 说明 |
| --- | --- | --- |
| 6.0.14 | 2026-07-20 | 最低系统版本由 iOS 13.0 下调为 iOS 11.0，7 个模块的 device / simulator 二进制全部重建并通过最低版本门禁；插屏和激励视频在服务端同时下发图片时于视频完播后展示图片完播页（开屏保持原关闭语义）；请求字段 `lts` 移入 `device`，补齐分格式点击回调丢弃、客户端竞价时间戳/曝光宏和设备调试状态字段。公开 API 签名不变。 |
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

- iOS 11.0 及以上（从 `6.0.14` 起；历史 `6.0.13` 及更早二进制不追溯扩大支持范围）。
- Xcode 14.1 及以上，建议使用较新 Xcode 构建。
- 交付形态：`6.0.14` 为各模块 `xcframework`（含 **device + 模拟器** 切片，**可在模拟器调试**，见「按广告形式可组合接入（模型 A）」）；`6.0.0` 为单一 `IFLYADLib.framework`（**仅真机 arm64、不含模拟器切片**，模拟器无法运行）。
- 统一入口头文件：`#import <IFLYADLib/IFLYADLib.h>`。

## CocoaPods 接入

> **推荐使用最新 `6.0.14`**（按广告形式可组合、含模拟器切片、最低支持 iOS 11）——见「[按广告形式可组合接入（模型 A）](#按广告形式可组合接入模型-a)」。下面的 `6.0.0` 为历史单包 `Full`（仅真机 arm64）。

`6.0.14` 已发布到 CocoaPods 官方源。若 CDN 版本索引尚未同步，可先 `pod repo update` 或临时使用 tag 固定的 `:podspec` 直连。

```ruby
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  pod 'IFLYADLib', '6.0.14'
end
```

安装：

```bash
pod install --repo-update
```

示例工程的 Podfile 已固定到 `IFLYADLib 6.0.14`：

```bash
cd IFLYADLibSimple
pod install --repo-update
open IFLYADLibSimple.xcworkspace
```

## 按广告形式可组合接入（模型 A）

`6.0.1` 起支持「按广告形式可组合」接入：`Core` 必选，`Banner` / `Splash` / `Interstitial` / `NativeFeed` / `Reward` 各格式按需选用，`VideoUI` 由依赖图自动带入。只接入需要的格式可减小包体。当前 `6.0.14` 产物为各模块独立 `xcframework`（含 device + simulator 切片），最低支持 iOS 11.0。

> **资源依赖**：`CocoaPods` 接入时，图像/视频控件等资源经 `resource_bundles` 随依赖自动带入；**`Swift Package Manager` 接入时资源不会自动带入**（SPM `binaryTarget` 不支持 `resource_bundles`），详见下方「Swift Package Manager」的资源说明。

> `Full`（默认）等价于五种广告全开，行为与 6.0.0 单包一致。

### CocoaPods（可组合 subspec）

> `6.0.14` 已发布到 CocoaPods 官方源，标准写法 `pod 'IFLYADLib/Splash', '6.0.14'` 可直接使用（若索引未同步先 `pod repo update`）。下方「`:podspec` 直连」为可选的免 trunk 备用方式。

**已发布到 trunk 后（推荐，零配置）：**

```ruby
platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  # 例：只接开屏 + Banner（VideoUI/Core 自动带入）
  pod 'IFLYADLib/Splash', '6.0.14'
  pod 'IFLYADLib/Banner', '6.0.14'

  # 或全量：
  # pod 'IFLYADLib', '6.0.14'
end
```

**尚未发布到 trunk 时 —— `:podspec` 直连（无需 trunk，立即可用）：**

```ruby
platform :ios, '11.0'

target 'YOUR_APP_TARGET' do
  use_frameworks!

  pod 'IFLYADLib/Splash',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.0.14/IFLYADLib.podspec'
end
```

> 二进制照常从本仓库 Release 的合并 zip 下载，subspec 选择照常生效；URL 请钉死到 tag `6.0.14`（勿指向分支）。**不要改用 `:git` / `:path`** —— 二进制在 Release zip、不在 git 仓代码里，这两种外部源会跳过 zip 下载导致缺 `xcframework`。

可选 subspec：`Core`（必选，自动带入）、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward`、`Full`（默认）。其中 `Splash` / `Interstitial` / `Reward` 会自动带入 `VideoUI`。

> **导入头文件**：统一用伞头 `#import <IFLYADLib/IFLYADLib.h>` 即可——`6.0.3` 起伞头用 `__has_include` 守卫，在全量 `Full` 与按格式部分安装下都能正常编译（自动只导入已安装格式的入口类）。也可按需直接 import 具体格式头（如 `<IFLYADLib/IFLYSplashAd.h>`）。注：`6.0.2` 及更早版本，部分安装须用具体格式头、不能用伞头。

### Swift Package Manager

在 Xcode「Add Packages」填入仓库地址 `https://github.com/LJMcarryu/IFLYADLib_iOS`，选 `6.0.14`，按需勾选 product：`Core` / `Banner` / `Splash` / `Interstitial` / `NativeFeed` / `Reward` / `Full`。

> ⚠️ **SPM 接入方需在 App target 的 Other Linker Flags（`OTHER_LDFLAGS`）添加 `-ObjC`**，否则静态库 category / `+load` 会被剥离导致运行异常。CocoaPods 的 podspec 已内置 `-ObjC`，无需手动添加。
>
> ⚠️ **SPM 不携带资源 bundle**：SPM 的 `binaryTarget` 无法像 CocoaPods 那样随包分发 `resource_bundles`。因此用到内置素材的格式（开屏/插屏交互图、视频播放控件、激励 UI 等）经 **SPM** 接入时，运行期会找不到对应图片/资源而降级（图标缺失等）。**需要这些资源的接入方请优先使用 CocoaPods**；若必须用 SPM，需自行把对应 `.bundle` 资源加入 App target（资源见 Release 合并包 `IFLYADLib-modelA-6.0.14.zip` 内 `resources/` 目录的 `Core` / `VideoUI` / `Reward` 三域）。纯 `Banner`、纯 `NativeFeed`（图片）等不依赖内置素材的组合不受影响。

## 权限与隐私配置

### 隐私清单（PrivacyInfo.xcprivacy）

SDK 自带 Apple 隐私清单，声明以下隐私特征。**接入方须在 App Store Connect 的隐私「营养标签」中如实合并声明这些数据收集，并据 `NSPrivacyTracking = YES` 提供 ATT 授权（见下）。**

- **追踪**：`NSPrivacyTracking = YES`；追踪域名：`voiceads.cn`、`bjimp.voiceads.cn`、`ai.voiceads.cn`、`msdk.voiceads.cn`、`caid-api.adn-plus.com.cn`。
- **收集的数据类型**：设备 ID（DeviceID）、产品交互（ProductInteraction）、广告数据（AdvertisingData）——均关联用户且用于追踪，用途为第三方广告与分析；其他诊断数据（OtherDiagnosticData）——不关联、不用于追踪，用途为 App 功能与分析。
- **Required Reason API**：UserDefaults（`CA92.1`）、文件时间戳（`C617.1`）、系统启动时间（`35F9.1`）、磁盘可用空间（`E174.1`）。

CocoaPods 接入会经资源 bundle 自动带入该隐私清单（`6.0.0` 随框架、`6.0.2+` 随 `Core` 资源 `IFLYADLibCoreResources`）；**Swift Package Manager 接入方需自行把隐私清单随工程提交**（可从 Release 合并包 `IFLYADLib-modelA-6.0.14.zip` 内 `resources/Core/PrivacyInfo.xcprivacy` 取用），以满足 App Store 审核对第三方 SDK 隐私清单的要求。

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

信息流广告由媒体侧根据 `ad.adData` 自行渲染 UI，再通过 `IFLYNativeFeedAdViewBinder` 把容器、点击视图、关闭按钮、视频承载视图交给 SDK。

```objc
@interface NativeFeedViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) UIView *mediaContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

- (void)loadNativeFeed {
    IFLYNativeFeedAd *ad = [[IFLYNativeFeedAd alloc] initWithAdUnitId:@"YOUR_NATIVE_FEED_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    self.nativeAd = ad;

    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedAdData *data = ad.adData;
    self.titleLabel.text = data.title ?: @"广告标题";
    self.descLabel.text = data.desc ?: data.content;
    [self.ctaButton setTitle:data.actionText ?: @"查看详情" forState:UIControlStateNormal];

    // 图片素材请媒体侧自行下载并渲染到 imageView。
    // 视频素材请准备 videoView 容器，不要自行播放 videoURL。

    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    binder.renderViews = @[self.mediaContainer, self.titleLabel, self.descLabel, self.ctaButton];
    binder.clickViews = @[self.mediaContainer, self.ctaButton];
    binder.closeView = self.closeButton;
    binder.videoView = ad.hasVideoTemplate ? self.mediaContainer : nil;
    binder.titleView = self.titleLabel;
    binder.descView = self.descLabel;
    binder.imageView = self.imageView;
    binder.ctaView = self.ctaButton;

    IFLYAdError *error = nil;
    BOOL success = [ad bindAdWithViewBinder:binder error:&error];
    if (!success) {
        NSLog(@"Native bind failed: %d %@", error.errorCode, error.errorDescription);
    }
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    if (ad.hasVideoTemplate) {
        [ad startPlay];
    }
}
```

复用注意：

- `containerView` 必填。
- 视频素材必须传 `videoView`，由 SDK 创建播放器并完成播放监测。
- `UITableViewCell` / `UICollectionViewCell` 复用前调用 `unbindAd` 或 `destroy`。
- 绑定成功后该广告实例视为已消费；新的广告机会请创建新实例并重新加载。

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

广告加载成功后，可通过 `bidInfo` 或 `ecpm` 获取竞价信息。媒体侧完成竞价决策后，可通过基类方法通知结果：

```objc
if (ad.bidInfo.winNoticeAvailable) {
    [ad sendBidResultWithType:IFLYAdBidResultTypeWin reason:@"win"];
} else {
    [ad sendBidResultWithType:IFLYAdBidResultTypeLoseBidLower reason:@"loss"];
}
```

具体是否需要通知、通知时机和价格字段请以业务接入约定为准。

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
| `pod install` 找不到 `6.0.14` | 执行 `pod install --repo-update`；或临时用 `:podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.0.14/IFLYADLib.podspec'` 直连本仓 Release。 |
| 模拟器无法运行 | `6.0.14`（模型 A）含模拟器切片，可直接在模拟器调试；仅旧 `6.0.0` 单包不含模拟器切片需真机。 |
| IDFA 为空 | 确认 `NSUserTrackingUsageDescription` 已配置；用户已允许 ATT；在授权完成后再读取 `ASIdentifierManager`；过滤全零 UUID。 |
| `isAdValid` 为 NO | 确认已收到 `DidReady` 回调；广告未过期、未展示过、实例未销毁。 |
| 展示失败 | 确认 `rootViewController` 已在 window 上，当前没有正在 present 的控制器。 |
| Banner 不展示 | 确认容器宽度大于 0，布局已完成后再调用 `showInView:`。 |
| 信息流绑定失败 | 确认 `containerView` 非空；视频素材传入 `videoView`；绑定在主线程执行。 |

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
pod install --repo-update
open IFLYADLibSimple.xcworkspace
```

> 说明：示例当前固定 `pod 'IFLYADLib', '6.0.14'`，默认 `Full`（五种广告全开），为模型 A 可组合的 `xcframework`、**含模拟器切片**（可直接在模拟器运行）且工程最低版本为 iOS 11.0。如需体验按广告形式部分接入（如 `pod 'IFLYADLib/Splash'`）或 SPM，参见「按广告形式可组合接入（模型 A）」。示例覆盖五种广告的基础用法；**S2S 服务端竞价与 Header Bidding 仅在本文档说明，示例工程未内置端到端演示**（端到端需媒体服务端配合下发 `rspToken`）。真机运行请在 Xcode「Signing & Capabilities」选择你自己的开发者 Team（示例已置空 `DEVELOPMENT_TEAM`）。

## 接入建议

- 广告对象请由页面或管理对象强持有，避免请求过程中提前释放。
- `delegate` 回调均按广告实例生命周期触发，页面销毁时建议置空 delegate 并调用 `destroy`。
- 展示类广告通常在 `DidReady` 后再展示，不要在 `DidLoad` 里直接展示。
- 单个广告实例通常为一次性消费，展示/关闭/销毁后请重新创建实例。
- 正式上线前请替换为平台分配的真实广告位 ID，并关闭排查用日志。

## 从 6.0.0 / 6.0.13 升级到 6.0.14

`6.0.14` 不改公开 API 签名，业务代码与头文件引用无需调整。新版本把最低系统下调到 iOS 11.0，并新增插屏/激励视频完播图与若干内部请求、监测兼容行为；历史版本二进制的最低系统范围不追溯变更。

- **CocoaPods · 保持全量**：`pod 'IFLYADLib'` → `pod 'IFLYADLib', '6.0.14'`（默认 `Full` 即五种广告全开）。
- **CocoaPods · 改为按需**：把 `pod 'IFLYADLib'` 换成所需格式 subspec，例如 `pod 'IFLYADLib/Splash'`、`pod 'IFLYADLib/Banner'`；`Core` 必选、`VideoUI` 与资源按依赖自动带入。
- **改用 SPM**：见「按广告形式可组合接入（模型 A）」→「Swift Package Manager」，注意 `-ObjC` 与资源两条说明。
- **subspec ↔ 格式**：`Splash` / `Banner` / `Interstitial` / `NativeFeed` / `Reward`。

> `6.0.14` 已发布到 CocoaPods 官方源（trunk）+ GitHub Releases + SPM，`pod 'IFLYADLib', '6.0.14'` 可直接使用。

## 问题反馈与支持

- 本仓库是 IFLYADLib 的**对外分发与接入文档仓**（不含 SDK 源码），**不接受外部代码 PR**。
- **使用问题 / Bug**：请在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交，并附 SDK 版本、iOS / Xcode 版本、接入方式（CocoaPods / SPM）、复现步骤与日志。
- **安全漏洞**：请勿在公开 Issue 披露，按 [SECURITY.md](./SECURITY.md) 私密上报。
- **商务合作 / 广告位申请**：请通过讯飞广告官方渠道联系。
