//
//  IFLYAdConfig.h
//  IFLYADLib
//
//  Created by admin on 27.2.25.
//
// SDK 全局配置门面：以类方法形式提供个性化配置状态记录与日志开关，无需实例化。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 讯飞广告 SDK 全局配置。
/// @discussion 提供 SDK 级别的全局配置项，如个性化配置状态记录、日志开关等。
///             所有配置方法均为类方法，应在广告请求发起前调用。
@interface IFLYAdConfig : NSObject

/// 设置个性化配置状态。
/// @param enabled @c YES 表示开启（默认），@c NO 表示关闭。
/// @discussion 当前版本仅记录该状态，便于接入方按自身合规流程保存选择；不会过滤或改写
///             IDFA、CAID、UA、设备信息、广告请求字段、广告填充、展示、点击、监测或竞价行为。
+ (void)setPersonalizedEnabled:(BOOL)enabled;

/// 当前个性化配置状态。
/// @return @c YES 表示开启，@c NO 表示关闭。
/// @note 返回的是进程内记录值，不代表 SDK 已执行真实个性化关闭逻辑。
+ (BOOL)isPersonalizedEnabled;

/// 设置是否开启 SDK 日志输出
/// @param enabled @c YES 开启日志输出，@c NO 关闭（默认值取决于构建模式：Debug 默认开启，Release 默认关闭）
/// @discussion 在 Release 构建中调用 @c setLogEnabled:YES 可强制开启日志，用于线上问题排查。
///             日志内容通过 NSLog 输出到 Xcode Console / 系统日志。
///             Release 构建即使开启日志，也不会输出 Debug 级日志和完整请求/响应 JSON。
///             建议仅在排查问题时临时开启，正式发布时关闭。
+ (void)setLogEnabled:(BOOL)enabled;

/// 当前日志是否开启
/// @return @c YES 表示日志开启，@c NO 表示关闭。
/// @note 返回值即进程内全局开关的实时状态，受 @c setLogEnabled: 影响；
///       未调用过 @c setLogEnabled: 时取构建模式默认值（Debug=YES / Release=NO）。
+ (BOOL)isLogEnabled;

@end

NS_ASSUME_NONNULL_END
