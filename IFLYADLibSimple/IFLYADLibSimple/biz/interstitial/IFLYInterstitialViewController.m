#import "IFLYInterstitialViewController.h"

#import "IFLYADUtil.h"
#import <IFLYADLib/IFLYADLib.h>

@interface IFLYInterstitialViewController () <IFLYInterstitialAdDelegate>

@property (nonatomic, strong) IFLYInterstitialAd *interstitialAd;
@property (nonatomic, strong) UISegmentedControl *styleControl;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextView *logView;

@end

@implementation IFLYInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"插屏广告";
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
    [self log:@"插屏示例：Load -> Ready -> Show -> Close"];
}

- (void)dealloc {
    [self.interstitialAd destroy];
}

- (void)setupUI {
    CGFloat margin = 16;
    CGFloat width = self.view.bounds.size.width;
    CGFloat contentWidth = width - margin * 2;
    CGFloat y = 110;

    UILabel *desc = [IFLYADUtil createSectionTitleWithText:@"插屏由 SDK 负责渲染和 present。媒体侧在 didReady 后传入展示配置并调用 show。"
                                                     frame:CGRectMake(margin, y, contentWidth, 38)];
    [self.view addSubview:desc];
    y += 48;

    self.styleControl = [[UISegmentedControl alloc] initWithItems:@[@"半屏", @"全屏"]];
    self.styleControl.frame = CGRectMake(margin, y, contentWidth, 32);
    self.styleControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.styleControl];
    y += 48;

    CGFloat buttonWidth = (contentWidth - 8) / 2.0;
    UIButton *loadButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(margin, y, buttonWidth, 44)
                                                            title:@"Load"
                                                           target:self
                                                           action:@selector(loadAd)];
    [self.view addSubview:loadButton];

    self.showButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(margin + buttonWidth + 8, y, buttonWidth, 44)
                                                        title:@"Show"
                                                       target:self
                                                       action:@selector(showAd)];
    [self setShowButtonEnabled:NO];
    [self.view addSubview:self.showButton];
    y += 54;

    UIButton *destroyButton = [IFLYADUtil createSmallButtonWithTitle:@"Destroy"
                                                               color:UIColor.systemRedColor
                                                              target:self
                                                              action:@selector(destroyAd)];
    destroyButton.frame = CGRectMake(margin, y, buttonWidth, 34);
    [self.view addSubview:destroyButton];

    UIButton *statusButton = [IFLYADUtil createSmallButtonWithTitle:@"检查状态"
                                                              color:UIColor.systemBlueColor
                                                             target:self
                                                             action:@selector(checkStatus)];
    statusButton.frame = CGRectMake(margin + buttonWidth + 8, y, buttonWidth, 34);
    [self.view addSubview:statusButton];
    y += 48;

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, contentWidth, 22)];
    self.statusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.statusLabel.textColor = UIColor.systemBlueColor;
    self.statusLabel.text = @"等待加载";
    [self.view addSubview:self.statusLabel];
    y += 34;

    UILabel *logTitle = [IFLYADUtil createSectionTitleWithText:@"回调日志"
                                                         frame:CGRectMake(margin, y, contentWidth, 18)];
    [self.view addSubview:logTitle];
    y += 22;

    CGFloat logHeight = MAX(260, self.view.bounds.size.height - y - 24);
    self.logView = [IFLYADUtil createLogTextViewWithFrame:CGRectMake(margin, y, contentWidth, logHeight)];
    [self.view addSubview:self.logView];
}

- (void)loadAd {
    [self destroyAdSilently];
    [self setShowButtonEnabled:NO];
    [self updateStatus:@"正在加载插屏" color:UIColor.systemBlueColor];
    [self log:[NSString stringWithFormat:@"Load adUnitId=%@", __INTERSTITIAL_AD_UNIT_ID__]];

    IFLYInterstitialAd *ad = [[IFLYInterstitialAd alloc] initWithAdUnitId:__INTERSTITIAL_AD_UNIT_ID__];
    ad.delegate = self;
    ad.currentViewController = self;
    self.interstitialAd = ad;
    [ad loadAdWithRequestConfig:[IFLYADUtil mediaSampleRequestConfig]];
}

- (void)showAd {
    if (!self.interstitialAd || ![self.interstitialAd isAdValid]) {
        [self log:@"Show ignored: 插屏尚未 ready 或已失效"];
        [self updateStatus:@"请先等待 ready 回调" color:UIColor.systemRedColor];
        [self setShowButtonEnabled:NO];
        return;
    }

    IFLYInterstitialAdConfig *config = [[IFLYInterstitialAdConfig alloc] init];
    config.presentationStyle = self.styleControl.selectedSegmentIndex == 1
                                   ? IFLYInterstitialPresentationStyleFullScreen
                                   : IFLYInterstitialPresentationStyleHalfScreen;
    config.muteOnStart = YES;
    config.muteButtonHidden = NO;
    [self log:[NSString stringWithFormat:@"调用 show，style=%@", self.styleControl.selectedSegmentIndex == 1 ? @"全屏" : @"半屏"]];
    [self setShowButtonEnabled:NO];
    [self.interstitialAd showAdFromRootViewController:self config:config];
}

- (void)destroyAd {
    [self destroyAdSilently];
    [self updateStatus:@"已销毁" color:[IFLYADUtil demoTealColor]];
    [self log:@"Destroy"];
}

- (void)checkStatus {
    [self log:[NSString stringWithFormat:@"状态 isAdValid=%@ ecpm=%.2f",
                                      (self.interstitialAd && [self.interstitialAd isAdValid]) ? @"YES" : @"NO",
                                      self.interstitialAd ? [self.interstitialAd ecpm] : -1.0]];
}

- (void)destroyAdSilently {
    if (!self.interstitialAd) {
        return;
    }
    self.interstitialAd.delegate = nil;
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
    [self setShowButtonEnabled:NO];
}

- (void)setShowButtonEnabled:(BOOL)enabled {
    self.showButton.enabled = enabled;
    self.showButton.alpha = enabled ? 1.0 : 0.45;
}

- (void)updateStatus:(NSString *)text color:(UIColor *)color {
    self.statusLabel.text = text;
    self.statusLabel.textColor = color;
}

- (void)log:(NSString *)text {
    [IFLYADUtil appendLog:text toTextView:self.logView];
    IFLYSampleLogInfo(@"Interstitial", @"%@", text);
}

#pragma mark - IFLYInterstitialAdDelegate

- (void)interstitialAdDidLoad:(IFLYInterstitialAd *)ad {
    [self log:[NSString stringWithFormat:@"interstitialAdDidLoad video=%@ landscape=%@ ecpm=%.2f",
                                      ad.hasVideoTemplate ? @"YES" : @"NO",
                                      ad.isLandscapeTemplate ? @"YES" : @"NO",
                                      [ad ecpm]]];
    [self updateStatus:@"已加载，等待素材 ready" color:[IFLYADUtil demoIndigoColor]];
}

- (void)interstitialAdDidReady:(IFLYInterstitialAd *)ad {
    [self log:@"interstitialAdDidReady"];
    [self updateStatus:@"插屏已 ready，可展示" color:UIColor.systemGreenColor];
    [self setShowButtonEnabled:ad == self.interstitialAd && [ad isAdValid]];
}

- (void)interstitialAdDidShow:(IFLYInterstitialAd *)ad {
    [self log:@"interstitialAdDidShow"];
}

- (void)interstitialAdDidRender:(IFLYInterstitialAd *)ad {
    [self log:@"interstitialAdDidRender"];
}

- (void)interstitialAdDidExpose:(IFLYInterstitialAd *)ad {
    [self log:@"interstitialAdDidExpose"];
    [self updateStatus:@"插屏已曝光" color:UIColor.systemGreenColor];
}

- (void)interstitialAdDidClick:(IFLYInterstitialAd *)ad {
    [self log:@"interstitialAdDidClick"];
}

- (void)interstitialAdDidClose:(IFLYInterstitialAd *)ad {
    [self log:@"interstitialAdDidClose"];
    [self updateStatus:@"插屏已关闭" color:[IFLYADUtil demoTealColor]];
}

- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"interstitialAd didFailWithError %@", [IFLYADUtil summaryForError:error]]];
    [self updateStatus:@"插屏加载或展示失败" color:UIColor.systemRedColor];
    [self setShowButtonEnabled:NO];
}

- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailToRenderWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"interstitialAd didFailToRender %@", [IFLYADUtil summaryForError:error]]];
}

- (void)interstitialAd:(IFLYInterstitialAd *)ad didJumpWithSuccess:(BOOL)success {
    [self log:[NSString stringWithFormat:@"interstitialAd didJumpWithSuccess=%@", success ? @"YES" : @"NO"]];
}

@end
