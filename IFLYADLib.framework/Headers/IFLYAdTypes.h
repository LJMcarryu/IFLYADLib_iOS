//
//  IFLYAdTypes.h
//  IFLYADLib
//
//  五种广告形式共享的公开类型：广告状态、竞价结果、统一请求配置、统一展示配置与竞价信息。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IFLYAdData;

/// 广告实例的统一只读状态。
typedef NS_ENUM(NSInteger, IFLYAdState) {
    /// 初始态或上一轮状态已清空。
    IFLYAdStateIdle = 0,
    /// 请求进行中。
    IFLYAdStateLoading,
    /// 响应解析成功，主素材可能仍在预加载。
    IFLYAdStateLoaded,
    /// 主素材已就绪，可进入 show / showInView。NativeFeed 无 didReady 阶段，通常停留在 Loaded 后进入 bind。
    IFLYAdStateReady,
    /// 展示或绑定流程已走通。
    IFLYAdStateShowing,
    /// 已完成有效曝光。
    IFLYAdStateExposed,
    /// 已关闭。
    IFLYAdStateClosed,
    /// 已销毁。
    IFLYAdStateDestroyed,
    /// 最近一次生命周期进入失败态。
    IFLYAdStateFailed,
};

/// Header Bidding 结果类型。数值与服务端 win_notice_url 的 __TYPE__ 宏保持一致。
typedef NS_ENUM(NSInteger, IFLYAdBidResultType) {
    /// 获胜竞得。
    IFLYAdBidResultTypeWin = 100,
    /// 未获胜：出价低。
    IFLYAdBidResultTypeLoseBidLower = 101,
    /// 未获胜：素材未审核。
    IFLYAdBidResultTypeLoseCreativePending = 102,
    /// 未获胜：素材审核拒绝。
    IFLYAdBidResultTypeLoseCreativeRejected = 103,
    /// 未获胜：竞价优先级低。
    IFLYAdBidResultTypeLosePriorityLower = 104,
    /// 竞价响应错误。
    IFLYAdBidResultTypeError = 105,
    /// 竞价响应超时。
    IFLYAdBidResultTypeTimeout = 106,
};

/// 广告请求期配置。接入方优先使用本类型表达常用请求参数；协议扩展字段再通过 setParamValue:forKey: 写入。
/// @discussion 本对象只承载配置，不会主动发起请求；传给 loadAdWithRequestConfig: 时才会应用并加载。
@interface IFLYAdRequestConfig : NSObject <NSCopying>

/// 广告请求 ID。不设置时 SDK 自动生成。
@property (nonatomic, copy, nullable) NSString *requestId;
/// 交易方式：0=固定价格，1=RTB。
@property (nonatomic, strong, nullable) NSNumber *settleType;
/// 竞价底价，单位 CNY 元/千次展示。
@property (nonatomic, strong, nullable) NSNumber *bidFloor;
/// 广告位互动状态：1=开启，2=关闭。
@property (nonatomic, strong, nullable) NSNumber *interactStatus;
/// PMP 订单信息数组。
@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *pmpDeals;
/// 宿主应用版本号。
@property (nonatomic, copy, nullable) NSString *appVersion;
/// 宿主应用名称。
@property (nonatomic, copy, nullable) NSString *appName;
/// 广告请求超时时间，单位秒。
@property (nonatomic, strong, nullable) NSNumber *requestTimeout;
/// 自定义浏览器 User-Agent。
@property (nonatomic, copy, nullable) NSString *userAgent;
/// 外部传入 IDFA。
@property (nonatomic, copy, nullable) NSString *idfa;
/// 外部传入 CAID 列表。
@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *caidList;
/// 落地页跳转动画样式。
@property (nonatomic, strong, nullable) NSNumber *landingPageTransitionType;
/// 落地页屏幕旋转方式。
@property (nonatomic, strong, nullable) NSNumber *landingPageAutorotateType;
/// DeepLink 是否跳过 canOpenURL 直接跳转。
@property (nonatomic, strong, nullable) NSNumber *jumpDirectly;
/// 是否禁用 DeepLink。YES 时点击直接走落地页；不会改变广告请求参数。
@property (nonatomic, strong, nullable) NSNumber *deepLinkDisabled;

@end

/// 展示期通用配置。具体广告形式可继承后追加自身字段。
/// @discussion 展示配置只影响 show/bind 阶段的呈现行为，不会重新请求广告或改变已加载素材。
@interface IFLYAdShowConfig : NSObject <NSCopying>

/// 是否隐藏视频静音按钮，默认 NO。
@property (nonatomic, assign) BOOL muteButtonHidden;
/// 视频初始静音态，默认 YES。
@property (nonatomic, assign) BOOL muteOnStart;

@end

/// 各广告形式统一的竞价信息对象。
@interface IFLYAdBidInfo : NSObject <NSCopying>

/// 广告位 ID。
@property (nonatomic, copy, readonly, nullable) NSString *adUnitId;
/// 服务端返回的 bid_id。
@property (nonatomic, copy, readonly, nullable) NSString *bidId;
/// 创意 ID。
@property (nonatomic, copy, readonly, nullable) NSString *creativeId;
/// PMP deal_id。
@property (nonatomic, copy, readonly, nullable) NSString *dealId;
/// 成交价，单位元。
@property (nonatomic, strong, readonly, nullable) NSNumber *price;
/// 货币，固定 CNY。
@property (nonatomic, copy, readonly, nullable) NSString *currency;
/// 素材类型：0=未知，1=图片，2=视频。
@property (nonatomic, assign, readonly) NSInteger adType;
/// 主图 URL。
@property (nonatomic, copy, readonly, nullable) NSString *imageURL;
/// 视频 URL。
@property (nonatomic, copy, readonly, nullable) NSString *videoURL;
/// DeepLink URL。
@property (nonatomic, copy, readonly, nullable) NSString *deeplinkURL;
/// 落地页 URL。
@property (nonatomic, copy, readonly, nullable) NSString *landingPageURL;
/// 下载地址。
@property (nonatomic, copy, readonly, nullable) NSString *downloadURL;
/// 应用包名。
@property (nonatomic, copy, readonly, nullable) NSString *packageName;
/// 广告标题。
@property (nonatomic, copy, readonly, nullable) NSString *title;
/// 是否存在竞价通知 URL。
@property (nonatomic, assign, readonly) BOOL winNoticeAvailable;
/// 字典形式，便于日志或桥接层透传。
@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;

- (instancetype)initWithAdUnitId:(nullable NSString *)adUnitId
                           bidId:(nullable NSString *)bidId
                          adData:(nullable IFLYAdData *)adData;

- (instancetype)initWithAdUnitId:(nullable NSString *)adUnitId
                           bidId:(nullable NSString *)bidId
                          adData:(nullable IFLYAdData *)adData
               serverBiddingLoad:(BOOL)serverBiddingLoad NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
