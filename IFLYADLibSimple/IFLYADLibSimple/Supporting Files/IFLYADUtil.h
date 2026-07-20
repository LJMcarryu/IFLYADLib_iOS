//
//  IFLYADUtil.h
//  IFLYADLibSimple
//
//  Created by admin on 6.3.25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IFLYAdError;
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
+ (void)loadImageWithURLString:(NSString *)urlString
                    completion:(void (^)(UIImage *_Nullable image, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
