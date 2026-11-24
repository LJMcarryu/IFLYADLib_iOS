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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdCore.xcframework.zip",
            checksum: "6f2a4283935b824f4a9c89af9ae9b1b4aac848205d421156c0e8e71110bf146e"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdVideoUI.xcframework.zip",
            checksum: "ef748a5d85528c752e44fc6ba1cc78a48bcbefec238570803f9fc193e92eae9c"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdBanner.xcframework.zip",
            checksum: "41451c878fc6edcca1ec3fe70fc56379a6754abb3e71147fbb2808b64ac19991"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdSplash.xcframework.zip",
            checksum: "ed4e2938c5d2739939939192f9433bef22c84fb175512d94559b880ec3283022"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdInterstitial.xcframework.zip",
            checksum: "340021756b26248204d3a7e60a7fba02869ef8b0548f03054743c9c9ebe78986"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdNativeFeed.xcframework.zip",
            checksum: "00f7c281df5e10bad32e38ce8a5f102c11035ffa86c619f18d2958272502282b"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/general/IFLYAdReward.xcframework.zip",
            checksum: "2c63ea8e8d7912c1e77c1c66b13ba7b6e439e92265ae229d100c332e2a670568"
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
