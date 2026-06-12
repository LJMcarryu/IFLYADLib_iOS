//
//  IFLYAdTool.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2020/4/8.
//  Copyright © 2020 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 图片下载完成回调
/// @param image    下载成功时返回的 UIImage 对象，失败时为 nil
/// @param error    下载失败时返回的错误信息，成功时为 nil
/// @param imageURL 图片的原始 URL 地址
typedef void (^IFLYAdToolImageCompletionBlock)(UIImage *image, NSError *error, NSURL *imageURL);

/// 广告 SDK 工具类
/// @discussion 提供图片处理、图片缓存/下载、SDK 版本查询等常用工具方法。
@interface IFLYAdTool : NSObject

#pragma mark - image tools

/// 生成高斯模糊扩展图片
/// @discussion 当原始图片高度不足目标高度时，在上下方向使用高斯模糊效果填充扩展区域，
///             使图片达到目标高度。适用于开屏广告素材需要适配全屏但原始素材不够高的场景。
///             当 originImage 为 nil 或其高度已大于等于 height 时，直接返回原图。
/// @param originImage 原始图片
/// @param height      目标图片高度（单位：pt）
/// @param radius      高斯模糊半径，数值越大模糊程度越强
/// @return 处理后的图片；若无需处理则返回原图
+ (UIImage *)gaussianBlurImage:(UIImage *)originImage withHeight:(CGFloat)height andRadius:(CGFloat)radius;

/// 下载指定 URL 的图片
/// @discussion 下载完成后，回调在主线程执行，可在回调中直接更新 UI。
///             下载成功的图片会自动写入 SDK 图片缓存。
/// @param url             图片的 URL 地址字符串
/// @param completionBlock 下载完成回调
/// @note 当 url 为空字符串或 nil 时，仍会在主线程以全 nil 参数（image/error/imageURL 均为 nil）触发一次回调。
+ (void)downloadImageFromURL:(NSString *)url completed:(IFLYAdToolImageCompletionBlock)completionBlock;

/// 获取当前 SDK 版本号
/// @return 版本号字符串，格式为语义化版本，如 @c @"6.0.0"
+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
