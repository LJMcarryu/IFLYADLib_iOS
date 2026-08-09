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
@property (nonatomic, copy) NSArray<UIImageView *> *multipleImageViews;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *adBadgeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITextView *logView;

@end

@implementation IFLYNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自渲染信息流示例";
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
    [self log:@"自渲染信息流示例：Load -> 读取 adData -> 媒体渲染 -> SDK 托管挂载"];
}

- (void)dealloc {
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainer];
    self.nativeAd.delegate = nil;
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

    self.slotControl = [[UISegmentedControl alloc] initWithItems:@[@"单图", @"视频", @"多图"]];
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

    NSMutableArray<UIImageView *> *multipleImageViews = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger index = 0; index < 3; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1.0];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 6;
        imageView.hidden = YES;
        [self.adContainer addSubview:imageView];
        [multipleImageViews addObject:imageView];
    }
    self.multipleImageViews = multipleImageViews.copy;

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

    CGFloat ctaW = 72;
    self.ctaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.ctaButton setTitle:@"查看详情" forState:UIControlStateNormal];
    [self.ctaButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.ctaButton.backgroundColor = [IFLYADUtil demoIndigoColor];
    self.ctaButton.layer.cornerRadius = 6;
    self.ctaButton.clipsToBounds = YES;
    self.ctaButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.ctaButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.ctaButton.titleLabel.minimumScaleFactor = 0.75;
    self.ctaButton.frame = CGRectMake(CGRectGetMinX(self.closeButton.frame) - gap - ctaW,
                                      rowY,
                                      ctaW,
                                      rowH);
    self.ctaButton.userInteractionEnabled = YES;
    self.ctaButton.hidden = YES;
    [self.adContainer addSubview:self.ctaButton];

    CGFloat descX = CGRectGetMaxX(self.adBadgeLabel.frame) + gap;
    CGFloat descW = CGRectGetMinX(self.ctaButton.frame) - gap - descX;
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(descX, rowY, descW, rowH)];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = UIColor.darkGrayColor;
    self.descLabel.numberOfLines = 1;
    self.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.adContainer addSubview:self.descLabel];
}

- (void)loadAd {
    [self clearAdSilently];
    [self resetAdCard];

    NSString *adUnitId = __TYPED_ONE_NATIVE_AD_UNIT_ID__;
    if (self.slotControl.selectedSegmentIndex == 1) {
        adUnitId = __FEED_VIDEO_AD_UNIT_ID__;
    } else if (self.slotControl.selectedSegmentIndex == 2) {
        adUnitId = __TYPED_MORE_NATIVE_AD_UNIT_ID__;
    }
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
    IFLYNativeFeedAd *ad = [self takeCurrentAdAndDetach];
    [ad destroy];
    [self resetAdCard];
    [self updateStatus:@"已销毁" color:[IFLYADUtil demoTealColor]];
    [self log:@"Destroy"];
}

- (nullable IFLYNativeFeedAd *)takeCurrentAdAndDetach {
    IFLYNativeFeedAd *ad = self.nativeAd;
    if (!ad) {
        return nil;
    }
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainer];
    self.nativeAd = nil;
    ad.delegate = nil;
    return ad;
}

- (void)clearAdSilently {
    // 正常页面替换/条目结束无需显式 destroy；释放最后一个 Ad 强引用即由 SDK 收口资源。
    (void)[self takeCurrentAdAndDetach];
}

- (void)resetAdCard {
    // 先按容器 detach 让 SDK 移除自己的播放器宿主；媒体仅复位自己创建的视图。
    self.videoView.hidden = NO;
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"广告素材展示区域";
    self.imageView.hidden = YES;
    self.imageView.image = nil;
    for (UIImageView *imageView in self.multipleImageViews) {
        imageView.hidden = YES;
        imageView.image = nil;
    }
    self.adBadgeLabel.hidden = YES;
    self.adBadgeLabel.text = @"广告";
    self.descLabel.text = @"";
    self.ctaButton.hidden = YES;
    [self.ctaButton setTitle:nil forState:UIControlStateNormal];
    self.closeButton.hidden = YES;
}

- (void)renderAndAttachAd:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedAdData *data = ad.adData;
    if (!data || !data.isMaterialComplete ||
        data.materialType == IFLYNativeFeedAdMaterialTypeUnknown) {
        [self log:@"素材不完整或类型未知，不渲染、不挂载"];
        [self updateStatus:@"素材不可用" color:UIColor.systemRedColor];
        [self clearAdSilently];
        [self resetAdCard];
        return;
    }
    self.adBadgeLabel.hidden = NO;
    self.adBadgeLabel.text = data.adSourceMark.length > 0 ? data.adSourceMark : @"广告";
    self.closeButton.hidden = NO;
    self.descLabel.text =
        data.appName.length > 0 ? data.appName :
        (data.title.length > 0 ? data.title :
         (data.brand.length > 0 ? data.brand :
          (data.desc.length > 0 ? data.desc : (data.content.length > 0 ? data.content : @"广告"))));

    BOOL clickable =
        data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
        data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    self.ctaButton.hidden = !clickable;
    NSString *fallbackCTA =
        data.interactionType == IFLYNativeFeedAdInteractionTypeDownload ? @"立即下载" : @"查看详情";
    [self.ctaButton setTitle:(clickable ? (data.ctaText.length > 0 ? data.ctaText : fallbackCTA) : nil)
                    forState:UIControlStateNormal];

    [self log:[NSString stringWithFormat:
                                      @"素材 templateId=%ld materialType=%ld interactionType=%ld interactType=%ld appName=%@",
                                      (long)data.templateId,
                                      (long)data.materialType,
                                      (long)data.interactionType,
                                      (long)data.interactType,
                                      data.appName ?: @"无"]];

    switch (data.materialType) {
        case IFLYNativeFeedAdMaterialTypeVideo:
            self.imageView.hidden = YES;
            self.videoView.hidden = NO;
            self.placeholderLabel.hidden = NO;
            self.placeholderLabel.text = @"视频加载中...";
            [self attachNativeAd:ad video:YES mediaViews:@[self.videoView]];
            return;
        case IFLYNativeFeedAdMaterialTypeSingleImage:
            [self renderImagesForAd:ad URLs:@[data.imageURLs.firstObject] multiple:NO];
            return;
        case IFLYNativeFeedAdMaterialTypeMultipleImages:
            [self renderImagesForAd:ad URLs:data.imageURLs multiple:YES];
            return;
        case IFLYNativeFeedAdMaterialTypeUnknown:
        default:
            [self updateStatus:@"素材类型未知" color:UIColor.systemRedColor];
            [self clearAdSilently];
            [self resetAdCard];
            return;
    }
}

- (void)renderImagesForAd:(IFLYNativeFeedAd *)ad
                     URLs:(NSArray<NSString *> *)URLs
                 multiple:(BOOL)multiple {
    NSUInteger expectedCount = multiple ? MIN(URLs.count, self.multipleImageViews.count) : MIN(URLs.count, 1);
    if (expectedCount == 0) {
        [self log:@"图片素材为空，不挂载"];
        [self updateStatus:@"图片素材为空" color:UIColor.systemRedColor];
        [self clearAdSilently];
        [self resetAdCard];
        return;
    }

    NSMutableArray *loadedImages = [NSMutableArray arrayWithCapacity:expectedCount];
    for (NSUInteger index = 0; index < expectedCount; index++) {
        [loadedImages addObject:NSNull.null];
    }

    __block NSUInteger remaining = expectedCount;
    __block NSError *firstError = nil;
    __weak typeof(self) weakSelf = self;
    for (NSUInteger index = 0; index < expectedCount; index++) {
        [IFLYADUtil loadImageWithURLString:URLs[index]
                                completion:^(UIImage *image, NSError *error) {
                                    __strong typeof(weakSelf) self = weakSelf;
                                    if (!self || self.nativeAd != ad) {
                                        return;
                                    }
                                    if (image) {
                                        loadedImages[index] = image;
                                    } else if (!firstError) {
                                        firstError =
                                            error ?: [NSError errorWithDomain:@"IFLYADLibSimple"
                                                                         code:-2
                                                                     userInfo:@{
                                                                         NSLocalizedDescriptionKey : @"图片数据无效"
                                                                     }];
                                    }
                                    remaining -= 1;
                                    if (remaining > 0) {
                                        return;
                                    }
                                    if (firstError) {
                                        [self log:[NSString stringWithFormat:@"图片加载失败：%@",
                                                                            firstError.localizedDescription ?: @"未知"]];
                                        [self updateStatus:@"图片加载失败，未挂载广告" color:UIColor.systemRedColor];
                                        [self clearAdSilently];
                                        [self resetAdCard];
                                        return;
                                    }
                                    [self showLoadedImages:loadedImages multiple:multiple];
                                    NSArray<UIView *> *mediaViews =
                                        multiple ? [self.multipleImageViews subarrayWithRange:NSMakeRange(0, expectedCount)]
                                                 : @[self.imageView];
                                    [self log:multiple ? @"多图素材已渲染，开始挂载" : @"单图素材已渲染，开始挂载"];
                                    [self attachNativeAd:ad video:NO mediaViews:mediaViews];
                                }];
    }
}

- (void)showLoadedImages:(NSArray<UIImage *> *)images multiple:(BOOL)multiple {
    self.placeholderLabel.hidden = YES;
    self.videoView.hidden = YES;
    self.imageView.hidden = multiple;
    if (!multiple) {
        self.imageView.image = images.firstObject;
        return;
    }

    CGFloat spacing = 4;
    CGFloat width = (CGRectGetWidth(self.videoView.frame) - spacing * (images.count - 1)) / images.count;
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger index, BOOL *stop) {
        (void)stop;
        UIImageView *imageView = self.multipleImageViews[index];
        imageView.frame = CGRectMake(CGRectGetMinX(self.videoView.frame) + (width + spacing) * index,
                                     CGRectGetMinY(self.videoView.frame),
                                     width,
                                     CGRectGetHeight(self.videoView.frame));
        imageView.image = image;
        imageView.hidden = NO;
    }];
}

- (void)attachNativeAd:(IFLYNativeFeedAd *)ad
                video:(BOOL)isVideo
           mediaViews:(NSArray<UIView *> *)mediaViews {
    IFLYNativeFeedAdData *data = ad.adData;
    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    NSMutableArray<UIView *> *renderViews = [mediaViews mutableCopy];
    [renderViews addObjectsFromArray:@[self.adBadgeLabel, self.descLabel, self.closeButton]];
    if (!self.ctaButton.hidden) {
        [renderViews addObject:self.ctaButton];
    }
    binder.renderViews = renderViews.copy;
    BOOL clickable =
        data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
        data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    // nil 会默认整容器可点击；纯曝光与未知行为必须显式传空数组。
    binder.clickViews = clickable ? @[self.adContainer] : @[];
    binder.closeView = self.closeButton;
    binder.videoView = isVideo ? self.videoView : nil;
    binder.imageView = isVideo ? nil : mediaViews.firstObject;
    binder.descView = self.descLabel;
    binder.adSourceView = self.adBadgeLabel;
    binder.ctaView = self.ctaButton.hidden ? nil : self.ctaButton;

    IFLYAdError *error = nil;
    BOOL success = [ad attachWithViewBinder:binder error:&error];
    [self log:[NSString stringWithFormat:@"attachWithViewBinder success=%@ %@", success ? @"YES" : @"NO",
                                      error ? [IFLYADUtil summaryForError:error] : @""]];
    if (!success) {
        [self updateStatus:@"信息流挂载失败" color:UIColor.systemRedColor];
        [self clearAdSilently];
        [self resetAdCard];
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
    if (ad != self.nativeAd) {
        return;
    }
    [self log:[NSString stringWithFormat:@"nativeFeedAdDidLoad materialType=%ld appName=%@ price=%.2f dealId=%@",
                                      (long)ad.materialType,
                                      ad.adData.appName ?: @"无",
                                      [IFLYADUtil priceForAd:ad],
                                      ad.bidInfo.dealId ?: @"无"]];
    [self updateStatus:@"加载成功，媒体侧开始渲染" color:[IFLYADUtil demoIndigoColor]];
    [self renderAndAttachAd:ad];
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidRender"];
    [self updateStatus:@"挂载成功，等待曝光" color:UIColor.systemGreenColor];
    if (ad.hasVideoTemplate) {
        [ad startPlay];
        [self log:@"视频信息流调用 startPlay"];
    }
}

- (void)nativeFeedAdDidExpose:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidExpose"];
    [self updateStatus:@"信息流已曝光" color:UIColor.systemGreenColor];
}

- (void)nativeFeedAdDidClick:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidClick"];
}

- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidClose"];
    [self updateStatus:@"信息流已关闭" color:[IFLYADUtil demoTealColor]];
    [self clearAdSilently];
    [self resetAdCard];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailWithError:(IFLYAdError *)error {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:[NSString stringWithFormat:@"nativeFeedAd didFailWithError %@", [IFLYADUtil summaryForError:error]]];
    [self updateStatus:@"信息流加载失败" color:UIColor.systemRedColor];
    [self clearAdSilently];
    [self resetAdCard];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToRenderWithError:(IFLYAdError *)error {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:[NSString stringWithFormat:@"nativeFeedAd didFailToRender %@", [IFLYADUtil summaryForError:error]]];
    [self updateStatus:@"信息流渲染失败" color:UIColor.systemRedColor];
    [self clearAdSilently];
    [self resetAdCard];
}

- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidStartPlay"];
    self.placeholderLabel.hidden = YES;
}

- (void)nativeFeedAdDidPausePlay:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidPausePlay"];
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"视频已暂停";
}

- (void)nativeFeedAdDidResumePlay:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidResumePlay"];
    self.placeholderLabel.hidden = YES;
}

- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:@"nativeFeedAdDidPlayFinish"];
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"视频播放完成";
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToPlayWithError:(IFLYAdError *)error {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:[NSString stringWithFormat:@"nativeFeedAd didFailToPlay %@", [IFLYADUtil summaryForError:error]]];
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"视频播放失败";
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didJumpWithSuccess:(BOOL)success {
    if (ad != self.nativeAd) {
        return;
    }
    [self log:[NSString stringWithFormat:@"nativeFeedAd didJumpWithSuccess=%@", success ? @"YES" : @"NO"]];
}

@end
