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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdCore.xcframework.zip",
            checksum: "38d7802671e11d73149b3d4cc5d98e701aba2bada1133881dd2a3625395d5cc5"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdVideoUI.xcframework.zip",
            checksum: "060a0af93a8ad415b589e85d68b3372b6e9d215642c155f33a69f1ec6074800b"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdBanner.xcframework.zip",
            checksum: "b87e5da6db901a86e04b3f859d723c5f04d2502c626d80a1fded8969e8224e98"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdSplash.xcframework.zip",
            checksum: "7720d53d27417bd40c9e96fb8403e4fe44b9db53a8f85ee0740651eb7df47662"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdInterstitial.xcframework.zip",
            checksum: "f9571d518e0df001be7ced5db590c12be8789dd4ae26a886181c3e2fdf8505e6"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdNativeFeed.xcframework.zip",
            checksum: "298135f20c51f108658bd405b5fb381a0d83a2f48ea486ad06c24d2080ea16b3"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/general/IFLYAdReward.xcframework.zip",
            checksum: "cc6f4ddbbad08250b79262407412b5cb597a95ccbe163509a5d589a160736230"
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
