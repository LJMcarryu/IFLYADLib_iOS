//
//  IFLYADUtil.m
//  IFLYADLibDemo
//
//  Created by admin on 6.3.25.
//

#import "IFLYADUtil.h"

@implementation IFLYADUtil

+ (UIButton *)createADTypeButtonWithFrame:(CGRect)frame title:(NSString *)title target:(nullable id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    button.layer.cornerRadius = frame.size.height / 2;
    button.clipsToBounds = YES;

    return button;
}

@end
