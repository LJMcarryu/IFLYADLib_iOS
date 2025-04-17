//
//  IFLYAdKeys.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/9/26.
//  Copyright © 2016年 iflytek. All rights reserved.
//

#ifndef IFLYAdLib_IFLYAdKeys_h
#define IFLYAdLib_IFLYAdKeys_h

typedef NSString *IFLYAdKey NS_STRING_ENUM;
/**
 * 广告位ID
 * 用于广告请求
 */
extern IFLYAdKey const IFLYAdKeyAdUnitId;
/**
 * 广告请求ID
 * 用于外部设置特定的广告请求，不设置时会默认生成
 */
extern IFLYAdKey const IFLYAdKeyRequestId;
/**
 * 横幅广告轮询时间间隔
 * 只用于横幅广告轮询场景，单位：s
 */
extern IFLYAdKey const IFLYAdKeyBannerInterval;
/**
 * 开屏互动状态
 * 1：开启开屏互动；2：关闭开屏互动（摇一摇/滑动）；默认：1
 */
extern IFLYAdKey const IFLYAdKeyInteractStatus;
/**
 * 交易方式
 * 0：固定价格流量；1：RTB竞价模式；2：PD模式（暂不支持）；默认：0
 */
extern IFLYAdKey const IFLYAdKeySettleType;
/**
 * 底价
 * CPM 竞价流量下该字段必填
 * 单位：元/千次
 */
extern IFLYAdKey const IFLYAdKeyBIDFloor;
/**
 * 广告竞价参数
 * 实际成交价
 * 值：NSNumber
 * 单位：元
 */
extern IFLYAdKey const IFLYAdKeyAuctionPrice;
/**
 * 订单信息
 * 传入 IFLYAdDeal 数组
 */
extern IFLYAdKey const IFLYAdKeyPMP;
/**
 * 应用版本参数
 * 用于外部设置使用此 SDK 的应用版本号
 */
extern IFLYAdKey const IFLYAdKeyAPPVersion;
/**
 * 应用版本参数
 * 用于外部设置使用此 SDK 的应用名称
 */
extern IFLYAdKey const IFLYAdKeyAPP;
/**
 * 支持的货币类型
 * CNY – 元；USD – 美元；默认：CNY
 * 值：NSString
 * ','分割支持多个
 */
extern IFLYAdKey const IFLYAdKeyCurrency;
/**
 * 广告请求超时时间
 */
extern IFLYAdKey const IFLYAdKeyRequestTimeout;
/**
 * 广告请求UA（传入的UA为浏览器UA）
 * 值：NSString
 */
extern IFLYAdKey const IFLYAdKeyUA;
/**
 * 广告请求IDFA
 * 值：NSString；格式"00000000-0000-0000-0000-000000000000"
 */
extern IFLYAdKey const IFLYAdKeyIDFA;
/**
 * 广告请求中广协CAIDList
 * 值：NSArray 参数示例：[{"ver": "20230330", "caid": "75c7bc3754b3019c135b526cb8eb4420"}, {"ver": "20220111", "caid": "8799abe1c76805fab06ee3f98a3f704e"}]
 */
extern IFLYAdKey const IFLYAdKeyCAIDList;
/**
 * 广告请求是否需要录音权限
 * BOOL 型 NSNumber
 */
extern IFLYAdKey const IFLYAdKeyNeedAudio;
/**
 * 广告请求是否需要地理位置权限
 * BOOL 型 NSNumber
 */
extern IFLYAdKey const IFLYAdKeyNeedLocation;
/**
 * 广告落地页跳转动画样式
 * NSUInteger 型 NSNumber
 * @0：右侧转入
 * @1：底部转入
 * 默认：右侧转入
 */
extern IFLYAdKey const IFLYAdKeyLandingPageTransitionType;
/**
 * 广告落地页跳转旋转方式
 * NSUInteger 型 NSNumber
 * @0：仅 Portrait
 * @1：仅 Landscape
 * @2：除 UpsideDown 外
 * @3：所有
 * 默认：不旋转(@0)
 */
extern IFLYAdKey const IFLYAdKeyLandingPageAutorotateType;
/**
 * 广告 deeplink 跳转是否直接跳转而不判断能否打开
 * BOOL 型 NSNumber
 * 注意：此参数目前仅对原生广告和视频广告生效
 * 默认：开启(@(YES))
 */
extern IFLYAdKey const IFLYAdKeyJumpDirectly;

#endif /* IFLYAdLib_IFLYAdKeys_h */
