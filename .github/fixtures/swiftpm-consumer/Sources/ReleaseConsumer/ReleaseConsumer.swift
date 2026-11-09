import Foundation

#if IFLY_MODULAR_FRAMEWORKS
import IFLYAdCore
import IFLYAdBanner
import IFLYAdSplash
import IFLYAdInterstitial
import IFLYAdNativeFeed
import IFLYAdReward

// 同时引用公共基类、配置、五种格式及协议，缺任一模块必须编译失败。
public final class SDKModuleConsumer: NSObject, IFLYBannerAdDelegate,
    IFLYSplashAdDelegate, IFLYInterstitialAdDelegate,
    IFLYNativeFeedAdDelegate, IFLYRewardVideoAdDelegate {
    public let requestConfig = IFLYAdRequestConfig()
    public let showConfig = IFLYAdShowConfig()
    public let splashConfig = IFLYSplashAdConfig()
    public let interstitialConfig = IFLYInterstitialAdConfig()
    public let rewardConfig = IFLYRewardVideoAdConfig()
    public let nativeBinder = IFLYNativeFeedAdViewBinder()
    public let banner = IFLYBannerAd(adUnitId: "consumer-banner")
    public let splash = IFLYSplashAd(adUnitId: "consumer-splash")
    public let interstitial = IFLYInterstitialAd(adUnitId: "consumer-interstitial")
    public let nativeFeed = IFLYNativeFeedAd(adUnitId: "consumer-native")
    public let reward = IFLYRewardVideoAd(adUnitId: "consumer-reward")

    public override init() {
        super.init()
        banner.delegate = self
        splash.delegate = self
        interstitial.delegate = self
        nativeFeed.delegate = self
        reward.delegate = self
        banner.apply(requestConfig)
    }

    public var ads: [IFLYAdBase] { [banner, splash, interstitial, nativeFeed, reward] }
    public var nativeData: IFLYNativeFeedAdData? { nativeFeed.adData }
}
#endif

public enum ReleaseConsumer {
    public static let verificationMarker = "IFLYADLib-6.5.0"
}
