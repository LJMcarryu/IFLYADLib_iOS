//
//  IFLYBannerAd.h
//  IFLYADLib
//
//  Banner（横幅）广告对外公开接口。开发者通过本类发起请求、将广告展示到指定容器，
//  并通过 IFLYBannerAdDelegate 接收加载/就绪/曝光/点击/跳转/落地页/关闭/失败等生命周期回调。
//

#import <Foundation/Foundation.h>
#import <IFLYADLib/IFLYAdBase.h>
#import <IFLYADLib/IFLYAdError.h>

@class IFLYBannerAd;

NS_ASSUME_NONNULL_BEGIN

/// Banner 广告生命周期回调协议。所有方法均 @optional，回调统一在主线程派发。
/// @discussion 典型时序：loadAd 后先 didLoad（响应解析成功），主图预加载完成后 didReady，
/// 展示到容器并满足曝光条件后 didExpose，用户点击 didClick，用户点击关闭按钮 didClose；
/// 任一环节失败走 didFailWithError:。委托被 IFLYBannerAd 弱引用，需自行保证存活。
@protocol IFLYBannerAdDelegate <NSObject>

@optional
/// 广告响应解析成功（已校验主图 URL/尺寸合法），主图尚未下载完成。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidLoad:(IFLYBannerAd *)ad;
/// 广告主图预加载并校验通过，此时 isAdValid 可返回 YES，可调用 showInView: 展示。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidReady:(IFLYBannerAd *)ad;
/// 广告达成有效曝光（可见面积达到 2/3、App 处于前台且未锁屏，并连续保持 500ms）并完成曝光监测上报。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidExpose:(IFLYBannerAd *)ad;
/// 用户点击广告（含普通点击与摇一摇触发），已发起落地页跳转并完成点击监测上报。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidClick:(IFLYBannerAd *)ad;
/// 广告点击跳转完成。
/// @param ad      触发回调的广告实例
/// @param success YES 表示跳转成功，NO 表示跳转失败
- (void)bannerAd:(IFLYBannerAd *)ad didJumpWithSuccess:(BOOL)success;
/// 用户关闭内嵌落地页。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidDismissLandingPage:(IFLYBannerAd *)ad;
/// 用户关闭应用内 App Store 页面。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidDismissStore:(IFLYBannerAd *)ad;
/// DeepLink 外跳或 App 进入后台。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidLeaveApplication:(IFLYBannerAd *)ad;
/// 用户点击右上角关闭按钮，广告视图已移除。
/// @param ad 触发回调的广告实例
- (void)bannerAdDidClose:(IFLYBannerAd *)ad;
/// 广告加载或展示失败。
/// @param ad    触发回调的广告实例
/// @param error 失败原因，错误码见 IFLYAdError（如无填充、主图下载失败、容器布局超时等）
- (void)bannerAd:(IFLYBannerAd *)ad didFailWithError:(IFLYAdError *)error;

@end

/// Banner 广告。SDK 负责请求、素材预加载、内置原生渲染、曝光与点击上报。
/// @discussion 继承 IFLYAdBase，通过 initWithAdUnitId:（基类提供）以广告位 ID 初始化。
/// 单实例为一次性使用：已展示/已关闭/已销毁后不可重新 loadAd（会回调对应错误）。
@interface IFLYBannerAd : IFLYAdBase

/// 生命周期回调委托，弱引用。需在 loadAd 前设置以接收完整回调。
@property (nonatomic, weak, nullable) id<IFLYBannerAdDelegate> delegate;
/// 是否展示右上角关闭按钮，默认 YES。必须在 showInView: 前设置（展示后修改不生效）。
@property (nonatomic, assign) BOOL closeButtonVisible;
/// 摇一摇/扭一扭交互方式开关。默认 NO=摇一摇（加速度计）；YES=降级为扭一扭（罗盘角度），并非禁用交互。
/// @note 仅当广告启用了摇一摇交互（shake_info 下发）时生效；置 YES 后改走罗盘朝向判定，
///       触发上报省略 acc_*/new_acc_* 加速度宏（与开屏一致）。须在 showInView: 前设置。
@property (nonatomic, assign) BOOL headingInteractionEnabled;

/// 发起广告请求并预加载素材。成功依次回调 didLoad → didReady。
/// @note 已销毁直接忽略；广告位 ID 为空、已展示/已曝光、已关闭等前置校验失败时回调 didFailWithError:。
/// 加载中再次调用会取消旧请求并以新 token 重新请求。
- (void)loadAd;
/// 使用 S2S 服务端竞价响应 token 发起广告请求并预加载素材。
/// @param rspToken 媒体服务端竞价胜出后返回给客户端的响应 token。
/// @note 空 token 会回调 @c IFLYAdErrorCodeS2STokenEmpty；重复使用、加载中或已消耗 token 会回调
///       @c IFLYAdErrorCodeS2STokenInvalid。成功加载后的 @c ecpm 固定返回 0.0。
- (void)loadAdWithServerBiddingToken:(NSString *)rspToken;
/// 将就绪的广告展示到指定容器视图。
/// @param containerView 承载广告的容器。其宽度须 > 0；高度为 0 时 SDK 会按主图宽高比自适应撑高。
/// @note 必须在 didReady 之后（isAdValid 为 YES）调用。容器布局未就绪时内部会重试，
/// 超过 3 秒仍无有效宽高则回调布局超时错误。非主线程调用会自动切回主线程。
- (void)showInView:(UIView *)containerView;
/// 销毁广告：取消在途下载与请求、停止曝光检测与摇一摇监听、移除广告视图并释放素材。
/// @note 幂等，重复调用被忽略；销毁后实例不可再用。
- (void)destroy;
/// 广告当前是否可展示：未销毁/关闭/展示/曝光，且主图已就绪、未过期、尺寸有效。
/// @return YES 表示可调用 showInView: 展示
- (BOOL)isAdValid;
/// 返回当前广告价格，单位：元。未加载或无价格时返回 -1.0。
/// @return 广告竞价 eCPM，取自服务端响应 ad.price
- (double)ecpm;

@end

NS_ASSUME_NONNULL_END
