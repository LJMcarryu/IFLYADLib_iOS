// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库中的 Objective-C category 需要 -ObjC：本清单【不再】用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。改由【消费方】在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：binaryTarget url 指向其 GitHub Releases tag 6.3.0 的
//   各 IFLYAd<模块>.xcframework.zip（checksum 为 sha256）；本仓同时承载伞 target 与受版本控制资源。
// 产物由私有源码仓的 package-model-a-release.sh 打包并计算 checksum（device(ios-arm64)+simulator 双切片）；
//   换版本/主机时在私有源码仓重跑该脚本后，据 release/checksums.txt 同步更新此处的 url/checksum。
// binaryTarget 本身不能声明资源；Core / VideoUI / Reward 伞 target 分别投递受版本控制的资源。
// 所有公开 product 均经 Core 依赖闭包自动携带 PrivacyInfo.xcprivacy；视频格式自动携带
// VideoUI 资源，Reward 额外携带激励资源，接入方无需手工复制资源 bundle。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    // 下列 checksum 来自 6.3.0 正式签名 zip。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdCore.xcframework.zip",
            checksum: "65e9de1069232f8eb8939649dab2d9684a41ce9143303d7b42a68f2c39b23e73"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdVideoUI.xcframework.zip",
            checksum: "6eea80903e7a45583c96ba00119041835467a50f65cdb15467dc39f5acebae18"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdBanner.xcframework.zip",
            checksum: "dc31bc372ae78001fe3ac825110bd63de1a0e6351f38ac3580c72709203eab6d"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdSplash.xcframework.zip",
            checksum: "096c72d0f4cfa69001e83bc06c0ab66fae34235a8d1f811d74f2f0123d6ceb38"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdInterstitial.xcframework.zip",
            checksum: "2985ac1b8af5071418a1de28fa831f9287f2cbf9fc68cd835f5a6b61700597a8"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdNativeFeed.xcframework.zip",
            checksum: "b5a3c0e9cd677e82e2c5b9b641d07cb14ac36f8fef6e4c109633800097fa99af"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.3.0/IFLYAdReward.xcframework.zip",
            checksum: "db919bb3c5196fa6567f4323a6505d899ee7a5d8a92b246e22681da77bdc0b6b"
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
