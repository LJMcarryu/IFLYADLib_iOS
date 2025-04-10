//
//  IFLYSplashViewController.m
//  IFLYADLibDemo
//
//  Created by admin on 6.3.25.
//

#import "IFLYSplashViewController.h"

#import "IFLYADUtil.h"

/// 1. 引入头文件
#import <IFLYADLib/IFLYADLib.h>

/// 2. 声明代理 IFLYSplashAdDelegate 依赖
@interface IFLYSplashViewController ()<IFLYSplashAdDelegate>
/// 3. 创建开屏广告模版
@property (nonatomic, strong) IFLYSplashAd *splashAd;

@end

@implementation IFLYSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    UIButton *loadImageSpalshAdButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 200, self.view.frame.size.width - 80, 50) title:__SPLASH_NATIVE_AD_UNIT_ID__ target:self action:@selector(loadImageSpalshAd)];
    UIButton *loadVideoSpalshAdButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 300, self.view.frame.size.width - 80, 50) title:__SPLASH_VIDEO_AD_UNIT_ID__ target:self action:@selector(loadVideoSpalshAd)];

    [self.view addSubview:loadImageSpalshAdButton];
    [self.view addSubview:loadVideoSpalshAdButton];
}

- (void)loadImageSpalshAd {
    [self loadAdWithUnitId:__SPLASH_NATIVE_AD_UNIT_ID__];
}

- (void)loadVideoSpalshAd {
    [self loadAdWithUnitId:__SPLASH_VIDEO_AD_UNIT_ID__];
}

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
    /// 设置是否禁止摇一摇功能
    /// 默认false 非必填
//    splashAd.disableShaking = false;

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

@end
