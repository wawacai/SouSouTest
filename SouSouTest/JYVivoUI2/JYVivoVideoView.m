//
//  JYVivoVideoVIew.m
//  JYVivoUI
//
//  Created by jock li on 15/1/19.
//  Copyright (c) 2015年 timedge. All rights reserved.
//

#import "JYVivoVideoView.h"
#import <AVFoundation/AVFoundation.h>

@implementation JYVivoVideoView

+(Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    self.clipsToBounds = YES;
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer*)[self layer];
    switch (contentMode)
    {
        case UIViewContentModeScaleAspectFill:
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case UIViewContentModeScaleToFill:
            layer.videoGravity = AVLayerVideoGravityResize;
            break;
        default:
            layer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
    }
}

@end
