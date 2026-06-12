//
//  IFLYSplashAd.h
//  IFLYAdLib
//
//  Created by jmliu6 on 2023/5/10.
//  Copyright © 2023 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IFLYADLib/IFLYAdBase.h>

NS_ASSUME_NONNULL_BEGIN

@class IFLYAdData;
@class IFLYAdError;
@class IFLYSplashAd;

/// 开屏展示配置。用于在 show 阶段一次性传入窗口、倒计时、底部视图、交互与静音配置。
/// @discussion 展示期参数只通过 showAdFromRootViewController:config: 传入，避免与加载参数混在一起。
@interface IFLYSplashAdConfig : IFLYAdShowConfig

/// 媒体自定义展示 Window。非空时开屏本体 addSubview 到该 window；为空时使用 rootVC 所在 window。
@property (nonatomic, weak, nullable) UIWindow *customWindow;
/// 广告倒计时时长，单位秒。有效值为 3~5；默认 5，传 0 或越界值时展示层回退为 5。
@property (nonatomic, assign) NSInteger traceDuration;
/// 媒体自定义底部视图，例如 App Logo 区域。视图高度由媒体侧控制。
@property (nonatomic, strong, nullable) UIView *mediumBottomView;
/// 摇一摇/扭一扭交互方式开关。默认 NO=摇一摇；YES=降级为扭一扭，并非禁用交互。
@property (nonatomic, assign) BOOL headingInteractionEnabled;
/// 是否显示"免除广告"按钮。默认 NO。
@property (nonatomic, assign) BOOL showNoAds;
@end

/// 开屏广告代理协议。所有回调方法均为 @optional，且统一在主线程触发。
@protocol IFLYSplashAdDelegate <NSObject>

@optional
/// 广告响应解析成功，主素材尚未下载完成；此时可读取 adData / bidInfo 做竞价决策。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidLoad:(IFLYSplashAd *)ad;
/// 主素材下载校验完成，此时 isAdValid 可返回 YES，可调用 showAdFromRootViewController:。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidReady:(IFLYSplashAd *)ad;
/// 开屏已展示到宿主 window。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidShow:(IFLYSplashAd *)ad;
/// 开屏达到有效曝光并完成曝光监测上报。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidExpose:(IFLYSplashAd *)ad;
/// 用户点击广告。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidClick:(IFLYSplashAd *)ad;
/// 广告点击跳转完成。
/// @param ad      触发回调的开屏广告实例
/// @param success YES 表示跳转成功，NO 表示跳转失败
- (void)splashAd:(IFLYSplashAd *)ad didJumpWithSuccess:(BOOL)success;
/// 用户关闭内嵌落地页。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidDismissLandingPage:(IFLYSplashAd *)ad;
/// 用户关闭应用内 App Store 页面。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidDismissStore:(IFLYSplashAd *)ad;
/// DeepLink 外跳或 App 进入后台。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidLeaveApplication:(IFLYSplashAd *)ad;
/// 视频开始播放（仅视频开屏）。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidStartPlay:(IFLYSplashAd *)ad;
/// 视频暂停播放（仅视频开屏）。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidPausePlay:(IFLYSplashAd *)ad;
/// 视频恢复播放（仅视频开屏）。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidResumePlay:(IFLYSplashAd *)ad;
/// 视频播放完成（仅视频开屏）。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidPlayFinish:(IFLYSplashAd *)ad;
/// 视频播放失败（仅视频开屏）。
/// @param ad    触发回调的开屏广告实例
/// @param error 播放失败错误
/// @note 这是视频播放失败的细分回调；同一失败还会进入 didFailWithError: 统一失败出口。
- (void)splashAd:(IFLYSplashAd *)ad didFailToPlayWithError:(IFLYAdError *)error;
/// 倒计时自然结束，广告关闭。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidClose:(IFLYSplashAd *)ad;
/// 用户点击跳过按钮，广告关闭。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidSkip:(IFLYSplashAd *)ad;
/// 用户点击"免除广告"按钮。SDK 内部不执行关闭或跳转。
/// @param ad 触发回调的开屏广告实例
- (void)splashAdDidTapNoAds:(IFLYSplashAd *)ad;
/// 广告加载或展示失败。
/// @param ad    触发回调的开屏广告实例
/// @param error 失败错误
- (void)splashAd:(IFLYSplashAd *)ad didFailWithError:(IFLYAdError *)error;

@end

/// 开屏广告
/// @discussion 开屏广告为全屏展示的广告形式，支持图片和视频素材，通常在 App 启动时展示。
///             典型接入流程：initWithAdUnitId: → 设置 delegate → loadAd → splashAdDidReady: →
///             showAdFromRootViewController:
@interface IFLYSplashAd : IFLYAdBase

/// 委托对象，用于接收广告加载结果回调
/// @note 回调均在主线程触发，delegate 为弱引用
@property (nonatomic, weak, nullable) id<IFLYSplashAdDelegate> delegate;
/// 当前加载的广告数据。splashAdDidLoad: 后可读，未加载或已销毁时为 nil。
@property (nonatomic, strong, readonly, nullable) IFLYAdData *adData;
/// 是否为视频素材。splashAdDidLoad: 后可读。
@property (nonatomic, assign, readonly) BOOL hasVideoTemplate;
/// 是否横版模板。splashAdDidLoad: 后可读，取决于服务端 @c rendering.screen_orientation == 1。
/// @discussion 该字段只透出服务端模板方向，不改变开屏本体的全屏承载方式、宿主方向或布局策略。
@property (nonatomic, assign, readonly) BOOL isLandscapeTemplate;

/// 发起广告请求
/// @discussion [必选] 发起拉取广告请求，广告数据返回后通过 delegate 回调通知。
///             调用前需确保已设置 delegate
/// @note 成功时依次回调 splashAdDidLoad: → splashAdDidReady:；失败时回调 splashAd:didFailWithError:
- (void)loadAd;

/// 使用 S2S 服务端竞价响应 token 发起广告加载。
/// @param rspToken 媒体服务端竞价胜出后返回给客户端的响应 token。
/// @note 空 token 会回调 @c IFLYAdErrorCodeS2STokenEmpty；重复使用、加载中或已消耗 token 会回调
///       @c IFLYAdErrorCodeS2STokenInvalid。成功加载后的 @c ecpm 固定返回 0.0。
- (void)loadAdWithServerBiddingToken:(NSString *)rspToken;

/// 展示开屏广告
/// @param vc 用于确认宿主窗口并承载落地页的根视图控制器，须已加入 window。
/// @discussion 须在 splashAdDidReady: 回调后调用。开屏本体以 addSubview 覆盖在 vc.view.window 上。
/// @note 展示结果通过 splashAdDidShow: / splashAd:didFailWithError: 回调通知。
- (void)showAdFromRootViewController:(UIViewController *)vc;

/// 携带展示配置展示开屏广告。
/// @param vc     用于确认宿主窗口并承载落地页的根视图控制器，须已加入 window。
/// @param config 展示配置；传 nil 时使用默认配置。
/// @discussion 须在 splashAdDidReady: 回调后调用。
- (void)showAdFromRootViewController:(UIViewController *)vc config:(nullable IFLYSplashAdConfig *)config;

/// 销毁广告，释放资源并使在途请求/下载回调失效
/// @discussion 调用后会取消在途的广告请求与视频下载、断开呈现层回交，使在途回调因 token 失配被丢弃。
///             销毁后再次调用 loadAd 不会发起新请求。建议在不再使用该广告实例时调用。
/// @note 幂等，重复调用无副作用
- (void)destroy;

/// 广告当前是否可展示。
/// @return 已加载且素材就绪、未展示/未销毁、未过期且素材有效时返回 YES。
- (BOOL)isAdValid;

/// 返回当前广告价格，单位：元。未加载或无价格时返回 -1.0。
- (double)ecpm;

@end

NS_ASSUME_NONNULL_END
