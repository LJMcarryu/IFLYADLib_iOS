//
//  IFLYVideoAd.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/12/19.
//  Copyright © 2016年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * 视频广告类型
 */
typedef NS_ENUM(NSInteger, IFLYVideoAdType) {
    // 激励视频
    IFLYVideoAdTypeReward,
    // 开屏视频
    IFLYVideoAdTypeSplash,
    // 信息流视频
    IFLYVideoAdTypeNative
};

@class IFLYAdData;
@class IFLYAdError;
@class IFLYVideoAd;

@protocol IFLYVideoAdDelegate <NSObject>

/**
 * 视频广告加载成功回调
 * @param adData IFLYAdData对象
 */
- (void)onVideoAdReceived:(IFLYAdData *)adData;

/**
 * 视频广告失败回调
 */
- (void)onVideoAdFailed:(IFLYAdError *)error;

@optional

/**
 * 视频广告加载成功回调
 * @param videoAdData IFlyAdData对象
 * @param videoSize   视频大小
 */
- (void)onPreloadSuccess:(IFLYAdData *)videoAdData withSize:(CGSize)videoSize;

/**
 * 视频广告预加载失败回调
 */
- (void)onPreloadFailed:(IFLYAdError *)error;

/**
 *  视频开始播放
 */
- (void)adStartPlay;

/**
 *  视频播放出错
 */
- (void)adPlayError;

/**
 *  视频播放结束
 */
- (void)adPlayCompleted;

/**
 *  视频重新播放
 */
- (void)adReplay;

/**
 *  广告被点击
 */
- (void)onVideoAdClicked;

@end


@interface IFLYVideoAd : NSObject

/**
 *  委托对象
 */
@property (nonatomic, weak) id<IFLYVideoAdDelegate> delegate;
/**
 *  父视图
 *  需设置为显示广告的UIViewController
 */
@property (nonatomic, weak) UIViewController *currentViewController;

/**
 *  跳转视图
 *  可设置为显示落地页的UIViewController，不填默认 currentViewController
 */
@property (nonatomic, weak) UIViewController *jumperViewController;

/**
 *  父view
 *  需设置为显示广告的UIView
 */
@property (nonatomic, weak) UIView *fatherView;
/** 静音（默认为NO）*/
@property (nonatomic, assign) BOOL mute;
/** 自动播放（默认为NO）*/
@property (nonatomic, assign) BOOL autoPlay;
/** 视频广告类型 */
@property (nonatomic, assign) IFLYVideoAdType videoType;
/** cell播放视频，以下属性必须设置值 */
@property (nonatomic, strong) UIScrollView *scrollView;

/** cell所在的indexPath */
@property (nonatomic, strong) NSIndexPath *indexPath;
/**
 * cell上播放必须指定
 * 播放器View的父视图tag（根据tag值在cell里查找playerView加到哪里)
 */
@property (nonatomic, assign) NSInteger fatherViewTag;

/**
 *  构造方法
 *  详解：adUnitId是广告位id
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

/**
 *  设置广告请求配置参数
 */
- (void)setParamValue:(NSObject *)value forKey:(NSString *)key;

/**
 *  设置广告请求配置参数,点击视频广告是否直接跳转
 */
- (void)setDerectJump:(BOOL)value;

/**
 *  视频广告预加载
 *  详解：预发起拉取广告请求，在获得广告后回调delegate
 */
- (void)preloadAd;

/**
 *  广告发起请求方法
 *  详解：[必选]发起拉取广告请求,在获得广告数据后回调delegate
 */
- (void)loadAd;

/**
 *  展示视频视图
 */
- (void)showAd;

/**
 *  广告曝光
 */
- (BOOL)attachAd;

/**
 *  广告曝光,当view附着在window上
 */
- (BOOL)attachWindowAd:(UIView *)view;

/**
 *  广告点击
 *  注意：当前视频广告内部已集成播放器，不需要调用此接口
 */
- (BOOL)clickAd;

/**
 *  带扩展信息的广告点击
 *  注意：当前视频广告内部已集成播放器，不需要调用此接口
 */
- (BOOL)clickAdWithExt:(NSDictionary *)ext;

/**
 *  开始播放
 */
- (void)startPlay;

/**
 *  暂停播放
 */
- (void)pausePlay;

/**
 *  恢复播放
 */
- (void)resumePlay;

/**
 *  结束播放
 */
- (void)stopPlay;

/**
 *  广告竞价胜出通知
 *  详解：[必选]
 *  TYPE=100，即获胜竞得
 *  TYPE=101，原因是出价低即未获胜
 *  TYPE=102，即未获胜原因是素材未审核
 *  TYPE=103，即未获胜原因是素材审核拒绝
 *  TYPE=104，即未获胜原因是竞价优先级低(如PDB>PD>RTB)
 *  TYPE=105，竞价响应错误
 *  TYPE=106，竞价响应超时
 *
 *  reason支持媒体侧自定义替换，上报的内容需要进行urlencode 当TYPE=103时尽量填写具体拒绝原因
 */
- (void)sendWinNoticeWithType:(NSNumber *)type reason:(NSString *)reason;

/**
 * 广告退出落地页的回调
 */
@property (nonatomic, copy) void (^ dismissBlock)(void);

/**
 * 广告退出应用商店的回调
 */
@property (nonatomic, copy) void (^ dismissStoreBlock)(void);

/**
 * 广告点击跳转完成回调
 */
@property (nonatomic, copy) void (^ didJumpBlock)(BOOL success);

/**
 * deeplink跳转离开app回调
 */
@property (nonatomic, copy) void (^ didLeaveApp)(void);

@end
