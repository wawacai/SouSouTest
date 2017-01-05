//
//  ISIDCardReaderController.h
//  ISIDReaderPreviewSDK
//
//  Created by Felix on 15/5/11.
//  Copyright (c) 2015年 IntSig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>
#import <CoreMedia/CoreMedia.h>

extern NSString *const kCardItemName;//姓名
extern NSString *const kCardItemGender;//性别
extern NSString *const kCardItemNation;//民族
extern NSString *const kCardItemBirthday;//出生日期
extern NSString *const kCardItemAddress;//住址
extern NSString *const kCardItemIDNumber;//号码
extern NSString *const kCardItemIssueAuthority;//签发机关
extern NSString *const kCardItemValidity;//有效期限

extern NSString *const kIDCardNumberPointsInOriginImage;//身份证号码在原图中的四个坐标点，分别为：左上、右上、右下、左下
extern NSString *const kIDCardNumberRectInCroppedImage;//身份证号码在切边后的图中所在矩形框
extern NSString *const kIDCardNumberImage;//身份证号码截图

extern NSString *const kIDCardImageCompletenessType;//身份证完整的状态
extern NSString *const kIDCardColorImage;//身份证是否为彩色图

typedef NS_ENUM(NSInteger, ISIDCardImageCompletenessType)
{
    ISIDCardImageCompletenessTypeComplete = 1,//质量完好
    ISIDCardImageCompletenessTypeImageCover = -1,//图像有遮挡
    ISIDCardImageCompletenessTypePhotoCover = -2,//正面人物头像质量不好
    ISIDCardImageCompletenessTypeNationalEmblemCover = -3,//反面国徽有遮挡
};

typedef void(^ConstructResourcesFinishHandler)(ISOpenSDKStatus status);
typedef void(^DetectCardFinishHandler)(int result, NSArray *borderPointsArray);
typedef void(^RecognizeCardFinishHandler)(NSDictionary *cardInfo);

@interface ISIDCardReaderController : NSObject<ISPreviewSDKProtocol>

+ (ISIDCardReaderController *)sharedISOpenSDKController;

- (ISOpenSDKCameraViewController *)cameraViewControllerWithAppkey:(NSString *)appKey
                                                        subAppkey:(NSString *)subAppKey;

- (void)constructResourcesWithAppKey:(NSString *)appKey
                           subAppkey:(NSString *)subAppKey
                       finishHandler:(ConstructResourcesFinishHandler)handler;

- (ISOpenSDKStatus)detectCardWithOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                           cardRect:(CGRect)rect//rect should be a golden rect for credit cards that are shaped with its proportions
                            detectCardFinishHandler:(DetectCardFinishHandler)detectCardFinishHandler
                         recognizeCardFinishHandler:(RecognizeCardFinishHandler)recognizeFinishHandler;

- (void)destructResources;

@end
