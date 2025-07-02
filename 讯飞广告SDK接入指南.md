# SDK接入说明

讯飞广告SDK代码托管地址：[IFLYADLib_iOS](https://github.com/LJMcarryu/IFLYADLib_iOS)

## SDK版本发布记录
| 文档版本 | 修订日期 | 修订说明 |
|-------|-------|-------|
| v5.2.5 | 2025-07-02 | 【新增】添加免除广告按钮<br>【新增】IFLYADLib_simulator调试库 |
| v5.1.1 | 2025-06-09 | 【新增】开屏广告添加网盘定制物料回调信息 |
| v5.1.0 | 2025-05-12 | 【新增】开屏广告添加广告方logo标识 |
| v5.0.8 | 2025-04-18 | 【优化】将包改为静态库 |
| v5.0.5 | 2025-04-18 | 【优化】进一步优化包体积 |
| v5.0.4 | 2025-04-17 | 【优化】优化包体积 |
| v5.0.3 | 2025-04-10 | 【优化】优化摇一摇功能 |
| v5.0.2 | 2025-04-01 | 【新增】原生广告可选参数 jumperViewController |
| v5.0.1 | 2025-03-07 | 【新增】SDK接入demo |
| v5.0.0 | 2025-03-07 | 【优化】支持CocoaPods导入<br>【优化】SDK文档说明 |

## SDK准备工作

### 接入须知
目前SDK已支持CocoaPods引入，**v < 5.0.0** 仅支持本地导入，**v >= 5.0.0** 开始支持CocoaPods方式。`v5.0.0以下版本更新到v5.0.0及以上版本，iOS集成方式会发生变更，详见下方说明。`

### CocoaPods引入
```
platform :ios, '11.0'

target 'YOUR_RELEASE_TARGET' do
    use_frameworks!
    pod 'IFLYADLib'
end
```

### 本地导入
获取framework库，导入项目工程即可。

SDK的framework库结构：

| 名称 | 简介 |
|-------|-------|
| IFLYADLib.framework | 接口层及广告业务实现层 |

### 运行环境配置
支持系统iOS 11.0 及以上

* SDK编译环境 Xcode 14.1 及以上版本
* 支持架构： arm64(⚠️仅支持真机测试)

### iOS14适配说明
以往广告归因依赖于IDFA。从iOS14开始，只有在获得用户明确许可的前提下，应用才可以访问用户的IDFA数据并向用户投放定向广告。在应用程序调用 App Tracking Transparency 框架向最终用户提出应用程序跟踪授权请求之前，IDFA将不可用。如果某个应用未提出此请求，则读取到的IDFA将返回全为0的字符串，这个可能会导致广告收入降低。

ATT(App Tracking Transparency)，适用于请求用户权限，访问与应用相关的数据已跟踪用户或设备。在iOS14.5以后(之前不做配置也能正常获取IDFA)想要依旧能使用IDFA，建议开发者在初始化SDK之前获取ATT授权，以便允许用户授权跟踪权限。

首先，需要在App层级的info.plist里添加ATT权限描述：

```
<key>NSUserTrackingUsageDescription</key>brbr<string>ATT权限使用说明，需要开发者自行设置描述</string>
```

其次，在代码层面请求授权，建议最好在SDK初始化之前请求授权。

```
#import <AppTrackingTransparency/AppTrackingTransparency.h>

- (void)requestIDFA {
  [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {}];
}
```
以上配置好之后，在APP启动后会出现如下ATT授权对话框, 点击"允许跟踪"将会使APP正常获取到IDFA。

### 隐私合规配置
SDK支持的隐私合规相关配置目前主要集中在**IFLYAdConfig**类来集中管理。

```
/// 设置是否开启个性化推荐
[IFLYAdConfig setPersonalizedEnabled:YES];
```
| 名称 | 简介 |
|-------|-------|
| /// 设置是否开启个性化推荐<br>/// - Parameter enabled: 是否开启个性化推荐<br>+ (void)setPersonalizedEnabled:(BOOL)enabled; | 个性化广告推荐<br><br>是否开启个性化广告：YES - 开启，NO - 关闭，默认YES |

## SDK接入
### SDK初始化说明
* 所有广告类型统一引用`#import <IFLYADLib/IFLYADLib.h>`头文件即可调用对应方法进行集成
* 接入过程中，建议尽量使用填充量100%的广告位id进行测试

SDK初始化操作由**IFLYAdConfig**类来完成。

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ......
    
    /// 设置是否开启个性化推荐
    [IFLYAdConfig setPersonalizedEnabled:YES];

    return YES;
}
```

### 开屏广告
完整示例如下：

- 创建开屏广告类

```
/// 1. 引入头文件
#import <IFLYADLib/IFLYADLib.h>

/// 2. 声明代理 IFLYSplashAdDelegate 依赖
@interface IFLYSplashViewController ()<IFLYSplashAdDelegate>
/// 3. 创建开屏广告模版
@property (nonatomic, strong) IFLYSplashAd *splashAd;

@end
```

- 初始化并配置开屏广告

```
- (void)loadAdWithUnitId:(NSString *)unitId {
    /// 4. 传入广告位ID 生成 IFLYSplashAd
    IFLYSplashAd *splashAd = [[IFLYSplashAd alloc] initWithAdUnitId:unitId];

    splashAd.delegate = self;

    /// 5. 传入 IFLYSplashAd 拓展的参数
    /// 完整参数和释义可参考 'IFLYAdKeys.h' 文件和开发文档
    ///
    /// 5.1
    /// 应用包名 「必填」⚠️已内部获取 无需填写
//    [splashAd setParamValue:[[NSBundle mainBundle] bundleIdentifier] forKey:IFLYAdKeyAPPBundle];
    /// 5.2
    /// 广告请求UA（传入的UA为浏览器UA） 「必填」
    /// 但可以不用实现 因为
    /// ⚠️ SDK会尝试获取 UA 需要观察日志中 request 请求体中 ua 字段是否有值
//    [splashAd setParamValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148" forKey:IFLYAdKeyUA];
    /// 5.3
    /// IDFA 和 CAIDList 「必填」二选一
    /// ⚠️ SDK会尝试获取 IDFA 需要观察日志中 request 请求体中 idfa 字段是否有值
    [splashAd setParamValue:@"4C5BA5FB-8EB4-4EEB-BF8F-B38921301128" forKey:IFLYAdKeyIDFA];
    /// 广协 CAIDList 示例
    /// ⚠️ 需要去广协官网进行申请 具体可询问相关运营
    [splashAd setParamValue:@[@{ @"ver": @"20230330", @"caid": @"75c7bc3754b3019c135b526cb8eb4420" }, @{ @"ver": @"20220111", @"caid": @"8799abe1c76805fab06ee3f98a3f704e" }] forKey:IFLYAdKeyCAIDList];

    /// 5.4
    /// ⚠️⚠️⚠️ 如果是实时竞价广告 以下两个参数「必填」
    /// 交易方式 IFLYAdKeySettleType Number
    /// 底价 IFLYAdKeyBIDFloor 单位：元
    {
        [splashAd setParamValue:@1 forKey:IFLYAdKeySettleType];
        [splashAd setParamValue:@"0.01" forKey:IFLYAdKeyBIDFloor];
    }

    /// 5.5
    /// 是否开启开屏互动 默认：1 开启 非必填
    [splashAd setParamValue:@1 forKey:IFLYAdKeyInteractStatus];

    /// 6. 传入 IFLYSplashAd 自定义属性
    ///
    /// 6.1
    /// 设置媒体自定义展示 Window
    /// ⚠️⚠️⚠️ 广告视图必须是放在此自定义window上
    /// ⚠️ 媒体如果将广告添加在自定义的window上，此参数「必填」
//    splashAd.customWindow = user_window;
    ///
    /// 6.2
    /// 设置广告倒计时
    /// 取值范围 3s～5s 默认5s 非必填
    splashAd.traceDuration = 5;
    /// 6.3
    /// 设置媒体自定义底部图片
    /// 宽度是屏幕宽度 只有高度生效  非必填
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    bottomView.backgroundColor = UIColor.cyanColor;
    splashAd.mediumBottomView = bottomView;
    ///
    /// 6.4
    /// 设置是否支持摇一摇功能
    /// 默认true 非必填
    splashAd.shakingAllowStatus = true;

    /// 7. 监听各种回调，自行实现额外的操作
    splashAd.didShowBlock = ^{
        NSLog(@"视图展示成功 didShowBlock");
    };
    splashAd.didShowFailedBlock = ^{
        NSLog(@"视图展示失败 didShowFailedBlock");
    };
    splashAd.didJumpBlock = ^(BOOL success) {
        NSLog(@"视图交互成功并跳转 didJumpBlock: %d", success);
    };
    splashAd.didLeaveApp = ^{
        NSLog(@"didLeaveApp");
    };
    splashAd.didCloseBlock = ^{
        NSLog(@"didCloseBlock");
    };
    splashAd.didSkipBlock = ^{
        NSLog(@"didSkipBlock");
    };
    splashAd.dismissBlock = ^{
        NSLog(@"dismissBlock");
    };
    splashAd.dismissStoreBlock = ^{
        NSLog(@"dismissStoreBlock");
    };

    /// 8. 请求广告 「必填」
    self.splashAd = splashAd;
    [splashAd loadAd];
}
```

- 实现 IFLYSplashAdDelegate

```
#pragma mark - IFLYSplashAdDelegate

/**
 *  开屏广告加载广告数据成功回调
 *
 *  @param adData IFLYAdData对象
 */
- (void)onSplashAdReceived:(IFLYAdData *)adData {
    /// 9. 请求到广告后，准备展示广告；有两种广告，运营会提前配置好，多沟通
    /// 9.1
    /// 非实时竞价
    if (!adData.price || adData.price <= 0) {
        /// 9.1.1
        /// 曝光广告 「必填」
        [self.splashAd showAd];
    }

    /// 9.2
    /// 实时竞价
    {
        if (adData.price && adData.price > 0) {
            /// 9.2.1
            /// 发送是否竞价获胜的通知
            /// 完整参数和释义可参考 'IFLYSplashAd.h' 文件和开发文档
            /// ⚠️⚠️⚠️ 竞价广告 此字段「必填」
            [self.splashAd sendWinNoticeWithType:@100 reason:@"测试竞价成功"];
            /// 9.2.2
            /// 填写实际成交价 单位：元
            /// ⚠️⚠️⚠️ 竞价广告 此字段「必填」
            [self.splashAd setParamValue:@"0.11" forKey:IFLYAdKeyAuctionPrice];
            /// 9.2.3
            /// 曝光广告 「必填」
            [self.splashAd showAd];
        }
    }
}

/**
 *  开屏广告错误回调
 *
 *  @param error 错误码，详见接入手册
 */
- (void)onSplashAdFailed:(IFLYAdError *)error {
}
```

`详细接入可参照demo中的IFLYSplashViewController类。`

### 非开屏自渲染图片广告
完整示例如下：

- 创建图片广告类

```
/// 1. 引入头文件
#import <IFLYADLib/IFLYADLib.h>

/// 2. 声明代理 IFLYNativeAdDelegate 依赖
@interface IFLYNativeViewController ()<IFLYNativeAdDelegate>
/// 3. 创建图片广告模版
@property (nonatomic, strong) IFLYNativeAd *nativeAd;

@end
```

- 初始化并配置图片广告

```
- (void)loadNativeAd {
    /// 4. 传入广告位ID 生成 IFLYNativeAd
    IFLYNativeAd *nativeAd = [[IFLYNativeAd alloc] initWithAdUnitId:__TYPED_ONE_NATIVE_AD_UNIT_ID__];

    nativeAd.delegate = self;

    /// 5. 传入 IFLYNativeAd 拓展的参数
    /// 完整参数和释义可参考 'IFLYNativeAd.h' 文件和开发文档
    ///
    /// 5.1
    /// 应用包名 「必填」⚠️已内部获取 无需填写
//    [nativeAd setParamValue:[[NSBundle mainBundle] bundleIdentifier] forKey:IFLYAdKeyAPPBundle];
    /// 5.2
    /// 广告请求UA（传入的UA为浏览器UA） 「必填」
    /// 但可以不用实现 因为
    /// ⚠️ SDK会尝试获取 UA 需要观察日志中 request 请求体中 ua 字段是否有值
    [nativeAd setParamValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148" forKey:IFLYAdKeyUA];
    /// 5.3
    /// IDFA 和 CAIDList 「必填」二选一
    /// ⚠️ SDK会尝试获取 IDFA 需要观察日志中 request 请求体中 idfa 字段是否有值
    [nativeAd setParamValue:@"4C5BA5FB-8EB4-4EEB-BF8F-B38921301128" forKey:IFLYAdKeyIDFA];
    /// 广协 CAIDList 示例
    /// ⚠️ 需要去广协官网进行申请 具体可询问相关运营
    [nativeAd setParamValue:@[@{ @"ver": @"20230330", @"caid": @"75c7bc3754b3019c135b526cb8eb4420" }, @{ @"ver": @"20220111", @"caid": @"8799abe1c76805fab06ee3f98a3f704e" }] forKey:IFLYAdKeyCAIDList];

    /// 5.4
    /// ⚠️⚠️⚠️ 如果是实时竞价广告 以下两个参数「必填」
    /// 交易方式 IFLYAdKeySettleType Number
    /// 底价 IFLYAdKeyBIDFloor 单位：元
    {
        [nativeAd setParamValue:@1 forKey:IFLYAdKeySettleType];
        [nativeAd setParamValue:@"0.01" forKey:IFLYAdKeyBIDFloor];
    }

    /// 6. 传入 IFLYSplashAd 自定义属性
    ///
    /// 6.1
    /// 显示广告的UIViewController
    /// ⚠️⚠️⚠️⚠️⚠️ 广告视图必须是放在此currentViewController上 「必填」
    nativeAd.currentViewController = self;


    /// 7. 监听各种回调，自行实现额外的操作
    nativeAd.didJumpBlock = ^(BOOL success) {
        NSLog(@"视图交互成功并跳转 didJumpBlock: %d", success);
    };
    nativeAd.didLeaveApp = ^{
        NSLog(@"didLeaveApp");
    };
    nativeAd.dismissBlock = ^{
        NSLog(@"dismissBlock");
    };
    nativeAd.dismissStoreBlock = ^{
        NSLog(@"dismissStoreBlock");
    };
    nativeAd.clickAdAnimateStartBlock = ^{
        NSLog(@"clickAdAnimateStartBlock");
    };
    nativeAd.clickAdAnimateCompleteBlock = ^{
        NSLog(@"clickAdAnimateCompleteBlock");
    };
    nativeAd.closeAdAnimateStartBlock = ^{
        NSLog(@"closeAdAnimateStartBlock");
    };
    nativeAd.closeAdAnimateCompleteBlock = ^{
        NSLog(@"closeAdAnimateCompleteBlock");
    };

    /// 8. 请求广告 「必填」
    self.nativeAd = nativeAd;
    [nativeAd loadAd];
}
```

- 实现 IFLYNativeAdDelegate

```
- (void)onNativeAdReceived:(IFLYAdData *)adData {
    /// 9. 请求到广告后，准备展示广告；有两种广告，运营会提前配置好，多沟通
    /// 9.1
    /// 非实时竞价
    if (!adData.price || adData.price <= 0) {
        /// 9.1.1
        /// 曝光广告 「必填」
        [self showAd:adData.img.url];
    }

    /// 9.2
    /// 实时竞价
    {
        if (adData.price && adData.price > 0) {
            /// 9.2.1
            /// 发送是否竞价获胜的通知
            /// 完整参数和释义可参考 'IFLYSplashAd.h' 文件和开发文档
            /// ⚠️⚠️⚠️ 竞价广告 此字段必传
            [self.nativeAd sendWinNoticeWithType:@103 reason:@"测试竞价失败原因"];
            /// 9.2.2
            /// 填写实际成交价 单位：元
            /// ⚠️⚠️⚠️ 竞价广告 此字段必传
            [self.nativeAd setParamValue:@"0.11" forKey:IFLYAdKeyAuctionPrice];
            /// 9.2.3
            /// 曝光广告 「必填」
            [self showAd:adData.img.url];
        }
    }
}

- (void)onNativeAdFailed:(IFLYAdError *)error {
}

/// 展示自渲染的（插屏、激励、信息流）图片广告
- (void)showAd:(NSString *)imageUrl {
    [IFLYAdTool downloadImageFromURL:imageUrl
                           completed:^(UIImage *_Nonnull image, NSError *_Nonnull error, NSURL *_Nonnull imageURL) {
        if (!error) {
            self.imgView.image = image;
        }
    }];
}
```

`详细接入可参照demo中的IFLYNativeViewController类。`

### 非开屏自渲染视频广告
完整示例如下：

- 创建视频广告类

```
/// 1. 引入头文件
#import <IFLYADLib/IFLYADLib.h>

/// 2. 声明代理 IFLYVideoAdDelegate 依赖
@interface IFLYVideoViewController ()<IFLYVideoAdDelegate>
/// 3. 创建视频广告模版
@property (nonatomic, strong) IFLYVideoAd *videoAd;

@end
```

- 初始化并配置视频广告

```
- (void)loadVideoAd {
    /// 4. 传入广告位ID 生成 IFLYVideoAd
    IFLYVideoAd *videoAd = [[IFLYVideoAd alloc]initWithAdUnitId:__PATCH_VIDEO_AD_UNIT_ID__];

    videoAd.delegate = self;

    // 5. 传入 IFLYVideoAd 拓展的参数
    /// 完整参数和释义可参考 'IFLYAdKeys.h' 文件和开发文档
    ///
    /// 5.1
    /// 应用包名 「必填」⚠️已内部获取 无需填写
//    [video setParamValue:[[NSBundle mainBundle] bundleIdentifier] forKey:IFLYAdKeyAPPBundle];
    /// 5.2
    /// 广告请求UA（传入的UA为浏览器UA） 「必填」
    /// 但可以不用实现 因为
    /// ⚠️ SDK会尝试获取 UA 需要观察日志中 request 请求体中 ua 字段是否有值
    [videoAd setParamValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148" forKey:IFLYAdKeyUA];
    /// 5.3
    /// IDFA 和 CAIDList 「必填」二选一
    /// ⚠️ SDK会尝试获取 IDFA 需要观察日志中 request 请求体中 idfa 字段是否有值
    [videoAd setParamValue:@"4C5BA5FB-8EB4-4EEB-BF8F-B38921301128" forKey:IFLYAdKeyIDFA];
    /// 广协 CAIDList 示例
    /// ⚠️ 需要去广协官网进行申请 具体可询问相关运营
    [videoAd setParamValue:@[@{ @"ver": @"20230330", @"caid": @"75c7bc3754b3019c135b526cb8eb4420" }, @{ @"ver": @"20220111", @"caid": @"8799abe1c76805fab06ee3f98a3f704e" }] forKey:IFLYAdKeyCAIDList];

    /// 5.4
    /// ⚠️⚠️⚠️ 如果是实时竞价广告 以下两个参数「必填」
    /// 交易方式 IFLYAdKeySettleType Number
    /// 底价 IFLYAdKeyBIDFloor 单位：元
    {
        [videoAd setParamValue:@1 forKey:IFLYAdKeySettleType];
        [videoAd setParamValue:@"0.01" forKey:IFLYAdKeyBIDFloor];
    }

    /// 6. 传入 IFLYVideoAd 自定义属性
    ///
    /// 6.1
    /// 显示广告的 UIViewController
    /// ⚠️⚠️⚠️⚠️⚠️ 广告视图必须是放在此自定义 UIViewController 上 此参数「必填」
    videoAd.currentViewController = self;
    /// 6.2
    /// 显示广告的 UIView
    /// ⚠️⚠️⚠️⚠️⚠️ 广告视图必须是放在此 UIView 上
    /// ⚠️⚠️⚠️⚠️⚠️ UIView 必须属于显示广告的 UIViewController 此参数「必填」
    UIView *fatherView = [[UIView alloc]initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.width / 16 * 9)];
    fatherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fatherView];
    videoAd.fatherView = fatherView;

    /// 6.3
    /// 是否静音 是否自动播放 按需设置
    videoAd.mute = YES;
    videoAd.autoPlay = YES;

    /// 6.4
    /// ⚠️ videoType 分三种：开屏、激励、信息流 按需填写 「必填」
    /// ⚠️ 无特殊要求 可填写 IFLYVideoAdTypeReward
    videoAd.videoType = IFLYVideoAdTypeReward;

    /// 7. 监听各种回调，自行实现额外的操作
    videoAd.didJumpBlock = ^(BOOL success) {
        NSLog(@"视图交互成功并跳转 didJumpBlock: %d", success);
    };

    videoAd.didLeaveApp = ^{
        NSLog(@"didLeaveApp");
    };

    videoAd.dismissBlock = ^{
        NSLog(@"dismissBlock");
    };

    videoAd.dismissStoreBlock = ^{
        NSLog(@"dismissStoreBlock");
    };

    /// 8. 请求广告 「必填」
    self.videoAd = videoAd;
    [videoAd loadAd];
}
```

- 实现 IFLYVideoAdDelegate

```
#pragma mark - IFLYVideoAdDelegate

/// 视频广告加载成功回调
/// ⚠️ 必须实现
- (void)onVideoAdReceived:(IFLYAdData *)adData {
    /// 9. 请求到广告后，准备展示广告；有两种广告，运营会提前配置好，多沟通
    /// 9.1
    /// 非实时竞价
    if (!adData.price || adData.price <= 0) {
        /// 9.1.1
        /// 曝光广告 「必填」
        [self.videoAd showAd];
        [self.videoAd attachAd];
    }

    /// 9.2
    /// 实时竞价
    {
        if (adData.price && adData.price > 0) {
            /// 9.2.1
            /// 发送是否竞价获胜的通知
            /// 完整参数和释义可参考 'IFLYSplashAd.h' 文件和开发文档
            /// ⚠️⚠️⚠️ 竞价广告 此字段「必填」
            [self.videoAd sendWinNoticeWithType:@100 reason:@"测试竞价成功"];
            /// 9.2.2
            /// 填写实际成交价 单位：元
            /// ⚠️⚠️⚠️ 竞价广告 此字段「必填」
            [self.videoAd setParamValue:@"0.11" forKey:IFLYAdKeyAuctionPrice];
            /// 9.2.3
            /// 曝光广告 「必填」
            [self.videoAd showAd];
            [self.videoAd attachAd];
        }
    }
}

/// 视频广告失败回调
/// ⚠️ 必须实现
- (void)onVideoAdFailed:(IFLYAdError *)error {
}

/// ------------------------------- 以下选择实现 ----------------------------------------

/**
 *  视频开始播放
 */
- (void)adStartPlay {
}

/**
 *  视频播放出错
 */
- (void)adPlayError {
}

/**
 *  视频播放结束
 */
- (void)adPlayCompleted {
}

/**
 *  视频重新播放
 */
- (void)adReplay {
}

/**
 *  广告被点击
 */
- (void)onVideoAdClicked {
}

#pragma mark - viewDidDisappear

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.videoAd) {
        [self.videoAd stopPlay];
    }
}
```

`详细接入可参照demo中的IFLYVideoViewController类。`
