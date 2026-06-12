//
//  IFLYAdVideoData.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/12/19.
//  Copyright © 2016年 iflytek. All rights reserved.
//
//  视频广告素材数据模型（对外公开头，属 API 契约）：承载服务端下发的单条视频素材
//  的播放地址、尺寸、码率、格式与缓存过期时间等字段，由 IFLYAdData 在解析广告数据时构造。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 视频广告素材数据模型
/// @discussion 所有属性均为只读，对象一经构造即不可变；仅能通过 @c -initWithDic: 由
///   服务端响应字典填充。各字段经 IFLYAdParseUtils 的安全解析函数过滤，类型不匹配时
///   对应属性会落为 @c nil。
/// @warning 头部处于 @c NS_ASSUME_NONNULL_BEGIN 区间，属性虽标注为非空，但当服务端未
///   下发对应字段或字段类型不符时，运行时仍可能为 @c nil，使用前请按需判空。
@interface IFLYAdVideoData : NSObject

/// 视频资源 URL
/// @note 必填字段
@property (readonly, nonatomic, strong) NSString *url;
/// 视频时长，单位：秒
/// @note 非必填
@property (readonly, nonatomic, strong) NSNumber *duration;
/// 视频宽度，单位：像素
/// @note 非必填
@property (readonly, nonatomic, strong) NSNumber *width;
/// 视频高度，单位：像素
/// @note 非必填
@property (readonly, nonatomic, strong) NSNumber *height;
/// 视频码率，单位：kbps
/// @note 非必填
@property (readonly, nonatomic, strong) NSNumber *bitrate;
/// 视频格式
/// @note 非必填。取值范围：0=mp4，1=3gp，2=avi，3=flv
@property (readonly, nonatomic, strong) NSNumber *format;
/// 缓存过期时间戳，单位：秒（Unix 时间戳，超过该时间后本地缓存失效）
/// @note 非必填
@property (readonly, nonatomic, strong) NSNumber *end_time;
/// 扩展信息字典
/// @note 非必填
@property (readonly, nonatomic, strong) NSDictionary *ext;

/// 通过字典初始化视频素材数据模型
/// @param dic 视频素材数据字典（来源于服务端响应）；按 @c url / @c duration / @c width /
///   @c height / @c bitrate / @c format / @c end_time / @c ext 等键逐项安全解析。
/// @return 视频素材数据实例；恒不为 @c nil。
/// @note 即使 @c dic 非 NSDictionary（如传入 @c nil 或类型错误），也会返回一个所有
///   属性均为 @c nil 的有效实例，而非返回 @c nil。
- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
