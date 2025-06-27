////
////  IFLYCustomSplashAdapter.m
////  IFLYADLibSimple
////
////  Created by admin on 4.3.25.
////
//
//#import <IFLYADLib/IFLYADLib.h>
//#import "IFLYCustomSplashAdapter.h"
//
//@interface IFLYCustomSplashAdapter () <IFLYSplashAdDelegate>
//
//@property (nonatomic, strong) IFLYSplashAd *splashAd;
//
//@end
//
//@implementation IFLYCustomSplashAdapter
//
//- (BUMMediatedAdStatus)mediatedAdStatus {
//    return BUMMediatedAdStatusNormal;
//}
//
//- (void)dismissSplashAd {
//}
//
//- (void)loadSplashAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
//    /// 传入广告位ID 生成 IFLYSplashAd
//    IFLYSplashAd *splashAd = [[IFLYSplashAd alloc] initWithAdUnitId:slotID];
//
//    splashAd.delegate = self;
//
//    /// 传入 IFLYSplashAd 拓展的参数
//    /// 完整参数和释义可参考 'IFLYAdKeys.h' 文件和开发文档
//    ///
//    /// 广告请求UA（传入的UA为浏览器UA） 「必填」
//    /// 但可以不用实现 因为
//    /// ⚠️ SDK会尝试获取 UA 需要观察日志中 request 请求体中 ua 字段是否有值
////    [splashAd setParamValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148" forKey:IFLYAdKeyUA];
//    ///
//    /// TODO: IDFA 和 CAIDList 「必填」二选一
//    /// ⚠️ SDK会尝试获取 IDFA 需要观察日志中 request 请求体中 idfa 字段是否有值
////    [splashAd setParamValue:@"4C5BA5FB-8EB4-4EEB-BF8F-B38921301128" forKey:IFLYAdKeyIDFA];
//    /// 广协 CAIDList 示例
//    /// ⚠️ 需要去广协官网进行申请 具体可询问相关运营
////    [splashAd setParamValue:@[@{ @"ver": @"20230330", @"caid": @"75c7bc3754b3019c135b526cb8eb4420" }, @{ @"ver": @"20220111", @"caid": @"8799abe1c76805fab06ee3f98a3f704e" }] forKey:IFLYAdKeyCAIDList];
//
//    /// ⚠️⚠️⚠️ 如果是实时竞价广告 以下两个参数「必填」
//    /// 交易方式 IFLYAdKeySettleType Number
//    /// 底价 IFLYAdKeyBIDFloor 单位：元
////    {
////        [splashAd setParamValue:@1 forKey:IFLYAdKeySettleType];
////        [splashAd setParamValue:@"0.01" forKey:IFLYAdKeyBIDFloor];
////    }
//
//    /// 是否开启开屏互动 默认：1 开启 非必填
////    [splashAd setParamValue:@1 forKey:IFLYAdKeyInteractStatus];
//
//    /// 传入 IFLYSplashAd 自定义属性
//    ///
//    /// 设置媒体自定义展示 Window
//    /// ⚠️⚠️⚠️ 广告视图必须是放在此自定义window上
//    /// ⚠️ 媒体如果将广告添加在自定义的window上，此参数「必填」
////    splashAd.customWindow = user_window;
//    ///
//    /// 设置广告倒计时
//    /// 取值范围 3s～5s 默认5s 非必填
////    splashAd.traceDuration = 3;
//
//    /// 设置媒体自定义底部图片
//    /// 宽度是屏幕宽度 只有高度生效  非必填
//    splashAd.mediumBottomView = parameter[BUMAdLoadingParamSPCustomBottomView];
//
//    /// 设置是否支持摇一摇功能
//    /// 默认true 非必填
////    splashAd.shakingAllowStatus = true;
//
//    __weak typeof(self) weakSelf = self;
//    self.splashAd.didShowBlock = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdWillVisible:strongSelf];
//    };
//    self.splashAd.didShowFailedBlock = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdDidShowFailed:strongSelf error:[NSError new]];
//    };
//    self.splashAd.didJumpBlock = ^(BOOL success) {
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdDidClick:strongSelf];
//    };
//    self.splashAd.didLeaveApp = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdWillPresentFullScreenModal:strongSelf];
//    };
//    self.splashAd.didCloseBlock = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdDidCountDownToZero:strongSelf];
//        [strongSelf.bridge splashAdDidClose:strongSelf];
//        [strongSelf.bridge splashAdViewControllerDidClose:strongSelf];
//    };
//    self.splashAd.didSkipBlock = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdDidClickSkip:strongSelf];
//    };
//    self.splashAd.dismissBlock = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdWillDismissFullScreenModal:strongSelf];
//    };
//    self.splashAd.dismissStoreBlock = ^{
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf.bridge splashAdWillDismissFullScreenModal:strongSelf];
//    };
//    /// 请求广告 「必填」
//    self.splashAd = splashAd;
//    [splashAd loadAd];
//}
//
//- (void)showSplashAdInWindow:(nonnull UIWindow *)window parameter:(nonnull NSDictionary *)parameter {
//}
//
//- (void)didReceiveBidResult:(BUMMediaBidResult *)result {
//    // 在此处理Client Bidding的结果回调
//}
//
//#pragma mark - IFLYSplashAdDelegate
//
///**
// *  开屏广告加载广告数据成功回调
// *
// *  @param adData IFLYAdData对象
// */
//- (void)onSplashAdReceived:(IFLYAdData *)adData {
//    /// 加载完成
//    [self.bridge splashAd:self didLoadWithExt:@{}];
//
//    /// 请求到广告后，准备展示广告；有两种广告，运营会提前配置好，多沟通
//    /// 非实时竞价
//    if (!adData.price || adData.price <= 0) {
//        /// 曝光广告 「必填」
//        [self.splashAd showAd];
//    }
//
//    /// 实时竞价
//    {
//        if (adData.price && adData.price > 0) {
//        /// 发送是否竞价获胜的通知
//        /// 完整参数和释义可参考 'IFLYSplashAd.h' 文件和开发文档
//        /// ⚠️⚠️⚠️ 竞价广告 此字段「必填」
//            [self.splashAd sendWinNoticeWithType:@100 reason:@"讯飞广告竞价成功"];
//
//        /// 填写实际成交价 单位：元
//        /// ⚠️⚠️⚠️ 竞价广告 此字段「必填」
////            [self.splashAd setParamValue:@"0.11" forKey:IFLYAdKeyAuctionPrice];
//
//        /// 曝光广告 「必填」
//            [self.splashAd showAd];
//        }
//    }
//}
//
///**
// *  开屏广告错误回调
// **/
//- (void)onSplashAdFailed:(IFLYAdError *)error {
//    /// 加载失败
//    [self.bridge splashAd:self didLoadFailWithError:nil ext:@{}];
//}
//
//@end
