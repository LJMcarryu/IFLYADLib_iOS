// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库中的 Objective-C category 需要 -ObjC：本清单【不再】用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。改由【消费方】在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：binaryTarget url 指向其 GitHub Releases tag 6.1.0 的
//   各 IFLYAd<模块>.xcframework.zip（checksum 为 sha256）；本仓同时承载伞 target 与受版本控制资源。
// 产物用 scripts/package-model-a-release.sh 打包并算 checksum（device(ios-arm64)+simulator 双切片）；
//   换版本/主机时重跑该脚本（--base-url <新主机>）后据 release/checksums.txt 同步更新此处与公开仓 url/checksum。
// binaryTarget 本身不能声明资源；Core / VideoUI / Reward 伞 target 分别投递受版本控制的资源。
// 所有公开 product 均经 Core 依赖闭包自动携带 PrivacyInfo.xcprivacy；视频格式自动携带
// VideoUI 资源，Reward 额外携带激励资源，接入方无需手工复制资源 bundle。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    // 下列 7 个 checksum 来自 6.1.0 正式签名 zip 的 swift package compute-checksum 结果。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdCore.xcframework.zip",
            checksum: "7b1d616e3a778e6b2f192cc6b23e62b5ef9ca69a4f5c071afe0693eb71bc84d2"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdVideoUI.xcframework.zip",
            checksum: "e6a99fd2928c1b787b35d6efd64cf4ab4fdc11bcbe08e3bf6538db15803f223f"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdBanner.xcframework.zip",
            checksum: "a34cca13ec3863312e9a0984a7ec75bfd28ad8d335a45e95a449133716d12e99"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdSplash.xcframework.zip",
            checksum: "3b591f78515d8f51c3471aecf9ddb8714a06e1ebd50b35968e0df0b9208dd55a"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdInterstitial.xcframework.zip",
            checksum: "dab4f65b26f6ec7b28c5a7bb46af416b8ccb0746441446f53f7730115a2507cb"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdNativeFeed.xcframework.zip",
            checksum: "e9e2464dec930b6199a62ce2b8f639457c44cd454e7669f8f7aa1991200182f3"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.1.0/IFLYAdReward.xcframework.zip",
            checksum: "9ee8b802f8c7eef5dd6c74f5360b7b03c0670d56bc35f6c21b2e369393adca3d"
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
