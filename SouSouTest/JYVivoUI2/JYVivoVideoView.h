//
//  JYVivoVideoVIew.h
//  JYVivoUI
//
//  Created by jock li on 15/1/19.
//  Copyright (c) 2015年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

/**
 用于显示摄像回放的视图
 */
@interface JYVivoVideoView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
