# Swift 模块接入与头路径迁移

本文面向从通用模型 A 旧包升级到 `6.5.0` 的宿主开发者。安装入口见[安装与分包](安装与分包.md)，历史 Tag、Release 和资产保持不可变。

## 先确认升级范围

本次覆盖 Core、VideoUI、Banner、Splash、Interstitial、NativeFeed、Reward 七模块，仍然静态链接。每个 XCFramework 的平台切片从 `.a + Headers` 改为带 `Headers`、`Modules/module.modulemap` 和模块专属伞头的 `.framework`；无需嵌入动态库。`Full` 继续聚合五种广告及其依赖，不是第八个二进制，也不是可替代二进制模块名的导入承诺。

本版还包含点击策略 `ids_a`、CAID 系统时间字段和加速度计能力守卫变化。升级前由服务端及宿主负责人一起审阅[更新记录](../../CHANGELOG.md)，不能只替换包装后沿用旧字段、监测模板或合规结论。优酷 NativeFeed 的 SDK 摇/扭 fallback 不属于通用能力。

公开类、方法和协议签名保持；旧 `<IFLYADLib/...>` 头路径在本次目标结构中不作为兼容承诺，因此 Objective-C 工程需要修改导入。全部模块和资源锁定同一版本；不要混用新旧模块，或同时链接通用模型 A 与任一导出相同 `IFLY*` 类的整包。

## 选择产品与模块

产品名用于选择安装内容，二进制模块名用于代码导入。仅导入所安装格式；VideoUI 为视频格式的内部依赖，不提供宿主广告入口。

| 需要的能力 | SwiftPM product / CocoaPods subspec | 必需二进制模块 | Swift 导入 |
| --- | --- | --- | --- |
| 基础配置和公共类型 | `Core` | `IFLYAdCore` | `import IFLYAdCore` |
| Banner | `Banner` | Core、`IFLYAdBanner` | Core、`IFLYAdBanner` |
| 自渲染信息流 | `NativeFeed` | Core、`IFLYAdNativeFeed` | Core、`IFLYAdNativeFeed` |
| 开屏 | `Splash` | Core、VideoUI、`IFLYAdSplash` | Core、`IFLYAdSplash` |
| 插屏 | `Interstitial` | Core、VideoUI、`IFLYAdInterstitial` | Core、`IFLYAdInterstitial` |
| 激励视频 | `Reward` | Core、VideoUI、`IFLYAdReward` | Core、`IFLYAdReward` |
| 五种格式 | `Full` | 全部七模块 | Core 与实际调用的五种格式模块 |

表中 Core、VideoUI 分别指 `IFLYAdCore`、`IFLYAdVideoUI`。多个格式共用一份 Core 和 VideoUI；包管理器通过 product/subspec 的依赖关系带入，手动集成须自行补齐。

## 安装与宿主配置

以下步骤使用同一版本的正式资产，固定为 `6.5.0`。

1. 选择一种安装方式。SwiftPM 固定 `6.5.0` Tag 和所需 product；CocoaPods 使用官方 trunk 与所需 subspec，具体命令见[安装指南](安装与分包.md)。
2. 手动接入时，替换所选格式及全部依赖的 XCFramework；把各模块的 XCFramework 根目录交给 Xcode 选择平台切片，Embed 设为 **Do Not Embed**。不要单独拖入切片 framework，也不要复制旧切片的头目录覆盖新包。
3. 最终 App target 的 `Other Linker Flags` 添加 `$(inherited) -ObjC`。CocoaPods 的配置传播也须在最终 App 的 build settings 中确认；SwiftPM 接入由宿主设置此参数。
4. 链接 `AdSupport.framework`，`AppTrackingTransparency.framework` 保持 **Optional**。最低 iOS 声明为 11.0；实际兼容性仍须检查最终 Mach-O、目标设备与运行结果。
5. 保留资源闭包。Core 总是需要，视频格式另需 VideoUI，Reward 另需 Reward 资源。SwiftPM/CocoaPods 按依赖投递；手动集成从同版 Tag 的 `spm` 取得 `IFLYADLibCoreResources.bundle`、所需 `IFLYADLibVideoUIResources.bundle`、`IFLYADLibRewardResources.bundle`，加入 **Copy Bundle Resources**。把 `spm/Core/Resources/PrivacyInfo.xcprivacy` 单独加入，不能仅确认 zip 内有文件。
6. 通过 `.xcworkspace` 构建消费工程。先确认导入和链接，再在目标系统验证资源加载、授权、广告回调和业务收尾。

新 framework 公开头平铺在自己的 `Headers` 下，由 framework 搜索与 modulemap 解析；不需要把旧 `Headers/IFLYADLib` 添加到自定义 `HEADER_SEARCH_PATHS`。包管理器配置后若 Swift 找不到模块，先检查所安装版本和完整依赖，不用额外头搜索路径掩盖缺失。

## Swift 直接导入

Banner 最小类型消费示例：

```swift
import UIKit
import IFLYAdCore
import IFLYAdBanner

final class BannerHost: NSObject, IFLYBannerAdDelegate {
    let ad = IFLYBannerAd(adUnitId: "替换为自己的Banner广告位")

    override init() {
        super.init()
        ad.delegate = self
        let request = IFLYAdRequestConfig()
        request.appName = "YourApp"
        ad.apply(request)
    }

    func bannerAdDidReady(_ ad: IFLYBannerAd) {
        // 确认自己的容器完成布局后，再调用 ad.show(in: container)。
    }
}
```

这个示例引用真实类、公共请求配置和回调协议，不会因为模块缺失而静默跳过。宿主强持有 `BannerHost`，再按[Banner 指南](Banner广告.md)控制加载和展示时机；仅创建对象不会发起请求。Swift importer 将 Objective-C 的 `applyRequestConfig:` 映射为 `apply(_:)`，其他调用以 Xcode 对目标版本显示的 Swift 接口为准。

使用其他格式时增加相应导入，例如：

```swift
import IFLYAdCore
import IFLYAdSplash
import IFLYAdInterstitial
import IFLYAdNativeFeed
import IFLYAdReward
```

SwiftPM 的 `Full`、`Banner` 等是产品名；本文不承诺 `import Full`、`import Banner` 或 `import IFLYADLib` 重导出模型 A 的公开 API。模块使用全名和正确大小写。

升级并验证新模块后，可删除仅为本 SDK 配置的 bridging header 引用；如果同一 bridging header 仍服务于其他 Objective-C 代码，只移除 SDK 的旧头导入，保留其他配置。不要保留旧 SDK 头与新模块同时声明同一组类型。

## Objective-C 头路径迁移

按代码实际使用的类型导入。Core 和格式头分别归属自身模块，格式头引用共享类型时依赖 Core，不重复复制共享头。

| 使用的头 | 旧路径（6.4.4） | 新路径（6.5.0） |
| --- | --- | --- |
| 共享类型、配置与工具 | `<IFLYADLib/IFLYAdTypes.h>` 等 | `<IFLYAdCore/IFLYAdTypes.h>` 等；也可使用 `<IFLYAdCore/IFLYAdCore.h>` |
| Banner | `<IFLYADLib/IFLYBannerAd.h>` | `<IFLYAdBanner/IFLYBannerAd.h>` |
| 开屏 | `<IFLYADLib/IFLYSplashAd.h>` | `<IFLYAdSplash/IFLYSplashAd.h>` |
| 插屏 | `<IFLYADLib/IFLYInterstitialAd.h>` | `<IFLYAdInterstitial/IFLYInterstitialAd.h>` |
| 信息流及数据 | `<IFLYADLib/IFLYNativeFeedAd.h>`、`<IFLYADLib/IFLYNativeFeedAdData.h>` | `<IFLYAdNativeFeed/IFLYNativeFeedAd.h>`、`<IFLYAdNativeFeed/IFLYNativeFeedAdData.h>` |
| 激励视频 | `<IFLYADLib/IFLYRewardVideoAd.h>` | `<IFLYAdReward/IFLYRewardVideoAd.h>` |

例如仅使用 Banner 的文件：

```objective-c
#import <IFLYAdCore/IFLYAdCore.h>
#import <IFLYAdBanner/IFLYBannerAd.h>

IFLYBannerAd *ad = [[IFLYBannerAd alloc] initWithAdUnitId:@"自己的Banner广告位"];
IFLYAdRequestConfig *request = [IFLYAdRequestConfig new];
[ad applyRequestConfig:request];
```

旧总伞头 `<IFLYADLib/IFLYADLib.h>` 不对应新的聚合 framework。使用多种格式的文件分别导入需要的模块头；仅选择 Banner 时不要为修复导入错误额外装入 Full。旧版指南中的旧头示例继续适用于其标注的 `6.4.4`，迁移时按此表替换导入，沿用方法签名和广告生命周期规则。

## 验证升级结果与排错

| 现象或检查 | 处理 |
| --- | --- |
| `no such module 'IFLYAdCore'` | 确认使用新 framework 结构、Core 已加入目标，且没有继续解析旧版缓存。先检查依赖版本和实际切片，不加旧头搜索路径。 |
| `IFLYADLib/... file not found` | 宿主仍使用旧导入，或混入旧公开头；按上表迁移并整组核对版本。 |
| 类型重复或链接重复符号 | 检查是否同时链接整包和模型 A、重复 Core，或旧头与模块同时暴露同一类型。 |
| Swift 能导入但 App 链接失败 | 检查完整依赖、最终 `-ObjC` 和系统 framework，不能把语法解析成功当作最终链接。 |
| 能构建但无资源或隐私清单 | 查看最终 App 包，确认对应 bundle 与独立隐私清单已复制，再验证实际加载。 |
| 部分格式能编译、组合失败 | 在只含所选格式依赖的干净宿主中重测；缺 Core 或必需 VideoUI 应报错，不添加未选格式兜底。 |

本地编译证明只覆盖实际执行的工具链、架构和资产。iOS 11 最低系统声明不等于已完成真机运行，模拟器成功也不等于实际媒体投放通过。发布状态与验收范围以根目录 `release-state.json`、README 发布说明和同版发布记录为准。

升级失败时，回到固定的旧正式版本及其同版资源；不要保留半套新模块或覆盖历史资产。反馈时提供 SDK 版本、Xcode/iOS、安装方式、所选产品、实际 import 和完整编译错误，并移除 token、设备标识与业务敏感值。
