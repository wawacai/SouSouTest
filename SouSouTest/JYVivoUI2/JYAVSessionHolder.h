//
//  JYAVSessionHolder.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/24.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ISOpenSDKFoundation/ISOpenSDKFoundation.h"
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>



@class JYVivoVideoView;
@class JYVivoResult;

// 一般拍照回调函数
typedef void(^JYPictureTaked)(NSURL* savedUrl);

// 自拍检测回调函数
typedef void (^JYCheckSelfPhotoBlock)(int photoType);

// 内部调试处理回调
typedef void(^JYDebugCall)(id some);

// 活体检测状态回调协议声明
@protocol JYActionDelegate <NSObject>

@required

// 接收单个动作检测状态
-(void)actionCheckCompleted:(BOOL)success;

// 接收最终检测状态
-(void)actionFinishCompleted:(BOOL)success;

@optional

// 接收需要执行指令动作
-(void)requestActionType:(int)actionType;
// 接收需要执行动作次数
-(void)requestActionCount:(int)actionCount;
// 接收当前动作幅度
-(void)responseActionRange:(int)actionRange;
// 接收总成功次数
-(void)responseTotalSuccessCount:(int)count;
// 接收总失败次数
-(void)responseTotalFailCount:(int)count;
// 接收可用时间
-(void)responseClockTime:(int)time;
// 接收动作完成的次数
-(void)responseDoneOperationCount:(int)count;
// 接收动作完成的幅度
-(void)responseDoneOperationRange:(int)range;
// 接收信息提示
-(void)responseHintMsg:(int)hint;




@end

// 用于保存一个摄像头相关会话，用于在会话过程中共享会话上下文
@interface JYAVSessionHolder : NSObject

@property AVCaptureSession* session;

// 项目名称
@property (readonly) NSString* projectName;
// 库版本
@property (readonly) NSString* libVersion;
// 保存的图片数
@property int savePhotoNum;
// 服务的地址
@property NSString* serviceUrl;


// 获取共享会话上下文
+(JYAVSessionHolder*)instance;

@property IBOutlet JYVivoVideoView* videoView;
// 当前使用的摄像头方向
@property AVCaptureDevicePosition devicePosition;

@property (readonly) JYVivoResult* result;

// 新加



-(void)stop2;

// 开始摄像头相关会话
-(void)start;
// 停止摄像头相关会话
-(void)stop;
// 进行一次自动对焦
-(void)autoFocus;
// 进行一次拍照
-(void)takePicture:(JYPictureTaked)taked;
// 开始自拍检测
-(void)beginCheckSelfPhoto:(JYCheckSelfPhotoBlock)result;
// 停止自拍检测
-(void)endCheckSelfPhoto;
// 开始活体检测
-(void)beginActionCheck:(id<JYActionDelegate>)delegate;
// 停止活体检测
-(void)endActionCheck;

// 调试用方法，返回灰度值
-(void)debugGrayImage:(JYDebugCall) callback;


@end
