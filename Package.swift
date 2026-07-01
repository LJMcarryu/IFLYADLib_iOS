// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库 category / +load 依赖 -ObjC：本清单不用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。消费方需在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// binaryTarget url 指向本仓库 GitHub Releases tag 6.0.10 的各 IFLYAd<模块>.xcframework.zip（device ios-arm64 + simulator 双切片），checksum 为其 sha256。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdCore.xcframework.zip",
            checksum: "d5075ff4cb79bf9171d9c6a1cc741602154cbc6f70048c762ad0c253ba05e073"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdVideoUI.xcframework.zip",
            checksum: "5b2da0b82d5f0313a76d97a4141cde79f1cb846d4dc37e5f276e6bb97802360b"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdBanner.xcframework.zip",
            checksum: "1523304db8856b999f5f3897fe14fc9cb19e4b5d581d85fc51d1405730438181"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdSplash.xcframework.zip",
            checksum: "5030d22c39439640a9a87a7ccbd03d50dacd1d7f59fddc39d203b1228438ac96"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdInterstitial.xcframework.zip",
            checksum: "620d90588e475fb3113e82a1196b8c3456e19f078d7676ae9fd259fa3a821474"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdNativeFeed.xcframework.zip",
            checksum: "547428d88b257a21d125668a81a6b174546d5be8dcd4e824576d139fcae6adf0"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYAdReward.xcframework.zip",
            checksum: "b736b2f90376c2c715738c3e35669a93ce5e4ede62c7affcb29c00bdf3fd910c"
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
