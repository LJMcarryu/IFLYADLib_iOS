#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class IFLYAdData;
@class IFLYAdError;
@class IFLYNativeAd;

@protocol IFLYNativeAdDelegate <NSObject>

/**
 *  原生广告加载广告数据成功回调
 *
 *  @param adData IFLYAdData对象
 */
- (void)onNativeAdReceived:(IFLYAdData *)adData;

/**
 *  原生广告错误回调
 *
 *  @param error 错误码，详见接入手册
 */
- (void)onNativeAdFailed:(IFLYAdError *)error;

@end


@interface IFLYNativeAd : NSObject

/**
 *  委托对象
 */
@property (nonatomic, weak) id<IFLYNativeAdDelegate> delegate;

/**
 *  父视图
 *  需设置为显示广告的UIViewController
 */
@property (nonatomic, weak) UIViewController *currentViewController;

/**
 *  跳转视图
 *  可设置为显示落地页的UIViewController，不填默认 currentViewController
 */
@property (nonatomic, weak) UIViewController *jumperViewController;

/**
 *  构造方法
 *  详解：adUnitId是广告位id
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

/**
 *  设置广告配置参数
 */
- (void)setParamValue:(NSObject *)value forKey:(NSString *)key;

/**
 *  广告发起请求方法
 *  详解：[必选]发起拉取广告请求,在获得广告数据后回调delegate
 */
- (void)loadAd;

/**
 *  广告数据渲染完毕即将展示时调用方法
 *  详解：[必选]广告数据渲染完毕，即将展示时需调用本方法。
 *      @param view         渲染出的广告结果页面
 */
- (BOOL)attachAd:(UIView *)view;

/**
 *  开屏广告数据渲染完毕即将展示时调用方法
 *  详解：[必选]广告数据渲染完毕，即将展示时需调用本方法。
 *      @param view         渲染出的广告结果页面
 */
- (BOOL)attachWindowAd:(UIView *)view;

/**
 *  广告点击调用方法
 *  详解：当用户点击广告时，开发者需调用本方法，系统会弹出内嵌浏览器、或内置AppStore、
 *      或打开系统Safari，来展现广告目标页面
 *      @param view         渲染出的广告结果页面
 */
- (BOOL)clickAd:(UIView *)view;

/**
 *  广告点击调用方法
 *  详解：当用户点击广告时，开发者需调用本方法，系统会弹出内嵌浏览器、或内置AppStore、
 *      或打开系统Safari，来展现广告目标页面
 *      @param ext         渲染出的广告结果页面
 */
- (BOOL)clickAdWithExt:(NSDictionary *)ext;

/**
 *  广告点击为deeplink时是否禁用deeplink跳转
 *  详解：当用户点击广告时，设置是否禁止进行deeplink跳转，默认NO启用
 *      @param disable         YES禁用deeplink跳转，NO启用
 */
- (void)setDeepLinkDisable:(BOOL)disable;

/**
 *  广告竞价胜出通知
 *  详解：[必选]
 *  TYPE=100，即获胜竞得
 *  TYPE=101，原因是出价低即未获胜
 *  TYPE=102，即未获胜原因是素材未审核
 *  TYPE=103，即未获胜原因是素材审核拒绝
 *  TYPE=104，即未获胜原因是竞价优先级低(如PDB>PD>RTB)
 *  TYPE=105，竞价响应错误
 *  TYPE=106，竞价响应超时
 *
 *  reason支持媒体侧自定义替换，上报的内容需要进行urlencode 当TYPE=103时尽量填写具体拒绝原因
 */
- (void)sendWinNoticeWithType:(NSNumber *)type reason:(NSString *)reason;

/**
 * 广告退出落地页的回调
 */
@property (nonatomic, copy) void (^ dismissBlock)(void);

/**
 * 广告退出应用商店的回调
 */
@property (nonatomic, copy) void (^ dismissStoreBlock)(void);

/**
 * 广告点击跳转完成回调
 */
@property (nonatomic, copy) void (^ didJumpBlock)(BOOL success);

/**
 * deeplink跳转离开app回调
 */
@property (nonatomic, copy) void (^ didLeaveApp)(void);

/**
 * 广告点击跳转动画开始回调
 */
@property (nonatomic, copy) void (^ clickAdAnimateStartBlock)(void);

/**
 * 广告点击跳转动画结束回调
 */
@property (nonatomic, copy) void (^ clickAdAnimateCompleteBlock)(void);

/**
 * 广告点击关闭动画开始回调
 */
@property (nonatomic, copy) void (^ closeAdAnimateStartBlock)(void);

/**
 * 广告点击关闭动画结束回调
 */
@property (nonatomic, copy) void (^ closeAdAnimateCompleteBlock)(void);


@end
