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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdCore.xcframework.zip",
            checksum: "c14fd88b36798af8a13ccc2b5cf94b0c1c4ba05d2c2311b2e6bfd25611517344"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdVideoUI.xcframework.zip",
            checksum: "f9aa31236da16f20c218dc994bdd80d95b62428da328620d986a757136d0646c"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdBanner.xcframework.zip",
            checksum: "c43b8e5869686d0afbb78886a97a20d3ffec88c20dfc361431d77de89132dbe5"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdSplash.xcframework.zip",
            checksum: "133a26196089b745eb4cd61f5c0106fa1596777cec60b113574dbea992bb6865"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdInterstitial.xcframework.zip",
            checksum: "2c2ebab2fb4fca3de080c73b295dd55c96e86ab2b65ee64336402d41718c35c5"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdNativeFeed.xcframework.zip",
            checksum: "517bf128e6fdae8ccd152fc3efc9b20b041dee1cc53d59d6c488b1202c62de12"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/general/IFLYAdReward.xcframework.zip",
            checksum: "25c75bf9e2d5a1856aa1a1416f668f73855599d20b8912cbf5718ef6e461ed6a"
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
