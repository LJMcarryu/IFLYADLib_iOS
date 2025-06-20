////
////  IFLYCustomConfigAdapter.m
////  IFLYADLibSimple
////
////  Created by admin on 4.3.25.
////
//
//#import <IFLYADLib/IFLYADLib.h>
//#import "IFLYCustomConfigAdapter.h"
//
//@implementation IFLYCustomConfigAdapter
//
///// 该自定义adapter是基于哪个版本实现的，填写编写时的最新值即可，GroMore会根据该值进行兼容处理
//- (BUMCustomAdapterVersion *)basedOnCustomAdapterVersion {
//    return BUMCustomAdapterVersion1_1;
//}
//
///// adn初始化方法
///// @param initConfig 初始化配置，包括appid、appkey基本信息和部分用户传递配置
//- (void)initializeAdapterWithConfiguration:(BUMSdkInitConfig *_Nullable)initConfig {
////    [BUAdSDKManager setSecretKey:initConfig.appKey];
//}
//
///// adapter的版本号
//- (NSString *_Nonnull)adapterVersion {
//    return [IFLYAdTool sdkVersion];
//}
//
///// adn的版本号
//- (NSString *_Nonnull)networkSdkVersion {
//    return [BUAdSDKManager SDKVersion];
//}
//
///// 隐私权限更新，用户更新隐私配置时触发，初始化方法调用前一定会触发一次
//- (void)didRequestAdPrivacyConfigUpdate:(NSDictionary *)config {
////    [[BUAdSDKConfiguration configuration] setPrivacyProvider:self];
//}
//
///// 用于统计adn的初始化相关信息，结构是字典，例：@{"status":@(YES),@"duration":@(200)}
///// 其中status代表初始化结果，YES成功，NO失败；duration代表耗时，单位是ms。
//- (nonnull NSMutableDictionary *)adnInitInfo {
//    return [NSMutableDictionary dictionaryWithDictionary:@{ @"status": @(YES), @"duration": @(200) }];
//}
//
//- (void)didReceiveConfigUpdateRequest:(nonnull BUMUserConfig *)config {
//}
//
//@end
