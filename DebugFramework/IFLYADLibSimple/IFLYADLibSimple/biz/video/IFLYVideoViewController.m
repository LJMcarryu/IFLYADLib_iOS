//
//  IFLYVideoViewController.m
//  IFLYADLibDemo
//
//  Created by admin on 6.3.25.
//

#import "IFLYVideoViewController.h"

/// 1. 引入头文件
#import <IFLYADLib/IFLYADLib.h>

#import "IFLYADUtil.h"

/// 2. 声明代理 IFLYVideoAdDelegate 依赖
@interface IFLYVideoViewController ()<IFLYVideoAdDelegate>
/// 3. 创建视频广告模版
@property (nonatomic, strong) IFLYVideoAd *videoAd;

@end

@implementation IFLYVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    UIButton *loadVideoAdButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 200, self.view.frame.size.width - 80, 50) title:__PATCH_VIDEO_AD_UNIT_ID__ target:self action:@selector(loadVideoAd)];

    [self.view addSubview:loadVideoAdButton];
}

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
//    videoAd.jumperViewController = self;
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

@end
