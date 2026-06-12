//
//  IFLYInterstitialAd.h
//  IFLYADLib
//
//  插屏广告对外公开头（API 契约）：声明插屏广告类、加载配置类与委托协议。

#import <Foundation/Foundation.h>
#import <IFLYADLib/IFLYAdBase.h>
#import <IFLYADLib/IFLYAdError.h>

@class IFLYInterstitialAd;

/// 插屏广告的呈现样式。
typedef NS_ENUM(NSInteger, IFLYInterstitialPresentationStyle) {
    /// 半屏：素材按比例居中显示，四周留出半透明遮罩，内容带圆角。
    IFLYInterstitialPresentationStyleHalfScreen = 0,
    /// 全屏：素材铺满整屏，遮罩为纯黑。
    IFLYInterstitialPresentationStyleFullScreen = 1,
};

/// 插屏展示配置。
@interface IFLYInterstitialAdConfig : IFLYAdShowConfig

/// 插屏呈现样式，默认 IFLYInterstitialPresentationStyleHalfScreen。
/// @discussion 展示形态只通过 showAdFromRootViewController:config: 的 config 控制。
@property (nonatomic, assign) IFLYInterstitialPresentationStyle presentationStyle;

@end

NS_ASSUME_NONNULL_BEGIN

/// 插屏广告事件委托协议。
/// @discussion 所有回调均在主线程派发。
///             方法均为可选，按需实现；委托为 weak 持有，需自行保证生命周期。
@protocol IFLYInterstitialAdDelegate <NSObject>

@optional
/// 广告数据请求并解析成功（素材尚未预加载完成）。此后可读 @c hasVideoTemplate / @c isLandscapeTemplate。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidLoad:(IFLYInterstitialAd *)ad;
/// 素材（图片或视频）预加载并校验通过，广告已可展示（@c -isAdValid 此时为 YES）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidReady:(IFLYInterstitialAd *)ad;
/// 插屏已展示（首次成功 present 完成时回调，整个展示周期仅触发一次）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidShow:(IFLYInterstitialAd *)ad;
/// 广告内容渲染完成（整个展示周期仅触发一次）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidRender:(IFLYInterstitialAd *)ad;
/// 渲染失败（控制器渲染失败或 present 超时触发）。失败后广告进入已关闭态。
/// @param ad    触发回调的广告实例
/// @param error 渲染失败错误
- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailToRenderWithError:(IFLYAdError *)error;
/// 曝光成功（曝光监测上报后回调）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidExpose:(IFLYInterstitialAd *)ad;
/// 广告被点击（普通点击或摇一摇触发点击均回调，并已发起落地页跳转）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidClick:(IFLYInterstitialAd *)ad;
/// 广告点击跳转完成。
/// @param ad      触发回调的广告实例
/// @param success YES 表示跳转成功，NO 表示跳转失败
- (void)interstitialAd:(IFLYInterstitialAd *)ad didJumpWithSuccess:(BOOL)success;
/// 用户关闭内嵌落地页。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidDismissLandingPage:(IFLYInterstitialAd *)ad;
/// 用户关闭应用内 App Store 页面。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidDismissStore:(IFLYInterstitialAd *)ad;
/// DeepLink 外跳或 App 进入后台。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidLeaveApplication:(IFLYInterstitialAd *)ad;
/// 视频开始播放（仅视频素材；整个展示周期仅触发一次）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidStartPlay:(IFLYInterstitialAd *)ad;
/// 视频暂停播放（仅视频素材）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidPausePlay:(IFLYInterstitialAd *)ad;
/// 视频恢复播放（仅视频素材）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidResumePlay:(IFLYInterstitialAd *)ad;
/// 视频播放完成（仅视频素材）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidPlayFinish:(IFLYInterstitialAd *)ad;
/// 视频播放失败（仅视频素材；整个展示周期仅触发一次）。
/// @param ad    触发回调的广告实例
/// @param error 播放失败错误
/// @note 这是视频播放失败的细分回调；同一失败还会进入 didFailWithError: 统一失败出口。
- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailToPlayWithError:(IFLYAdError *)error;
/// 广告关闭（用户关闭或内部错误关闭均回调）。
/// @param ad 触发回调的广告实例
- (void)interstitialAdDidClose:(IFLYInterstitialAd *)ad;
/// 广告流程失败（请求失败、素材预加载失败、展示前置校验失败、超时等统一经此回调）。
/// @param ad    触发回调的广告实例
/// @param error 失败错误
- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailWithError:(IFLYAdError *)error;

@end

/// 插屏广告。SDK 负责请求、素材预加载、内置原生渲染、曝光、点击、关闭和视频播放监测。
/// @discussion 典型生命周期：以 @c -initWithAdUnitId: （继承自 @c IFLYAdBase）创建实例 →
///             @c -loadAd 发起请求并预加载素材 → 收到
///             @c interstitialAdDidReady: 后设置 @c IFLYInterstitialAdConfig.presentationStyle 并调用
///             @c -showAdFromRootViewController:config: 展示 → 用完调用 @c -destroy 释放。
/// @warning 单个实例为一次性使用：展示或关闭后不可复用，再次 @c -loadAd 会以
///          @c IFLYAdErrorCodeInterstitialAdAlreadyUsed / @c IFLYAdErrorCodeInterstitialAdClosed 失败。
@interface IFLYInterstitialAd : IFLYAdBase

/// 事件委托。weak 持有，回调均在主线程派发。
@property (nonatomic, weak, nullable) id<IFLYInterstitialAdDelegate> delegate;
/// 是否为视频素材。didLoad 回调后可读。
/// @discussion 取决于服务端下发的 @c ad.video.url 是否非空；为 NO 时表示图片素材。
@property (nonatomic, assign, readonly) BOOL hasVideoTemplate;
/// 是否横版模板。didLoad 回调后可读，取决于 rendering.screen_orientation == 1。
@property (nonatomic, assign, readonly) BOOL isLandscapeTemplate;
/// 摇一摇/扭一扭交互方式开关。默认 NO=摇一摇（加速度计）；YES=降级为扭一扭（罗盘角度），并非禁用交互。
/// @note 仅当广告启用了摇一摇交互（shake_info 下发）时生效；置 YES 后改走罗盘朝向判定，
///       触发上报省略 acc_*/new_acc_* 加速度宏（与开屏一致）。须在展示前设置。
@property (nonatomic, assign) BOOL headingInteractionEnabled;

/// 发起广告请求并预加载素材（等价于以默认配置加载）。
/// @note 内部有防重入与一次性校验：实例已用过/已关闭/已销毁时直接以失败回调返回；
///       重复调用会取消上一次在途请求并以新 token 重新加载。
- (void)loadAd;
/// 使用 S2S 服务端竞价响应 token 发起广告请求并预加载素材。
/// @param rspToken 媒体服务端竞价胜出后返回给客户端的响应 token。
/// @note 空 token 会回调 @c IFLYAdErrorCodeS2STokenEmpty；重复使用、加载中或已消耗 token 会回调
///       @c IFLYAdErrorCodeS2STokenInvalid。成功加载后的 @c ecpm 固定返回 0.0。
- (void)loadAdWithServerBiddingToken:(NSString *)rspToken;
/// 展示插屏广告。
/// @param vc 用于 present 的根视图控制器，须已加入 window；内部会沿其链路找到最顶层可呈现控制器。
/// @discussion 半屏/全屏由 @c IFLYInterstitialAdConfig.presentationStyle 控制；未传 config 时默认半屏。
/// @note 须在 @c interstitialAdDidReady: 之后调用；前置校验不通过会经 @c interstitialAd:didFailWithError: 返回错误。
- (void)showAdFromRootViewController:(UIViewController *)vc;
/// 使用展示配置展示插屏广告。
/// @param vc     用于 present 的根视图控制器。
/// @param config 展示期配置；传 nil 时使用默认配置。
- (void)showAdFromRootViewController:(UIViewController *)vc config:(nullable IFLYInterstitialAdConfig *)config;
/// 销毁广告：取消下载、停止摇一摇监听、关闭并释放展示控制器、清空响应数据。幂等，重复调用无副作用。
- (void)destroy;
/// 广告当前是否可展示。
/// @return 已加载且素材就绪、未展示/未关闭/未销毁、未过期且素材文件校验通过时返回 YES。
- (BOOL)isAdValid;
/// 返回当前广告价格，单位：元。未加载或无价格时返回 -1.0。
- (double)ecpm;

@end

NS_ASSUME_NONNULL_END
