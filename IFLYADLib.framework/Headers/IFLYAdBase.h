//
//  IFLYAdBase.h
//  IFLYADLib
//
//  五种广告公开类的公共基类。接入者通常不直接实例化本类，而是通过具体广告类继承到
//  请求配置、状态查询、竞价通知和 DeepLink 控制能力。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IFLYADLib/IFLYAdTypes.h>

@class IFLYAdError;

NS_ASSUME_NONNULL_BEGIN

/// 广告公开基类，为 Banner、插屏、自渲染信息流、激励视频和开屏提供公共能力。
/// @discussion 本头为对外公开 API（含于伞头 IFLYADLib.h），仅暴露开发者需要的展示控制器、
///             参数设置、状态查询、竞价通知与 DeepLink 开关。
/// @note 接入者应实例化具体广告类，不应直接创建 IFLYAdBase。具体广告类会覆盖 loadAd 并补充 show/bind 等格式能力。
@interface IFLYAdBase : NSObject

/// 当前视图控制器，用于展示广告落地页
/// @note loadAd 不强制要求提前设置。各广告格式会在展示/绑定阶段尽量从 rootVC 或容器视图推断；
///       若需覆盖推断结果，可在点击跳转前显式设置。
@property (nonatomic, weak) UIViewController *currentViewController;

/// 落地页跳转视图控制器
/// @note 可选设置。若未设置，默认使用 currentViewController 来展示落地页。
@property (nonatomic, weak) UIViewController *jumperViewController;

/// 当前广告实例状态。由 SDK 按实例生命周期维护，用于接入方诊断和流程保护。
@property (nonatomic, assign, readonly) IFLYAdState adState;

/// 最近一次失败错误。新一轮加载开始或 resetMonitorState 时清空。
@property (nonatomic, strong, readonly, nullable) IFLYAdError *lastError;

/// 当前广告的统一竞价信息。广告请求解析成功后可读；未加载或无广告时为 nil。
@property (nonatomic, strong, readonly, nullable) IFLYAdBidInfo *bidInfo;

/// 使用广告位 ID 创建广告实例。
/// @param adUnitId 广告位 ID，由讯飞广告平台分配，格式如 @"xxxxxx"
/// @return 广告实例。广告位 ID 为空时对象仍会创建，但后续 loadAd 会通过失败回调返回错误。
- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

/// 设置广告协议扩展参数
/// @discussion 主流程优先使用 IFLYAdRequestConfig。仅当接入方需要写入结构化配置尚未覆盖的
///             协议字段时使用本方法。
/// @param value 参数值
/// @param key   参数键名，应使用 IFLYAdKeys.h 中定义的 IFLYAdKey 常量
- (void)setParamValue:(NSObject *)value forKey:(NSString *)key;

/// 应用统一请求配置。
/// @discussion 本方法只写入请求期参数和跳转配置，不会发起请求；适合在 loadAd 前调用。
///             结构化配置未覆盖的协议字段可通过 setParamValue:forKey: 作为扩展写入。
/// @param config 请求期配置；nil 时不做任何事。
- (void)applyRequestConfig:(nullable IFLYAdRequestConfig *)config;

/// 统一加载入口。具体广告类覆盖本方法并实现真实请求逻辑。
- (void)loadAd;

/// 使用统一请求配置发起加载。
/// @discussion 等价于先调用 applyRequestConfig:，再调用 loadAd。
/// @param config 请求期配置；nil 时等价于 loadAd。
- (void)loadAdWithRequestConfig:(nullable IFLYAdRequestConfig *)config;

/// 发送 Header Bidding 竞价结果通知。
/// @discussion 适用于胜出、失败、超时、错误等所有竞价结果。
/// @param type   竞价结果类型。
/// @param reason 自定义原因描述；SDK 会按 query value 规则进行 URL Encode。
- (void)sendBidResultWithType:(IFLYAdBidResultType)type reason:(nullable NSString *)reason;

/// 设置是否禁用 DeepLink 跳转
/// @param disable YES 禁用 DeepLink 跳转，NO 启用（默认值）
/// @note 默认为 NO，即允许 DeepLink 跳转。设置为 YES 后，点击广告将不再尝试 DeepLink，直接使用浏览器打开落地页。
///       这是跳转行为配置，不会改变广告请求参数。
- (void)setDeepLinkDisable:(BOOL)disable;

@end

NS_ASSUME_NONNULL_END
