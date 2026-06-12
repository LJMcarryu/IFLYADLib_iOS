//
//  IFLYAdMonitorData.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/12/19.
//  Copyright © 2016年 iflytek. All rights reserved.
//
//  广告监测（监测上报）数据模型，对外公开头，属 API 契约。
//  承载服务端下发的各类广告事件第三方监测 URL，由 SDK 在对应事件发生时回传上报。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告监测数据模型，包含各类广告事件的第三方监测 URL
/// @discussion 模型为只读不可变：所有属性经 -initWithDic: 一次性从服务端响应字典解析填充，
/// 之后不再变更。解析对字段类型严格校验，类型不符或字段缺失的属性将为 nil（详见各属性说明）。
/// @note 数组类型属性中的元素均为 NSString（监测 URL）；字段缺失或类型不符时该属性为 nil（而非空数组）。
@interface IFLYAdMonitorData : NSObject

/// 曝光监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *impress_urls;
/// 点击监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *click_urls;
/// 通用监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *general_monitor_urls;
/// DeepLink 已安装监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *app_installed_urls;
/// DeepLink 未安装监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *app_uninstalled_urls;
/// DeepLink 调起成功监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *app_invoke_success_urls;
/// DeepLink 调起失败监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *app_invoke_failed_urls;
/// 竞价胜出通知 URL（RTB 实时竞价场景）
/// @note 类型为 NSString（非数组）；服务端字段非字符串或缺失时为 nil。
@property (readonly, nonatomic, strong) NSString *win_notice_url;
/// 下载开始监测 URL 数组（应用下载类广告）
@property (readonly, nonatomic, strong) NSArray *download_start_urls;
/// 下载完成监测 URL 数组（应用下载类广告）
@property (readonly, nonatomic, strong) NSArray *download_complete_urls;
/// 安装开始监测 URL 数组（应用下载类广告）
@property (readonly, nonatomic, strong) NSArray *install_start_urls;
/// 安装完成监测 URL 数组（应用下载类广告）
@property (readonly, nonatomic, strong) NSArray *install_complete_urls;
/// 视频开始播放监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *start_urls;
/// 视频播放至 25% 监测 URL 数组（VAST 标准 firstQuartile）
@property (readonly, nonatomic, strong) NSArray *first_quartile_urls;
/// 视频播放至 50% 监测 URL 数组（VAST 标准 midpoint）
@property (readonly, nonatomic, strong) NSArray *mid_point_urls;
/// 视频播放至 75% 监测 URL 数组（VAST 标准 thirdQuartile）
@property (readonly, nonatomic, strong) NSArray *third_quartile_urls;
/// 视频播放完成监测 URL 数组（VAST 标准 complete，即 100%）
@property (readonly, nonatomic, strong) NSArray *complete_urls;
/// 视频暂停监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *pause_urls;
/// 视频恢复播放监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *resume_urls;
/// 视频播放错误监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *error_urls;
/// 视频跳过监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *skip_urls;
/// 静音监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *mute_urls;
/// 取消静音监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *unmute_urls;
/// 视频重播监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *replay_urls;
/// 关闭视频广告监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *close_linear_urls;
/// 进入全屏监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *fullscreen_urls;
/// 退出全屏监测 URL 数组
@property (readonly, nonatomic, strong) NSArray *exit_fullscreen_urls;
/// 扩展信息字典
/// @note 服务端字段非字典或缺失时为 nil。
@property (readonly, nonatomic, strong) NSDictionary *ext;

/// 通过字典初始化监测数据模型
/// @param dic 监测数据字典（来源于服务端响应）。允许传入非 NSDictionary：此时各属性均保持 nil，仅返回空实例。
/// @return 监测数据实例（始终非 nil；解析失败仅表现为属性为 nil，不返回 nil 实例）。
/// @note 解析按字段类型严格过滤——数组字段仅保留其中的 NSString 元素，URL 字段仅接受 NSString，ext 仅接受
/// NSDictionary，不符则对应属性为 nil。
- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
