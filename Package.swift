// swift-tools-version:5.9

// 按广告形式选择 product；资源与隐私清单自动包含。
// 在宿主 App target 的 Other Linker Flags 中添加 -ObjC。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    platforms: [
        .iOS("11.0"),
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Banner", targets: ["Banner"]),
        .library(name: "Splash", targets: ["Splash"]),
        .library(name: "Interstitial", targets: ["Interstitial"]),
        .library(name: "NativeFeed", targets: ["NativeFeed"]),
        .library(name: "Reward", targets: ["Reward"]),
        .library(name: "Full", targets: ["Full"]),
    ],
    targets: [
        .binaryTarget(
            name: "IFLYAdCore",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdCore.xcframework.zip",
            checksum: "64ce7a0286a9515fe3b1081d006d839552063460a7ddbd9e76fdd960c4abee5a"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdVideoUI.xcframework.zip",
            checksum: "6b808e5e4e125b1ff4ff088a08fb9fe065bde11f6df4f08f77905f3296f2665e"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdBanner.xcframework.zip",
            checksum: "696c7666c23aa2d58db3787b6ac343b31aceed8d1ff57844558f72219a68fdba"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdSplash.xcframework.zip",
            checksum: "37fca5f7aeee56b1d3d55af803979d34a99e5f77df62ad7aac987ca55e637f5a"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdInterstitial.xcframework.zip",
            checksum: "408bec0ae15fae9b5ab2e8bbcca1ac7378e3e7e26394a6460963cb8a941f5496"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdNativeFeed.xcframework.zip",
            checksum: "00ef857c07051072d441bc0c4bda2babc82009b41efba54949bbbae3b0580687"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/general/IFLYAdReward.xcframework.zip",
            checksum: "804dd97468a8d7243a146069914ef04c735cafa71398b754527234044488fad9"
        ),
        .target(
            name: "Core",
            dependencies: [
                "IFLYAdCore",
            ],
            path: "spm/Core",
            resources: [
                .process("Resources"),
                .copy("IFLYADLibCoreResources.bundle"),
            ]
        ),
        .target(
            name: "VideoUI",
            dependencies: [
                "IFLYAdVideoUI",
                "Core",
            ],
            path: "spm/VideoUI",
            resources: [
                .copy("IFLYADLibVideoUIResources.bundle"),
            ]
        ),
        .target(
            name: "Banner",
            dependencies: [
                "IFLYAdBanner",
                "Core",
            ],
            path: "spm/Banner"
        ),
        .target(
            name: "Splash",
            dependencies: [
                "IFLYAdSplash",
                "Core",
                "VideoUI",
            ],
            path: "spm/Splash"
        ),
        .target(
            name: "Interstitial",
            dependencies: [
                "IFLYAdInterstitial",
                "Core",
                "VideoUI",
            ],
            path: "spm/Interstitial"
        ),
        .target(
            name: "NativeFeed",
            dependencies: [
                "IFLYAdNativeFeed",
                "Core",
            ],
            path: "spm/NativeFeed"
        ),
        .target(
            name: "Reward",
            dependencies: [
                "IFLYAdReward",
                "Core",
                "VideoUI",
            ],
            path: "spm/Reward",
            resources: [
                .copy("IFLYADLibRewardResources.bundle"),
            ]
        ),
        .target(
            name: "Full",
            dependencies: [
                "Banner",
                "Splash",
                "Interstitial",
                "NativeFeed",
                "Reward",
            ],
            path: "spm/Full"
        ),
    ]
)
