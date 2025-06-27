//
//  IFLYADUtil.h
//  IFLYADLibDemo
//
//  Created by admin on 6.3.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFLYADUtil : NSObject

+ (UIButton *)createADTypeButtonWithFrame:(CGRect)frame title:(NSString *)title target:(nullable id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
