// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库中的 Objective-C category 需要 -ObjC：本清单【不再】用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。改由【消费方】在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：binaryTarget url 指向自有域名上的 6.4.6 TOS 冻结资产：
//   各 IFLYAd<模块>.xcframework.zip（checksum 为 sha256）；本仓同时承载伞 target 与受版本控制资源。
// 产物由私有源码仓的 package-model-a-release.sh 打包并计算 checksum（device(ios-arm64)+simulator 双切片）；
//   换版本/主机时在私有源码仓重跑该脚本后，据 release/checksums.txt 同步更新此处的 url/checksum。
// binaryTarget 本身不能声明资源；Core / VideoUI / Reward 伞 target 分别投递受版本控制的资源。
// 所有公开 product 均经 Core 依赖闭包自动携带 PrivacyInfo.xcprivacy；视频格式自动携带
// VideoUI 资源，Reward 额外携带激励资源，接入方无需手工复制资源 bundle。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    // 下列 checksum 来自 6.4.6 冻结签名 zip。
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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdCore.xcframework.zip",
            checksum: "05f4ca5038c4c4c3e55ba4ed999bbfaa17028fbdba869ed5b04cda45c7ce09b4"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdVideoUI.xcframework.zip",
            checksum: "26ff648c5ff3028bdf1f090a7192c990d6d01563fbaad5af165590bdb3cf37fd"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdBanner.xcframework.zip",
            checksum: "536d3a146459f1c0a5c957455177da85ea320e88165bc48bfbaa209d6bbcb8fd"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdSplash.xcframework.zip",
            checksum: "7e6ca0e14b464c5c2e918cec7d042de193b38dffda48e3f32da9bfd46bbd7a1a"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdInterstitial.xcframework.zip",
            checksum: "369a00ea236c2f0e3f935cb5df3a092d75c8e9b3a7e1712950356243b27c81ea"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdNativeFeed.xcframework.zip",
            checksum: "0c6d8f1cfa6c2c4341842b64420f1758b63aa4ff13f728ffe103c6e4d11330ee"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/general/IFLYAdReward.xcframework.zip",
            checksum: "f2c0804743e0d1460d9653aa720d18045c7794cc36d2c1949d576242bb2680de"
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
