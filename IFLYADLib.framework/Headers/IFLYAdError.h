//
//  IFLYAdError.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/9/26.
//  Copyright © 2016年 iflytek. All rights reserved.
//
// 广告错误码定义与错误对象封装：集中声明 SDK 全量错误码枚举 IFLYAdErrorCode，
// 并提供 IFLYAdError 错误模型（错误码 + 描述）及其便捷工厂方法。

#import <Foundation/Foundation.h>

/// 广告错误码枚举
/// @discussion 错误码按范围划分为两类：
///             - **服务端错误 (70xxx)**：由广告服务端返回，表示请求层面的异常。
///             - **客户端错误 (71xxx)**：由 SDK 本地产生，表示参数、网络、环境等问题。
typedef NS_ENUM(NSInteger, IFLYAdErrorCode) {

    // MARK: - 服务端错误码 (70xxx)

    /// 请求成功
    IFLYAdErrorCodeSuccess = 70200,
    /// 请求成功，但没有广告填充
    IFLYAdErrorCodeNotFill = 70204,
    /// 无效的广告位 ID（服务端校验未通过）
    IFLYAdErrorCodeInvalidAdUnitId = 70400,
    /// S2S 竞价响应 token 为空
    IFLYAdErrorCodeS2STokenEmpty = 70401,
    /// 当日广告请求次数已达上限
    IFLYAdErrorCodeOverMaxRequest = 70403,
    /// S2S 竞价响应 token 无效、已过期、已消耗或未竞胜
    IFLYAdErrorCodeS2STokenInvalid = 70404,
    /// S2S Load 响应解码失败
    IFLYAdErrorCodeS2SDecodeFailed = 70406,
    /// 服务端内部错误
    IFLYAdErrorCodeServer = 70500,

    // MARK: - 客户端错误码 (71xxx)

    /// 未知错误（通常为服务端下发数据解析失败）
    IFLYAdErrorCodeUnknown = 71001,
    /// 无效的广告请求（请求参数校验未通过）
    IFLYAdErrorCodeInvalidRequest = 71002,
    /// 网络连接错误
    IFLYAdErrorCodeNetWork = 71003,
    /// 必要权限未授予（如 IDFA 等）
    IFLYAdErrorCodePermission = 71004,
    /// 广告位 ID 为空
    IFLYAdErrorCodeEmptyAdUnitId = 71005,
    /// 广告请求超时
    IFLYAdErrorCodeTimeout = 71006,
    /// 当前视图控制器为 nil（无法展示广告）
    IFLYAdErrorCodeCurrentViewController = 71007,
    /// 父视图为 nil（无法挂载广告视图）
    IFLYAdErrorCodeFatherView = 71008,

    // MARK: - 激励视频错误码 (712xx)

    /// 视频下载失败
    IFLYAdErrorCodeRewardVideoDownloadFailed = 71201,
    /// 视频校验失败（size=0/格式错）
    IFLYAdErrorCodeRewardVideoVerifyFailed = 71202,
    /// 激励广告未就绪（未等 didReady 或素材已失效）
    IFLYAdErrorCodeRewardNotReady = 71203,
    /// 广告已过期（超过 preload_time）
    IFLYAdErrorCodeRewardAdExpired = 71204,
    /// 广告已展示过
    IFLYAdErrorCodeRewardAdAlreadyUsed = 71205,
    /// 视频播放失败
    IFLYAdErrorCodeRewardVideoPlayFailed = 71206,

    // MARK: - Banner 错误码 (713xx)

    /// Banner 素材无效（img.url 为空、URL 非法、素材字段不可用）
    IFLYAdErrorCodeBannerMaterialInvalid = 71301,
    /// Banner 图片下载失败
    IFLYAdErrorCodeBannerImageDownloadFailed = 71302,
    /// Banner 图片校验失败（解码失败、动图、尺寸无效）
    IFLYAdErrorCodeBannerImageVerifyFailed = 71303,
    /// Banner 容器无效（容器为空或宽高无效）
    IFLYAdErrorCodeBannerContainerInvalid = 71304,
    /// Banner 广告已展示或已使用
    IFLYAdErrorCodeBannerAdAlreadyUsed = 71305,
    /// Banner 广告已关闭
    IFLYAdErrorCodeBannerAdClosed = 71306,
    /// Banner 广告已销毁
    IFLYAdErrorCodeBannerAdDestroyed = 71307,
    /// Banner 广告未就绪
    IFLYAdErrorCodeBannerNotReady = 71308,
    /// Banner 等待容器布局超时
    IFLYAdErrorCodeBannerLayoutTimeout = 71309,

    // MARK: - 插屏错误码 (714xx)

    /// 插屏素材缺失或素材类型不支持
    IFLYAdErrorCodeInterstitialMaterialInvalid = 71401,
    /// 插屏图片下载失败
    IFLYAdErrorCodeInterstitialImageDownloadFailed = 71402,
    /// 插屏图片校验或渲染失败
    IFLYAdErrorCodeInterstitialImageVerifyFailed = 71403,
    /// 插屏视频下载失败
    IFLYAdErrorCodeInterstitialVideoDownloadFailed = 71404,
    /// 插屏视频校验失败
    IFLYAdErrorCodeInterstitialVideoVerifyFailed = 71405,
    /// 插屏广告未准备好
    IFLYAdErrorCodeInterstitialNotReady = 71406,
    /// 插屏广告已过期
    IFLYAdErrorCodeInterstitialAdExpired = 71407,
    /// 插屏广告已展示过
    IFLYAdErrorCodeInterstitialAdAlreadyUsed = 71408,
    /// 插屏广告已关闭或已销毁
    IFLYAdErrorCodeInterstitialAdClosed = 71409,
    /// 插屏 RootViewController 不可用
    IFLYAdErrorCodeInterstitialRootViewControllerInvalid = 71410,
    /// 插屏布局或渲染超时
    IFLYAdErrorCodeInterstitialLayoutTimeout = 71411,
    /// 插屏视频播放失败
    IFLYAdErrorCodeInterstitialVideoPlayFailed = 71412,

    // MARK: - 自渲染信息流错误码 (715xx)

    /// 自渲染信息流素材缺失或素材类型不支持
    IFLYAdErrorCodeNativeFeedMaterialInvalid = 71501,
    /// 自渲染信息流容器无效
    IFLYAdErrorCodeNativeFeedContainerInvalid = 71502,
    /// 自渲染信息流点击视图无效
    IFLYAdErrorCodeNativeFeedClickViewsInvalid = 71503,
    /// 自渲染信息流视频承载视图无效
    IFLYAdErrorCodeNativeFeedVideoViewInvalid = 71504,
    /// 自渲染信息流广告未准备好（未成功 didLoad、素材字段不完整或绑定前置条件未满足）
    IFLYAdErrorCodeNativeFeedNotReady = 71505,
    /// 自渲染信息流广告已过期
    IFLYAdErrorCodeNativeFeedAdExpired = 71506,
    /// 自渲染信息流广告已关闭
    IFLYAdErrorCodeNativeFeedAdClosed = 71507,
    /// 自渲染信息流广告已销毁
    IFLYAdErrorCodeNativeFeedAdDestroyed = 71508,
    /// 自渲染信息流绑定失败
    IFLYAdErrorCodeNativeFeedBindFailed = 71509,
    /// 自渲染信息流视频播放失败
    IFLYAdErrorCodeNativeFeedVideoPlayFailed = 71510,
    /// 自渲染信息流广告已展示过，不能重新加载/绑定
    IFLYAdErrorCodeNativeFeedAdAlreadyUsed = 71511,

    // MARK: - 开屏错误码 (716xx)

    /// 开屏广告已展示过，不能重新展示
    IFLYAdErrorCodeSplashAdAlreadyUsed = 71601,
    /// 开屏素材加载失败
    IFLYAdErrorCodeSplashMaterialLoadFailed = 71602,
    /// 开屏广告未就绪
    IFLYAdErrorCodeSplashNotReady = 71603,
    /// 开屏 RootViewController 不可用
    IFLYAdErrorCodeSplashRootViewControllerInvalid = 71604,
    /// 开屏视频播放失败
    IFLYAdErrorCodeSplashVideoPlayFailed = 71605,
};

/// 广告错误信息
/// @discussion 封装广告请求或展示过程中的错误信息，包含错误码和错误描述。
///             通过类方法 @c generateByCode: 快捷创建。
@interface IFLYAdError : NSObject

/// 错误描述文本
/// @discussion 经 @c generateByCode: 创建时取自内置错误码映射表，未命中则为 @c nil；
///             经 @c generateByCode:description: 创建时为调用方传入的自定义文本。
@property (strong, nonatomic) NSString *errorDescription;

/// 错误码，对应 @c IFLYAdErrorCode 枚举值（如 @c 71001）
@property (assign, nonatomic) int errorCode;

/// 根据错误码生成错误对象，错误描述自动从内置映射表填充
/// @param code 错误码。可传入完整的 5 位内部错误码（如 @c 71001）；
///             也可传入服务端下发的短码：当 @c code 小于 @c 1000 时，
///             内部会加偏移量 @c 70000 归一到 70xxx 错误码体系（如 @c 200 → @c 70200）。
///             注意：仅 @c <1000 的码会被补偏移，@c >=1000 的码按原值使用。
/// @return 对应的 @c IFLYAdError 实例；其 @c errorDescription 取自内置映射表，
///         若映射表中无该码则为 @c nil。
/// @note 内部会按需懒加载错误码描述映射表（线程安全）。
+ (IFLYAdError *)generateByCode:(int)code;

/// 根据错误码和自定义描述生成错误对象
/// @param code 错误码，按原值直接存入 @c errorCode。
/// @param desc 自定义错误描述文本，直接存入 @c errorDescription。
/// @return 对应的 @c IFLYAdError 实例
/// @note 与 @c generateByCode: 不同：本方法不补 @c 70000 偏移、也不查映射表，
///       @c code 与 @c desc 均原样使用。
+ (IFLYAdError *)generateByCode:(int)code description:(NSString *)desc;

@end
