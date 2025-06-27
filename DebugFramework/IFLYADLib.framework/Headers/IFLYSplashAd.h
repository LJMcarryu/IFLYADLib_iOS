//
//  IFLYSplashAd.h
//  IFLYAdLib
//
//  Created by jmliu6 on 2023/5/10.
//  Copyright © 2023 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IFLYAdData;
@class IFLYAdError;

@protocol IFLYSplashAdDelegate <NSObject>

/**
 *  开屏广告加载广告数据成功回调
 *
 *  @param adData IFLYAdData对象
 */
- (void)onSplashAdReceived:(IFLYAdData *)adData;

/**
 *  开屏广告错误回调
 *
 *  @param errorCode 错误码，详见接入手册
 */
- (void)onSplashAdFailed:(IFLYAdError *)error;

@end

@interface IFLYSplashAd : NSObject

/**
 *  委托对象
 */
@property (nonatomic, weak) id<IFLYSplashAdDelegate> delegate;

/**
 *  构造方法
 *  详解：adUnitId是广告位id
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

/**
 *  设置广告配置参数
 */
- (void)setParamValue:(NSObject *)value forKey:(NSString *)key;


/**
 *  设置媒体自定义展示 Window
 */
@property (nonatomic, strong) UIWindow *customWindow;

/**
 *  设置广告倒计时 默认5秒
 */
@property (nonatomic, assign) NSInteger traceDuration;

/**
 *  设置免除广告
 */
@property (nonatomic, assign) BOOL showNoAds;

/**
 *  设置媒体自定义底部图片
 */
@property (nonatomic, strong) UIView *mediumBottomView;

/**
 *  设置是否禁止摇一摇功能
 */
@property (nonatomic, assign) BOOL disableShaking;

/**
 *  广告发起请求方法 并直接显示
 *  详解：[必选]发起拉取广告请求,在获得广告数据后回调delegate
 */
- (void)loadAd;

- (void)showAd;

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
 *  获取广告请求成功后特定的物料信息
 */
- (NSDictionary *)getAdCallbackDic;

/**
 * 广告展示成功
 */
@property (nonatomic, copy) void (^ didShowBlock)(void);
/**
 * 广告展示失败
 */
@property (nonatomic, copy) void (^ didShowFailedBlock)(void);
/**
 * 广告点击跳转完成回调
 */
@property (nonatomic, copy) void (^ didJumpBlock)(BOOL success);
/**
 * deeplink跳转离开app回调
 */
@property (nonatomic, copy) void (^ didLeaveApp)(void);
/**
 * 广告结束的回调
 */
@property (nonatomic, copy) void (^ didCloseBlock)(void);
/**
 * 广告跳过的回调
 */
@property (nonatomic, copy) void (^ didSkipBlock)(void);
/**
 * 广告免除的回调
 */
@property (nonatomic, copy) void (^ didNoAdsBlock)(void);
/**
 * 广告退出落地页的回调
 */
@property (nonatomic, copy) void (^ dismissBlock)(void);
/**
 * 广告退出应用商店的回调
 */
@property (nonatomic, copy) void (^ dismissStoreBlock)(void);

@end

NS_ASSUME_NONNULL_END
