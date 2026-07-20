// swift-tools-version:5.9

// 模型 A 的 binaryTarget 均为只含自身 .o 的静态 xcframework，模块间符号在最终 App link 阶段统一解析。
// SwiftPM 的 binaryTarget 不能直接声明 target 间依赖，因此这里使用轻量伞 target 表达依赖图。
// 静态库 category / +load 依赖 -ObjC：本清单【不再】用 .unsafeFlags 注入 -ObjC（unsafeFlags 会让本包
// 无法作为带版本号的依赖被标准 SwiftPM 消费）。改由【消费方】在自己 App target 的 OTHER_LDFLAGS 加 -ObjC。
// 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：binaryTarget url 指向其 GitHub Releases tag 6.0.14 的
//   各 IFLYAd<模块>.xcframework.zip（checksum 为 sha256）。本仓库私有，仅承载源码/构建脚本；此清单与公开仓一致。
// 产物用 scripts/package-model-a-release.sh 打包并算 checksum（device(ios-arm64)+simulator 双切片）；
//   换版本/主机时重跑该脚本（--base-url <新主机>）后据 release/checksums.txt 同步更新此处与公开仓 url/checksum。
// 资源 bundle 限制：SwiftPM 的 binaryTarget 不能像 CocoaPods 那样挂 resource_bundles；需要
//   Core/VideoUI/Reward 资源的消费方请走 CocoaPods（podspec 已配 resource_bundles），或把资源 .bundle 嵌进对应 xcframework。

import PackageDescription

let package = Package(
    name: "IFLYADLib",
    // 6.0.14 的 binaryTarget 已按 iOS 11 重新构建并与本声明同步发布。
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
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdCore.xcframework.zip",
            checksum: "7271cd7eefd3bbe98007dddd0eba6cee747c6dd86249aea7223299eab970a1f6"
        ),
        .binaryTarget(
            name: "IFLYAdVideoUI",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdVideoUI.xcframework.zip",
            checksum: "2f559fb21f8fef67ccf1fc9d728bf1e6675bb4d123ade4c7ba893ff33134e469"
        ),
        .binaryTarget(
            name: "IFLYAdBanner",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdBanner.xcframework.zip",
            checksum: "37e0a287687513c812bfeeceb08eb41ad3a240ce351d817aaf1a3a29e15c5803"
        ),
        .binaryTarget(
            name: "IFLYAdSplash",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdSplash.xcframework.zip",
            checksum: "59ab260e29f42efbbb55bdb6e61e0dd4117d895c74b5390b21de9343106146c7"
        ),
        .binaryTarget(
            name: "IFLYAdInterstitial",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdInterstitial.xcframework.zip",
            checksum: "61b5f2fac173c6c56c0641838077edef967f8ab1e2f727bbc7bc6831818e3de6"
        ),
        .binaryTarget(
            name: "IFLYAdNativeFeed",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdNativeFeed.xcframework.zip",
            checksum: "45981edb2d1db4e0bd0e67afbcaf6f8db4965de31f4ad0559baaf6ec589104c3"
        ),
        .binaryTarget(
            name: "IFLYAdReward",
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.14/IFLYAdReward.xcframework.zip",
            checksum: "d9ce7ec479c4cfa55477ed85ab9c7fb1062ff2ed6945bb6dbbb8ff4a6091eaa0"
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
