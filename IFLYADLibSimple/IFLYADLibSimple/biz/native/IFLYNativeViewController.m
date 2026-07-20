#import "IFLYNativeViewController.h"

#import "IFLYADUtil.h"
#import <IFLYADLib/IFLYADLib.h>

@interface IFLYNativeViewController () <IFLYNativeFeedAdDelegate>

@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UISegmentedControl *slotControl;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *adBadgeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITextView *logView;

@end

@implementation IFLYNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自渲染信息流";
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
    [self log:@"信息流示例：Load -> 媒体渲染素材 -> bindAdWithViewBinder"];
}

- (void)dealloc {
    [self.nativeAd destroy];
}

- (void)setupUI {
    CGFloat margin = 16;
    CGFloat width = self.view.bounds.size.width;
    CGFloat contentWidth = width - margin * 2;
    CGFloat y = 100;

    UILabel *desc = [IFLYADUtil createSectionTitleWithText:@"媒体侧根据 adData 自行渲染 UI，然后通过 Binder 把容器、点击视图、关闭按钮和视频容器交给 SDK。"
                                                     frame:CGRectMake(margin, y, contentWidth, 42)];
    [self.view addSubview:desc];
    y += 54;

    self.slotControl = [[UISegmentedControl alloc] initWithItems:@[@"图文", @"视频"]];
    self.slotControl.frame = CGRectMake(margin, y, contentWidth, 32);
    self.slotControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.slotControl];
    y += 48;

    CGFloat buttonWidth = (contentWidth - 8) / 2.0;
    UIButton *loadButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(margin, y, buttonWidth, 44)
                                                            title:@"Load"
                                                           target:self
                                                           action:@selector(loadAd)];
    [self.view addSubview:loadButton];

    UIButton *destroyButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(margin + buttonWidth + 8, y, buttonWidth, 44)
                                                                title:@"Destroy"
                                                               target:self
                                                               action:@selector(destroyAd)];
    destroyButton.backgroundColor = UIColor.systemRedColor;
    [self.view addSubview:destroyButton];
    y += 54;

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, contentWidth, 22)];
    self.statusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.statusLabel.textColor = UIColor.systemBlueColor;
    self.statusLabel.text = @"等待加载";
    [self.view addSubview:self.statusLabel];
    y += 32;

    [self buildNativeAdCardAtY:y contentWidth:contentWidth margin:margin];
    y += 246;

    UILabel *logTitle = [IFLYADUtil createSectionTitleWithText:@"回调日志"
                                                         frame:CGRectMake(margin, y, contentWidth, 18)];
    [self.view addSubview:logTitle];
    y += 22;

    CGFloat logHeight = MAX(170, self.view.bounds.size.height - y - 24);
    self.logView = [IFLYADUtil createLogTextViewWithFrame:CGRectMake(margin, y, contentWidth, logHeight)];
    [self.view addSubview:self.logView];
    [self resetAdCard];
}

// 卡片布局参考私有库 Demo：深色媒体区（视频承载/图片叠加）+ 下方一行「广告角标 | 描述 | 圆形关闭」。
- (void)buildNativeAdCardAtY:(CGFloat)y contentWidth:(CGFloat)contentWidth margin:(CGFloat)margin {
    self.adContainer = [[UIView alloc] initWithFrame:CGRectMake(margin, y, contentWidth, 230)];
    self.adContainer.backgroundColor = UIColor.whiteColor;
    self.adContainer.layer.cornerRadius = 8;
    self.adContainer.layer.borderColor = [UIColor colorWithWhite:0.86 alpha:1.0].CGColor;
    self.adContainer.layer.borderWidth = 1;
    self.adContainer.clipsToBounds = YES;
    [self.view addSubview:self.adContainer];

    CGFloat padding = 12;
    CGFloat innerW = contentWidth - padding * 2;

    // 媒体区：视频素材承载视图（深色底），图片素材叠加同区域的 imageView
    self.videoView = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, innerW, 170)];
    self.videoView.backgroundColor = [UIColor colorWithRed:0.11 green:0.12 blue:0.14 alpha:1.0];
    self.videoView.layer.cornerRadius = 6;
    self.videoView.clipsToBounds = YES;
    [self.adContainer addSubview:self.videoView];

    self.placeholderLabel = [[UILabel alloc] initWithFrame:self.videoView.bounds];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.placeholderLabel.text = @"广告素材展示区域";
    self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
    self.placeholderLabel.font = [UIFont systemFontOfSize:14];
    [self.videoView addSubview:self.placeholderLabel];

    self.imageView = [[UIImageView alloc] initWithFrame:self.videoView.frame];
    self.imageView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1.0];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 6;
    self.imageView.hidden = YES;
    [self.adContainer addSubview:self.imageView];

    CGFloat rowY = CGRectGetMaxY(self.videoView.frame) + 10;
    CGFloat rowH = 28;
    CGFloat badgeW = 40;
    CGFloat badgeH = 20;
    CGFloat closeSide = 28;
    CGFloat gap = 8;

    self.adBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, rowY + (rowH - badgeH) * 0.5, badgeW, badgeH)];
    self.adBadgeLabel.text = @"广告";
    self.adBadgeLabel.textAlignment = NSTextAlignmentCenter;
    self.adBadgeLabel.textColor = UIColor.whiteColor;
    self.adBadgeLabel.font = [UIFont systemFontOfSize:10];
    self.adBadgeLabel.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4];
    self.adBadgeLabel.layer.cornerRadius = 4;
    self.adBadgeLabel.clipsToBounds = YES;
    self.adBadgeLabel.hidden = YES;
    [self.adContainer addSubview:self.adBadgeLabel];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.frame = CGRectMake(contentWidth - padding - closeSide, rowY, closeSide, closeSide);
    self.closeButton.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4];
    self.closeButton.layer.cornerRadius = closeSide * 0.5;
    self.closeButton.clipsToBounds = YES;
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.closeButton setTitle:@"×" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.adContainer addSubview:self.closeButton];

    CGFloat descX = CGRectGetMaxX(self.adBadgeLabel.frame) + gap;
    CGFloat descW = CGRectGetMinX(self.closeButton.frame) - gap - descX;
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(descX, rowY, descW, rowH)];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = UIColor.darkGrayColor;
    self.descLabel.numberOfLines = 1;
    self.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.adContainer addSubview:self.descLabel];
}

- (void)loadAd {
    [self destroyAdSilently];
    [self resetAdCard];

    NSString *adUnitId = self.slotControl.selectedSegmentIndex == 1 ? __FEED_VIDEO_AD_UNIT_ID__ : __TYPED_ONE_NATIVE_AD_UNIT_ID__;
    [self updateStatus:@"正在加载信息流" color:UIColor.systemBlueColor];
    [self log:[NSString stringWithFormat:@"Load adUnitId=%@", adUnitId]];

    IFLYNativeFeedAd *ad = [[IFLYNativeFeedAd alloc] initWithAdUnitId:adUnitId];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    self.nativeAd = ad;
    [ad loadAdWithRequestConfig:[IFLYADUtil mediaSampleRequestConfig]];
}

- (void)destroyAd {
    [self destroyAdSilently];
    [self resetAdCard];
    [self updateStatus:@"已销毁" color:[IFLYADUtil demoTealColor]];
    [self log:@"Destroy"];
}

- (void)destroyAdSilently {
    if (!self.nativeAd) {
        return;
    }
    self.nativeAd.delegate = nil;
    [self.nativeAd destroy];
    self.nativeAd = nil;
}

- (void)resetAdCard {
    // 复位媒体区：移除视频承载视图里临时添加的子视图，保留占位标签
    for (UIView *subview in [self.videoView.subviews copy]) {
        if (subview != self.placeholderLabel) {
            [subview removeFromSuperview];
        }
    }
    self.videoView.hidden = NO;
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"广告素材展示区域";
    self.imageView.hidden = YES;
    self.imageView.image = nil;
    self.adBadgeLabel.hidden = YES;
    self.descLabel.text = @"";
    self.closeButton.hidden = YES;
}

- (void)renderAndBindAd:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedAdData *data = ad.adData;
    self.adBadgeLabel.hidden = NO;
    self.closeButton.hidden = NO;
    self.descLabel.text = data.desc.length > 0 ? data.desc : (data.content.length > 0 ? data.content : (data.title.length > 0 ? data.title : @"广告描述"));

    [self log:[NSString stringWithFormat:@"素材 materialType=%ld title=%@", (long)data.materialType, data.title ?: @"无"]];
    if (ad.hasVideoTemplate) {
        // 视频：深色媒体区承载视频，先显示"视频加载中"占位
        self.imageView.hidden = YES;
        self.videoView.hidden = NO;
        self.placeholderLabel.hidden = NO;
        self.placeholderLabel.text = @"视频加载中...";
        [self bindNativeAd:ad video:YES];
        return;
    }

    NSString *imageURL = data.imageURLs.firstObject;
    __weak typeof(self) weakSelf = self;
    [IFLYADUtil loadImageWithURLString:imageURL
                            completion:^(UIImage *image, NSError *error) {
                                __strong typeof(weakSelf) self = weakSelf;
                                if (!self || self.nativeAd != ad) {
                                    return;
                                }
                                if (image) {
                                    // 图文：图片素材覆盖媒体区，隐藏深色占位
                                    self.placeholderLabel.hidden = YES;
                                    self.videoView.hidden = YES;
                                    self.imageView.hidden = NO;
                                    self.imageView.image = image;
                                    [self log:@"图片素材已渲染，开始绑定"];
                                    [self bindNativeAd:ad video:NO];
                                } else {
                                    [self log:[NSString stringWithFormat:@"图片加载失败：%@", error.localizedDescription ?: @"未知"]];
                                    [self updateStatus:@"图片加载失败，未绑定广告" color:UIColor.systemRedColor];
                                }
                            }];
}

- (void)bindNativeAd:(IFLYNativeFeedAd *)ad video:(BOOL)isVideo {
    UIView *mediaView = isVideo ? self.videoView : self.imageView;
    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    binder.renderViews = @[mediaView, self.adBadgeLabel, self.descLabel, self.closeButton];
    binder.clickViews = @[mediaView];
    binder.closeView = self.closeButton;
    binder.videoView = isVideo ? self.videoView : nil;
    binder.imageView = isVideo ? nil : self.imageView;
    binder.descView = self.descLabel;
    binder.adSourceView = self.adBadgeLabel;

    IFLYAdError *error = nil;
    BOOL success = [ad bindAdWithViewBinder:binder error:&error];
    [self log:[NSString stringWithFormat:@"bindAdWithViewBinder success=%@ %@", success ? @"YES" : @"NO",
                                      error ? [IFLYADUtil summaryForError:error] : @""]];
    if (!success) {
        [self updateStatus:@"信息流绑定失败" color:UIColor.systemRedColor];
    }
}

- (void)updateStatus:(NSString *)text color:(UIColor *)color {
    self.statusLabel.text = text;
    self.statusLabel.textColor = color;
}

- (void)log:(NSString *)text {
    [IFLYADUtil appendLog:text toTextView:self.logView];
    IFLYSampleLogInfo(@"NativeFeed", @"%@", text);
}

#pragma mark - IFLYNativeFeedAdDelegate

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    [self log:[NSString stringWithFormat:@"nativeFeedAdDidLoad materialType=%ld ecpm=%.2f",
                                      (long)ad.materialType,
                                      [ad ecpm]]];
    if (ad != self.nativeAd) {
        return;
    }
    [self updateStatus:@"加载成功，媒体侧开始渲染" color:[IFLYADUtil demoIndigoColor]];
    [self renderAndBindAd:ad];
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    [self log:@"nativeFeedAdDidRender"];
    [self updateStatus:@"绑定成功，等待曝光" color:UIColor.systemGreenColor];
    if (ad == self.nativeAd && ad.hasVideoTemplate) {
        [ad startPlay];
        [self log:@"视频信息流调用 startPlay"];
    }
}

- (void)nativeFeedAdDidExpose:(IFLYNativeFeedAd *)ad {
    [self log:@"nativeFeedAdDidExpose"];
    [self updateStatus:@"信息流已曝光" color:UIColor.systemGreenColor];
}

- (void)nativeFeedAdDidClick:(IFLYNativeFeedAd *)ad {
    [self log:@"nativeFeedAdDidClick"];
}

- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad {
    [self log:@"nativeFeedAdDidClose"];
    [self updateStatus:@"信息流已关闭" color:[IFLYADUtil demoTealColor]];
    if (ad == self.nativeAd) {
        [self destroyAdSilently];
        [self resetAdCard];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"nativeFeedAd didFailWithError %@", [IFLYADUtil summaryForError:error]]];
    [self updateStatus:@"信息流加载失败" color:UIColor.systemRedColor];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToRenderWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"nativeFeedAd didFailToRender %@", [IFLYADUtil summaryForError:error]]];
    [self updateStatus:@"信息流渲染失败" color:UIColor.systemRedColor];
}

- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad {
    [self log:@"nativeFeedAdDidStartPlay"];
}

- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad {
    [self log:@"nativeFeedAdDidPlayFinish"];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToPlayWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"nativeFeedAd didFailToPlay %@", [IFLYADUtil summaryForError:error]]];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didJumpWithSuccess:(BOOL)success {
    [self log:[NSString stringWithFormat:@"nativeFeedAd didJumpWithSuccess=%@", success ? @"YES" : @"NO"]];
}

@end
