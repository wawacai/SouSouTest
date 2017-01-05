//
//  JYAVSessionHolder.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/24.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "JYAVSessionHolder.h"
#import "FaceModuleHead.h"
#import "JYDefines.h"
#import "JYVivoVideoView.h"
#import "JYVivoResult.h"
#import "UIImage+Tools.h"
#import "idCardAdoptMode.h"
#import "JYResource.h"




#define LIB_TEXTINFO_SIZE 50

#define BYTE unsigned char


#define RGB2GRAY(r,g,b) ((((b)*117 + (g)*601 + (r)*306) >> 10) & 255)

//取照区域
#define IDCARD_RECT_1 (self.mode.numberOne == 0 && n>209&&n<299  &&  m>245&&m<316  &&  p>251&&p<347  &&  q>290&&q<370)

#define IDCARD_RECT_2 (self.mode.numberOne != 0 &&  n>145&&n<203  &&  m>239&&m<321  &&  p>209&&p<245  &&  q>290&&q<370)

#define IDCARD_RECT_3 (number == 0  &&  n>145&&n<203  &&  m>239&&m<321  &&  p>209&&p<245  &&  q>291&&q<367)



#define CAN_GET_PHOTOS (ntmp == 2)


//返回的是哪种调用
#define GET_HINT                    ((feature & 1)   > 0)
#define GET_TARGET_OPERATION_COUNT  ((feature & 2)   > 0)
#define GET_TARGET_OPERATION_ACTION ((feature & 4)   > 0)
#define ACTION_CHECK_COMPLETED      ((feature & 8)   > 0)
#define GET_TOTAL_SUCCESS_COUNT     ((feature & 16)  > 0)
#define GET_TOTAL_FAIL_COUNT        ((feature & 32)  > 0)
#define GET_COUNT_CLOCK_TIME        ((feature & 64)  > 0)
#define GET_DONE_OPERATION_COUNT    ((feature & 128) > 0)
#define GET_DONE_OPERATION_RANGE    ((feature & 256) > 0)
#define IS_FINISH_BODY_CHECK        ((feature & 512) > 0)



static void * ICP_CapturingStillImageContext = &ICP_CapturingStillImageContext;
static void * ICP_SessionRunningAndDeviceAuthorizedContext = &ICP_SessionRunningAndDeviceAuthorizedContext;//授权

@interface JYAVSessionHolder () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    __weak JYVivoVideoView* _videoView;
    JYPictureTaked _pictureTaked;
    JYCheckSelfPhotoBlock _selfPhotoChecked;//自拍检测的回调
    id<JYActionDelegate> _actionDelegate;
    AVCaptureDevicePosition _devicePosition;
    
    int videoWidth;
    int videoHeight;
    
    BOOL _libInited; // 是否已经调用 JYInit();
    BOOL _libVersionCalled; // 是否已经调用 getVersion();.a中获取版本信息的方法
    BOOL _libSelfPhotoSetted; // 是否已经调用 setSelfPhotoJpgBuffer()
    NSString* _projectName;  //项目名称
    NSString* _libVersion;  //版本号
    int _libLastError;
    BOOL _frameProcessing;
    NSDate *_lastTickTime;
    
    JYDebugCall _debugGrayImage;
    NSData* _jpgData;
    NSData* _jpgIDPhotoData;
    JYVivoResult *_result;
}


// Capture Session 管理
@property (nonatomic) dispatch_queue_t sessionQueue; //线程
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;//输入流对象
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;//照片输出流
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;//获取实时数据流（视频音频）



@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;

@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;

@property (nonatomic) BOOL capturing; //是否正在捕捉

@property (nonatomic,strong) idCardAdoptMode *mode;

@property (nonatomic,weak) NSTimer *timer;


@property (nonatomic, strong) AVAudioPlayer* adoptPlayer;//成功获取的声音


@property (nonatomic, copy) NSData* IDPhotoImageData;//存身份证

@end

static JYAVSessionHolder *s_instance = nil;

@implementation JYAVSessionHolder



static bool focusing = NO;  //是否在聚焦
static void *pxdata;        //避免内存泄漏图片指针
static bool cardIng = NO;   //是否正在取身份证照片
static int ntmp = 0;        //用来记录已经聚焦过后第二次的图片




+(id)alloc
{
    if (s_instance)
    {
        return s_instance;
    }
    
//    //到线程中执行
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
//                   {
//                       //#error Please fill in your appKey
//                       NSString *appKey = @"RT3F0dL85ey5bRUfPHf9Jhff"; //设置app key
//                       NSString *subAppkey = nil;//reserved for future use
//                       [[ISIDCardReaderController sharedISOpenSDKController] constructResourcesWithAppKey:appKey subAppkey:subAppkey finishHandler:^(ISOpenSDKStatus status) {
//                           if(status == ISOpenSDKStatusSuccess)
//                           {
//                               NSLog(@"成功:%ld",(long)status);
//                           }
//                           else
//                           {
//                               NSLog(@"失败:%ld",(long)status);
//                           }
//                       }];
//                   });
    
    
    return s_instance = [super alloc];
}

//01初始化方法
+(JYAVSessionHolder*)instance
{
    if (s_instance == nil)
    {
        s_instance = [JYAVSessionHolder new];
    }
    

    
    
    return s_instance;
}


//返回视频的控件
-(JYVivoVideoView*)videoView
{
    return _videoView;
}


-(void)setVideoView:(JYVivoVideoView *)videoView
{
    _videoView = videoView;
    _videoView.session = _session;
    
}


-(AVCaptureDevicePosition)devicePosition
{
    return _devicePosition;
}

//设置配置
-(void)setDevicePosition:(AVCaptureDevicePosition)devicePosition
{
    if (_devicePosition != devicePosition)
    {
        _devicePosition = devicePosition;
        
        if (_session.isRunning)//如果正在运行
        {
            [_session beginConfiguration];//开始配置输入输出
        }
        
        if (_videoDeviceInput)//如果存在
        {
            [_session removeInput:_videoDeviceInput];//删除
        }
        NSError *error;
        
        AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:_devicePosition];//获取摄像头的媒体设备的方向
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];//创建适应方向的摄像头的输入流对象
        
        if (error)
        {
            NSLog(@"切换视频输入设备失败\n%@", [error localizedDescription]);
        }
        
        if ([_session canAddInput:videoDeviceInput])//如果可以将输入流对象添加到输入输出流
        {
            [_session addInput:videoDeviceInput];//添加输入流
            
            [self setVideoDeviceInput:videoDeviceInput];
        }
        if (_session.isRunning)//如果输入输出在运行
        {
            [_session commitConfiguration];//提交配置（配置设置完毕，启用）
        }
    }
}

//开始运行
-(void)start {
    _result = nil;
    
    if (_session == nil)//如果输入输出为空
    {
        _session = [AVCaptureSession new];//创建一个输入输出赋值给自己
        [self initSession];//
        return;
    }
    
    if (_videoView != nil)
    {
        [_videoView setSession:_session];
    }
    
    if (!self.session.isRunning)
    {
        [self.session startRunning];
    }
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    self.mode = mode;
    

    //定时器
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(isFocusing) userInfo:nil repeats:YES];
    self.timer = timer;
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStop) name:@"timerStop" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStart) name:@"timerStart" object:nil];
    
    
    self.adoptPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"takephoto" withExtension:@"wav"] error:nil];//音频赋值
    
    [self.adoptPlayer prepareToPlay];//准备播放

}

//定时器停止
-(void)timerStop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer invalidate];
    });
}

//定时器开始
-(void)timerStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(isFocusing) userInfo:nil repeats:YES];
        self.timer = timer;
    
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
        [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    
        self.mode.adopt = NO;
        self.mode.photoGraph = NO;
        cardIng = NO;
        focusing = YES;
    
        [self.timer fire];
        
    });
}


//_session停止
-(void)stop {
    if (_session)
    {
        self.IDPhotoImageData = nil;
        
        [_session stopRunning];
    }
    [self libUnInit];
    
    _jpgData = nil;
    _jpgIDPhotoData = nil;
    _libSelfPhotoSetted = NO;
    
    self.mode.adopt = NO;
    self.mode.photoGraph = NO;
    cardIng = NO;
    focusing = YES;
    [self.timer invalidate];
}

//停止后，还原所有开关与定时器
-(void)stop2
{
    self.mode.adopt = NO;
    self.mode.photoGraph = NO;
    cardIng = NO;
    focusing = YES;
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//设置输入输出流
-(void)initSession
{
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);//创建一个GCD队列
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{//在队列中运行
        
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];//后台运行
        
        [self.session beginConfiguration];//开始配置输入输出
        
        
        //[_session setSessionPreset:AVCaptureSessionPresetHigh];
        [_session setSessionPreset:JYVIDEO_PRESET];//设置摄像头的图片质量
        
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:ICP_SessionRunningAndDeviceAuthorizedContext];//观察者
        
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:ICP_CapturingStillImageContext];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:_devicePosition];//获取摄像头的媒体设备的方向
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];//创建摄像头的输入流
        
        if (error)
        {
            NSLog(@"初始化视频输入设备失败\n%@", [error localizedDescription]);
        }
        
        if ([_session canAddInput:videoDeviceInput])//如果可以添加输入流到输入输出
        {
            [_session addInput:videoDeviceInput];//添加输入流
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[[(AVCaptureVideoPreviewLayer *)[[self videoView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
                [[(AVCaptureVideoPreviewLayer *)[[self videoView] layer] connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            });
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];//设置输出流的视频解码和输出图片格式
            [_session addOutput:stillImageOutput];//添加图片输出到输入输出流
            [self setStillImageOutput:stillImageOutput];
        }
        
        
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];//创建视频输出流
        dataOutput.alwaysDiscardsLateVideoFrames = YES;//设置丢弃迟缓的视频
        if ([_session canAddOutput:dataOutput])//如果可以添加到输入输出流
        {
            dispatch_queue_t queue = dispatch_queue_create("outputQueue", NULL);//获取输出流的线程
            [dataOutput setSampleBufferDelegate:self queue:queue];//设置视频输出流的代理和运行的线程
            [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt: kCVPixelFormatType_32BGRA]}];
            
            if ( [_session canAddOutput:dataOutput] )//如果能加入输入输出流
            {
                [_session addOutput:dataOutput];//添加到输入输出流
                
                AVCaptureConnection* videoDataConnection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];//设置输出的格式为视频
                
                if (videoDataConnection.isVideoOrientationSupported)
                {
                    [videoDataConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                    //[videoDataConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                }
                
                [self setVideoDataOutput:dataOutput];//将适配输出流赋值给自己
            }
        } else
        {
            NSLog(@"未知错误，无法加入视频数据输出处理器。");
        }
        
        [self.session commitConfiguration];//提交配置（配置设置完毕，启用）
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self start];//到主线程中，开始运行
        });
    });
}

//KVO观察者必须实现的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == ICP_CapturingStillImageContext)
    {
        NSLog(@"ICP_CapturingStillImageContext changed");
    }
    else if (context == ICP_SessionRunningAndDeviceAuthorizedContext)
    {
        NSLog(@"ICP_SessionRunningAndDeviceAuthorizedContext changed");
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 对焦
-(void)autoFocus
{
    if (ntmp == 0)
    {
        CGPoint center = CGPointMake(.5, .5);//设置屏幕中心点
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:center monitorSubjectAreaChange:NO];//手动对焦
    }else
    {
        focusing = YES;
    }
}




//旋转
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}




// 拍照处理
-(void)takePicture:(JYPictureTaked)taked
{
    __weak typeof (self) weakSelf = self;
    
    if (weakSelf.capturing)
    {
        return;
    }
    if (![weakSelf.session isRunning])
    {
        return;
    }
    
    weakSelf.capturing = YES;
    _pictureTaked = taked;
    // 获取一张图片
    [[weakSelf stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[weakSelf stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {
        
        if (imageDataSampleBuffer)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            if (imageData)
            {
                weakSelf.IDPhotoImageData = imageData;
                
                UIImage *image = [UIImage imageWithData:imageData];
                
                image = [weakSelf imageOrientation:image rotation:UIImageOrientationLeft];//图片转向
                
                CGImageRef sourceImageRef = [image CGImage];
                
                NSLock *imageBufferLock = [[NSLock alloc] init];
                
                [imageBufferLock lock];
                
                CVPixelBufferRef imageBuffer = [weakSelf pixelBufferFromCGImage:(sourceImageRef)];//生成灰度值
                
                [imageBufferLock unlock];
                
                JYInit();
                
                CVPixelBufferLockBaseAddress(imageBuffer, 0);// 锁定buf的基地址
                
                SInputGrayBufInfo *bufInfo = [weakSelf createGrayBufInfo:imageBuffer];// 从buf生成灰度值信息的结构体//传imageBuffer进去了
                
                int n=0,m=0,p=0,q=0;
                
                int number = getFacePos(bufInfo, &n,  &m, &p , &q);
                
                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                
                imageBuffer = NULL;
                
                if (IDCARD_RECT_3)
                {
                    //拍照可以识别，拍照成功
                    weakSelf.mode.adopt = YES;
                    
                }else
                {
                    //识别不了
                    weakSelf.mode.adopt = NO;
                }
                JYUnInit();
                
                UIImage *tmpImage = [UIImage imageWithData:imageData];
                NSData *tmpImageData = UIImageJPEGRepresentation(tmpImage, 0.7);
                
                //保存照片到本地
                [weakSelf savePhotoToLocalWithData:tmpImageData];
            }
            if (pxdata)
            {
                free(pxdata);  //释放
                pxdata = NULL;
            }
            
            weakSelf.capturing = NO;
        }
    }];
}

//保存照片
-(void)savePhotoToLocalWithData:(NSData *)imageData
{
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDir stringByAppendingPathComponent:@"ICP_ID.JPG"];
    [self.IDPhotoImageData writeToFile:tmpPath atomically:NO];
    NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:tmpPath];//保存到本地
    _jpgIDPhotoData = imageData;//赋值本地url地址
    if (_pictureTaked)
    {
        _pictureTaked(fileUrl);
    }
}


- (UIImage *)imageOrientation:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newPic;
}





- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    __weak NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,frameSize.height, 8, 4*frameSize.width, rgbColorSpace,kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}


// 视频对焦锁定，自动，连续自动。视频捕捉曝光锁定，自动，连续自动。点。yes/no
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    //到线程中执行
    dispatch_async([self sessionQueue], ^{
         //获取输入设备
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        
        //如果呼叫成功并锁定，就可以控制摄像头
        if ([device lockForConfiguration:&error])
        {
            //判断是否支持控制对焦
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                //设置对焦模式
                [device setFocusMode:focusMode];
                //设置对焦点
                [device setFocusPointOfInterest:point];
            }
            //判断是否支持控制曝光(暂时关闭,报错）
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                //设置曝光模式
                [device setExposureMode:exposureMode];
                //设置曝光点
                [device setExposurePointOfInterest:point];
            }
            //设置可以监控是否移动，一旦有移动则会接收到通知
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            //关闭锁定摄像头
            [device unlockForConfiguration];
        }else
        {
            NSLog(@"%@", error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            focusing = YES;
        });
    });
}


//获取一个适用方向的媒体设备
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}


//申请一块内存，并返回一个char *指针指向这片内存
-(unsigned char*) grayBuffer
{
    static unsigned char *_grayBuffer; // 灰度值缓存
    if (_grayBuffer == NULL)//如果buf为空
    {
//        size_t size = sizeof(unsigned char) * 640 * 480;
        size_t size = sizeof(unsigned char) * 4000 * 4000;//获取char＊4000*4000的大小
        _grayBuffer = (unsigned char*)malloc(size);//申请空间
        memset(_grayBuffer, 0, size);//将这块内存置0
    }
    return _grayBuffer;//返回这个内存指针
}


-(void)convertGrayBuffer:(BYTE*)grayBuffer byBGRABuffer:(BYTE*)colorBuffer width:(size_t*)w height:(size_t*)h {
    if ( 0 == colorBuffer )
        return;
    if ( 0 == grayBuffer )
        return;
    BYTE b,g,r;//三个数,
    if (*w > *h) {//如果宽大于高
        // 需要旋转 90 度
        for (size_t y = 0; y < *h; y++)
        {
            for (size_t x = 0; x < *w; x++)
            {
                b = *colorBuffer++;
                g = *colorBuffer++;
                r = *colorBuffer++;
                colorBuffer++;
                *(grayBuffer + x*(*h) + y) = RGB2GRAY(r,g,b);
            }
        }
        size_t t = *w;
        *w = *h;
        *h = t;
    } else {
        size_t size = *w * *h;
        for (size_t i = 0; i<size; i++) {
            b = *colorBuffer++;
            g = *colorBuffer++;
            r = *colorBuffer++;
            colorBuffer++;
        
            *grayBuffer++ = RGB2GRAY(r,g,b);
        }
    }
}

// 从buf生成灰度值信息的结构体
-(SInputGrayBufInfo*)createGrayBufInfo:(CVImageBufferRef)imageBuffer
{
    static SInputGrayBufInfo *pGrayBufInfo = NULL;//创建灰度值的结构体，包括灰度值,图片宽，高
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);// 锁定buf的基地址
    unsigned char *grayBuffer = [self grayBuffer];//获取灰度值
    size_t width = CVPixelBufferGetWidth(imageBuffer);//获取宽度
    size_t height = CVPixelBufferGetHeight(imageBuffer);//获取高度
    
    
    videoWidth = (int)width;
    videoHeight = (int)height;
    
    //reference_convert(grayBuffer, (unsigned char *)baseAddress, (int)(width * height));
    
    [self convertGrayBuffer:grayBuffer byBGRABuffer:(BYTE*)baseAddress width:&width height:&height];
    
    if(pGrayBufInfo == NULL)//如果结构体为NULL
    {
        pGrayBufInfo = (SInputGrayBufInfo *)malloc(sizeof(SInputGrayBufInfo));//申请空间
    }
    pGrayBufInfo->pGrayBuf = grayBuffer;//给结构体赋值
    pGrayBufInfo->iWidth = (int)width;
    pGrayBufInfo->iHeight = (int)height;
    return pGrayBufInfo;//返回结构体
}


// 利用灰度图结构体，生成黑白图片
-(UIImage*)createGrayImage:(SInputGrayBufInfo*)pInfo
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();//
    CGContextRef context = CGBitmapContextCreate(pInfo->pGrayBuf, pInfo->iWidth, pInfo->iHeight, 8, pInfo->iWidth, colorSpace, 0);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:image];
}


// 从视频帧生成图片（彩色）
-(UIImage*)createImage:(CVImageBufferRef)imageBuffer
{
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);// 锁定buf的基地址
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);//得到buf的行字节数
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);// 得到buf的宽
    
    size_t height = CVPixelBufferGetHeight(imageBuffer);// 得到buf的高

    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用缓存的数据创建一个位图格式的图形上下文对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // 根据这个位图context中的像素数据创建一个CGimage对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //CGimage转UIimage
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];

    // 释放CGimage对象
    CGImageRelease(quartzImage);
    
    //返回UIimage对象
    return image;
}


// 从视频帧生成JPEG图片数据
-(NSData*)createJpgData:(CVImageBufferRef)imageBuffer
{
    return UIImageJPEGRepresentation([self createImage:imageBuffer], 0.8);//调用上面一个从视频生成照片的方法，然后压缩并转为JPEG格式，并返回
}


//获取图片
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    
    u_int8_t *baseAddress = (u_int8_t *)malloc(bytesPerRow*height);
    
    memcpy( baseAddress, CVPixelBufferGetBaseAddress(imageBuffer), bytesPerRow * height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    if (baseAddress)
    {
        free(baseAddress);
        baseAddress = NULL;
    }
    
    CGImageRelease(quartzImage);
    
    return (image);
}


-(void)isFocusing
{
    if (self.session.isRunning)
    {
        [self autoFocus];
    }
    
}

#define kMaxRange  120

#define BorderOriginY 60
#define BorderWidth 270
#define BorderHeight 428



#define ImageFrameWidth 640
#define ImageFrameHeight 480




//代理方法，获取帧数据
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    if (!_libInited || (_selfPhotoChecked == nil && _actionDelegate == nil))
    {
        return;
    }
    
    if ( _frameProcessing)  //如果正在获取帧数据，返回
    {
        return;
    }
    
    _frameProcessing = YES; //设为正在获取的状态
    
    NSDate *now = [NSDate date];//生成一个当下的时间
    
    if (_actionDelegate == nil && _lastTickTime && [now timeIntervalSinceDate:_lastTickTime] < SELF_CHECK_DELAY)//如果代理指针指向空，并且最后一个时间不为空，并且最后一个时间到现在的时间差值小于1秒
    {
        _frameProcessing = NO;//设置为不在获取的状态
        return;
    }
    _lastTickTime = now;// 设置最后一个时间为现在的时间
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);// 为媒体数据设置一个buf的Video图像缓存对象

    CVPixelBufferLockBaseAddress(imageBuffer, 0);// 锁定buf的基地址
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);// 得到指向buf指针
    
    size_t dataSize = CVPixelBufferGetDataSize(imageBuffer);// 得到buf的大小
    
    SInputGrayBufInfo *pGrayBufInfo = [self createGrayBufInfo:imageBuffer];// 从buf生成灰度值信息的结构体
    
    if (_debugGrayImage)
    {
        _debugGrayImage([self createGrayImage:pGrayBufInfo]);
    }
    
    if (_selfPhotoChecked && !_libSelfPhotoSetted && self.mode.severalController == 0) {//如果存在自拍的block回调对象，但是没有调用 setSelfPhotoJpgBuffer()是.a当中的方法并且正在环境检测的时候
        if(self.mode.libInit == 1)
        {
            //如果没有初始化就初始化
            [self libInit];
        }

        int result = checkSelfPhotoGrayBuffer(pGrayBufInfo);//检测自拍照上的人脸是否满足要求，是.a中的方法
        
        if (result<0)
        {
            //如果环境错误就反初始化再初始化
            [self libUnInit];
            
            [self libInit];
        }
        
        if(result == eCSPT_OK)//如果经过检测，人脸满足要求
        {
            NSData *jpgData = [self createJpgData:imageBuffer];//从视频帧生成JEPG的图片data
            if((_libLastError = setSelfPhotoJpgBuffer((unsigned char *)jpgData.bytes , (int)jpgData.length)) == 0) {//如果设置自拍照的图片buf成功
                _libSelfPhotoSetted = YES;//就设置成已经调用setSelfPhotoJpgBuffer()
                _jpgData = jpgData;//将自拍照的data赋值给自己
            } else
            {
                NSLog(@"** 错误 ** 调用 setSelfPhotoJpgBuffer 失败。 code: %d", _libLastError);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{//到主线程中
            if(_selfPhotoChecked){//自拍照的block的回调
                
                _selfPhotoChecked(result);
            }
        });
    }
    
    if (_actionDelegate && self.mode.severalController == 1)
    {
        SScrImgInfo srcImgInfo;//创建一个帧图结构体
        srcImgInfo.iBufSize = (int)dataSize;//将buf大小传入结构体
        srcImgInfo.pSrcImgBuf = (unsigned char*)baseAddress;//将图片的指针传入结构体
        int feature = putFeatureBuf(pGrayBufInfo, &srcImgInfo);//将灰度值结构体和帧图结构体传给.a文件
        
        if (feature > 0 && self.mode.severalController == 1) {//如果成功
            dispatch_async(dispatch_get_main_queue(), ^{//到主线程
                
                [self setFeature:feature];//将检查结果传递到代理
               
                //[_actionDelegate actionFinishCompleted:NO];//调用后结束
            });
        }
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    imageBuffer = NULL;
    if (baseAddress) {
        baseAddress = NULL;
    }
    
    
    _frameProcessing = NO;
}

//处理帧图
-(void)getOnePhotoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //获取的图片可以识别，成功
    self.mode.adopt = YES;
    
    [self.timer invalidate];
    
    NSData *idCardData = UIImagePNGRepresentation([self imageFromSampleBuffer:sampleBuffer]);
    
    UIImage *upImage = [UIImage imageWithData:idCardData];
    
    upImage = [self imageOrientation:upImage rotation:UIImageOrientationUp];
    
    idCardData =UIImageJPEGRepresentation(upImage,1);
    
    
    UIImage *image2 = [UIImage imageWithData:self.IDPhotoImageData];
    
    
    image2 = [UIImage imageWithCGImage:image2.CGImage scale:1 orientation:UIImageOrientationRight];
    
    NSData *image2Data =UIImagePNGRepresentation(image2);
    
    _jpgIDPhotoData = image2Data;//self.IDPhotoImageData;
    
    
    UIImage * tmp = [UIImage imageWithData:_jpgIDPhotoData];
    
    _jpgIDPhotoData = UIImageJPEGRepresentation(tmp,0.7);
    
    self.mode.idCardData = idCardData;
    
    ntmp = 0;
    
    [self.adoptPlayer play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoIsOk" object:self];//发送通知
}


//处理帧图
-(void)getTwoPhotoWithSamlpeBuffer:(CMSampleBufferRef)sampleBuffer
{
    self.mode.adopt = YES;
    
    [self.timer invalidate];
    
    NSData *idCardData = UIImagePNGRepresentation([self imageFromSampleBuffer:sampleBuffer]);
    
    UIImage *rightImage = [UIImage imageWithData:idCardData];
    
    rightImage = [self imageOrientation:rightImage rotation:UIImageOrientationRight];
    
    idCardData =UIImageJPEGRepresentation(rightImage,1);
    
    _jpgIDPhotoData = self.IDPhotoImageData;
    
    UIImage * tmp = [UIImage imageWithData:_jpgIDPhotoData];
    
    _jpgIDPhotoData = UIImageJPEGRepresentation(tmp,0.7);
    
    self.mode.idCardData = idCardData;
    
    ntmp = 0;
    
    [self.adoptPlayer play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoIsOk" object:self];//发送通知
}


//调用.a中的各种检测方法，并传递到代理
-(void) setFeature:(int)feature
{
    if (GET_HINT)
    {
        int hit = getHintMsg();//接收提示语
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(responseHintMsg:)])//如果代理实现了 接受信息提示 的方法
        {
            [_actionDelegate responseHintMsg:hit];//给代理传递 信息提示
        }
    }
    if (GET_TARGET_OPERATION_COUNT)
    {
        int count = getTargetOperationCount();//接收需要执行指令次数
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(requestActionCount:)])//如果代理实现了 接受执行指令次数 的方法
        {
            [_actionDelegate requestActionCount:count];//给代理传递 需要执行指令的次数
        }
    }
    if (GET_TARGET_OPERATION_ACTION)
    {
        int iAction = getTargetOperationAction();//接收需要执行指令动作
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(requestActionType:)])//如果代理实现了 接受执行指令动作 的方法
        {
            [_actionDelegate requestActionType:iAction];//给代理传递 需要执行的指令动作
        }
    }
    if (ACTION_CHECK_COMPLETED)
    {
        if(_actionDelegate)
        {
            [_actionDelegate actionCheckCompleted:iSOperationSuccess() == 0];//接收执行指令成功还是失败

        }
    }
    if (GET_TOTAL_SUCCESS_COUNT)
    {
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(responseTotalSuccessCount:)])//如果代理实现了 接受总成功次数 的方法
        {
            [_actionDelegate responseTotalSuccessCount:getTotalSuccessCount()];// 给代理传递 总成功次数
        }
    }
    if (GET_TOTAL_FAIL_COUNT)
    {
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(responseTotalFailCount:)])// 如果代理实现了 接收总失败次数 的方法
        {
            [_actionDelegate responseTotalFailCount:getTotalFailCount()];//给代理传递 总失败次数
            
        }
    }
    if (GET_COUNT_CLOCK_TIME)
    {
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(responseClockTime:)])//如果代理实现了 接收可用时间 的方法
        {
            [_actionDelegate responseClockTime:getCountClockTime()];//给代理传递 可用时间

        }
    }
    if (GET_DONE_OPERATION_COUNT)
    {
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(responseDoneOperationCount:)])//如果代理实现了 接收动作完成的次数 的方法
        {
            [_actionDelegate responseDoneOperationCount:getDoneOperationCount()];//给代理传递 接收动作完成的次数
        }
    }
    if (GET_DONE_OPERATION_RANGE)
    {
        if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(responseDoneOperationRange:)])// 如果代理实现了 接收某个动作完成幅度 的方法 (幅度为1-4)
        {
            [_actionDelegate responseDoneOperationRange:getDoneOperationRange()];//给代理传递 接收某个动作完成幅度（在创建对象的类中实现方法即可接收到传递的对象）
        }
    }
    if (IS_FINISH_BODY_CHECK)
    {
        int result = iSFinishBodyCheck();//获取到是否完成活体检测
        switch (result)
        {
            case 0://如果为0，代表通过检测
                [self buildResult:YES];
                [_actionDelegate actionFinishCompleted:YES];//通过代理，传递 最终检测状态为YES
                break;
            case 1:
                [self buildResult:NO];
                [_actionDelegate actionFinishCompleted:NO];//通过代理，传递 最终检测状态为NO
                break;
            default:
                break;
        }
    }
}


-(void)buildResult:(BOOL)success
{
    JYVivoResult *result = [JYVivoResult new];//创建一个模型，这个模型里面可以保存 打包上传的照片data, 是否已通过本地检测，以及证件照和自拍照。
    result.success = success;//设置模型中的值 是否通过本地检测
    result.jpgData = _jpgData;//设置模型中的值 自拍照片
    result.idJpgData = _jpgIDPhotoData;//设置模型中的值 身份证照片
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    mode.sceneData = _jpgData;
    
    
    if (success)//如果通过检测
    {
        int nums = getOFPhotoNum();//从.a得到采集到的最优人脸照片个数
        NSMutableArray *photos = [NSMutableArray new];//创建可变数组
        
        for (int i=0; i<nums; i++)
        {
            int iSize = getSrcImgBufferSize(i);//得到第i个最优人脸照片对应的大小
            unsigned char *pOut = (unsigned char *)malloc(iSize);//申请空间
            getSrcImgBuffer(i, pOut);//获取第i张最优人脸照的到pOut的空间中
            
            // 生成JPG图片
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//创建RGB的空间
            CGContextRef context = CGBitmapContextCreate(pOut, videoWidth, videoHeight, 8,
                                                         videoWidth * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);//生成位图
            CGImageRef quartzImage = CGBitmapContextCreateImage(context);//生成ref照片
            UIImage *image = [UIImage imageWithCGImage:quartzImage];//ref转image
            
            if (videoWidth > videoHeight)
            {
                image = [self imageOrientation:image rotation:UIImageOrientationRight];//图片转向
                
            }
            
            [photos addObject:image];//将图片添加到数组
            
            // 处理接口数据
            NSData *jpgData = UIImageJPEGRepresentation(image, 0.8); //将图片转jpeg并压缩
            
            CGImageRelease(quartzImage);//删除ref照片
            
            setPhotoJpgBuffer(i, (unsigned char*)jpgData.bytes, (int)jpgData.length);//将jpg照片设置到.a文件的第i张最优人脸照中
            if (pOut)
            {
                free(pOut);// 释放最优人脸照空间
                pOut = NULL;
            }
            
        }
        int iCSize = getDataBufferSize();// 获取data buffer的大小
        unsigned char *pData = (unsigned char *)malloc(iCSize); //申请空间
        getDataBuffer(pData);//获取data包
        
        mode.photos = photos;
        mode.packagedData = [NSData dataWithBytes:pData length:iCSize];
        
        result.photos = photos;
        result.packagedData = [NSData dataWithBytes:pData length:iCSize];
    }
    _result = result;
}


-(BOOL) updateUserDefaults:(void(^)(NSUserDefaults* userDefaults)) setters {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    setters(userDefaults);
    return [userDefaults synchronize];
}

//获取版本信息
-(void) readVersion
{
    if (!_libVersionCalled)
    {
        _libVersionCalled = YES;//设置成已经调用
        int p1, p2, p3, p4;
        BYTE *pTextInfo = (BYTE *)malloc(LIB_TEXTINFO_SIZE);//申请50的空间
        int result = getVersion(&p1, &p2, &p3, &p4, pTextInfo, LIB_TEXTINFO_SIZE);//调用.a的方法，获取版本信息
        if(result != 0) {
            NSLog(@"获取版本数据时失败，错误代码：%d", result);
            
            if (pTextInfo)
            {
                free(pTextInfo);//释放空间并返回
                pTextInfo = NULL;
            }
            return;
        }
        _libVersion = [NSString stringWithFormat:@"%d.%d.%d.%d", p1, p2, p3, p4];//拼接库版本号并赋值给自己
        _projectName = [NSString stringWithCString:(char*)pTextInfo encoding:NSUTF8StringEncoding];//将项目名称转义后赋值给自己
    }
}

// 获取项目名称
-(NSString*) projectName
{
    [self readVersion];//调用获取版本信息的方法
    return _projectName;//返回项目名称
}

// 获取库版本
-(NSString*) libVersion
{
    [self readVersion];//调用获取版本信息的方法
    return _libVersion;//返回版本号
}

// 获取保存的图片数
-(int)savePhotoNum
{
    int result = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"JY_SAVE_PHOTO_NUM"];
    if (result == 0)
    {
        result = 0;
    }
    return result;
}

// 设置保存的图片数
-(void)setSavePhotoNum:(int)savePhotoNum
{
    if (_libInited)
    {
        setOFPhotoNum(savePhotoNum+1);
    }
    [self updateUserDefaults:^(NSUserDefaults *userDefaults)
    {
        [userDefaults setInteger:savePhotoNum forKey:@"JY_SAVE_PHOTO_NUM"];
    }];
}

-(NSString*)serviceUrl
{
    NSString* url = [[NSUserDefaults standardUserDefaults] stringForKey:@"JY_SERVICE_URL"];
    if (url)
    {
        return url;
    }
    return SERVICE_URL;
}

-(void)setServiceUrl:(NSString *)serviceUrl
{
    [self updateUserDefaults:^(NSUserDefaults *userDefaults)
    {
        [userDefaults setObject:serviceUrl forKey:@"JY_SERVICE_URL"];
    }];
}

// 调用库初始化方法
-(BOOL) libInit
{
    [self libUnInit];
    
    if (_libInited)
    {
        return YES;
    }
    self.mode.libInit = 0;//调用初始化后，设为0
    
    int result = JYInit();
    _libLastError = result;
    _libInited = (result >= 0);
    if (_libInited)
    {
        setOFPhotoNum(self.savePhotoNum+1);
    } else
    {
        NSLog(@"** 错误 ** 内核库初始化失败(code:%d)", _libLastError);
    }
    return _libInited;
}

// 调用库反初始化方法
-(BOOL) libUnInit
{
    if (!_libInited)
    {
        return YES;
    }
    self.mode.libInit = 1;//调用反初始化后，设为1
    
    _libLastError = JYUnInit();
    
    if (_libLastError >= 0){
    } else
    {
        NSLog(@"** 错误 ** 内核库释放失败(code:%d)", _libLastError);
    }
    
    return _libInited = _libLastError < 0;
}

-(void)beginCheckSelfPhoto:(JYCheckSelfPhotoBlock)result
{
    [self libInit];

    _selfPhotoChecked = result;
    _libSelfPhotoSetted = NO;
}

-(void)endCheckSelfPhoto
{
    _selfPhotoChecked = nil;
    
}

-(void)beginActionCheck:(id<JYActionDelegate>)delegate
{
    _actionDelegate = delegate;
}

-(void)endActionCheck
{
    _actionDelegate = nil;
}

-(void)debugGrayImage:(JYDebugCall) callback
{
    _debugGrayImage = callback;
}


@end
