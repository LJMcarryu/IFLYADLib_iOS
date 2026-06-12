#import "IFLYRewardVideoViewController.h"

#import "IFLYADUtil.h"
#import <IFLYADLib/IFLYADLib.h>

@interface IFLYRewardVideoViewController () <IFLYRewardVideoAdDelegate>

@property (nonatomic, strong) IFLYRewardVideoAd *rewardAd;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextView *logView;

@end

@implementation IFLYRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"激励视频广告";
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
    [self log:@"激励视频示例：Load -> Ready -> Show -> Reward/Close"];
}

- (void)dealloc {
    [self.rewardAd destroy];
}

- (void)setupUI {
    CGFloat margin = 16;
    CGFloat width = self.view.bounds.size.width;
    CGFloat contentWidth = width - margin * 2;
    CGFloat y = 110;

    UILabel *desc = [IFLYADUtil createSectionTitleWithText:@"激励视频须等待 rewardVideoAdDidReady: 后展示。发奖以 didRewardEffective 回调为准。"
                                                     frame:CGRectMake(margin, y, contentWidth, 42)];
    [self.view addSubview:desc];
    y += 54;

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

    CGFloat logHeight = MAX(300, self.view.bounds.size.height - y - 24);
    self.logView = [IFLYADUtil createLogTextViewWithFrame:CGRectMake(margin, y, contentWidth, logHeight)];
    [self.view addSubview:self.logView];
}

- (void)loadAd {
    [self destroyAdSilently];
    [self setShowButtonEnabled:NO];
    [self updateStatus:@"正在加载激励视频" color:UIColor.systemBlueColor];
    [self log:[NSString stringWithFormat:@"Load adUnitId=%@", __REWARD_VIDEO_AD_UNIT_ID__]];

    IFLYRewardVideoAd *ad = [[IFLYRewardVideoAd alloc] initWithAdUnitId:__REWARD_VIDEO_AD_UNIT_ID__];
    ad.delegate = self;
    ad.currentViewController = self;
    self.rewardAd = ad;
    [ad loadAdWithRequestConfig:[IFLYADUtil mediaSampleRequestConfig]];
}

- (void)showAd {
    if (!self.rewardAd || ![self.rewardAd isAdValid]) {
        [self log:@"Show ignored: 激励视频尚未 ready 或已失效"];
        [self updateStatus:@"请先等待 ready 回调" color:UIColor.systemRedColor];
        [self setShowButtonEnabled:NO];
        return;
    }

    IFLYRewardVideoAdConfig *config = [[IFLYRewardVideoAdConfig alloc] init];
    config.muteOnStart = YES;
    config.muteButtonHidden = NO;
    [self log:@"调用 showAdFromRootViewController:config:"];
    [self setShowButtonEnabled:NO];
    [self.rewardAd showAdFromRootViewController:self config:config];
}

- (void)destroyAd {
    [self destroyAdSilently];
    [self updateStatus:@"已销毁" color:UIColor.systemTealColor];
    [self log:@"Destroy"];
}

- (void)checkStatus {
    [self log:[NSString stringWithFormat:@"状态 isAdValid=%@ ecpm=%.2f",
                                      (self.rewardAd && [self.rewardAd isAdValid]) ? @"YES" : @"NO",
                                      self.rewardAd ? [self.rewardAd ecpm] : -1.0]];
}

- (void)destroyAdSilently {
    if (!self.rewardAd) {
        return;
    }
    self.rewardAd.delegate = nil;
    [self.rewardAd destroy];
    self.rewardAd = nil;
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
    IFLYSampleLogInfo(@"Reward", @"%@", text);
}

#pragma mark - IFLYRewardVideoAdDelegate

- (void)rewardVideoAdDidLoad:(IFLYRewardVideoAd *)ad {
    [self log:[NSString stringWithFormat:@"rewardVideoAdDidLoad video=%@ landscape=%@ ecpm=%.2f",
                                      ad.hasVideoTemplate ? @"YES" : @"NO",
                                      ad.isLandscapeTemplate ? @"YES" : @"NO",
                                      [ad ecpm]]];
    [self updateStatus:@"已加载，等待素材 ready" color:UIColor.systemIndigoColor];
}

- (void)rewardVideoAdDidReady:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidReady"];
    [self updateStatus:@"激励视频已 ready，可展示" color:UIColor.systemGreenColor];
    [self setShowButtonEnabled:ad == self.rewardAd && [ad isAdValid]];
}

- (void)rewardVideoAdDidShow:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidShow"];
}

- (void)rewardVideoAdDidExpose:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidExpose"];
}

- (void)rewardVideoAdDidClick:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidClick"];
}

- (void)rewardVideoAdDidStartPlay:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidStartPlay"];
}

- (void)rewardVideoAdDidPlayFinish:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidPlayFinish"];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didRewardEffective:(NSDictionary *)info {
    [self log:[NSString stringWithFormat:@"rewardVideoAd didRewardEffective info=%@", info ?: @{}]];
    [self updateStatus:@"激励已生效，媒体侧可在此发放奖励" color:UIColor.systemGreenColor];
}

- (void)rewardVideoAdDidClose:(IFLYRewardVideoAd *)ad {
    [self log:@"rewardVideoAdDidClose"];
    [self updateStatus:@"激励视频已关闭" color:UIColor.systemTealColor];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"rewardVideoAd didFailWithError %@", [IFLYADUtil summaryForError:error]]];
    [self updateStatus:@"激励视频加载或展示失败" color:UIColor.systemRedColor];
    [self setShowButtonEnabled:NO];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailToRenderWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"rewardVideoAd didFailToRender %@", [IFLYADUtil summaryForError:error]]];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didFailToPlayWithError:(IFLYAdError *)error {
    [self log:[NSString stringWithFormat:@"rewardVideoAd didFailToPlay %@", [IFLYADUtil summaryForError:error]]];
}

- (void)rewardVideoAd:(IFLYRewardVideoAd *)ad didJumpWithSuccess:(BOOL)success {
    [self log:[NSString stringWithFormat:@"rewardVideoAd didJumpWithSuccess=%@", success ? @"YES" : @"NO"]];
}

@end
