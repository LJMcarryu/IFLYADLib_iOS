//
//  IFLYNativeFeedAd.h
//  IFLYADLib
//
//  自渲染（信息流）广告对外接口：SDK 负责广告请求、容器绑定、曝光检测、点击/摇一摇响应、
//  关闭与视频播放控制及监测上报；广告 UI 由媒体侧依据 adData 自行渲染。

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IFLYADLib/IFLYAdBase.h>
#import <IFLYADLib/IFLYAdError.h>
#import <IFLYADLib/IFLYNativeFeedAdData.h>

@class IFLYNativeFeedAd;

NS_ASSUME_NONNULL_BEGIN

/// 自渲染信息流视图绑定对象。
/// @discussion 使用该对象完成绑定，避免把容器、渲染视图、点击视图、关闭视图、视频视图散落在长参数方法中。
@interface IFLYNativeFeedAdViewBinder : NSObject

/// 广告容器视图。曝光检测、摇一摇和点击视图归属校验均以它为准。
@property (nonatomic, weak, nullable) UIView *containerView;
/// 渲染视图集合。未传时 SDK 会从下方语义视图中自动收集非空项。
@property (nonatomic, copy, nullable) NSArray<UIView *> *renderViews;
/// 可点击视图集合。未传时默认使用 containerView 作为点击视图。
@property (nonatomic, copy, nullable) NSArray<UIView *> *clickViews;
/// 关闭按钮视图，可为空。
@property (nonatomic, weak, nullable) UIView *closeView;
/// 视频承载视图。视频素材必传，非视频素材可为空。
@property (nonatomic, weak, nullable) UIView *videoView;
/// 标题视图，可选，仅用于自动收集 renderViews。
@property (nonatomic, weak, nullable) UIView *titleView;
/// 描述视图，可选，仅用于自动收集 renderViews。
@property (nonatomic, weak, nullable) UIView *descView;
/// 图标视图，可选，仅用于自动收集 renderViews。
@property (nonatomic, weak, nullable) UIView *iconView;
/// 主图视图，可选，仅用于自动收集 renderViews。
@property (nonatomic, weak, nullable) UIView *imageView;
/// 广告来源视图，可选，仅用于自动收集 renderViews。
@property (nonatomic, weak, nullable) UIView *adSourceView;
/// CTA 视图，可选，仅用于自动收集 renderViews。
@property (nonatomic, weak, nullable) UIView *ctaView;

@end

/// 自渲染信息流代理协议。所有回调均在主线程触发。
/// @discussion 全部方法为 @optional；视频相关回调（didStartPlay/didPausePlay/didResumePlay/
/// didPlayFinish/didFailToPlay）仅在视频素材（hasVideoTemplate==YES）时才会触发。
/// 每个回调对应一次广告生命周期事件，且大多带去重门控（同一事件本类内只回调一次）。
@protocol IFLYNativeFeedAdDelegate <NSObject>

@optional
/// 广告请求成功，媒体侧可读取 ad.adData 自行渲染 UI。
/// @param ad 触发回调的广告实例。
/// @note 在 loadAd 请求成功并校验素材完整后回调；UI 渲染完成后须调用 bindAdWithViewBinder:error: 完成绑定。
- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad;
/// 广告绑定到容器成功。
/// @param ad 触发回调的广告实例。
/// @note bindAdWithViewBinder:error: 成功后回调；本类内对同一次绑定只回调一次。
- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad;
/// 广告绑定或播放器渲染失败。
/// @param ad    触发回调的广告实例。
/// @param error 失败原因（容器/点击视图/视频视图非法、广告已销毁/已关闭/未就绪/已过期、
///              视频播放器创建失败等）。
- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToRenderWithError:(IFLYAdError *)error;
/// 广告达到曝光条件并完成曝光上报。
/// @param ad 触发回调的广告实例。
/// @note 前台活跃、未锁屏且容器在屏可见面积达到 2/3 并连续保持 500ms 后判定曝光；曝光只上报一次。
- (void)nativeFeedAdDidExpose:(IFLYNativeFeedAd *)ad;
/// 广告点击完成处理。
/// @param ad 触发回调的广告实例。
- (void)nativeFeedAdDidClick:(IFLYNativeFeedAd *)ad;
/// 广告点击跳转完成。
/// @param ad      触发回调的广告实例
/// @param success YES 表示跳转成功，NO 表示跳转失败
- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didJumpWithSuccess:(BOOL)success;
/// 用户关闭内嵌落地页。
/// @param ad 触发回调的广告实例
- (void)nativeFeedAdDidDismissLandingPage:(IFLYNativeFeedAd *)ad;
/// 用户关闭应用内 App Store 页面。
/// @param ad 触发回调的广告实例
- (void)nativeFeedAdDidDismissStore:(IFLYNativeFeedAd *)ad;
/// DeepLink 外跳或 App 进入后台。
/// @param ad 触发回调的广告实例
- (void)nativeFeedAdDidLeaveApplication:(IFLYNativeFeedAd *)ad;
/// 广告关闭按钮被点击。
/// @param ad 触发回调的广告实例。
/// @note 关闭后广告进入 hasClosed 状态，不可再绑定。
- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad;
/// 视频素材开始播放。
/// @param ad 触发回调的广告实例。
- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad;
/// 视频素材暂停播放。
/// @param ad 触发回调的广告实例。
/// @note 用户点击暂停、调用 pausePlay 或 App 切后台时触发。
- (void)nativeFeedAdDidPausePlay:(IFLYNativeFeedAd *)ad;
/// 视频素材恢复播放。
/// @param ad 触发回调的广告实例。
- (void)nativeFeedAdDidResumePlay:(IFLYNativeFeedAd *)ad;
/// 视频素材播放完成。
/// @param ad 触发回调的广告实例。
- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad;
/// 视频素材播放失败。
/// @param ad    触发回调的广告实例。
/// @param error 播放失败原因。
- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToPlayWithError:(IFLYAdError *)error;
/// 广告请求、绑定或展示流程失败。
/// @param ad    触发回调的广告实例。
/// @param error 失败原因（空广告位/网络错误/无填充/素材不完整、容器非法等，见 IFLYAdError）。
- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailWithError:(IFLYAdError *)error;

@end

/// 自渲染信息流广告。SDK 负责请求、绑定、曝光、点击、摇一摇、关闭和视频播放响应；UI 由媒体侧渲染。
/// @discussion 典型接入流程：
///   1. 用 initWithAdUnitId:（继承自 IFLYAdBase）创建实例并设置 delegate；
///   2. 调用 loadAd 发起请求，didLoad 回调中读取 adData 自渲染广告 UI；
///   3. UI 就绪后调用 bindAdWithViewBinder:error: 把容器、点击视图、关闭视图（及视频视图）交给 SDK；
///   4. SDK 自动完成曝光检测、点击/摇一摇响应、关闭与视频播放控制及监测上报；
///   5. 不再使用当前容器时调用 unbindAd 清理绑定资源，或调用 destroy 彻底销毁。
/// @note UITableView/UICollectionView cell prepareForReuse、同一容器重新渲染其他广告或移除广告视图前，
///       必须先对旧广告实例调用 unbindAd，避免旧手势、曝光监听和视频播放器继续绑定到复用视图。
///       绑定成功即视为本广告实例已展示/已消费；unbindAd 不会重置一次性语义。新的广告机会请创建新实例并重新 loadAd。
@interface IFLYNativeFeedAd : IFLYAdBase

/// 事件委托。回调均在主线程触发；建议设为 weak 持有方避免循环引用。
@property (nonatomic, weak, nullable) id<IFLYNativeFeedAdDelegate> delegate;
/// 当前加载的统一信息流数据。didLoad 后可读，未加载/已清理时为 nil。
@property (nonatomic, strong, readonly, nullable) IFLYNativeFeedAdData *adData;
/// 当前素材类型（单图/三图/视频/未知）。didLoad 后可读，未加载时为 Unknown。
@property (nonatomic, assign, readonly) IFLYNativeFeedAdMaterialType materialType;
/// 是否为视频素材。didLoad 后可读；等价于 materialType==IFLYNativeFeedAdMaterialTypeVideo。
@property (nonatomic, assign, readonly) BOOL hasVideoTemplate;
/// 视频初始静音态，默认 YES。仅视频素材生效。
/// @note 绑定后实时生效；切换静音/取消静音会触发对应监测上报（需视频已开始播放）。
@property (nonatomic, assign) BOOL muteOnStart;
/// 摇一摇/扭一扭交互方式开关。默认 NO=摇一摇（加速度计）；YES=降级为扭一扭（罗盘角度），并非禁用交互。
/// @note 仅当广告启用了摇一摇交互（shake_info 下发）时生效；置 YES 后改走罗盘朝向判定，
///       触发上报省略 acc_*/new_acc_* 加速度宏（与开屏一致）。须在 bindAdWithViewBinder:error: 前设置。
@property (nonatomic, assign) BOOL headingInteractionEnabled;

/// 发起广告请求。
/// @note 请求结果经 delegate 的 didLoad/didFailWithError 回调；实例已销毁则忽略。
///       重复调用会取消上一次进行中的请求并重置已加载状态。
- (void)loadAd;
/// 使用 S2S 服务端竞价响应 token 发起广告请求。
/// @param rspToken 媒体服务端竞价胜出后返回给客户端的响应 token。
/// @note 空 token 会回调 @c IFLYAdErrorCodeS2STokenEmpty；重复使用、加载中或已消耗 token 会回调
///       @c IFLYAdErrorCodeS2STokenInvalid。成功加载后的 @c ecpm 固定返回 0.0。
- (void)loadAdWithServerBiddingToken:(NSString *)rspToken;

/// 使用 Binder 绑定广告容器与各语义视图。
/// @param binder 绑定对象；其中 containerView 必填，视频素材 videoView 必填。
/// @param error  绑定失败时回填错误（可传 NULL 不接收）。
/// @return 绑定成功返回 YES；失败返回 NO 并触发 didFailToRender 回调。
/// @note 必须在主线程同步调用；后台线程调用会直接返回 NO、回填错误并触发 didFailToRender，不会自动切主线程。
- (BOOL)bindAdWithViewBinder:(IFLYNativeFeedAdViewBinder *)binder error:(IFLYAdError *_Nullable *_Nullable)error;

/// 解绑广告：停止曝光/摇一摇监听、移除手势与视频播放器并释放容器引用，但保留已加载素材。
/// @note cell/view 复用、重新绑定其他广告或从页面移除当前广告视图前必须调用。
///       仅清理当前绑定资源，不复位 hasShown，不允许同一广告实例再次 bindAdWithViewBinder:error:；
///       新的广告机会请创建新实例。
- (void)unbindAd;

/// 销毁广告：取消请求、清理绑定与已加载状态，置为不可用。
/// @note 一次性操作；销毁后 loadAd/bindAdWithViewBinder:error: 均失效。
- (void)destroy;

/// 当前广告是否仍可绑定展示。
/// @return 未销毁/未关闭、已加载且素材完整、未过期（视频还需未过投放截止时间）才返回 YES。
- (BOOL)isAdValid;

/// 返回当前广告价格，单位：元。未加载或无价格时返回 -1.0。
- (double)ecpm;

/// 请求开始播放视频（仅视频素材有效）。
/// @note 实际播放须同时满足：已绑定播放器、未销毁/未关闭、已曝光且未播放完成。条件不满足时仅置位待播标记。
- (void)startPlay;
/// 暂停视频播放（仅视频素材有效）。会清除待播/后台续播标记并上报暂停监测。
- (void)pausePlay;
/// 恢复/继续播放视频（仅视频素材有效），语义同 startPlay。
- (void)resumePlay;
/// 停止并重置视频播放器（仅视频素材有效），并上报关闭监测。
- (void)stopPlay;

@end

NS_ASSUME_NONNULL_END
