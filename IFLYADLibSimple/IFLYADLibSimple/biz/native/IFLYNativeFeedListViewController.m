#import "IFLYNativeFeedListViewController.h"

#import "IFLYADUtil.h"
#import <IFLYADLib/IFLYADLib.h>

static NSInteger const IFLYNativeFeedListAdRow = 4;
static NSInteger const IFLYNativeFeedListRowCount = 13;
static NSString *const IFLYNativeFeedListAdItemID = @"native-feed-list-ad-1";
static NSString *const IFLYNativeFeedListContentCellID = @"native-feed-list-content";
static NSString *const IFLYNativeFeedListAdCellID = @"native-feed-list-ad";

@class IFLYNativeFeedListCell;

/// 生产接入可把该模型扩展为字典/缓存；关键是由稳定 item ID 持有 Ad + DisplaySession。
@interface IFLYNativeFeedListItem : NSObject
@property (nonatomic, copy) NSString *itemIdentifier;
@property (nonatomic, strong, nullable) IFLYNativeFeedAd *ad;
@property (nonatomic, strong, nullable) IFLYNativeFeedDisplaySession *session;
@property (nonatomic, strong, nullable) UIImage *coverImage;
@property (nonatomic, assign) BOOL presentationReady;
@property (nonatomic, assign) NSUInteger generation;
@property (nonatomic, weak, nullable) IFLYNativeFeedListCell *attachedCell;
@end

@implementation IFLYNativeFeedListItem
@end

/// Cell 只保存自己的 Binding 和媒体 UI，不拥有或销毁 Ad / DisplaySession。
@interface IFLYNativeFeedListCell : UITableViewCell
@property (nonatomic, copy, nullable) NSString *representedItemIdentifier;
@property (nonatomic, strong, nullable) IFLYNativeFeedAdBinding *binding;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *mediaView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *mediaLabel;
@property (nonatomic, strong) UILabel *adBadgeLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIButton *closeButton;
- (nullable IFLYNativeFeedAd *)boundAd;
- (BOOL)attachDisplaySession:(IFLYNativeFeedDisplaySession *)session
              itemIdentifier:(NSString *)itemIdentifier
                  coverImage:(nullable UIImage *)coverImage
                       error:(IFLYAdError *_Nullable *_Nullable)error;
- (void)detachBinding;
- (void)setVideoCoverHidden:(BOOL)hidden text:(nullable NSString *)text;
@end

@implementation IFLYNativeFeedListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildCard];
    }
    return self;
}

- (void)buildCard {
    self.cardView = [[UIView alloc] initWithFrame:CGRectZero];
    self.cardView.backgroundColor = UIColor.whiteColor;
    self.cardView.layer.cornerRadius = 10;
    self.cardView.layer.borderWidth = 1;
    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.86 alpha:1].CGColor;
    self.cardView.clipsToBounds = YES;
    [self.contentView addSubview:self.cardView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.12 alpha:1];
    [self.cardView addSubview:self.titleLabel];

    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = [IFLYADUtil demoSecondaryLabelColor];
    self.descLabel.numberOfLines = 2;
    [self.cardView addSubview:self.descLabel];

    self.mediaView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mediaView.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1];
    self.mediaView.layer.cornerRadius = 8;
    self.mediaView.clipsToBounds = YES;
    [self.cardView addSubview:self.mediaView];

    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    [self.mediaView addSubview:self.coverImageView];

    self.mediaLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.mediaLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mediaLabel.font = [UIFont systemFontOfSize:13];
    self.mediaLabel.textAlignment = NSTextAlignmentCenter;
    self.mediaLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1];
    [self.mediaView addSubview:self.mediaLabel];

    self.adBadgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.adBadgeLabel.font = [UIFont systemFontOfSize:10];
    self.adBadgeLabel.textAlignment = NSTextAlignmentCenter;
    self.adBadgeLabel.textColor = UIColor.whiteColor;
    self.adBadgeLabel.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.7];
    self.adBadgeLabel.layer.cornerRadius = 4;
    self.adBadgeLabel.clipsToBounds = YES;
    [self.cardView addSubview:self.adBadgeLabel];

    self.ctaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.ctaButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.ctaButton.backgroundColor = [IFLYADUtil demoIndigoColor];
    self.ctaButton.layer.cornerRadius = 5;
    self.ctaButton.clipsToBounds = YES;
    [self.ctaButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.cardView addSubview:self.ctaButton];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.closeButton.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.7];
    self.closeButton.layer.cornerRadius = 13;
    self.closeButton.clipsToBounds = YES;
    [self.closeButton setTitle:@"×" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.cardView addSubview:self.closeButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cardWidth = CGRectGetWidth(self.contentView.bounds) - 24;
    self.cardView.frame = CGRectMake(12, 8, cardWidth, CGRectGetHeight(self.contentView.bounds) - 16);
    CGFloat innerWidth = cardWidth - 24;
    self.titleLabel.frame = CGRectMake(12, 10, innerWidth, 22);
    self.descLabel.frame = CGRectMake(12, 34, innerWidth, 34);
    self.mediaView.frame = CGRectMake(12, 74, innerWidth, 174);
    self.coverImageView.frame = self.mediaView.bounds;
    self.mediaLabel.frame = self.mediaView.bounds;
    CGFloat footerY = CGRectGetMaxY(self.mediaView.frame) + 9;
    self.adBadgeLabel.frame = CGRectMake(12, footerY + 3, 42, 20);
    self.closeButton.frame = CGRectMake(cardWidth - 38, footerY, 26, 26);
    self.ctaButton.frame = CGRectMake(CGRectGetMinX(self.closeButton.frame) - 82, footerY, 72, 26);
}

- (nullable IFLYNativeFeedAd *)boundAd {
    return self.binding.displaySession.ad;
}

- (BOOL)attachDisplaySession:(IFLYNativeFeedDisplaySession *)session
              itemIdentifier:(NSString *)itemIdentifier
                  coverImage:(nullable UIImage *)coverImage
                       error:(IFLYAdError *_Nullable *_Nullable)error {
    if (self.binding.isActive && self.binding.displaySession == session &&
        [self.representedItemIdentifier isEqualToString:itemIdentifier]) {
        if (error) {
            *error = nil;
        }
        return YES;
    }
    [self detachBinding];
    self.representedItemIdentifier = itemIdentifier;

    IFLYNativeFeedAdData *data = session.ad.adData;
    if (!data || !data.isMaterialComplete ||
        data.materialType == IFLYNativeFeedAdMaterialTypeUnknown) {
        return NO;
    }
    [self configureWithAdData:data itemIdentifier:itemIdentifier coverImage:coverImage];

    BOOL isVideo = data.materialType == IFLYNativeFeedAdMaterialTypeVideo;
    BOOL clickable = data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
                     data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    NSMutableArray<UIView *> *renderViews = [NSMutableArray arrayWithArray:@[
        self.titleLabel, self.descLabel, self.mediaView, self.adBadgeLabel, self.closeButton
    ]];
    if (!self.ctaButton.hidden) {
        [renderViews addObject:self.ctaButton];
    }

    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.cardView;
    binder.renderViews = renderViews.copy;
    binder.clickViews = clickable ? @[self.cardView] : @[];
    binder.closeView = self.closeButton;
    binder.videoView = isVideo ? self.mediaView : nil;
    binder.titleView = self.titleLabel;
    binder.descView = self.descLabel;
    binder.imageView = isVideo ? nil : self.mediaView;
    binder.adSourceView = self.adBadgeLabel;
    binder.ctaView = self.ctaButton.hidden ? nil : self.ctaButton;

    IFLYNativeFeedAdBinding *binding = [session attachWithViewBinder:binder error:error];
    if (!binding) {
        [self resetPresentation];
        return NO;
    }
    self.binding = binding;
    return YES;
}

- (void)configureWithAdData:(IFLYNativeFeedAdData *)data
             itemIdentifier:(NSString *)itemIdentifier
                 coverImage:(nullable UIImage *)coverImage {
    [self resetPresentation];
    self.representedItemIdentifier = itemIdentifier;
    self.titleLabel.text = data.title.length > 0 ? data.title :
                           (data.appName.length > 0 ? data.appName :
                            (data.brand.length > 0 ? data.brand : @"广告"));
    self.descLabel.text = data.desc.length > 0 ? data.desc :
                          (data.content.length > 0 ? data.content : @"");
    self.adBadgeLabel.text = data.adSourceMark.length > 0 ? data.adSourceMark : @"广告";
    self.adBadgeLabel.hidden = NO;
    self.closeButton.hidden = NO;

    BOOL clickable = data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
                     data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    self.ctaButton.hidden = !clickable;
    NSString *fallbackCTA = data.interactionType == IFLYNativeFeedAdInteractionTypeDownload ? @"立即下载" : @"查看详情";
    [self.ctaButton setTitle:(clickable ? (data.ctaText.length > 0 ? data.ctaText : fallbackCTA) : nil)
                    forState:UIControlStateNormal];

    BOOL isVideo = data.materialType == IFLYNativeFeedAdMaterialTypeVideo;
    self.mediaLabel.text = isVideo ? @"视频加载中" :
                           (data.materialType == IFLYNativeFeedAdMaterialTypeMultipleImages ? @"多图素材（完整渲染见基础示例）" : @"图片加载中");
    self.coverImageView.image = coverImage;
    self.mediaLabel.hidden = coverImage != nil;
}

- (void)setVideoCoverHidden:(BOOL)hidden text:(nullable NSString *)text {
    self.coverImageView.hidden = hidden;
    self.mediaLabel.hidden = hidden;
    if (!hidden && text.length > 0) {
        self.mediaLabel.text = text;
    }
}

- (void)detachBinding {
    IFLYNativeFeedAdBinding *binding = self.binding;
    self.binding = nil;
    [binding detach];
    [self resetPresentation];
}

- (void)resetPresentation {
    self.titleLabel.text = @"";
    self.descLabel.text = @"";
    self.adBadgeLabel.hidden = YES;
    self.ctaButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.coverImageView.image = nil;
    self.coverImageView.hidden = NO;
    self.mediaLabel.hidden = NO;
    self.mediaLabel.text = @"等待广告";
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self detachBinding];
    self.representedItemIdentifier = nil;
}

@end

@interface IFLYNativeFeedListViewController () <UITableViewDataSource, UITableViewDelegate, IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, copy) NSArray<NSString *> *itemIdentifiers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, IFLYNativeFeedListItem *> *itemsByIdentifier;
@property (nonatomic, weak, nullable) IFLYNativeFeedListCell *visibleAdCell;
@property (nonatomic, copy, nullable) NSString *visibleAdItemIdentifier;
- (void)startLoadingItem:(IFLYNativeFeedListItem *)item;
- (BOOL)attachItem:(IFLYNativeFeedListItem *)item toCell:(IFLYNativeFeedListCell *)cell;
- (void)continueItemAfterCellDetached:(nullable IFLYNativeFeedListItem *)item;
- (void)evictItem:(nullable IFLYNativeFeedListItem *)item;
- (nullable IFLYNativeFeedListItem *)itemForAd:(IFLYNativeFeedAd *)ad;
@end

@implementation IFLYNativeFeedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息流列表复用";
    self.view.backgroundColor = UIColor.whiteColor;
    [self buildStableDataSource];
    [self buildTableView];
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"淘汰广告"
                                        style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(evictCurrentAdItem)];
}

- (void)dealloc {
    for (IFLYNativeFeedListItem *item in self.itemsByIdentifier.allValues) {
        [self evictItem:item];
    }
}

- (void)buildStableDataSource {
    NSMutableArray<NSString *> *identifiers = [NSMutableArray arrayWithCapacity:IFLYNativeFeedListRowCount];
    for (NSInteger row = 0; row < IFLYNativeFeedListRowCount; row++) {
        [identifiers addObject:row == IFLYNativeFeedListAdRow
                                   ? IFLYNativeFeedListAdItemID
                                   : [NSString stringWithFormat:@"content-%ld", (long)row]];
    }
    self.itemIdentifiers = identifiers.copy;
    IFLYNativeFeedListItem *adItem = [[IFLYNativeFeedListItem alloc] init];
    adItem.itemIdentifier = IFLYNativeFeedListAdItemID;
    self.itemsByIdentifier = [NSMutableDictionary dictionaryWithObject:adItem forKey:adItem.itemIdentifier];
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:IFLYNativeFeedListContentCellID];
    [self.tableView registerClass:IFLYNativeFeedListCell.class forCellReuseIdentifier:IFLYNativeFeedListAdCellID];
    [self.view addSubview:self.tableView];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 104)];
    UILabel *explanation = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, CGRectGetWidth(header.bounds) - 32, 58)];
    explanation.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    explanation.numberOfLines = 3;
    explanation.font = [UIFont systemFontOfSize:13];
    explanation.textColor = [IFLYADUtil demoSecondaryLabelColor];
    explanation.text = @"稳定 item ID 的数据层持有 Ad + DisplaySession；Cell 只持 Binding。滚出时 detach，回屏恢复原广告；淘汰时 endDisplaySession → destroy。";
    [header addSubview:explanation];
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 70, CGRectGetWidth(header.bounds) - 32, 24)];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.statusLabel.textColor = [IFLYADUtil demoIndigoColor];
    self.statusLabel.text = @"滚动到第 5 行加载广告";
    [header addSubview:self.statusLabel];
    self.tableView.tableHeaderView = header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    (void)section;
    return self.itemIdentifiers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *itemIdentifier = [self itemIdentifierAtIndexPath:indexPath];
    if ([itemIdentifier isEqualToString:IFLYNativeFeedListAdItemID]) {
        return [tableView dequeueReusableCellWithIdentifier:IFLYNativeFeedListAdCellID forIndexPath:indexPath];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IFLYNativeFeedListContentCellID
                                                             forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"普通内容 · %@", itemIdentifier];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    return [[self itemIdentifierAtIndexPath:indexPath] isEqualToString:IFLYNativeFeedListAdItemID] ? 318 : 64;
}

- (void)tableView:(UITableView *)tableView
 willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    NSString *itemIdentifier = [self itemIdentifierAtIndexPath:indexPath];
    IFLYNativeFeedListItem *item = self.itemsByIdentifier[itemIdentifier];
    if (!item || ![cell isKindOfClass:IFLYNativeFeedListCell.class]) {
        return;
    }

    IFLYNativeFeedListCell *adCell = (IFLYNativeFeedListCell *)cell;
    adCell.representedItemIdentifier = itemIdentifier;
    self.visibleAdCell = adCell;
    self.visibleAdItemIdentifier = itemIdentifier;
    if (item.session) {
        if (item.session.isValid) {
            if (item.presentationReady) {
                [self attachItem:item toCell:adCell];
            }
            return;
        }

        // 到期只禁止下一次 attach；当前 Binding 仍活动，或旧 Cell 尚未 didEndDisplaying 时，
        // 不能在 willDisplay 中中断正在展示的广告。
        BOOL cellKeepsCurrentBinding = adCell.binding.isActive && adCell.binding.displaySession == item.session;
        if (cellKeepsCurrentBinding || item.session.isAttached) {
            return;
        }
        [self evictItem:item];
        adCell.representedItemIdentifier = itemIdentifier;
        self.visibleAdCell = adCell;
        self.visibleAdItemIdentifier = itemIdentifier;
    } else if (item.ad) {
        return;
    }
    [self startLoadingItem:item];
}

- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    (void)indexPath;
    if (![cell isKindOfClass:IFLYNativeFeedListCell.class]) {
        return;
    }

    // 回调 indexPath 可能已过时；只按 Cell 保存的稳定 item ID 对具体 Binding 执行 detach。
    IFLYNativeFeedListCell *adCell = (IFLYNativeFeedListCell *)cell;
    NSString *itemIdentifier = adCell.representedItemIdentifier;
    IFLYNativeFeedListItem *item = self.itemsByIdentifier[itemIdentifier];
    [adCell detachBinding];
    if (item.attachedCell == adCell) {
        item.attachedCell = nil;
    }
    if (self.visibleAdCell == adCell && [self.visibleAdItemIdentifier isEqualToString:itemIdentifier]) {
        self.visibleAdCell = nil;
        self.visibleAdItemIdentifier = nil;
    }
    [self continueItemAfterCellDetached:item];
}

- (nullable NSString *)itemIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row >= 0 && indexPath.row < (NSInteger)self.itemIdentifiers.count
               ? self.itemIdentifiers[indexPath.row]
               : nil;
}

- (void)startLoadingItem:(IFLYNativeFeedListItem *)item {
    if (!item || item.ad) {
        return;
    }
    item.generation += 1;
    IFLYNativeFeedAd *ad = [[IFLYNativeFeedAd alloc] initWithAdUnitId:__TYPED_ONE_NATIVE_AD_UNIT_ID__];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    item.ad = ad;
    self.statusLabel.text = @"正在加载稳定广告条目";
    [ad loadAdWithRequestConfig:[IFLYADUtil mediaSampleRequestConfig]];
}

- (BOOL)attachItem:(IFLYNativeFeedListItem *)item toCell:(IFLYNativeFeedListCell *)cell {
    if (!item || !cell || !item.session || !item.presentationReady || item.session.ad != item.ad) {
        return NO;
    }
    IFLYNativeFeedDisplaySession *session = item.session;
    if (cell.binding.isActive && cell.binding.displaySession == session) {
        item.attachedCell = cell;
        return YES;
    }
    if (!session.isValid) {
        if (!session.isAttached) {
            [self evictItem:item];
            [self startLoadingItem:item];
        }
        return NO;
    }
    IFLYAdError *error = nil;
    BOOL attached = [cell attachDisplaySession:session
                                itemIdentifier:item.itemIdentifier
                                    coverImage:item.coverImage
                                         error:&error];
    self.statusLabel.text = attached
                                ? @"已挂载：滚出后 detach，回屏恢复同一广告"
                                : [NSString stringWithFormat:@"挂载等待/失败：%@",
                                                           error ? [IFLYADUtil summaryForError:error] : @"旧 Cell 尚未 detach"];
    // valid 检查与 SDK attach 之间仍可能跨过 TTL/视频截止时间边界；只有没有活动 Binding
    // 时才能淘汰，避免误拆仍在屏幕上的旧 Cell。
    if (!attached && item.session == session && !session.isAttached && !session.isValid) {
        [self evictItem:item];
        [self startLoadingItem:item];
    } else if (attached) {
        item.attachedCell = cell;
    }
    return attached;
}

- (void)continueItemAfterCellDetached:(nullable IFLYNativeFeedListItem *)item {
    if (!item || !item.session || item.session.isAttached) {
        return;
    }

    IFLYNativeFeedListCell *visibleCell = self.visibleAdCell;
    BOOL hasWaitingVisibleCell =
        visibleCell && !visibleCell.binding &&
        [self.visibleAdItemIdentifier isEqualToString:item.itemIdentifier];
    if (!item.session.isValid) {
        // TTL/视频截止时间只禁止下一次 attach；活动 Binding 已由 Cell 正常 detach 后，
        // 立即结束旧会话并预取新广告，避免把不可恢复对象留到下次回屏才淘汰。
        NSString *itemIdentifier = item.itemIdentifier;
        [self evictItem:item];
        if (hasWaitingVisibleCell) {
            visibleCell.representedItemIdentifier = itemIdentifier;
        }
        [self startLoadingItem:item];
        return;
    }

    if (hasWaitingVisibleCell && item.presentationReady) {
        [self attachItem:item toCell:visibleCell];
    }
}

- (void)evictCurrentAdItem {
    IFLYNativeFeedListItem *item = self.itemsByIdentifier[IFLYNativeFeedListAdItemID];
    [self evictItem:item];
    self.statusLabel.text = @"已淘汰：endDisplaySession → destroy";
    if (self.visibleAdCell && [self.visibleAdItemIdentifier isEqualToString:item.itemIdentifier]) {
        self.visibleAdCell.representedItemIdentifier = item.itemIdentifier;
        [self startLoadingItem:item];
    }
}

- (void)evictItem:(nullable IFLYNativeFeedListItem *)item {
    if (!item) {
        return;
    }
    IFLYNativeFeedAd *ad = item.ad;
    IFLYNativeFeedDisplaySession *session = item.session;
    IFLYNativeFeedListCell *attachedCell = item.attachedCell;
    item.generation += 1;
    item.ad = nil;
    item.session = nil;
    item.coverImage = nil;
    item.presentationReady = NO;
    item.attachedCell = nil;
    if (session && attachedCell.binding.displaySession == session) {
        [attachedCell detachBinding];
    }
    if ((session && self.visibleAdCell.binding.displaySession == session) ||
        (ad && self.visibleAdCell.boundAd == ad)) {
        [self.visibleAdCell detachBinding];
    }
    [session endDisplaySession];
    ad.delegate = nil;
    [ad destroy];
}

- (nullable IFLYNativeFeedListItem *)itemForAd:(IFLYNativeFeedAd *)ad {
    for (IFLYNativeFeedListItem *item in self.itemsByIdentifier.allValues) {
        if (item.ad == ad) {
            return item;
        }
    }
    return nil;
}

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedListItem *item = [self itemForAd:ad];
    if (!item) {
        return;
    }
    IFLYAdError *error = nil;
    IFLYNativeFeedDisplaySession *session = [ad beginDisplaySessionWithError:&error];
    if (!session) {
        self.statusLabel.text = [NSString stringWithFormat:@"创建会话失败：%@", [IFLYADUtil summaryForError:error]];
        [self evictItem:item];
        return;
    }
    item.session = session;
    IFLYNativeFeedAdData *data = ad.adData;
    BOOL imageRequired = data.materialType != IFLYNativeFeedAdMaterialTypeVideo;
    NSString *coverURL = data.materialType == IFLYNativeFeedAdMaterialTypeVideo
                             ? data.videoCoverURL
                             : data.imageURLs.firstObject;
    if (coverURL.length == 0 && imageRequired) {
        self.statusLabel.text = @"图片素材地址为空，已淘汰当前广告";
        [self evictItem:item];
        return;
    }

    NSUInteger generation = item.generation;
    __weak typeof(self) weakSelf = self;
    void (^finishPresentation)(UIImage *_Nullable, NSError *_Nullable) =
        ^(UIImage *_Nullable image, NSError *_Nullable imageError) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            IFLYNativeFeedListItem *currentItem = [self itemForAd:ad];
            if (currentItem != item || item.generation != generation || item.session != session) {
                return;
            }
            if (!image && imageRequired) {
                NSString *failureDescription = imageError.localizedDescription.length > 0
                                                   ? imageError.localizedDescription
                                                   : @"图片数据无效";
                self.statusLabel.text = [NSString stringWithFormat:@"图片加载失败，已淘汰：%@",
                                                                    failureDescription];
                [self evictItem:item];
                return;
            }
            if (!session.isValid) {
                [self evictItem:item];
                [self startLoadingItem:item];
                return;
            }
            item.coverImage = image;
            item.presentationReady = YES;
            self.statusLabel.text = @"素材就绪，数据层持有 Ad + DisplaySession";
            if (self.visibleAdCell &&
                [self.visibleAdItemIdentifier isEqualToString:item.itemIdentifier] &&
                !self.visibleAdCell.binding) {
                [self attachItem:item toCell:self.visibleAdCell];
            }
        };

    if (coverURL.length == 0) {
        finishPresentation(nil, nil);
    } else {
        self.statusLabel.text = @"加载成功，正在准备媒体素材";
        [IFLYADUtil loadImageWithURLString:coverURL completion:finishPresentation];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailWithError:(IFLYAdError *)error {
    IFLYNativeFeedListItem *item = [self itemForAd:ad];
    if (!item) {
        return;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"加载失败：%@", [IFLYADUtil summaryForError:error]];
    [self evictItem:item];
}

- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedListItem *item = [self itemForAd:ad];
    if (item) {
        self.statusLabel.text = @"广告已关闭并淘汰";
        [self evictItem:item];
    }
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    if (self.visibleAdCell.boundAd == ad) {
        self.statusLabel.text = @"当前 Cell 绑定成功";
        // 列表复挂载不能重复 startPlay，否则会覆盖离屏前显式 pause/stop 的播放意图。
        // SDK 在首次绑定时已有默认起播请求，后续由同一 DisplaySession 自行恢复。
    }
}

- (void)nativeFeedAdDidExpose:(IFLYNativeFeedAd *)ad {
    if ([self itemForAd:ad]) {
        self.statusLabel.text = @"广告已曝光；再次回屏不会重复曝光";
    }
}

- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad {
    if (self.visibleAdCell.boundAd == ad) {
        [self.visibleAdCell setVideoCoverHidden:YES text:nil];
    }
}

- (void)nativeFeedAdDidResumePlay:(IFLYNativeFeedAd *)ad {
    if (self.visibleAdCell.boundAd == ad) {
        [self.visibleAdCell setVideoCoverHidden:YES text:nil];
    }
}

- (void)nativeFeedAdDidPausePlay:(IFLYNativeFeedAd *)ad {
    if (self.visibleAdCell.boundAd == ad) {
        [self.visibleAdCell setVideoCoverHidden:NO text:@"视频已暂停"];
    }
}

- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad {
    if (self.visibleAdCell.boundAd == ad) {
        [self.visibleAdCell setVideoCoverHidden:NO text:@"视频播放完成"];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToPlayWithError:(IFLYAdError *)error {
    (void)error;
    if (self.visibleAdCell.boundAd == ad) {
        [self.visibleAdCell setVideoCoverHidden:NO text:@"视频播放失败"];
    }
}

@end
