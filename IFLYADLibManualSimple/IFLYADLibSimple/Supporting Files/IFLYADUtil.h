//
//  IFLYADUtil.h
//  IFLYADLibSimple
//
//  Created by admin on 6.3.25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IFLYAdError;
@class IFLYAdBase;
@class IFLYAdRequestConfig;

NS_ASSUME_NONNULL_BEGIN

@interface IFLYADUtil : NSObject

+ (UIButton *)createADTypeButtonWithFrame:(CGRect)frame
                                    title:(NSString *)title
                                   target:(nullable id)target
                                   action:(SEL)action;
+ (UIButton *)createSmallButtonWithTitle:(NSString *)title
                                   color:(UIColor *)color
                                  target:(nullable id)target
                                  action:(SEL)action;
+ (UILabel *)createSectionTitleWithText:(NSString *)text frame:(CGRect)frame;
+ (UITextView *)createLogTextViewWithFrame:(CGRect)frame;
+ (UIColor *)demoSecondaryLabelColor;
+ (UIColor *)demoIndigoColor;
+ (UIColor *)demoTealColor;
+ (void)appendLog:(NSString *)text toTextView:(UITextView *)textView;
+ (IFLYAdRequestConfig *)mediaSampleRequestConfig;
+ (NSString *)summaryForError:(nullable IFLYAdError *)error;
/// 返回 SDK 6.1.0 统一竞价对象中的 price；尚未加载或服务端未下发时返回 -1。
+ (double)priceForAd:(nullable IFLYAdBase *)ad;
+ (void)loadImageWithURLString:(NSString *)urlString
                    completion:(void (^)(UIImage *_Nullable image, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
