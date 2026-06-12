//
//  IFLYAdData.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/12/19.
//  Copyright © 2016年 iflytek. All rights reserved.
//
//  对外公开头（经伞头 IFLYADLib.h 导出）：单条广告创意的完整数据模型，
//  汇集素材（图/视频/H5/图标）、交互参数、应用下载信息、价格、监测与落地页等字段。
//  由服务端响应字典解析得到，详见对应的 IFLYAdData.m 实现。
//

#import <Foundation/Foundation.h>

@class IFLYAdImgVoiceData;
@class IFLYAdVideoData;
@class IFLYAdMonitorData;
@class IFLYAdRenderingData;

NS_ASSUME_NONNULL_BEGIN

/// 广告数据模型，包含广告素材、交互参数、监测数据等完整广告信息
/// @discussion 所有字段均由 -initWithDic: 从服务端响应字典一次性解析填充，对外只读（readonly），构造后不可变。
/// 标量字段（NSString/NSNumber/NSDictionary/NSArray）经类型安全解析：类型不符或字段缺失时为 nil（见
/// IFLYAdParseUtils）。 子模型字段（img/icon/video/monitor/rendering 等）始终为非 nil
/// 实例——即便源字典缺失对应键，也会以空字典构造出"空"子模型，调用方无需判空即可访问其属性。
/// @note 本类经伞头导出，属性属于对外 API 契约的一部分。
@interface IFLYAdData : NSObject

/// 广告模板 ID
@property (readonly, nonatomic, strong) NSNumber *template_id;
/// 广告创意 ID
@property (readonly, nonatomic, strong) NSString *creative_id;
/// 广告出价，单位：元，支持小数
/// @note 源值为可整体解析为 double 的字符串时也会被转成 NSNumber；无法解析或缺失时为 nil。
@property (readonly, nonatomic, strong) NSNumber *price;
/// PMP 交易 ID（Private Marketplace）
@property (readonly, nonatomic, strong) NSString *deal_id;
/// 广告主图素材
/// @note 子模型恒非 nil：源字典缺 "img" 键时以空字典构造空实例，可直接访问其属性。
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img;
/// 图片素材 1（多图广告场景），恒非 nil（缺失时为空实例）
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img1;
/// 图片素材 2（多图广告场景），恒非 nil（缺失时为空实例）
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img2;
/// 图片素材 3（多图广告场景），恒非 nil（缺失时为空实例）
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img3;
/// 视频素材，恒非 nil（缺失时为空实例）
@property (readonly, nonatomic, strong) IFLYAdVideoData *video;
/// 交互类型
/// @note 取值范围：1=点击，2=点击+摇一摇，3=点击+上滑，4=点击+摇一摇+上滑
@property (readonly, nonatomic, strong) NSNumber *interact;
/// 点击类型
/// @note 取值范围：0=区域可点，1=全屏可点
@property (readonly, nonatomic, strong) NSNumber *click_type;
/// 摇一摇参数
/// @note 字典包含 acc（灵敏度）和 angle（旋转角度）
@property (readonly, nonatomic, strong) NSDictionary *shake_info;
/// 广告标题
@property (readonly, nonatomic, strong) NSString *title;
/// 广告描述
@property (readonly, nonatomic, strong) NSString *desc;
/// 应用图标素材，恒非 nil（缺失时为空实例）
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *icon;
/// 广告正文内容
@property (readonly, nonatomic, strong) NSString *content;
/// CTA 按钮文字（Call-to-Action，如"立即下载""了解更多"）
@property (readonly, nonatomic, strong) NSString *ctatext;
/// 应用名称（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *app_name;
/// 应用下载量（应用下载类广告）
@property (readonly, nonatomic, strong) NSNumber *downloads;
/// 应用评分（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *rating;
/// 应用下载地址（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *app_download_url;
/// 应用介绍页地址（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *app_intro_url;
/// 应用版本号（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *app_ver;
/// 应用包大小，单位：字节（应用下载类广告）
@property (readonly, nonatomic, strong) NSNumber *app_size;
/// 电话号码（电话拨打类广告）
@property (readonly, nonatomic, strong) NSString *phone;
/// 点赞数
@property (readonly, nonatomic, strong) NSNumber *likes;
/// 原价
@property (readonly, nonatomic, strong) NSNumber *original_price;
/// 现价
@property (readonly, nonatomic, strong) NSNumber *current_price;
/// 赞助商名称
@property (readonly, nonatomic, strong) NSString *sponsored;
/// 地址信息
@property (readonly, nonatomic, strong) NSString *address;
/// 应用 ID（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *app_id;
/// 应用包名（应用下载类广告）
@property (readonly, nonatomic, strong) NSString *package_name;
/// 品牌名称
@property (readonly, nonatomic, strong) NSString *brand;
/// 展示标签数组
/// @note 已过滤为仅含 NSString 元素的数组；源值非数组时为 nil。
@property (readonly, nonatomic, strong) NSArray *display_labels;
/// 关闭按钮图标 URL
@property (readonly, nonatomic, strong) NSString *close_icon;
/// 广告监测数据，恒非 nil（缺失时为空实例）
@property (readonly, nonatomic, strong) IFLYAdMonitorData *monitor;
/// DeepLink 跳转地址
@property (readonly, nonatomic, strong) NSString *deeplink;
/// 落地页 URL
@property (readonly, nonatomic, strong) NSString *landing;
/// 应用市场跳转地址（下载类广告兜底）
@property (readonly, nonatomic, strong) NSString *market_url;
/// 点击行为类型
/// @note 支持服务端下发字符串或数字：数字会被转为其 stringValue 后存储。
@property (readonly, nonatomic, strong) NSString *action_type;
/// 广告来源图标 URL
@property (readonly, nonatomic, strong) NSString *ad_source_icon;
/// 广告来源标记文字
@property (readonly, nonatomic, strong) NSString *ad_source_mark;
/// 扩展信息字典
@property (readonly, nonatomic, strong) NSDictionary *ext;
/// 视频交互类型（激励视频）：0=标准 / 1=提前领取 / 2=必点
@property (readonly, nonatomic, strong, nullable) NSNumber *video_interact;
/// 视频交互触发秒数（激励视频）：到达后弹出 dialog/小手
@property (readonly, nonatomic, strong, nullable) NSNumber *video_interact_duration;
/// 渲染配置
/// @note 标注 nullable，但实现中恒以子模型构造，实际非 nil（缺失时为空实例）。
@property (readonly, nonatomic, strong, nullable) IFLYAdRenderingData *rendering;

/// 通过字典初始化广告数据模型
/// @param dic 广告数据字典（来源于服务端响应）；非 NSDictionary 时跳过解析，返回各字段均为初始值（nil/空子模型）的实例
/// @return 广告数据实例（始终返回非 nil 对象）
/// @note 各字段经类型安全解析填充，详见 IFLYAdData.m 与 IFLYAdParseUtils。
- (instancetype)initWithDic:(NSDictionary *)dic;

/// SDK 根据 action_type 解析出的 CTA 文案。
/// @return action_type == 4 时返回"立即下载"，其余情况返回"查看详情"。
- (NSString *)ifly_ctaTextForActionType;

@end

NS_ASSUME_NONNULL_END
