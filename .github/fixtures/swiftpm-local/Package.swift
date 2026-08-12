// swift-tools-version:5.9

// Release CI 将 7 个正式 XCFramework 解压到本清单旁，
// 以真实本地 binaryTarget 构建模型 A 的 Full 产品和最小消费端。

import PackageDescription

let package = Package(
    name: "IFLYADLibReleaseValidation",
    platforms: [.iOS("11.0")],
    products: [
        .library(name: "IFLYADLib", targets: ["Full"]),
    ],
    targets: [
        .binaryTarget(name: "IFLYAdCore", path: "IFLYAdCore.xcframework"),
        .binaryTarget(name: "IFLYAdVideoUI", path: "IFLYAdVideoUI.xcframework"),
        .binaryTarget(name: "IFLYAdBanner", path: "IFLYAdBanner.xcframework"),
        .binaryTarget(name: "IFLYAdSplash", path: "IFLYAdSplash.xcframework"),
        .binaryTarget(name: "IFLYAdInterstitial", path: "IFLYAdInterstitial.xcframework"),
        .binaryTarget(name: "IFLYAdNativeFeed", path: "IFLYAdNativeFeed.xcframework"),
        .binaryTarget(name: "IFLYAdReward", path: "IFLYAdReward.xcframework"),
        .target(name: "Core", dependencies: ["IFLYAdCore"], path: "spm/Core", resources: [.process("Resources"), .copy("IFLYADLibCoreResources.bundle")]),
        .target(name: "VideoUI", dependencies: ["IFLYAdVideoUI", "Core"], path: "spm/VideoUI", resources: [.copy("IFLYADLibVideoUIResources.bundle")]),
        .target(name: "Banner", dependencies: ["IFLYAdBanner", "Core"], path: "spm/Banner"),
        .target(name: "Splash", dependencies: ["IFLYAdSplash", "Core", "VideoUI"], path: "spm/Splash"),
        .target(name: "Interstitial", dependencies: ["IFLYAdInterstitial", "Core", "VideoUI"], path: "spm/Interstitial"),
        .target(name: "NativeFeed", dependencies: ["IFLYAdNativeFeed", "Core"], path: "spm/NativeFeed"),
        .target(name: "Reward", dependencies: ["IFLYAdReward", "Core", "VideoUI"], path: "spm/Reward", resources: [.copy("IFLYADLibRewardResources.bundle")]),
        .target(name: "Full", dependencies: ["Banner", "Splash", "Interstitial", "NativeFeed", "Reward"], path: "spm/Full"),
    ]
)
