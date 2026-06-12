//
//  IFLYAdRenderingData.h
//  IFLYAdLib
//
//  Created by jmliu6 on 2026/5/8.
//  Copyright © 2026 iflytek. All rights reserved.
//
//  广告渲染指令模型（rendering 字段）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告渲染指令模型，对应服务端广告响应中的 rendering 字段。
/// @discussion 承载与“如何渲染/缓存这条广告”相关的下发配置，由上层广告数据模型在解析
///             响应时构造。所有字段均为只读，仅在 @c initWithDic: 中一次性赋值，构造完成后
///             即视为不可变。各字段在服务端缺省或类型非法时为 @c nil，调用方需自行兜底。
@interface IFLYAdRenderingData : NSObject

/// 屏幕朝向：@c 0 表示竖版、@c 1 表示横版。
/// @note 服务端未下发或值非法（无法解析为数字）时为 @c nil；取值时建议先判空再 @c integerValue。
@property (readonly, nonatomic, strong, nullable) NSNumber *screen_orientation;
/// 广告缓存有效期，单位：小时。
/// @note 表示该条广告自缓存起可复用的时长上限；服务端未下发或值非法时为 @c nil。
@property (readonly, nonatomic, strong, nullable) NSNumber *preload_time;

/// 用服务端下发的 rendering 字典构造渲染配置模型。
/// @param dic rendering 字段对应的字典（通常来自 JSON 反序列化）；可为 @c nil 或非字典类型。
/// @return 初始化后的实例；恒不为 @c nil。
/// @note 当 @c dic 为 @c nil 或运行时类型不是 @c NSDictionary 时，所有属性保持默认值 @c nil，
///       但仍返回一个有效（各字段全空）的实例，不会返回 @c nil。
/// @note 字段经 @c IFLYAdSafeNumber 安全解析：NSNumber 原样保留，纯数字字符串转为 NSNumber，
///       其它类型一律置 @c nil，因此对脏数据天然容错。
- (instancetype)initWithDic:(nullable NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
