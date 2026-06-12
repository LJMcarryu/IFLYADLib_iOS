//
//  IFLYAdKeys.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/9/26.
//  Copyright © 2016年 iflytek. All rights reserved.
//

/// 广告请求参数 Key 常量
/// @discussion 配合各广告格式继承自 IFLYAdBase 的 @c -[IFLYAdBase setParamValue:forKey:] 使用，
///             用于在广告请求前设置各项业务参数。
///             常用结构化参数优先使用 IFLYAdRequestConfig；本文件用于补充协议扩展字段和旧式调用。
#ifndef IFLYAdLib_IFLYAdKeys_h
#define IFLYAdLib_IFLYAdKeys_h

/// 广告请求参数 Key 的类型别名
/// @discussion 本质是 @c NSString，借助 @c NS_STRING_ENUM 标注为字符串枚举，
///             使本文件下方的各 @c IFLYAdKey 常量在 Swift 中以强类型枚举形式暴露、
///             在 OC 中作为带类型语义的字符串常量使用，避免直接传裸字符串字面量出错。
typedef NSString *IFLYAdKey NS_STRING_ENUM;

/// 广告位 ID
/// @discussion 用于标识一个广告位，在广告请求时必须设置。
///             值类型：NSString。
extern IFLYAdKey const IFLYAdKeyAdUnitId;

/// 广告请求 ID
/// @discussion 用于外部设置特定的广告请求标识，便于追踪和日志关联。
///             不设置时 SDK 会自动生成唯一请求 ID。
///             值类型：NSString。
extern IFLYAdKey const IFLYAdKeyRequestId;

/// 广告位互动状态
/// @discussion 控制该广告位请求是否启用互动行为（如摇一摇、上滑等）。具体可用玩法仍以广告格式实现与服务端下发为准。
///             值类型：NSNumber。
///             - @c 1 ：开启互动（默认）
///             - @c 2 ：关闭互动
extern IFLYAdKey const IFLYAdKeyInteractStatus;

/// 交易方式
/// @discussion 指定广告的竞价/交易模式。
///             值类型：NSNumber。
///             - @c 0 ：固定价格流量（默认）
///             - @c 1 ：RTB 竞价模式
extern IFLYAdKey const IFLYAdKeySettleType;

/// 竞价底价
/// @discussion 在 CPM 竞价流量（settleType = 1）下该字段必填，
///             表示广告位的最低竞价门槛。
///             值类型：NSNumber（单位：CNY 元/千次展示，即 CPM）。
extern IFLYAdKey const IFLYAdKeyBIDFloor;

/// 竞价成交价扩展字段
/// @discussion 当前 iOS SDK 曝光监测中的 ${AUCTION_PRICE} 宏使用广告响应 ad.price，
///             setParamValue:forKey: 传入该 key 不会覆盖价格宏。
///             值类型：NSNumber（单位：CNY 元）。
extern IFLYAdKey const IFLYAdKeyAuctionPrice;

/// PMP 订单信息
/// @discussion 传入订单字典数组，用于 PMP（Private Marketplace）私有交易。
///             每个订单字典使用 @c id 作为订单 ID，@c bidfloor 作为订单底价。
///             值类型：NSArray<NSDictionary *>，请求体输出为 @c pmp.deals。
extern IFLYAdKey const IFLYAdKeyPMP;

/// 应用版本号
/// @discussion 用于设置接入 SDK 的宿主应用版本号，会随广告请求上报。
///             值类型：NSString。
extern IFLYAdKey const IFLYAdKeyAPPVersion;

/// 应用名称
/// @discussion 用于设置接入 SDK 的宿主应用名称，会随广告请求上报。
///             值类型：NSString。
extern IFLYAdKey const IFLYAdKeyAPP;

/// 广告请求超时时间
/// @discussion 设置广告请求的超时时间上限。
///             值类型：NSNumber（单位：秒）。
extern IFLYAdKey const IFLYAdKeyRequestTimeout;

/// 浏览器 User-Agent
/// @discussion 用于自定义广告请求中的 UA 字段，传入的值应为浏览器 UA 字符串。
///             值类型：NSString。
extern IFLYAdKey const IFLYAdKeyUA;

/// 广告请求 IDFA
/// @discussion 用于外部传入 IDFA（Identifier for Advertisers）值。
///             值类型：NSString，格式为 @c "00000000-0000-0000-0000-000000000000"。
extern IFLYAdKey const IFLYAdKeyIDFA;

/// CAID 列表（中国广告协会互联网广告标识）
/// @discussion 用于传入由中国广告协会（中广协 / CAA）分配的 CAID 标识列表。
///             值类型：NSArray<NSDictionary *>。
///             每个字典包含 @c ver（版本号）和 @c caid（标识值）两个字段。
///             示例：
///             @code
///             @[@{@"ver": @"20230330", @"caid": @"75c7bc3754b3019c135b526cb8eb4420"},
///               @{@"ver": @"20220111", @"caid": @"8799abe1c76805fab06ee3f98a3f704e"}]
///             @endcode
extern IFLYAdKey const IFLYAdKeyCAIDList;

/// 落地页跳转动画样式
/// @discussion 控制点击广告后打开落地页时的转场动画方向。
///             值类型：NSNumber（NSUInteger）。
///             - @c 0 ：从右侧滑入（默认）
///             - @c 1 ：从底部滑入
extern IFLYAdKey const IFLYAdKeyLandingPageTransitionType;

/// 落地页屏幕旋转方式
/// @discussion 控制落地页支持的设备方向。
///             值类型：NSNumber（NSUInteger）。
///             - @c 0 ：仅竖屏 Portrait（默认）
///             - @c 1 ：仅横屏 Landscape
///             - @c 2 ：支持除 UpsideDown 外的所有方向
///             - @c 3 ：支持所有方向
extern IFLYAdKey const IFLYAdKeyLandingPageAutorotateType;

/// DeepLink 是否直接跳转
/// @discussion 设置 DeepLink 跳转时是否跳过 @c canOpenURL 检查直接调用 @c openURL。
///             值类型：NSNumber（BOOL），默认 @c YES。
/// @note 此参数在广告请求前通过 setParamValue:forKey: 设置，控制 DeepLink 跳转行为；也可通过
///       IFLYAdRequestConfig.jumpDirectly 配置。
/// @note 该 key 在 @c -[IFLYAdBase setParamValue:forKey:] 中被特殊拦截：直接写入 jumper 的
///       @c isDirectly 属性，不进入 @c IFLYAdParam 请求参数容器（它是跳转行为配置而非请求字段）。
/// @warning 传入的值若非 @c NSNumber 类型将被直接忽略，不会改变跳转行为。
extern IFLYAdKey const IFLYAdKeyJumpDirectly;

#endif /* IFLYAdLib_IFLYAdKeys_h */
