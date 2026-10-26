# Banner 广告

适用于 `IFLYADLib 6.4.3`。[返回 SDK 首页](../../README.md)。完整方法签名以所安装版本的公开头为准。

先阅读[配置与隐私](配置与隐私.md#请求配置)。下面的代码为业务控制器片段：属性放在类声明内，方法放在 `@implementation` 内；`requestConfig` 是该指南中的宿主辅助方法。

容器必须已经完成布局，宽度大于 0；高度为 0 时 SDK 可按素材比例自适应。

```objc
@interface BannerViewController () <IFLYBannerAdDelegate>
@property (nonatomic, strong) IFLYBannerAd *bannerAd;
@property (nonatomic, strong) UIView *bannerContainer;
@end

- (void)loadBanner {
    IFLYBannerAd *ad = [[IFLYBannerAd alloc] initWithAdUnitId:@"YOUR_BANNER_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.closeButtonVisible = YES;
    self.bannerAd = ad;
    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)bannerAdDidReady:(IFLYBannerAd *)ad {
    if (ad == self.bannerAd && ad.isAdValid) {
        [ad showInView:self.bannerContainer];
    }
}
```

展示、曝光、点击、跳转、关闭和失败分别通过 delegate 回调通知。Banner 实例展示后不要再次 `loadAd`，需要新机会时销毁旧实例并重新创建。

加载失败、重试与对象清理见[失败处理与生命周期](常见问题.md#生命周期)。
