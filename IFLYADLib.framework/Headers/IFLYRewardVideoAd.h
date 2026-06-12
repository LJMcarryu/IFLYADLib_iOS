//
//  IFLYRewardVideoAd.h
//  IFLYAdLib
//
//  Created by jmliu6 on 2026/5/8.
//  Copyright © 2026 iflytek. All rights reserved.
//
//  激励视频广告对外公开 API（继承 IFLYAdBase）
//

#import <Foundation/Foundation.h>
#import <IFLYADLib/IFLYAdBase.h>
#import <IFLYADLib/IFLYAdError.h>

@class IFLYRewardVideoAd;

NS_ASSUME_NONNULL_BEGIN

/// 激励视频展示配置。
@interface IFLYRewardVideoAdConfig : IFLYAdShowConfig

@end

/// 激励视频广告事件回调协议
/// @discussion 所有回调方法均为 @optional，且统一在主线程触发。媒体侧通过实现关心的方法
///             感知加载、展示、曝光、点击、发奖、播放完成、关闭与错误。
///             典型时序：didLoad（广告数据解析成功）→ didReady（主素材下载校验完成，可展示）→
///             didShow（控制器展示完成）→ didExpose → [didClick] → didRewardEffective →
///             didPlayFinish → didClose；任一环节失败走 didFailWithError:。
@protocol IFLYRewardVideoAdDelegate <NSObject>

@optional
/// 广告数据加载成功
/// @param ad 触发回调的激励视频广告实例
/// @note 此回调仅表示广告数据解析成功；视频模板和纯图模板主素材均可能仍在预加载，
///       须再等 rewardVideoAdDidReady: 后方可 show。
- (void)rewardVideoAdDidLoad:(IFLYRewardVideoAd *)ad;

/// 主素材下载校验完成（可 show）
/// @param ad 触发回调的激励视频广告实例
/// @note 视频模板表示视频文件已下载并校验通过；纯图模板表示主图已下载并进入缓存。
- (void)rewardVideoAdDidReady:(IFLYRewardVideoAd *)ad;

/// 广告已展示（展示转场完成）
/// @param ad 触发回调的激励视频广告实例
/// @note 在 present 的 completion 中触发；同一次展示只回调一次。
- (void)rewardVideoAdDidShow:(IFLYRewardVideoAd *)ad;

/// 广告渲染失败（展示控制器转场超时或控制器不可见等）。
/// @param ad    触发回调的激励视频广告实例
/// @param error 渲染失败错误
/// @note 这是渲染失败的细分回调；同一失败还会进入 didFailWithError: 统一失败出口。
- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailToRenderWithError:(IFLYAdError *)error;

/// 广告曝光（已计入曝光监测）
/// @param ad 触发回调的激励视频广告实例
- (void)rewardVideoAdDidExpose:(IFLYRewardVideoAd *)ad;

/// 广告被点击
/// @param ad 触发回调的激励视频广告实例
- (void)rewardVideoAdDidClick:(IFLYRewardVideoAd *)ad;

/// 广告点击跳转完成。
/// @param ad      触发回调的广告实例
/// @param success YES 表示跳转成功，NO 表示跳转失败
- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didJumpWithSuccess:(BOOL)success;
/// 用户关闭内嵌落地页。
/// @param ad 触发回调的广告实例
- (void)rewardVideoAdDidDismissLandingPage:(IFLYRewardVideoAd *)ad;
/// 用户关闭应用内 App Store 页面。
/// @param ad 触发回调的广告实例
- (void)rewardVideoAdDidDismissStore:(IFLYRewardVideoAd *)ad;
/// DeepLink 外跳或 App 进入后台。
/// @param ad 触发回调的广告实例
- (void)rewardVideoAdDidLeaveApplication:(IFLYRewardVideoAd *)ad;

/// 视频开始播放（仅视频模板）。
/// @param ad 触发回调的激励视频广告实例
- (void)rewardVideoAdDidStartPlay:(IFLYRewardVideoAd *)ad;
/// 视频暂停播放（仅视频模板）。
/// @param ad 触发回调的激励视频广告实例
- (void)rewardVideoAdDidPausePlay:(IFLYRewardVideoAd *)ad;
/// 视频恢复播放（仅视频模板）。
/// @param ad 触发回调的激励视频广告实例
- (void)rewardVideoAdDidResumePlay:(IFLYRewardVideoAd *)ad;
/// 视频播放完成
/// @param ad 触发回调的激励视频广告实例
/// @note 视频播放至结尾，或播放进度回调中检测到 currentTime >= duration 时触发。
- (void)rewardVideoAdDidPlayFinish:(IFLYRewardVideoAd *)ad;
/// 视频播放失败（仅视频模板）。
/// @param ad    触发回调的激励视频广告实例
/// @param error 播放失败错误
/// @note 这是视频播放失败的细分回调；同一失败还会进入 didFailWithError: 统一失败出口。
- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailToPlayWithError:(IFLYAdError *)error;

/// 激励发放生效
/// @param ad   触发回调的激励视频广告实例
/// @param info 发奖相关信息字典
- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didRewardEffective:(NSDictionary *)info;

/// 广告关闭
/// @param ad 触发回调的激励视频广告实例
/// @note 用户主动关闭或内部错误后自动关闭均会触发；实例已销毁（destroy）时不再回调。
- (void)rewardVideoAdDidClose:(IFLYRewardVideoAd *)ad;

/// 广告加载或展示失败
/// @param ad    触发回调的激励视频广告实例
/// @param error 失败错误，错误码见 IFLYAdError.h（如 71203 未就绪、71204 已过期、71205 已展示过）
- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailWithError:(IFLYAdError *)error;

@end

/// 激励视频广告（公开 API）
/// @discussion 继承 IFLYAdBase，提供激励视频广告的加载、展示、有效性查询与销毁。
///             支持两种模板：视频模板（含 video.url，需预加载视频文件）与纯图模板（仅主图）。
///             典型用法：创建实例 → 设置 delegate → loadAd → 等回调就绪后
///             showAdFromRootViewController:config: → 通过 delegate 感知曝光/点击/发奖/关闭 → destroy。
@interface IFLYRewardVideoAd : IFLYAdBase

/// 事件回调委托（weak，避免循环引用）。delegate 回调均在主线程触发。
@property (nonatomic, weak, nullable) id<IFLYRewardVideoAdDelegate> delegate;
/// 是否含视频模板（YES=视频模板，需等 rewardVideoAdDidReady: 后再 show；
/// NO=纯图模板）。didLoad 回调后可读，show 须等待 rewardVideoAdDidReady:。
/// @note 取值依据为广告数据 video.url 是否非空；解析成功前 adResponseData 为空，读取返回 NO。
@property (nonatomic, assign, readonly) BOOL hasVideoTemplate;
/// 是否横版模板（YES=rendering.screen_orientation == 1；
/// NO=竖版或服务端未下发）。didLoad 回调后可读。
@property (nonatomic, assign, readonly) BOOL isLandscapeTemplate;
/// 加载广告
/// @note 异步执行，结果经 delegate 回调。预检失败（正在加载/正在展示/adUnitId 为空）会直接
///       回调 didFailWithError:。每次调用都会清理上一次加载状态并自增 loadToken 丢弃在途回调。
///       实例已销毁后调用本方法将被忽略。
- (void)loadAd;

/// 使用 S2S 服务端竞价响应 token 加载广告。
/// @param rspToken 媒体服务端竞价胜出后返回给客户端的响应 token。
/// @note 空 token 会回调 @c IFLYAdErrorCodeS2STokenEmpty；重复使用、加载中或已消耗 token 会回调
///       @c IFLYAdErrorCodeS2STokenInvalid。成功加载后的 @c ecpm 固定返回 0.0。
- (void)loadAdWithServerBiddingToken:(NSString *)rspToken;

/// 展示广告
/// @param vc 用于 present 广告控制器的根视图控制器，须已在窗口上且未 present 其他控制器
/// @note 非主线程调用会自动切回主线程。展示前会做一系列校验（实例存活、vc 可用、未展示过、
///       已加载、未过期、素材就绪），任一不满足均回调 didFailWithError:（错误码见 IFLYAdError.h）。
///       展示成功后回调 rewardVideoAdDidShow:，且广告为一次性消费（hasShown 置位，不可重复
///       showAdFromRootViewController:）。
- (void)showAdFromRootViewController:(UIViewController *)vc;

/// 使用展示配置展示广告。
/// @param vc     用于 present 广告控制器的根视图控制器。
/// @param config 展示期配置；传 nil 时使用默认配置。
- (void)showAdFromRootViewController:(UIViewController *)vc config:(nullable IFLYRewardVideoAdConfig *)config;

/// 销毁广告实例，释放资源并关闭可能在展示中的控制器
/// @note 一次性；重复调用将被忽略。会取消进行中的视频/图片下载、置位 hasDestroyed 丢弃在途回调，
///       并关闭可能仍在展示中的广告页、落地页或商店页。调用后该实例不应再使用。
- (void)destroy;

/// 缓存广告是否仍然可用（未过期 + 未展示）
/// @return YES 表示已加载、未展示、未销毁、未过期，且对应模板素材（视频文件/图片缓存）校验通过，可立即 show
- (BOOL)isAdValid;

/// 返回当前广告价格，单位：元。未加载或无价格时返回 -1.0。
- (double)ecpm;

@end

NS_ASSUME_NONNULL_END
