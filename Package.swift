// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库 category / +load 依赖 -ObjC：本清单不用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。消费方需在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// binaryTarget url 指向本仓库 GitHub Releases tag 6.0.9 的各 IFLYAd<模块>.xcframework.zip（device ios-arm64 + simulator 双切片），checksum 为其 sha256。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdCore.xcframework.zip",
            checksum: "c1f04def0e148c409116bc9d4d7a480c45cd8ee66e46fdcbc81b9d427777cba6"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdVideoUI.xcframework.zip",
            checksum: "646b2b5547cbcdd03aa419979d05b813a689b42fa66b25dbb3af9baf2ba59a62"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdBanner.xcframework.zip",
            checksum: "d08b51e72373d6e5b1c6b1b5ab067c390983240645a1b62fcb263740b00500c1"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdSplash.xcframework.zip",
            checksum: "300f411008957ec35cacd04acd8796632d9b70480f94969711ab2c9de0d744a9"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdInterstitial.xcframework.zip",
            checksum: "1f3f3df932a3f3bd41e1c6d17dd0f75057d5af58cabdcf4a4df9ac953d63a4d4"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdNativeFeed.xcframework.zip",
            checksum: "f58b3f08ec77a5168d26a3695e5f009a553c2cb4a85553484fb8ba2d4eb9f4cd"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.9/IFLYAdReward.xcframework.zip",
            checksum: "3af8e6521caa84c0b10a36ba35186f048878af88d71e74510eebb040653c6293"
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
