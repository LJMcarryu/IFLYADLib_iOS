//
//  IFLYNativeFeedAdData.h
//  IFLYADLib
//
// 自渲染信息流广告的统一素材视图模型：对外暴露只读字段，供接入方按 materialType 自行渲染单图/三图/视频信息流。

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IFLYAdData;

NS_ASSUME_NONNULL_BEGIN

/// 自渲染信息流素材类型
/// @discussion 由模板 ID 与实际素材字段共同推断（见 .m 中 resolvedMaterialTypeForAdData:）；
///             接入方据此决定渲染哪一套布局。
typedef NS_ENUM(NSInteger, IFLYNativeFeedAdMaterialType) {
    /// 未识别或素材不完整（既不命中已知模板，也凑不出可用图片）
    IFLYNativeFeedAdMaterialTypeUnknown = 0,
    /// 单图信息流（取首张可用图片）
    IFLYNativeFeedAdMaterialTypeSingleImage = 1,
    /// 三图信息流（取 img1/img2/img3 中的可用图片）
    IFLYNativeFeedAdMaterialTypeThreeImages = 2,
    /// 视频信息流（含视频地址，imageURLs 退化为视频封面单图）
    IFLYNativeFeedAdMaterialTypeVideo = 3,
};

/// 自渲染信息流广告数据。将底层 IFLYAdData 的文案、图片与视频字段合并为统一读取入口。
/// @discussion 该模型在 initWithAdData: 时一次性从底层 IFLYAdData 解析并缓存所有字段，
///             之后全部只读、不可变；字符串字段均经过去首尾空白处理（空串归一为 nil）。
@interface IFLYNativeFeedAdData : NSObject

/// 底层原始广告数据。用于回查本模型未直接暴露的字段或透传给点击/监测链路。
@property (nonatomic, strong, readonly) IFLYAdData *rawAdData;
/// 推断出的素材类型，决定 imageURLs/imageSize 的取值口径，初始化后固定不变。
@property (nonatomic, assign, readonly) IFLYNativeFeedAdMaterialType materialType;
/// 广告模板 ID（透传 IFLYAdData.template_id），用于精细化区分模板样式。
@property (nonatomic, strong, readonly, nullable) NSNumber *templateId;
/// 广告创意 ID（已去首尾空白）。
@property (nonatomic, copy, readonly, nullable) NSString *creativeId;
/// 广告标题（已去首尾空白）。isMaterialComplete 要求标题非空。
@property (nonatomic, copy, readonly, nullable) NSString *title;
/// 广告描述（已去首尾空白，对应 IFLYAdData.desc）。
@property (nonatomic, copy, readonly, nullable) NSString *desc;
/// 广告正文内容（已去首尾空白，对应 IFLYAdData.content）。
@property (nonatomic, copy, readonly, nullable) NSString *content;
/// CTA 按钮文案（SDK 根据 action_type 归一："立即下载"或"查看详情"）。
@property (nonatomic, copy, readonly, nullable) NSString *actionText;
/// 应用名称（已去首尾空白，应用下载类广告）。
@property (nonatomic, copy, readonly, nullable) NSString *appName;
/// 品牌名称（已去首尾空白）。
@property (nonatomic, copy, readonly, nullable) NSString *brand;
/// 赞助商名称（已去首尾空白）。
@property (nonatomic, copy, readonly, nullable) NSString *sponsored;
/// 应用/广告主图标 URL（已去首尾空白，取自 IFLYAdData.icon.url）。
@property (nonatomic, copy, readonly, nullable) NSString *iconURL;
/// 广告来源图标 URL（已去首尾空白，用于展示"广告来源"角标图）。
@property (nonatomic, copy, readonly, nullable) NSString *adSourceIconURL;
/// 广告来源标记文字（已去首尾空白，如"广告"字样）。
@property (nonatomic, copy, readonly, nullable) NSString *adSourceMark;
/// 渲染所需图片 URL 列表（每项均已去首尾空白且非空）。
/// @discussion 取值随 materialType 变化：三图取 img1/img2/img3 中可用项；
///             视频取视频封面（videoCoverURL）单元素；单图取首张可用图片单元素；无图则为空数组。
/// @note 非空数组（nonnull），无可用图片时为空数组而非 nil。
@property (nonatomic, copy, readonly) NSArray<NSString *> *imageURLs;
/// 图片尺寸。三图场景优先取 img1 尺寸、退化到 img；其余场景取主图 img 尺寸；无有效尺寸为 CGSizeZero。
@property (nonatomic, assign, readonly) CGSize imageSize;
/// 视频地址（已去首尾空白，取自 IFLYAdData.video.url）。非空即视为视频信息流。
@property (nonatomic, copy, readonly, nullable) NSString *videoURL;
/// 视频封面图 URL（已去首尾空白，取自 IFLYAdData.img.url）。
@property (nonatomic, copy, readonly, nullable) NSString *videoCoverURL;
/// 视频时长，单位：秒（透传 IFLYAdData.video.duration）。
@property (nonatomic, strong, readonly, nullable) NSNumber *videoDuration;
/// 视频尺寸（取自 IFLYAdData.video 的宽高），无有效尺寸为 CGSizeZero。
@property (nonatomic, assign, readonly) CGSize videoSize;
/// 广告 eCPM/出价（透传 IFLYAdData.price，单位：元）。
@property (nonatomic, strong, readonly, nullable) NSNumber *ecpm;
/// 是否支持摇一摇交互。
/// @discussion 由 IFLYAdData.interact 推断：取值 2 或 4 时为 YES。当前 NativeFeed
/// 仅消费其中的摇一摇分量，不实现上滑手势。
@property (nonatomic, assign, readonly) BOOL hasShakeInteraction;

/// 通过底层广告数据生成统一自渲染信息流数据。
/// @param adData 底层广告数据模型，提供文案/图片/视频等原始字段。
/// @return 解析并缓存好各字段的不可变信息流数据实例。
/// @note 所有字段在此一次性解析；字符串经去首尾空白处理，空串归一为 nil。
- (instancetype)initWithAdData:(IFLYAdData *)adData;

/// 通过底层广告数据生成统一自渲染信息流数据，并指定是否来自 S2S Load。
/// @param adData 底层广告数据模型。
/// @param serverBiddingLoad YES 表示来自 S2S Load，外部可读 ecpm 固定为 0。
- (instancetype)initWithAdData:(IFLYAdData *)adData serverBiddingLoad:(BOOL)serverBiddingLoad;

/// 当前素材是否满足对应类型的最低渲染要求。
/// @return 标题非空且按 materialType 满足图片/视频齐备条件时返回 YES，否则 NO。
/// @discussion 视频需 videoURL 与 videoCoverURL 均非空；三图需 imageURLs ≥ 3；
///             单图需 imageURLs ≥ 1；Unknown 一律返回 NO。
- (BOOL)isMaterialComplete;

@end

NS_ASSUME_NONNULL_END
