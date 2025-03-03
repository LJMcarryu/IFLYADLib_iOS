//
//  IFLYAdConfig.h
//  IFLYADLib
//
//  Created by admin on 27.2.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFLYAdConfig : NSObject

/// 设置是否开启个性化推荐
/// - Parameter enabled: 是否开启个性化推荐
+ (void)setPersonalizedEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
