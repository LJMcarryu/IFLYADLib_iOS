// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库 category / +load 依赖 -ObjC：本清单不用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。消费方需在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// binaryTarget url 指向本仓库 GitHub Releases tag 6.0.7 的各 IFLYAd<模块>.xcframework.zip（device ios-arm64 + simulator 双切片），checksum 为其 sha256。
// 资源 bundle 限制：SwiftPM 的 binaryTarget 不能像 CocoaPods 那样挂 resource_bundles；需要
//   Core/VideoUI/Reward 资源的消费方请走 CocoaPods（podspec 已配 resource_bundles），或把资源 .bundle 嵌进对应 xcframework。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    platforms: [
        .iOS(.v13),
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdCore.xcframework.zip",
            checksum: "d89e4c7f704dad282a592b56e226e027710863fe3f856b933dedb2e226a66798"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdVideoUI.xcframework.zip",
            checksum: "b7b48ea71c18ba60c75c1f801d82221dda48741475a8ffd4940f6cb8db903b8b"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdBanner.xcframework.zip",
            checksum: "a40e7d93e6760ec6e6aa3aae166477c78f7dfc3b8a55dffd58e22fcd5fbf66c3"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdSplash.xcframework.zip",
            checksum: "f9a08c9b65d8419cc94f18fa5aecef8bd023bdb17f41fe940edabd18d5cfe4f2"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdInterstitial.xcframework.zip",
            checksum: "04237e64ceec41f8ee53901231ea1c19d7a749ddb60cfca7c5b063b801cdd0ca"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdNativeFeed.xcframework.zip",
            checksum: "09db564d826ae4cdcacb53c90e1d2f3f40135dc806be0c3165f669479b44c8f9"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.7/IFLYAdReward.xcframework.zip",
            checksum: "4588a72cebb40bb6d324888a211173f7c2c438b4430f1185b528e0ef81494aa1"
        ),
        .target(
            name: "Core",
            dependencies: [
                "IFLYAdCore",
            ],
            path: "spm/Core"
        ),
        .target(
            name: "VideoUI",
            dependencies: [
                "IFLYAdVideoUI",
                "Core",
            ],
            path: "spm/VideoUI"
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
            path: "spm/Reward"
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
