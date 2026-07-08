// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库 category / +load 依赖 -ObjC：本清单不用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。消费方需在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// binaryTarget url 指向本仓库 GitHub Releases tag 6.0.11 的各 IFLYAd<模块>.xcframework.zip（device ios-arm64 + simulator 双切片），checksum 为其 sha256。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdCore.xcframework.zip",
            checksum: "44b04bdd39da2fd57020eb8422b465c2093d38d8f5eb4989937b3051e2d2e124"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdVideoUI.xcframework.zip",
            checksum: "4f81d3dd3fb50c980a58bd8d4acd62f40621d04c3772f45ba758937aea1afa93"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdBanner.xcframework.zip",
            checksum: "434d17b6c3dc963dad4e30ea13978eb607984495cb6c56ec45bea777684c51d8"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdSplash.xcframework.zip",
            checksum: "10a75ffdfea6be03364a5ec9d2e78d471ac6140f8bbea9e21d7aa3c02b3982c0"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdInterstitial.xcframework.zip",
            checksum: "da3300c107427fcc17e1e3f1b974bccaf46fdabec9e5d17a1b11b96bbbc579f2"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdNativeFeed.xcframework.zip",
            checksum: "1c18a25a65a63325126c0aa7b4c6d2a790d20b7570f48307a97c97546cda450c"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.11/IFLYAdReward.xcframework.zip",
            checksum: "8ec1fce1bc4868c13a3884fe5752ff838fead2c1a7cdb83bd76068e08e7eaaa6"
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
