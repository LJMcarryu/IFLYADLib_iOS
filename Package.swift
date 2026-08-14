// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库中的 Objective-C category 需要 -ObjC：本清单【不再】用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。改由【消费方】在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：binaryTarget url 指向其 GitHub Releases tag 6.2.3 的
//   各 IFLYAd<模块>.xcframework.zip（checksum 为 sha256）；本仓同时承载伞 target 与受版本控制资源。
// 产物由私有源码仓的 package-model-a-release.sh 打包并计算 checksum（device(ios-arm64)+simulator 双切片）；
//   换版本/主机时在私有源码仓重跑该脚本后，据 release/checksums.txt 同步更新此处的 url/checksum。
// binaryTarget 本身不能声明资源；Core / VideoUI / Reward 伞 target 分别投递受版本控制的资源。
// 所有公开 product 均经 Core 依赖闭包自动携带 PrivacyInfo.xcprivacy；视频格式自动携带
// VideoUI 资源，Reward 额外携带激励资源，接入方无需手工复制资源 bundle。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    // 下列 checksum 为 6.2.3 冻结签名 zip 的 SwiftPM 校验值。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdCore.xcframework.zip",
            checksum: "d882ccf1acbd1c8e7958f5d1d97fa72ce40f41d8796fa33d47ff5bd3a76a38e8"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdVideoUI.xcframework.zip",
            checksum: "da5e2d4de39f52f1aa97aeefeba0550de07c2dbdebe03c9ebaf41f5f4f7980aa"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdBanner.xcframework.zip",
            checksum: "99088d7483fe2d42d2fb64b6b47bc2eec1912a01c98994f8e728bca5a826905c"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdSplash.xcframework.zip",
            checksum: "969abb76d564ee29069823f93cd374fee9fe5f190d6240919316511317093fe2"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdInterstitial.xcframework.zip",
            checksum: "151ab58809ebc7e651ccfd53c274a75fbb6cc8eb9ba470de93d7a3555960618d"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdNativeFeed.xcframework.zip",
            checksum: "50856aa95a23a0447466928c663bbd2a778434d389c78c23e4c0fe9e01384c62"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.2.3/IFLYAdReward.xcframework.zip",
            checksum: "18941262de267834531794a589c8af430574f7572f0b9e06a9b6522d97a7d3fd"
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
