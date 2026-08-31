# IFLYADLibSimple — IFLYADLib 接入示例

面向媒体接入方的最小示例，仅使用公开 API，演示开屏、Banner、插屏、自渲染信息流和激励视频。当前示例对应已于 2026-09-01 正式发布的 `6.3.1`。

## 运行

```bash
pod install
open IFLYADLibSimple.xcworkspace
```

- Podfile 已固定到不可变 `6.3.1` tag 及同版本 Release 资产。
- 正式资产必须包含 arm64 真机及 arm64/x86_64 模拟器切片。真机运行请在「Signing & Capabilities」选择自己的开发者 Team。
- 工程最低支持 iOS 11.0，默认安装 `Full`。

## 演示内容

| 目录 | 广告形式 |
| --- | --- |
| [`biz/splash`](IFLYADLibSimple/biz/splash) | 开屏 |
| [`biz/banner`](IFLYADLibSimple/biz/banner) | Banner |
| [`biz/interstitial`](IFLYADLibSimple/biz/interstitial) | 插屏 |
| [`biz/native`](IFLYADLibSimple/biz/native) | 自渲染信息流：固定卡片与列表复用均使用 SDK 托管挂载 |
| [`biz/reward`](IFLYADLibSimple/biz/reward) | 激励视频 |

NativeFeed 生命周期统一为：

- 数据层只持 `IFLYNativeFeedAd`；Cell 不持 Session、Binding、Binding 集合或首次/复用状态。
- 固定卡片或 Cell 完成媒体 UI 后，在主线程调用 Ad 级 `attachWithViewBinder:error:`。
- Cell 离屏、`prepareForReuse`、切普通内容或重建 Binder 子视图前，调用 `+[IFLYNativeFeedAd detachAdFromContainerView:]`。
- 暂时滑出继续持有原 Ad，回屏直接重新 attach；不调用 `destroy`。
- 永久淘汰时 detach 已知容器、`delegate=nil` 并释放 Ad；最后一个强引用释放后 SDK 自动收口。只有仍持有 Ad 但希望立即终止时才可选调用 `destroy`。
- 视频 detach/attach 保留进度与播放意图；不要在每次 attach 或 `nativeFeedAdDidRender:` 无条件调用 `startPlay`。

`Redirect/Download` 才传点击视图；`Exposure/Unknown` 显式传 `@[]`。视频只传普通 `UIView` 给 Binder，播放器和监测由 SDK 管理。

`6.3.1` 默认仍要求 `clickViews` 位于 `containerView`。确需容器外 CTA 时显式设置 `allowsExternalClickViews`：attach 可先于 CTA 挂载和布局，不要求同 Cell、共同 wrapper、几何相邻、固定祖先路径或面积比例；点击时仍校验当前租约、同 window/scene、有效尺寸、可见交互和 container 前台至少 `2/3` 可见。父级广告点击会为媒体 `UIControl` 或媒体手势退让；71503 通过 `[71503/<point>]` 中文提示定位。固定单容器页面可按需使用 `detachFromCurrentContainer`。

## 从 6.2.1 升级到 6.2.2

- 删除数据模型中的 DisplaySession，删除 Cell 中的 Binding 及首次/复用标记。
- 将所有展示路径改为 Ad 级 attach，将离屏、复用和切普通内容改为容器级 detach。
- 永久结束改为“detach 已知容器 → `delegate=nil` → 释放 Ad”；`destroy` 不再是正常生命周期必调项。
- 清理旧头文件和二进制缓存，使用正式 `6.2.2` 资产重新编译。

## 切换接入方案

示例默认使用 `Full`。只需部分格式时可把 Podfile 改为 `IFLYADLib/Splash`、`IFLYADLib/NativeFeed` 等 subspec。统一使用 `#import <IFLYADLib/IFLYADLib.h>`，或按需导入具体格式头。

完整的 CocoaPods、SwiftPM、隐私、S2S 与 Header Bidding 说明见仓库根 [README](../README.md)。
