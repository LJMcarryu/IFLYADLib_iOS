# IFLYADLibSimple 接入示例

本工程使用 `IFLYADLib 6.3.5`，包含开屏、Banner、插屏、激励视频，以及信息流基础卡片和列表复用，共六个页面。内置渲染页面展示加载、就绪、展示和关闭；信息流页面展示素材渲染、视图挂载与解绑。

自己的 App 如何安装 SDK、各格式的公开接口与完整配置，见[仓库接入指南](../README.md)。

## 下载与运行

准备 macOS、Xcode、CocoaPods 和一个可用的 iOS Simulator runtime。工程最低部署版本为 iOS 11.0；真机调试需要选择自己的开发者 Team 和 Bundle Identifier。安装依赖需要访问 GitHub、`raw.githubusercontent.com` 和 CocoaPods 源。

首次获取最新示例，在终端执行：

```bash
git clone https://github.com/LJMcarryu/IFLYADLib_iOS.git
cd IFLYADLib_iOS/IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

已有仓库时，进入本目录从 `pod install` 开始。Podfile 固定使用公开 `6.3.5` Podspec，默认安装 `Full`；更新示例源码不会自动升级 SDK。

1. 在 Xcode 选择 **IFLYADLibSimple** scheme 和一个已安装的 iPhone 模拟器或真机。
2. 按下方说明替换广告位，真机运行时在 **Signing & Capabilities** 设置签名，再 Build & Run。
3. 首页显示实际加载的 SDK 版本和六个入口。先打开 Banner 或开屏测试基本流程，再查看信息流列表复用。
4. 内置渲染页面先点 **Load**，等待页面显示“已 ready，可展示”后点 **Show**。`didLoad` 不表示展示就绪。

始终打开 `.xcworkspace`。只打开 `.xcodeproj` 会遗漏 Pods 依赖。不要额外拖入另一套 SDK framework，避免重复符号和版本混用。

## 修改哪些配置

### 广告位

在 [`IFLYAdPrefixHeader.pch`](IFLYADLibSimple/Supporting%20Files/IFLYAdPrefixHeader.pch) 修改以下宏，保留 `@"..."` 的 Objective-C 字符串写法：

| 宏 | 对应页面与素材 |
| --- | --- |
| `__SPLASH_NATIVE_AD_UNIT_ID__` | 图片开屏；名称中的 `NATIVE` 不表示 NativeFeed API |
| `__SPLASH_VIDEO_AD_UNIT_ID__` | 视频开屏 |
| `__BANNER_AD_UNIT_ID__` | Banner |
| `__INTERSTITIAL_AD_UNIT_ID__` | 插屏 |
| `__REWARD_VIDEO_AD_UNIT_ID__` | 激励视频 |
| `__TYPED_ONE_NATIVE_AD_UNIT_ID__` | 信息流单图、列表复用 |
| `__TYPED_MORE_NATIVE_AD_UNIT_ID__` | 信息流多图 |
| `__FEED_VIDEO_AD_UNIT_ID__` | 信息流视频 |

向平台申请与自己的 App、广告形式匹配的 ID。示例 ID 不用于生产投放，是否有填充取决于平台配置与实际请求条件。选择“图片/视频/多图”会切换广告位，不会把返回的素材强制转换成另一种形式。

### 请求与展示

共享请求参数在 [`IFLYADUtil.m`](IFLYADLibSimple/Supporting%20Files/IFLYADUtil.m) 的 `mediaSampleRequestConfig` 中设置：请求超时为 5 秒，App 名称和版本取自工程配置，IDFA 只在允许读取时提供。`settleType`、`bidFloor` 和 `interactStatus` 是联调示例值，迁入业务 App 前按平台约定调整。

展示配置由各页面创建：开屏演示底部品牌区和跳过计时；插屏可切半屏/全屏；视频默认静音。请求配置传给 `loadAdWithRequestConfig:`，展示配置传给对应 `show` 方法，两者不要混用。

### 隐私、ATT 与 HTTP

[`AppDelegate.m`](IFLYADLibSimple/AppDelegate.m) 在应用进入前台后处理 ATT 请求，设置个性化状态并开启示例日志。`setPersonalizedEnabled:` 只记录媒体选择，不会阻止数据处理或广告请求，也不是隐私同意开关。

本示例没有业务隐私协议页面。迁入生产 App 时，应在取得应用所需的隐私同意后才允许进入广告加载流程；ATT 由宿主在合适时机请求。IDFA 为空时不要伪造 IDFA，也不要把未授权直接判定成 SDK 初始化失败。

[`Info.plist`](IFLYADLibSimple/Info.plist) 包含 `NSUserTrackingUsageDescription` 和用于联调 HTTP 素材的 ATS 设置。生产 App 应使用自己的权限文案与网络配置，并如实完成隐私披露。示例日志仅用于联调，上线前检查日志开关以及业务自行记录的广告数据。

## 按页面验证

| 首页入口 | 操作顺序 | 观察结果 | 代码 |
| --- | --- | --- | --- |
| 开屏广告 | 选择图片或视频 → Load → 等待 Ready → Show | 广告及底部品牌区显示；点击、跳过或关闭时收到对应回调 | [开屏](IFLYADLibSimple/biz/splash/IFLYSplashViewController.m) |
| Banner 广告 | Load → 等待 Ready → Show → Destroy | 广告显示在页面容器内；关闭或销毁后清理 | [Banner](IFLYADLibSimple/biz/banner/IFLYBannerViewController.m) |
| 插屏广告 | 选择半屏或全屏 → Load → 等待 Ready → Show | 按所选样式呈现，关闭后回到示例页面 | [插屏](IFLYADLibSimple/biz/interstitial/IFLYInterstitialViewController.m) |
| 激励视频广告 | Load → 等待 Ready → Show | 观察播放、关闭和 `didRewardEffective`；只有奖励回调才可发奖 | [激励](IFLYADLibSimple/biz/reward/IFLYRewardVideoViewController.m) |
| 自渲染信息流 | 选择单图、视频或多图 → Load | 页面下载并渲染图片，或把视频容器交给 SDK，挂载后等待曝光 | [基础卡片](IFLYADLibSimple/biz/native/IFLYNativeViewController.m) |
| 信息流列表复用（SDK 托管） | 滚动到第 5 行 → 滑出 → 滑回 → 淘汰广告 | 同一条广告暂时离屏可恢复；淘汰后不再恢复该条广告 | [列表复用](IFLYADLibSimple/biz/native/IFLYNativeFeedListViewController.m) |

内置渲染页面的 **检查状态** 用于查看实例是否仍可展示；**Destroy** 终止当前实例，再次测试需重新 Load。信息流基础卡片没有独立 Show 按钮，素材准备好后自动挂载。列表页面没有 Load 按钮，广告行进入可见区域时开始请求。

一次正常内置渲染加载会先收到 `didLoad`，再收到 `didReady`；点击 Show 后检查 `didShow`，真正满足可见条件后检查 `didExpose`。NativeFeed 没有 `didReady`，使用 `didLoad`、媒体素材渲染和 `didRender` 观察进度。

编译成功只证明接入和链接完成；取得填充、展示、曝光、点击返回和奖励须在有效广告位环境分别验证。不要手工调用 delegate 或伪造曝光/奖励来替代运行验证。

## 信息流接入要点

数据层强持有 `IFLYNativeFeedAd`，Cell 负责自己的视图。主线程完成素材渲染与布局后调用 `attachWithViewBinder:error:`；广告暂时离屏时按具体容器同步调用 `detachAdFromContainerView:`，保留 Ad，以便回到屏幕后重新挂载。

- `didEndDisplayingCell:` 使用回调给出的 Cell；在 `prepareForReuse` 和重建广告子视图前解绑旧容器，不按旧 `indexPath` 查找对象。
- Redirect/Download 提供实际点击视图，Exposure/Unknown 传 `@[]`。关闭按钮填入 `closeView`，点击和落地页交给 SDK。
- 视频的 `videoView` 使用普通 `UIView`，不创建另一套播放器；离屏后再回来，不要无条件调用 `startPlay` 覆盖用户的暂停意图。
- 永久移除条目或退出页面时，解绑容器、清空 delegate 并释放 Ad；只想暂时离屏时不要 `destroy`。
- `detachFromCurrentContainer` 仅适合固定、非复用且不会迁移的单容器，不能用于列表的迟到回调。
- 常规接入将点击按钮放在广告容器内。确需外部 CTA 时，按根 [README](../README.md#自渲染信息流)显式设置 `allowsExternalClickViews`，并处理 `71503` 拒绝回调。

## 接入部分广告形式

此示例编译全部六个页面，需要 `Full`。业务 App 可以按根[安装说明](../README.md#安装)选择所需 subspec/product。

如果把本示例改成仅开屏，除了把 Podfile 改为 `IFLYADLib/Splash`，还须从 App target 移除 Banner、插屏、信息流、激励页面的编译源及首页导入和入口，再重新 `pod install`。仅修改 Podfile 会因其他页面继续引用未安装类型而编译失败。

## 命令行构建

在本目录安装 Pods 后，先查看可用设备：

```bash
xcodebuild -showdestinations \
  -workspace IFLYADLibSimple.xcworkspace -scheme IFLYADLibSimple
```

只检查模拟器编译和链接时，无需选择具体设备：

```bash
xcodebuild build \
  -workspace IFLYADLibSimple.xcworkspace \
  -scheme IFLYADLibSimple -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

真机运行使用 Xcode 的签名配置；模拟器构建成功不能代替真机的点击回流、视频声音、系统授权及后台恢复测试。

## 常见问题

| 现象 | 检查顺序 |
| --- | --- |
| Podspec 下载失败、TLS/超时 | 检查网络能否访问 Podspec 和 GitHub Release；恢复后重新 `pod install`，不要改成不存在的 trunk 版本 |
| 找不到 `IFLYADLib.h` 或某个广告类 | 确认 Pods 安装成功、打开 workspace，且使用 Full；检查是否误删格式 subspec |
| 重复符号或版本不一致 | 移除手工添加的另一份 SDK；不要同时接入通用版与同名类的定制包 |
| Show 不可点击 | 检查是否收到 Ready，或实例已被展示、关闭、销毁；重新 Load 新实例 |
| 没有填充 | 核对广告位、App 配置、网络及错误码；按平台建议重试，避免无限循环请求 |
| 图片下载失败或落地页空白 | 检查 HTTP/HTTPS、ATS 和网络错误；图片未渲染时不要挂载信息流 |
| NativeFeed `71503` | 按 point 检查点击视图、主线程、尺寸和可见性；不可点击广告用空点击数组 |
| 列表广告滑回不见 | 数据层保留原 Ad，离屏仅 detach，回屏重新 attach；已关闭、过期或淘汰时换新广告 |
| IDFA 为空 | 检查 ATT 状态和权限文案；授权后重新读取，不能用固定标识代替 |
| SDK 资源丢失 | 确认资源随依赖安装；最终 App 链接参数保留 `$(inherited)` 和 `-ObjC` |

## 反馈问题

到[公开 Issues](https://github.com/LJMcarryu/IFLYADLib_iOS/issues)提供 SDK 版本、Xcode/iOS 版本、模拟器或机型、页面入口、操作顺序和错误码。截图与日志先脱敏，不提交完整 token、设备标识或业务敏感数据。
