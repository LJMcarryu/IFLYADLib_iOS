//
//  IFLYXCodeChineseLog.m
//
//  Created by Jimmy on 2020/11/13.
//  Copyright © 2020 jimmy. All rights reserved.
//

#import "IFLYXCodeChineseLog.h"
#import <objc/runtime.h>

static inline void IFLY_swizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation NSString (IFLYXCodeChineseLog)

- (NSString *)stringByReplaceUnicode {
    NSMutableString *convertedString = [self mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];

    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
}

@end

@implementation NSArray (IFLYXCodeChineseLog)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        IFLY_swizzleSelector(class, @selector(description), @selector(IFLY_description));
        IFLY_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(IFLY_descriptionWithLocale:));
        IFLY_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(IFLY_descriptionWithLocale:indent:));
    });
}

- (NSString *)IFLY_description {
    return [[self IFLY_description] stringByReplaceUnicode];
}

- (NSString *)IFLY_descriptionWithLocale:(nullable id)locale {
    return [[self IFLY_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)IFLY_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [[self IFLY_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end

@implementation NSDictionary (IFLYXCodeChineseLog)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        IFLY_swizzleSelector(class, @selector(description), @selector(IFLY_description));
        IFLY_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(IFLY_descriptionWithLocale:));
        IFLY_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(IFLY_descriptionWithLocale:indent:));
    });
}

- (NSString *)IFLY_description {
    return [[self IFLY_description] stringByReplaceUnicode];
}

- (NSString *)IFLY_descriptionWithLocale:(nullable id)locale {
    return [[self IFLY_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)IFLY_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [[self IFLY_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end

@implementation NSSet (IFLYXCodeChineseLog)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        IFLY_swizzleSelector(class, @selector(description), @selector(IFLY_description));
        IFLY_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(IFLY_descriptionWithLocale:));
        IFLY_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(IFLY_descriptionWithLocale:indent:));
    });
}

- (NSString *)IFLY_description {
    return [[self IFLY_description] stringByReplaceUnicode];
}

- (NSString *)IFLY_descriptionWithLocale:(nullable id)locale {
    return [[self IFLY_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)IFLY_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [[self IFLY_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end
