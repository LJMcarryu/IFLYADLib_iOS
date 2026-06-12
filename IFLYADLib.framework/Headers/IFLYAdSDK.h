#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// SDK 级能力入口。
@interface IFLYAdSDK : NSObject

/// 生成 S2S 服务端竞价 SDK token。
/// @param adUnitId 广告位 ID。
/// @param error 失败时返回 NSError，code 对齐 IFLYAdErrorCode。
/// @return 成功时返回 URL-safe Base64 且无 padding 的 token。
+ (nullable NSString *)getSdkTokenWithAdUnitId:(NSString *)adUnitId error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
