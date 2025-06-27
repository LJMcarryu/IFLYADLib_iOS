//
//  IFLYAdData.h
//  IFLYAdLib
//
//  Created by JzProl.m.Qiezi on 2016/12/19.
//  Copyright © 2016年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFLYAdHtmlData;
@class IFLYAdImgVoiceData;
@class IFLYAdAudioData;
@class IFLYAdVideoData;
@class IFLYAdMonitorData;

NS_ASSUME_NONNULL_BEGIN

@interface IFLYAdData : NSObject

@property (readonly, nonatomic, strong) NSNumber *template_id;
@property (readonly, nonatomic, strong) NSString *creative_id;
@property (readonly, nonatomic, strong) NSNumber *price;
@property (readonly, nonatomic, strong) NSString *deal_id;
@property (readonly, nonatomic, strong) IFLYAdHtmlData *html;
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img;
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img1;
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img2;
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *img3;
@property (readonly, nonatomic, strong) IFLYAdVideoData *video;
@property (readonly, nonatomic, strong) IFLYAdAudioData *audio;
/// 交互类型, 1:点击 2:点击+摇一摇 3:点击+上滑 4:点击+摇一摇+上滑
@property (readonly, nonatomic, strong) NSNumber *interact;
/// 点击类型, 0:区域可点 1:全屏可点
@property (readonly, nonatomic, strong) NSNumber *click_type;
/// 摇一摇参数, acc:灵敏度 angle:旋转角度
@property (readonly, nonatomic, strong) NSDictionary *shake_info;
@property (readonly, nonatomic, strong) NSString *title;
@property (readonly, nonatomic, strong) NSString *desc;
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *icon;
@property (readonly, nonatomic, strong) NSString *content;
@property (readonly, nonatomic, strong) NSString *ctatext;
@property (readonly, nonatomic, strong) NSString *app_name;
@property (readonly, nonatomic, strong) NSNumber *downloads;
@property (readonly, nonatomic, strong) NSString *rating;
@property (readonly, nonatomic, strong) NSString *app_download_url;
@property (readonly, nonatomic, strong) NSString *app_intro_url;
@property (readonly, nonatomic, strong) NSString *app_ver;
@property (readonly, nonatomic, strong) NSNumber *app_size;
@property (readonly, nonatomic, strong) NSString *phone;
@property (readonly, nonatomic, strong) NSNumber *likes;
@property (readonly, nonatomic, strong) NSNumber *original_price;
@property (readonly, nonatomic, strong) NSNumber *current_price;
@property (readonly, nonatomic, strong) NSString *sponsored;
@property (readonly, nonatomic, strong) NSString *address;
@property (readonly, nonatomic, strong) NSString *app_id;
@property (readonly, nonatomic, strong) NSString *package_name;
@property (readonly, nonatomic, strong) NSString *brand;
@property (readonly, nonatomic, strong) NSArray *display_labels;
@property (readonly, nonatomic, strong) IFLYAdImgVoiceData *voice_ad;
@property (readonly, nonatomic, strong) NSString *close_icon;
@property (readonly, nonatomic, strong) IFLYAdMonitorData *monitor;
@property (readonly, nonatomic, strong) NSString *deeplink;
@property (readonly, nonatomic, strong) NSString *landing;
@property (readonly, nonatomic, strong) NSString *action_type;
@property (readonly, nonatomic, strong) NSString *ad_source_icon;
@property (readonly, nonatomic, strong) NSString *ad_source_mark;
@property (readonly, nonatomic, strong) NSDictionary *ext;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
