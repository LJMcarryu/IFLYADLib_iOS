// swift-tools-version:5.9

import PackageDescription

// 独立消费端：不能通过本仓的本地 target 假装已消费 Release。
let package = Package(
    name: "IFLYADLibReleaseConsumer",
    platforms: [.iOS("11.0")],
    dependencies: [
        .package(
            url: "https://github.com/LJMcarryu/IFLYADLib_iOS.git",
            exact: "6.2.2"
        ),
    ],
    targets: [
        .target(
            name: "ReleaseConsumer",
            dependencies: [
                .product(name: "Full", package: "IFLYADLib_iOS"),
            ]
        ),
    ]
)
