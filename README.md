# IFLYADLib iOS SDK

`IFLYADLib` 是面向 iOS 应用的广告 SDK，提供开屏、Banner、插屏、自渲染信息流和激励视频。本文只介绍外部接入所需的公开能力；完整 API 以 framework 公开头为准。

## 6.3.1 发布状态

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.3.1","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.1"} -->

当前正式版本：[`6.3.1`](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.1)。生产项目请固定到具体版本，不要依赖 `main` 分支。

## 能力矩阵

| 能力 | 入口类 | 渲染方式 | 说明 |
| --- | --- | --- | --- |
| 开屏 | `IFLYSplashAd` | SDK 内置渲染 | 支持图片、视频和跳过/关闭回调 |
| Banner | `IFLYBannerAd` | SDK 内置渲染 | 在媒体提供的容器中展示 |
| 插屏 | `IFLYInterstitialAd` | SDK 内置渲染 | 支持半屏、全屏和图片/视频素材 |
| 自渲染信息流 | `IFLYNativeFeedAd` | 媒体渲染 UI，SDK 管理广告交互 | 支持单图、多图、视频和下载类广告 |
| 激励视频 | `IFLYRewardVideoAd` | SDK 内置渲染 | 奖励以 `didRewardEffective` 回调为准 |

所有广告对象都应由业务代码强持有。回调在主线程触发；加载成功不代表素材已经可以展示，内置渲染格式应等待 `DidReady`。单个开屏、Banner、插屏和激励视频实例通常只消费一次，展示或关闭后请重新创建。

## 环境要求

- iOS 11.0 及以上。
- Xcode 15.0 及以上；SwiftPM 使用 Swift tools 5.9。
- SDK 是静态 XCFramework，最终 App 必须链接 `-ObjC`，不需要 Embed & Sign。
- CocoaPods 和 SwiftPM 会自动投递 SDK 资源与 `PrivacyInfo.xcprivacy`；手动集成时需复制 Release 压缩包中的资源。
- 入口头：

  ```objc
  #import <IFLYADLib/IFLYADLib.h>
  ```

## 安装

### CocoaPods

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!
  pod 'IFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.1/IFLYADLib.podspec'
end
```

然后执行：

```bash
pod install
open YourApp.xcworkspace
```

默认 `Full` 包含全部五种广告；若只需要部分能力，可使用 `Core`、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward` 或 `Full` subspec。

### Swift Package Manager

在 Xcode 的 **File → Add Packages…** 中添加：

```text
https://github.com/LJMcarryu/IFLYADLib_iOS.git
```

选择版本 `6.3.1`，再按需要选择 `Core`、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward` 或 `Full` product。SwiftPM 会自动投递资源；在 App target 的 `Other Linker Flags` 中添加：

```text
-ObjC
```

### 手动集成

从 [Release 6.3.1](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.1) 下载对应压缩包：

1. 将需要的 `.xcframework` 加入 App target，Embed 选择 **Do Not Embed**。
2. 将压缩包中的资源 bundle 加入 **Copy Bundle Resources**。
3. 在 App target 的 `Other Linker Flags` 添加 `-ObjC`。
4. 导入 `<IFLYADLib/IFLYADLib.h>`。

## 初始化、隐私和请求配置

SDK 不要求单独的初始化对象。应用启动时设置全局状态，并在获得必要的隐私同意后创建广告对象：

```objc
#import <IFLYADLib/IFLYADLib.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [IFLYAdConfig setPersonalizedEnabled:YES];
    [IFLYAdConfig setLogEnabled:NO];
    return YES;
}
```

`setPersonalizedEnabled:` 用于记录媒体侧的个性化选择，不代替 ATT，也不会自动改写其他请求字段。排查问题时可以临时开启日志，正式版本建议关闭。

### ATT 和 IDFA

iOS 14 及以上如需使用 IDFA，请在 `Info.plist` 中配置说明，并在请求广告前取得 ATT 授权：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>用于获取广告标识符 IDFA，以便请求和展示相关广告。</string>
```

只有 ATT 状态为 `authorized` 时才读取或传入 IDFA。授权前传入的值会被丢弃；用户授权后请重新读取。宿主仍须在 App Store Connect 隐私标签中如实申报 SDK 实际使用的数据。

### 请求配置

所有广告类型都支持 `IFLYAdRequestConfig`：

```objc
- (IFLYAdRequestConfig *)requestConfig {
    IFLYAdRequestConfig *config = [[IFLYAdRequestConfig alloc] init];
    config.requestTimeout = @5;
    config.appName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    config.appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    config.settleType = @1;      // 0=固定价格，1=RTB
    config.bidFloor = @0.01;     // CNY 元/千次展示
    config.interactStatus = @1;  // 1=开启，2=关闭
    return config;
}
```

常用字段：`requestId`、`requestTimeout`、`appName`、`appVersion`、`userAgent`、`idfa`、`caidList`、`settleType`、`bidFloor`、`pmpDeals` 和 `deepLinkDisabled`。未显式设置 `requestId` 时 SDK 会生成请求 ID。广告对象可调用 `loadAd`，或调用：

```objc
[ad loadAdWithRequestConfig:[self requestConfig]];
```

广告点击、DeepLink、落地页和失败回退由 SDK 统一处理。历史字段 `jumpDirectly` 仅为兼容保留，不应再用来控制业务跳转分支。

## 开屏广告

开屏广告挂载到 window，不使用 `presentViewController:`。应在 `splashAdDidReady:` 后展示：

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
    if (ad != self.splashAd || !ad.isAdValid) return;
    IFLYSplashAdConfig *config = [[IFLYSplashAdConfig alloc] init];
    config.traceDuration = 5;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)splashAd:(IFLYSplashAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Splash failed: %d %@", error.errorCode, error.errorDescription);
}
```

常用回调包括 `splashAdDidLoad:`、`splashAdDidReady:`、`splashAdDidShow:`、`splashAdDidExpose:`、`splashAdDidClick:`、`splashAdDidClose:`、`splashAdDidSkip:` 和 `splashAd:didFailWithError:`。视频素材还会触发播放开始、暂停、恢复、完成和失败回调。

## Banner 广告

容器必须已经完成布局，宽度大于 0；高度为 0 时 SDK 可按素材比例自适应。

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
    if (ad == self.bannerAd && ad.isAdValid) {
        [ad showInView:self.bannerContainer];
    }
}
```

展示、曝光、点击、跳转、关闭和失败分别通过 delegate 回调通知。Banner 实例展示后不要再次 `loadAd`，需要新机会时销毁旧实例并重新创建。

## 插屏广告

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
    if (ad != self.interstitialAd || !ad.isAdValid) return;
    IFLYInterstitialAdConfig *config = [[IFLYInterstitialAdConfig alloc] init];
    config.presentationStyle = IFLYInterstitialPresentationStyleHalfScreen;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}
```

使用 `IFLYInterstitialPresentationStyleHalfScreen` 或 `IFLYInterstitialPresentationStyleFullScreen` 选择半屏或全屏。展示或关闭后请重新创建实例。

## 激励视频广告

奖励必须以 `rewardVideoAd:didRewardEffective:` 为准，不要用播放完成或关闭回调发奖：

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
    if (ad != self.rewardAd || !ad.isAdValid) return;
    IFLYRewardVideoAdConfig *config = [[IFLYRewardVideoAdConfig alloc] init];
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didRewardEffective:(NSDictionary *)info {
    [self grantRewardOnceWithInfo:info];
}
```

同时监听 `rewardVideoAdDidLoad:`、`rewardVideoAdDidReady:`、`rewardVideoAdDidShow:`、`rewardVideoAdDidExpose:`、`rewardVideoAdDidClick:`、`rewardVideoAdDidClose:` 和 `rewardVideoAd:didFailWithError:`。

## 自渲染信息流

NativeFeed 的数据由媒体渲染，SDK 负责曝光、点击、跳转、关闭、监测和视频播放。加载成功后使用 `ad.adData` 选择布局；`adData` 是公开白名单，不要通过 KVC 或反射读取原始响应。

```objc
@interface NativeFeedViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UIView *adContainer;
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
    if (ad != self.nativeAd || !ad.adData.isMaterialComplete) return;

    // 先根据 ad.adData 渲染标题、图片/视频、品牌和 CTA。
    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    binder.renderViews = @[/* 媒体实际渲染的视图 */];
    binder.clickViews = @[/* Redirect/Download 的点击视图；Exposure/Unknown 传 @[] */];
    binder.videoView = /* 视频素材使用普通 UIView；非视频传 nil */ nil;

    IFLYAdError *error = nil;
    if (![ad attachWithViewBinder:binder error:&error]) {
        NSLog(@"NativeFeed attach failed: %d %@", error.errorCode, error.errorDescription);
    }
}

- (void)leaveScreen {
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainer];
}
```

接入规则：

- `attachWithViewBinder:error:` 必须在主线程同步调用；`containerView` 必填，视频素材必须提供普通 `UIView` 作为 `videoView`。
- `interactionType` 为 `Exposure` 或 `Unknown` 时，`clickViews` 传 `@[]`；为 `Redirect` 或 `Download` 时只传实际点击视图。
- 如确实需要把 CTA 放在广告容器外，显式设置 `binder.allowsExternalClickViews = YES`，并保证 CTA 与广告处于同一 window/scene、可见且可交互。常规接入优先把 CTA 放在容器内部。
- 外部 CTA 不满足可见性或交互条件时，delegate 会通过 `nativeFeedAd:didRejectClickWithError:` 返回 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（`71503`）；业务应记录并修正视图层级，不要自行跳转。
- Cell 离屏、复用或切换为普通内容时，必须对具体容器调用 `detachAdFromContainerView:`；不要用旧 `indexPath` 反查广告。
- 固定单容器且明确知道当前广告对象时，也可以调用 `detachFromCurrentContainer`；可复用列表仍优先按容器调用 `detachAdFromContainerView:`。
- 列表数据层持有 `IFLYNativeFeedAd`，Cell 只负责渲染和 attach/detach。条目暂时离屏可继续持有同一 Ad；永久删除或页面退出时 detach、置空 delegate 并释放 Ad。
- SDK 管理视频播放器。绑定且曝光后可使用 `startPlay`、`pausePlay`、`resumePlay`、`stopPlay` 控制播放。

常用 `adData` 字段：`materialType`、`templateId`、`title`、`desc`、`content`、`ctaText`、`brand`、`appName`、`icon`、`mainImage`、`imageList`、`imageURLs`、`videoURL`、`videoCoverURL`、`videoDuration`、`targetURL`、`deeplinkURL`、`marketURL`、`downloadURL`、`packageName`、`interactionType` 和 `interactType`。点击和跳转由 SDK 处理，媒体不要自行打开这些 URL。

NativeFeed 回调包括 `nativeFeedAdDidLoad:`、`nativeFeedAdDidRender:`、`nativeFeedAdDidExpose:`、`nativeFeedAdDidClick:`、`nativeFeedAdDidJump:`、`nativeFeedAdDidClose:`、`nativeFeedAd:didFailWithError:` 和 `nativeFeedAd:didFailToRenderWithError:`；视频素材还会触发播放状态回调。

## S2S 和 Header Bidding

如平台已开通服务端竞价，客户端先生成 SDK token：

```objc
NSError *error = nil;
NSString *sdkToken = [IFLYAdSDK getSdkTokenWithAdUnitId:@"YOUR_AD_UNIT_ID" error:&error];
```

服务端竞价返回 `rspToken` 后，传给对应广告实例：

```objc
[ad loadAdWithServerBiddingToken:rspToken];
```

广告加载成功后，竞价信息从白名单字段读取：

```objc
NSNumber *price = ad.bidInfo.price;
NSString *dealId = ad.bidInfo.dealId;
[ad sendBidResultWithType:IFLYAdBidResultTypeWin reason:@"win"];
```

S2S、Header Bidding 的 token 生命周期、竞价通知时机和失败重试策略以平台双方协议为准；未开通时使用普通 `loadAd`。

## 错误处理与生命周期

所有格式都通过对应 delegate 的 `didFailWithError:` 返回 `IFLYAdError`。无填充、网络错误、超时、素材不完整和容器无效都应允许业务结束本次展示并按业务策略重试；不要在失败回调中无限重试。

- `DidLoad`：响应解析成功，素材可能还在下载。
- `DidReady`：SDK 管理的主素材已就绪，可以展示；NativeFeed 没有 `DidReady`，在 `DidLoad` 后完成自渲染并 attach。
- `isAdValid`：展示前检查实例仍可用。
- `destroy`：主动终止仍被持有的广告；NativeFeed 列表正常离屏只需 detach。
- 页面销毁时置空 delegate、detach 活动 NativeFeed 容器并释放强引用。

## 示例工程

`IFLYADLibSimple` 只使用公开 API，包含五种广告示例：

- `biz/splash`：开屏
- `biz/banner`：Banner
- `biz/interstitial`：插屏
- `biz/native`：固定卡片和列表复用信息流
- `biz/reward`：激励视频

运行：

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

请把示例中的广告位 ID 替换为平台分配的 ID，并在真实设备或配置好的模拟器上验证素材填充。示例工程的构建成功只代表接入和链接正确，不代表线上一定有填充。

## 常见问题

| 问题 | 处理方式 |
| --- | --- |
| `-ObjC` 缺失 | 在最终 App target 的 `Other Linker Flags` 添加 `-ObjC`，不要只添加到业务静态库 target。 |
| Banner 不展示 | 确认 `showInView:` 调用时容器已布局且宽度大于 0。 |
| 内置广告在 `DidLoad` 展示失败 | 改为等待 `DidReady`，并在展示前检查 `isAdValid`。 |
| NativeFeed attach 失败 | 确认在主线程调用、容器非空、视频传入 `videoView`，且 `clickViews` 与 `interactionType` 匹配。 |
| IDFA 为空 | 检查 ATT 授权、`NSUserTrackingUsageDescription` 和授权后重新读取逻辑；不要使用固定 IDFA。 |
| 激励重复发放 | 只处理一次 `didRewardEffective`，不要用关闭或播放完成回调发奖。 |

## 反馈与支持

请在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交问题，并附 SDK 版本、iOS/Xcode 版本、CocoaPods 或 SwiftPM 接入方式、复现步骤和相关错误回调。

版本变更见 [`CHANGELOG.md`](./CHANGELOG.md)。
