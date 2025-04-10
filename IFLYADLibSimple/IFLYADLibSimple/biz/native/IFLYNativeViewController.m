//
//  IFLYNativeViewController.m
//  IFLYADLibDemo
//
//  Created by admin on 6.3.25.
//

#import "IFLYNativeViewController.h"

/// 1. 引入头文件
#import <IFLYADLib/IFLYADLib.h>

#import "IFLYADUtil.h"

/// 2. 声明代理 IFLYNativeAdDelegate 依赖
@interface IFLYNativeViewController ()<IFLYNativeAdDelegate>

/// 3. 创建图片广告模版
@property (nonatomic, strong) IFLYNativeAd *nativeAd;

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation IFLYNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    UIButton *loadNativeAdButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 200, self.view.frame.size.width - 80, 50) title:__TYPED_ONE_NATIVE_AD_UNIT_ID__ target:self action:@selector(loadNativeAd)];

    [self.view addSubview:loadNativeAdButton];
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300, XH_ScreenW, 200)];
    [self.view addSubview:self.imgView];
    self.imgView.contentMode = UIViewContentModeScaleToFill;
    self.imgView.clipsToBounds = YES;
}

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
//    nativeAd.jumperViewController = self;


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

#pragma mark - IFLYNativeAdDelegate

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

@end
