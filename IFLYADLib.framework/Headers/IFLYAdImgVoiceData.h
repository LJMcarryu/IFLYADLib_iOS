//
//  IFLYAdImgVoiceData.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/12/19.
//  Copyright © 2016年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 图片/语音广告素材数据模型
/// @discussion 描述单条图片或语音素材（如广告主图、音频文件），承载素材的资源地址与展示尺寸。
///             由服务端下发的素材字典解析而来，所有属性均为只读，构造完成后不可变。
///             本类是对外公开头（通过伞头 IFLYADLib.h 导出），属 API 契约的一部分。
/// @note 解析容错：所有字段均经过类型安全校验（见 IFLYAdParseUtils.h），
///       服务端返回的字段缺失或类型不符时对应属性为 nil，不会抛异常。
@interface IFLYAdImgVoiceData : NSObject

/// 素材资源 URL（字符串形式）
/// @note 必填字段；服务端 JSON 中 key 为 @c "url"。
/// @warning 尽管声明为 nonnull（受 NS_ASSUME_NONNULL 约束），但解析时若服务端缺失或类型非字符串，
///          实际可能为 nil，使用前建议判空。
@property (readonly, nonatomic, strong) NSString *url;
/// 素材宽度，单位：像素
/// @note 非必填；服务端 JSON 中 key 为 @c "width"，可由数字或可解析为数字的字符串得到，无值时为 nil。
@property (readonly, nonatomic, strong) NSNumber *width;
/// 素材高度，单位：像素
/// @note 非必填；服务端 JSON 中 key 为 @c "height"，可由数字或可解析为数字的字符串得到，无值时为 nil。
@property (readonly, nonatomic, strong) NSNumber *height;
/// 扩展信息字典，承载素材的额外自定义字段
/// @note 非必填；服务端 JSON 中 key 为 @c "ext"，无值或类型非字典时为 nil。
@property (readonly, nonatomic, strong) NSDictionary *ext;

/// 通过字典初始化图片/语音素材数据模型
/// @param dic 素材数据字典（来源于服务端响应）。若传入非 NSDictionary，则返回各字段均为 nil 的空实例（不返回 nil）。
/// @return 图片/语音素材数据实例
/// @note 指定初始化器；逐字段经安全解析填充只读属性。
- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
