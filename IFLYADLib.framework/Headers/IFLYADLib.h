//
//  IFLYADLib.h
//  IFLYADLib
//
//
// IFLYADLib 伞头文件：framework 对外公开 API 的统一入口。
// 接入方通常只需 `#import <IFLYADLib/IFLYADLib.h>`，无需逐个 import 下方头文件。
// 下方每个公开头的注释按接入者视角描述调用顺序、回调时机、错误出口和对象复用语义。

/// IFLYADLib -- 讯飞广告 SDK 公开 API 入口。
/// @discussion 提供开屏、激励视频、Banner、插屏、自渲染信息流等广告能力。
///             主要入口类：IFLYSplashAd / IFLYRewardVideoAd / IFLYBannerAd /
///             IFLYInterstitialAd / IFLYNativeFeedAd。
/// @note 本文件只汇总公开头，不包含内部实现类。公开头导出清单须与 Xcode publicHeaders 保持一致。

#import <Foundation/Foundation.h>

//! Project version number for IFLYADLib.
/// framework 版本号（浮点形式），由构建系统按 Info.plist 中的版本生成。
FOUNDATION_EXPORT double IFLYADLibVersionNumber;

//! Project version string for IFLYADLib.
/// framework 版本字符串（字节数组形式），由构建系统按 Info.plist 中的版本生成。
FOUNDATION_EXPORT const unsigned char IFLYADLibVersionString[];

#pragma mark - model  数据模型
/// IFLYAdData：广告数据模型基类，承载各广告类型回填的素材与元数据。
#import <IFLYADLib/IFLYAdData.h>
/// IFLYAdRenderingData：广告渲染配置模型。
#import <IFLYADLib/IFLYAdRenderingData.h>
/// IFLYAdImgVoiceData：图文/语音类素材数据模型。
#import <IFLYADLib/IFLYAdImgVoiceData.h>
/// IFLYAdMonitorData：曝光/点击等监测上报链接数据模型。
#import <IFLYADLib/IFLYAdMonitorData.h>
/// IFLYAdVideoData：视频素材数据模型。
#import <IFLYADLib/IFLYAdVideoData.h>

#pragma mark - biz  广告类型
/// IFLYAdTypes：所有广告形式共享的状态、请求配置、展示配置与竞价信息类型。
#import <IFLYADLib/IFLYAdTypes.h>
/// IFLYAdBase：所有广告类型的公共基类，统一参数配置、曝光/点击、监测上报等收口能力。
#import <IFLYADLib/IFLYAdBase.h>
/// IFLYSplashAd：开屏广告入口类（含 IFLYSplashAdDelegate）。
#import <IFLYADLib/IFLYSplashAd.h>
/// IFLYRewardVideoAd：激励视频广告入口类（含 IFLYRewardVideoAdDelegate）。
#import <IFLYADLib/IFLYRewardVideoAd.h>
/// IFLYBannerAd：横幅广告入口类（含 IFLYBannerAdDelegate）。
#import <IFLYADLib/IFLYBannerAd.h>
/// IFLYInterstitialAd：插屏广告入口类（含 IFLYInterstitialAdConfig 与 IFLYInterstitialAdDelegate）。
#import <IFLYADLib/IFLYInterstitialAd.h>
/// IFLYNativeFeedAd：自渲染信息流广告入口类（含 IFLYNativeFeedAdDelegate）。
#import <IFLYADLib/IFLYNativeFeedAd.h>
/// IFLYNativeFeedAdData：自渲染信息流广告数据模型（含素材类型枚举 IFLYNativeFeedAdMaterialType）。
#import <IFLYADLib/IFLYNativeFeedAdData.h>

#pragma mark - tools  工具与配置
/// IFLYAdConfig：SDK 全局配置（日志开关、个性化配置状态）。
#import <IFLYADLib/IFLYAdConfig.h>
/// IFLYAdSDK：SDK 级能力入口，提供 S2S 服务端竞价 token 生成。
#import <IFLYADLib/IFLYAdSDK.h>
/// IFLYAdKeys：广告参数键名常量（IFLYAdKey 字符串枚举），配合 IFLYAdBase 的参数设置接口使用。
#import <IFLYADLib/IFLYAdKeys.h>
/// IFLYAdTool：对外工具门面（图片下载/高斯模糊/SDK 版本，含 IFLYAdToolImageCompletionBlock）。
#import <IFLYADLib/IFLYAdTool.h>
/// IFLYAdError：错误码枚举（IFLYAdErrorCode）与错误对象封装（IFLYAdError）。
#import <IFLYADLib/IFLYAdError.h>
