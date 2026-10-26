// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库中的 Objective-C category 需要 -ObjC：本清单【不再】用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。改由【消费方】在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：binaryTarget url 指向其 GitHub Releases tag 6.4.2 的
//   各 IFLYAd<模块>.xcframework.zip（checksum 为 sha256）；本仓同时承载伞 target 与受版本控制资源。
// 产物由私有源码仓的 package-model-a-release.sh 打包并计算 checksum（device(ios-arm64)+simulator 双切片）；
//   换版本/主机时在私有源码仓重跑该脚本后，据 release/checksums.txt 同步更新此处的 url/checksum。
// binaryTarget 本身不能声明资源；Core / VideoUI / Reward 伞 target 分别投递受版本控制的资源。
// 所有公开 product 均经 Core 依赖闭包自动携带 PrivacyInfo.xcprivacy；视频格式自动携带
// VideoUI 资源，Reward 额外携带激励资源，接入方无需手工复制资源 bundle。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    // 下列 checksum 来自 6.4.2 正式签名 zip。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdCore.xcframework.zip",
            checksum: "427a7ab0a95b76f2587d0d4c4fc66dcea35f1e6ebb6cf8de6ed8d4898982dda3"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdVideoUI.xcframework.zip",
            checksum: "512da919ddcccb4b039aca424ce5aa2db9155fbc7ecd2c9b4f252bdac2fa543e"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdBanner.xcframework.zip",
            checksum: "82c30a65d7bea52d85e1314c93a5cd7d83170d45cf6d2b0a6cb7fec09bce1bf9"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdSplash.xcframework.zip",
            checksum: "7d2c62ceb429e542539fb82d5ab5d01c3b91ec97ab988a42d8aca1a3ef5e6879"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdInterstitial.xcframework.zip",
            checksum: "143a92184447a06ecafe84d017efed50d1930935f98fb2099bcb0512dbd94ece"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdNativeFeed.xcframework.zip",
            checksum: "382f2fbe79e4149aea20c3d0b13bf4201f1af517fbf0c133a2e9d6890be8a924"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.4.4/IFLYAdReward.xcframework.zip",
            checksum: "02f5c8f00405f8248424574d42992d7eeff9ed66086e4eb8807aca480e71bb04"
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
