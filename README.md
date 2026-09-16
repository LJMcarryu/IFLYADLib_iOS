# IFLYADLib iOS SDK

`IFLYADLib` 是面向 iOS 应用的广告 SDK，提供开屏、Banner、插屏、自渲染信息流和激励视频，支持按广告形式接入。最低支持 iOS 11.0。

## 当前版本

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.3.5","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.5"} -->

当前正式版本：[`6.3.5`](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.5)。生产项目请固定具体版本；更新示例工程时可以跟随本仓 `main`，示例依赖仍固定为 `6.3.5`。

## 先读什么

- 首次接入：先按[示例运行指南](IFLYADLibSimple/README.md)跑通一种广告，再把对应页面的接入代码移入自己的 App。
- 选择广告形式与安装方式：见下方[能力矩阵](#能力矩阵)和[安装](#安装)。
- 加载和展示：先读[请求配置](#请求配置)，再选择对应广告章节；文中的方法片段放在业务控制器的 `@implementation` 内。
- 信息流列表：重点核对[自渲染信息流](#自渲染信息流)中的挂载、离屏与复用规则。
- 排查问题：见[常见问题](#常见问题)；完整签名、可选参数和错误码以所安装版本的公开头为准。

## 能力矩阵

| 能力 | 入口类 | 渲染方式 | 说明 |
| --- | --- | --- | --- |
| 开屏 | `IFLYSplashAd` | SDK 内置渲染 | 支持图片、视频和跳过/关闭回调 |
| Banner | `IFLYBannerAd` | SDK 内置渲染 | 在媒体提供的容器中展示 |
| 插屏 | `IFLYInterstitialAd` | SDK 内置渲染 | 支持半屏、全屏和图片/视频素材 |
| 自渲染信息流 | `IFLYNativeFeedAd` | 媒体渲染 UI，SDK 管理广告交互 | 支持单图、多图、视频和下载类广告 |
| 激励视频 | `IFLYRewardVideoAd` | SDK 内置渲染 | 奖励以 `didRewardEffective` 回调为准 |

所有广告对象都应由业务代码强持有，视图和展示操作在主线程执行。加载成功不代表素材已经可以展示，内置渲染格式应等待 `DidReady`。一次广告机会使用一个实例；已经成功展示的实例不能重新加载成另一条广告。

## 环境要求

- iOS 11.0 及以上。
- SwiftPM 清单使用 Swift tools 5.9；`6.3.5` 已在 Xcode `26.3`（Build `17C529`）验证，其他 Xcode 版本须由接入项目自行验证。
- SDK 是静态 XCFramework，最终 App 必须链接 `-ObjC`，不需要 Embed & Sign。
- CocoaPods 和 SwiftPM 会自动投递 SDK 资源与 `PrivacyInfo.xcprivacy`；手动集成时需复制 Release 压缩包中的资源。
- 入口头：

  ```objc
  #import <IFLYADLib/IFLYADLib.h>
  ```

## 安装

### CocoaPods

使用下面的公开版本 Podspec 地址安装。当前版本通过 GitHub 分发，不能仅写 Pod 名称和版本号从 CocoaPods trunk 安装。

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!
  # 默认安装 Full，包含开屏、Banner、插屏、自渲染信息流和激励视频五种广告。
  pod 'IFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.5/IFLYADLib.podspec'
end
```

然后执行：

```bash
pod install
open YourApp.xcworkspace
```

上面的裸写法等价于选择 `Full`，会安装全部五种广告。如果只需要部分能力，请将 `pod` 行替换为对应 subspec；同一个 target 不要同时写裸 `IFLYADLib` 和其他 subspec：

```ruby
# 只接入开屏：Core 和 VideoUI 会自动带入
pod 'IFLYADLib/Splash',
    :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.5/IFLYADLib.podspec'

# 只接入 Banner + 自渲染信息流：两个格式共用一份 Core
pod 'IFLYADLib/Banner',
    :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.5/IFLYADLib.podspec'
pod 'IFLYADLib/NativeFeed',
    :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.5/IFLYADLib.podspec'

# 只接入基础 Core（不包含任何广告格式）
pod 'IFLYADLib/Core',
    :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.5/IFLYADLib.podspec'

# 显式写 Full，和最上面的裸写法等价
pod 'IFLYADLib/Full',
    :podspec => 'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.5/IFLYADLib.podspec'
```

选择 `Splash`、`Interstitial` 或 `Reward` 时，`Core`、`VideoUI` 及所需资源会由依赖关系自动安装；`Banner` 和 `NativeFeed` 只自动依赖 `Core`。替换 Podfile 后重新执行 `pod install`，再打开生成的 `.xcworkspace`。

### Swift Package Manager

在 Xcode 的 **File → Add Packages…** 中添加：

```text
https://github.com/LJMcarryu/IFLYADLib_iOS.git
```

选择依赖规则 **Exact Version**，版本填 `6.3.5`，再按需要选择 `Core`、`Banner`、`Splash`、`Interstitial`、`NativeFeed`、`Reward` 或 `Full` product。SwiftPM 会自动投递资源；在 App target 的 `Other Linker Flags` 中添加：

```text
-ObjC
```

在 Xcode 中，product 的选择直接对应要接入的广告能力：只接开屏就选 `Splash`，同时接 Banner 和信息流就选 `Banner`、`NativeFeed`，需要全部能力就选 `Full`。如果使用 `Package.swift`，可以使用下面的完整片段（把 `YourApp` 换成自己的 target 名称）：

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS("11.0")
    ],
    dependencies: [
        .package(url: "https://github.com/LJMcarryu/IFLYADLib_iOS.git", exact: "6.3.5")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "Banner", package: "IFLYADLib_iOS"),
                .product(name: "NativeFeed", package: "IFLYADLib_iOS")
            ]
        )
    ]
)
```

格式 product 会自动依赖 `Core`（视频格式还会依赖 `VideoUI`）；无需再手动添加这些依赖。若改为全量接入，将上例两个 product 替换为 `.product(name: "Full", package: "IFLYADLib_iOS")`。

### 下载与手动集成

[Release 6.3.5](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.3.5) 提供 `IFLYADLib-modelA-6.3.5.zip` 完整压缩包和各模块的 `.xcframework.zip`。首次接入建议使用 CocoaPods 或 SwiftPM，由包管理器处理模块依赖、公开头和资源。

手动接入须把所选格式及其依赖一起加入 App target，Embed 选择 **Do Not Embed**：

| 使用的格式 | 必须链接的 XCFramework |
| --- | --- |
| Banner | `IFLYAdCore`、`IFLYAdBanner` |
| 自渲染信息流 | `IFLYAdCore`、`IFLYAdNativeFeed` |
| 开屏 | `IFLYAdCore`、`IFLYAdVideoUI`、`IFLYAdSplash` |
| 插屏 | `IFLYAdCore`、`IFLYAdVideoUI`、`IFLYAdInterstitial` |
| 激励视频 | `IFLYAdCore`、`IFLYAdVideoUI`、`IFLYAdReward` |

多个格式共用的模块只链接一次。在 App target 的 **Link Binary With Libraries** 中添加 `AdSupport.framework`，并将 `AppTrackingTransparency.framework` 设置为 **Optional**，以兼容 iOS 14 以下系统。最终 App 添加 `$(inherited) -ObjC`；这些模块包含静态库和 `Headers/IFLYADLib` 公开头目录，需确保所选切片的 `Headers` 可被 App 的 `Header Search Paths` 找到，再使用 `<IFLYADLib/IFLYADLib.h>` 导入。

完整压缩包的 `resources/Core`、`resources/VideoUI`、`resources/Reward` 是资源文件目录。手动接入可从本仓同一版本 Tag 的 `spm` 目录取得已整理的资源包，加入 App 的 **Copy Bundle Resources**：所有格式需要 `spm/Core/IFLYADLibCoreResources.bundle`；开屏、插屏、激励另需 `spm/VideoUI/IFLYADLibVideoUIResources.bundle`；激励再加 `spm/Reward/IFLYADLibRewardResources.bundle`。另将 `spm/Core/Resources/PrivacyInfo.xcprivacy` 单独加入 **Copy Bundle Resources**（完整压缩包中的对应文件为 `resources/Core/PrivacyInfo.xcprivacy`）；该隐私清单不在 Core 资源 bundle 内。不要只加入单个格式的二进制 zip，也不要混用不同版本的模块和资源。

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

`setPersonalizedEnabled:` 只记录媒体侧的个性化选择，不影响采集、请求、填充、展示或点击，不代替 ATT 或宿主的隐私同意门禁。排查问题时可以临时开启日志，正式版本建议关闭。

### ATT 和 IDFA

iOS 14 及以上如需使用 IDFA，请在 `Info.plist` 中配置说明，并在请求广告前取得 ATT 授权：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>用于获取广告标识符 IDFA，以便请求和展示相关广告。</string>
```

只有 ATT 状态为 `authorized` 时才读取或传入 IDFA。授权前传入的值会被丢弃；用户授权后请重新读取并设置。无授权时不要传入固定值或全零 IDFA。宿主仍须在 App Store Connect 隐私标签中如实申报 SDK 实际使用的数据；ATT 授权与应用自身的隐私同意是两件事。

### 网络与资源

素材、监测和落地页可能使用 HTTP。示例的 `Info.plist` 为联调允许 HTTP；生产 App 应按实际域名和业务需求配置 ATS 例外，并优先使用 HTTPS。出现素材或落地页加载失败时检查 ATS 和网络错误，不要直接把示例的全局放开设置复制到生产环境。

### 请求配置

所有广告类型都支持 `IFLYAdRequestConfig`。先向平台申请与 App、广告形式对应的广告位 ID，再创建实例；不要把示例广告位用于生产投放。

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

`settleType`、`bidFloor`、`pmpDeals` 等竞价参数须与平台约定一致，上例数值只用于说明字段类型。一次请求选择 `loadAd`、`loadAdWithRequestConfig:` 或服务端竞价入口中的一种，不要对同一实例同时发起多条加载链路。

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

常用回调包括 `splashAdDidLoad:`、`splashAdDidReady:`、`splashAdDidShow:`、`splashAdDidExpose:`、`splashAdDidClick:`、`splashAdDidClose:`、`splashAdDidSkip:` 和 `splashAd:didFailWithError:`。视频素材还会触发播放开始、暂停、恢复、完成和失败回调。`splashAdDidClose:` 表示倒计时结束并关闭；用户点击跳过通过 `splashAdDidSkip:` 通知。交互跳转和视频完播不会触发 `splashAdDidClose:`，业务流程应分别处理。

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

NativeFeed 的文字与图片由媒体渲染，SDK 管理曝光、广告点击、跳转和视频播放。`nativeFeedAdDidLoad:` 后按 `ad.adData.materialType` 选择单图、多图或视频布局；图片由媒体下载，视频向 SDK 提供普通 `UIView` 作为承载视图。多图至少显示返回的前两张，第三张可能不存在。显示广告来源标识，并按 `ctaText` 和 `interactionType` 设置操作按钮。

下面是素材已经渲染、视图已经加入 `adContainer` 并完成布局后的挂载片段。`nativeAd` 由控制器强持有；`mediaView` 是显示图片的视图或视频承载视图，其他视图均已创建。完整加载、图片下载和布局代码见[基础卡片示例](IFLYADLibSimple/IFLYADLibSimple/biz/native/IFLYNativeViewController.m)。

```objc
@interface NativeFeedViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) UIView *mediaView;
@property (nonatomic, strong) UILabel *adTitleLabel;
@property (nonatomic, strong) UILabel *adBadgeLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

- (void)attachRenderedNativeAd {
    IFLYNativeFeedAd *ad = self.nativeAd;
    IFLYNativeFeedAdData *data = ad.adData;
    if (!data.isMaterialComplete) return;
    BOOL clickable = data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
                     data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    self.ctaButton.hidden = !clickable;

    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    binder.renderViews = @[self.mediaView, self.adTitleLabel, self.adBadgeLabel];
    binder.clickViews = clickable ? @[self.ctaButton] : @[];
    binder.closeView = self.closeButton;
    binder.videoView = data.materialType == IFLYNativeFeedAdMaterialTypeVideo
        ? self.mediaView : nil;

    IFLYAdError *error = nil;
    if (![ad attachWithViewBinder:binder error:&error]) {
        NSLog(@"NativeFeed attach failed: %ld %@", (long)error.errorCode, error.errorDescription);
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
- `renderViews`、`closeView` 和 `videoView` 始终需要位于 `containerView` 内。外部 CTA 点击时应位于当前广告所在 window/scene，尺寸有效、可见可交互，广告容器处于前台且至少 `2/3` 可见；不能把 window 或控制器根视图作为 CTA。
- 外部 CTA 不满足点击条件时，delegate 通过 `nativeFeedAd:didRejectClickWithError:` 返回 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（`71503`）。按 `[71503/<point>]` 提示修正视图状态，不要自己补发曝光、点击或跳转。同一个点击视图不要同时交给多条广告。
- 关闭按钮交给 `closeView`，不要同时给它添加广告点击回调；业务交互按钮应保留自己的事件处理，不要为了让广告响应而关闭业务交互。
- Cell 离屏、复用或切换为普通内容时，必须对具体容器调用 `detachAdFromContainerView:`；不要用旧 `indexPath` 反查广告。
- 固定、非复用且不迁移的单容器，可以同步调用 `detachFromCurrentContainer`；可复用列表必须按对应容器调用 `detachAdFromContainerView:`，不能把解绑异步延迟到下一轮。
- 列表数据层持有 `IFLYNativeFeedAd`，Cell 只负责渲染和 attach/detach。条目暂时离屏可继续持有同一 Ad；永久删除或页面退出时 detach、置空 delegate 并释放 Ad。
- SDK 管理视频播放器。绑定且曝光后可使用 `startPlay`、`pausePlay`、`resumePlay`、`stopPlay` 控制播放。

常用 `adData` 字段：`materialType`、`templateId`、`title`、`desc`、`content`、`ctaText`、`brand`、`appName`、`icon`、`mainImage`、`imageList`、`imageURLs`、`videoURL`、`videoCoverURL`、`videoDuration`、`targetURL`、`deeplinkURL`、`marketURL`、`downloadURL`、`packageName`、`interactionType` 和 `interactType`。点击和跳转由 SDK 处理，媒体不要自行打开这些 URL。

NativeFeed 回调包括 `nativeFeedAdDidLoad:`、`nativeFeedAdDidRender:`、`nativeFeedAdDidExpose:`、`nativeFeedAdDidClick:`、`nativeFeedAd:didJumpWithSuccess:`、`nativeFeedAdDidClose:`、`nativeFeedAd:didFailWithError:` 和 `nativeFeedAd:didFailToRenderWithError:`；视频素材还会触发播放状态回调。`didRender` 表示挂载完成，曝光仍需满足实际可见条件；不要把它作为曝光或点击的替代信号。

通用版不提供媒体摇一摇上报能力；`reportMediaShakeTriggeredWithError:` 在此发行包返回 `IFLYAdErrorCodeNativeFeedMediaShakeUnavailable`（`71512`），不要直接复用定制渠道的调用方式。

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

生成 token 失败时先检查 `error`，不要发送空 token；将平台返回的 `rspToken` 原样交给对应广告实例。S2S 加载成功后 `bidInfo.price` 固定为 `0`，不能用它代替服务端返回的成交价格。加载成功只表示拿到广告，不代表在媒体竞价中获胜；上例 Win 通知应在实际胜出后发送，失败原因按平台协议填写。不要把完整 token、IDFA 或完整请求响应写入公开日志或问题单。

S2S、Header Bidding 的 token 生命周期、竞价通知时机和失败重试策略以平台双方协议为准；未开通时使用普通 `loadAd`。当前 Simple 演示普通请求，没有独立的 S2S 页面。

## 错误处理与生命周期

所有格式都通过对应 delegate 的 `didFailWithError:` 返回 `IFLYAdError`。无填充、网络错误、超时、素材不完整和容器无效都应允许业务结束本次展示并按业务策略重试；不要在失败回调中无限重试。

- `DidLoad`：响应解析成功，素材可能还在下载。
- `DidReady`：SDK 管理的主素材已就绪，可以展示；NativeFeed 没有 `DidReady`，在 `DidLoad` 后完成自渲染并 attach。
- `isAdValid`：展示前检查实例仍可用。
- `destroy`：主动终止仍被持有的广告；NativeFeed 列表正常离屏只需 detach。
- 页面销毁时置空 delegate、detach 活动 NativeFeed 容器并释放强引用。

## 示例工程

[`IFLYADLibSimple`](IFLYADLibSimple/README.md) 包含五种广告和六个页面，运行方式、广告位配置及逐页验证步骤集中在[示例运行指南](IFLYADLibSimple/README.md)：

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

请先把 [`IFLYAdPrefixHeader.pch`](IFLYADLibSimple/IFLYADLibSimple/Supporting%20Files/IFLYAdPrefixHeader.pch) 中的广告位 ID 替换为平台分配的 ID，再在设备上验证。编译、取得广告、展示和曝光是不同的检查点；无填充时先记录错误码和广告位配置，不要用循环请求替代排查。

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

请在 [Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues) 提交问题，并附 SDK 版本、iOS/Xcode 版本、接入方式、广告形式、复现步骤和错误码。日志与截图先去掉 token、设备标识、个人信息和业务敏感参数。

版本变更见 [`CHANGELOG.md`](./CHANGELOG.md)。
