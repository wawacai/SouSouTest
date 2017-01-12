//
//  ViewController.h
//  JYVivoUI2
//
//  Created by junyufr on 16/08/31.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "idCardViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>
//#import <CoreGraphics/CoreGraphics.h>
#import "idCardResultViewController.h"
#import "idCardAdoptMode.h"
#import "FaceModuleHead.h"
#import "MBProgressHUD.h"
#import "SoSoIdCardVertifyViewController.h"
#import "SSPersonalAuthenticationSingleton.h"
#define kMaxRange  120

#define BorderOriginY 60
#define BorderWidth 270
#define BorderHeight 428

//#warning 针对iphone4及以下低配置机型，width和height需设置在1280x720及以下。
#define ImageFrameWidth 1280
#define ImageFrameHeight 720


static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface idCardViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) CALayer *cardNumberLayer;
@property (nonatomic, strong) CALayer *cardBorderLayer;


@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) UIView *bigV;//大view
@property(nonatomic,strong)  UIImageView *scanV; // 扫描网格

@property (nonatomic, strong) UIButton *takePictureBtn;//拍照按钮
//@property (nonatomic, strong) UIButton *nextBtn;//下一步按钮
@property (nonatomic, strong) UIImageView *takePictureImageView;//手动拍照后显示的照片

@property (nonatomic, strong) UIButton *ledBtn;//闪光灯按钮

@property (nonatomic, assign) BOOL bTakePic;//是否完成手动拍照

@property (nonatomic, assign) BOOL bLed;//闪光灯开关

@property (nonatomic, strong) UIImageView *stepView;//步骤标签

@property (nonatomic, strong) UIButton *centerTitleBtn;//中间的提示语
@property (nonatomic, strong) UIButton *bottomLabel;//下方的提示语1
@property (nonatomic, strong) UIButton *bottomLabel2;//下方的提示语2

@property (nonatomic, strong) UIImageView *imgView;//框
@property(nonatomic,strong) UIButton *nextBtn; // 下一步
@property(nonatomic,strong) UIButton *restartBtn; // 重拍
@property(nonatomic,strong) NSTimer *timer;


@end

@implementation idCardViewController

bool isAutomatic;//是否是扫描获得


- (void)viewDidLoad {
    [super viewDidLoad];

//    //监听进入后台
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinBackground) name:UIApplicationWillResignActiveNotification object:nil];
//    //监听进入前台
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    self.bTakePic = NO;
    
    
    UIView *bigV = [[UIView alloc] initWithFrame:self.view.frame];
    self.bigV = bigV;
    [self.view addSubview:self.bigV];
    
    //头部
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
//    topView.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, topView.frame.size.width-120, topView.frame.size.height -20)];
//    titleLabel.text = @"证件扫描";
//    titleLabel.font = [UIFont systemFontOfSize:22];
//    [titleLabel setTextColor:[UIColor whiteColor]];
//    titleLabel.textAlignment = NSTextAlignmentCenter;//居中显示
//    
//    [self.bigV addSubview:topView];
//    [self.bigV addSubview:titleLabel];
    
//    //返回按钮
//    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 60)];
//    [backButton addTarget:self action:@selector(touchBackBtn) forControlEvents:UIControlEventTouchUpInside];
//    [backButton setBackgroundColor:[UIColor colorWithRed:17/255.0 green:115/255.0 blue:191/255.0 alpha:1]];
//    [backButton setImage:[UIImage imageNamed:@"BackWhite"] forState:UIControlStateNormal];
//    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [topView addSubview:backButton];
//    
//    [topView bringSubviewToFront:backButton];
}
//
//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
//}

//监听进入后台
//-(void)joinBackground{
//    
////    [self bSetBLed:NO];
//}
////监听退出后台
//-(void)exitBackground{
//    
////    [self bSetBLed:NO];
//}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}



//即将显示
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self bSetBLed:NO];
    
    if (self.takePictureImageView.image) {
        _bTakePic = YES;
    }
    
    __weak typeof (self) weakSelf = self;
    
    //到线程中执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       //#error Please fill in your appKey
                       NSString *appKey = @"rgS5MUYJTSW5yP84RF92TBHW"; //设置app key
                       NSString *subAppkey = nil;//reserved for future use
                       //1注册
                       [[ISIDCardReaderController sharedISOpenSDKController] constructResourcesWithAppKey:appKey subAppkey:subAppkey finishHandler:^(ISOpenSDKStatus status) {
                           if(status == ISOpenSDKStatusSuccess)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    [weakSelf setupAVCapture];//创建输入输出
                                    [weakSelf setupBorderView];//设置框
                                    [weakSelf setupOtherThings];//设置，点击 ，聚焦
                                    [weakSelf setupTimer];
                                    [weakSelf focus];//聚焦一次
                                    if (![weakSelf.captureSession isRunning])
                                    {
                                        //开始运行
                                        [weakSelf.captureSession startRunning];
                                    }
                                });
                           }
                           else
                           {
                               NSLog(@"Authorize error");
                           }
                       }];
                   });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) focus
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        NSError *error =  nil;
        if([device lockForConfiguration:&error]){
            [device setFocusPointOfInterest:CGPointMake(.5f, .5f)];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
}




- (void)setupAVCapture
{
    if (!self.captureSession) {
    
        NSLog(@"没有");
    
        NSError *error = nil;
    
        AVCaptureSession *session = [AVCaptureSession new];
        self.captureSession = session;
        // Select a video device, make an input
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
        if ( [session canAddInput:deviceInput] )
            [session addInput:deviceInput];
    
        // Make a video data output
        self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
        // we want YUV, both CoreGraphics and OpenGL work well with 'YUV'
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
        if ([session canAddOutput:self.videoDataOutput])
        {
            [session addOutput:self.videoDataOutput];
        }
    
    
        //添加拍照输出流
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];//设置输出流的视频解码和输出图片格式
            [session addOutput:stillImageOutput];//添加图片输出到输入输出流
            [self setStillImageOutput:stillImageOutput];
        }
    
        //#warning 针对iphone4及以下低配置机型，sessionPreset需设置在1280x720及以下，并且建议适用设备在iPhone4S以上。
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
        [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        [self.previewLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//        CALayer *rootLayer = [self.view layer];
//        [rootLayer setMasksToBounds:YES];
    
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat height = ImageFrameWidth * screenWidth / ImageFrameHeight ;
        //设定视频窗口大小位置
        [self.previewLayer setFrame:CGRectMake(0, 0, screenWidth, height)];

        
        [self.bigV.layer addSublayer:self.previewLayer];

        [session startRunning];
    }else{
        
        [self.bigV bringSubviewToFront:self.takePictureBtn];
        [self.bigV bringSubviewToFront:self.nextBtn];
        
        if (!self.captureSession.isRunning) {
            
            [self.captureSession startRunning];
        }
    }

    if (self.takePictureImageView.image) {
        return;
    }
//    //拍照按钮
//    UIButton *takePictureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-30, self.view.frame.size.height-50, 60, 40)];
//
//    [takePictureBtn setImage:[UIImage imageNamed:@"btn_photo_n"] forState:UIControlStateNormal];
//    [takePictureBtn setImage:[UIImage imageNamed:@"btn_photo_p"] forState:UIControlStateHighlighted];
//    
//    [takePictureBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
//    self.takePictureBtn = takePictureBtn;
//
//    [self.view addSubview:takePictureBtn];
    
    
//    // 下一步
//    CGFloat nextBtnW = 66;
//    CGFloat nextBtnH = 28;
//    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 16 - nextBtnW ,self.view.frame.size.height - 44 - nextBtnH, nextBtnW, nextBtnH)];
//    nextBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
//    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
//    nextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
//    nextBtn.layer.cornerRadius = 14;
//    nextBtn.layer.masksToBounds = YES;
//    nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    nextBtn.layer.borderWidth = 0.5;
//    nextBtn.backgroundColor = [UIColor orangeColor];
//    nextBtn.hidden = YES;
//    self.nextBtn = nextBtn;
//    [self.bigV addSubview:nextBtn];
//    
//    // 重拍按钮
//    CGFloat restartBtnW = 66;
//    CGFloat restartBtnH = 28;
//    UIButton *restartBtn = [[UIButton alloc] initWithFrame:CGRectMake(16 ,self.view.frame.size.height - 44 - restartBtnH, restartBtnW, restartBtnH)];
//    restartBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
//    [restartBtn setTitle:@"重拍" forState:UIControlStateNormal];
//    restartBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [restartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [restartBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
//    restartBtn.layer.cornerRadius = 14;
//    restartBtn.layer.masksToBounds = YES;
//    restartBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    restartBtn.layer.borderWidth = 0.5;
//    restartBtn.backgroundColor = [UIColor blackColor];
//    restartBtn.hidden = YES;
//    self.restartBtn = restartBtn;
//    [self.bigV addSubview:restartBtn];
    //原来 demo下一步按钮
    
//    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, takePictureBtn.frame.origin.y, 80, 40)];
//    
//    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
//    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
//    nextBtn.backgroundColor = [UIColor colorWithRed:17/255.0 green:115/255.0 blue:191/255.0 alpha:1];
//    if (!_takePictureImageView.image) {
//        nextBtn.alpha = 0.5;
//        nextBtn.userInteractionEnabled = NO;
//    }else{
//        nextBtn.alpha = 1;
//        nextBtn.userInteractionEnabled = YES;
//    }
//    self.nextBtn = nextBtn;
//    [self.view addSubview:nextBtn];
    
//    //步骤条
//    UIImageView *stepView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bigV.frame.size.width-200)/2, 100, 200, 24)];
//    stepView.image = [UIImage imageNamed:@"icon_number_1"];
//    self.stepView = stepView;
//    [self.bigV addSubview:stepView];
    
    //闪光灯按钮
//    UIButton *ledBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bigV.frame.size.width - 40, 90, 40, 40)];
//    [ledBtn setImage:[UIImage imageNamed:@"Led_On"] forState:UIControlStateNormal];
//    [ledBtn setImage:[UIImage imageNamed:@"Led_Off"] forState:UIControlStateSelected];
//    [ledBtn addTarget:self action:@selector(touchLedBtn) forControlEvents:UIControlEventTouchDown];
//    self.ledBtn = ledBtn;
//    [self.bigV addSubview:ledBtn];
    
//    //中间的提示语
//    UIButton *centerTitleBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bigV.frame.size.width/2-115, self.bigV.frame.size.height/2-30, 230, 100)];
//    centerTitleBtn.transform = CGAffineTransformRotate(centerTitleBtn.transform, M_PI_2);
//    [centerTitleBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];//换行
//    [centerTitleBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    centerTitleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;//居中显示
//    [centerTitleBtn setTitle:@"拍摄身份证正面照\n证件文字需清晰可读，照片需端正" forState:UIControlStateNormal];
//    [centerTitleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.centerTitleBtn = centerTitleBtn;
//    [self.bigV addSubview:centerTitleBtn];
    
    if (!_isFromHeadTest)
    {
        UIButton *bottomLabel = [[UIButton alloc]initWithFrame:CGRectMake(-125,80+ self.bigV.frame.size.height/2-112, 300, 30)];
        bottomLabel.transform = CGAffineTransformRotate(bottomLabel.transform, M_PI_2);
        self.bottomLabel = bottomLabel;
        [self.bottomLabel.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [self.bottomLabel setTitle:@"请将人像面放入框内，并调整好光线" forState:UIControlStateNormal];
        [self.bottomLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomLabel = bottomLabel;
        [self.bigV addSubview:self.bottomLabel];

    }
    //下方的提示语
    
//    UIButton *bottomLabel2 = [[UIButton alloc]initWithFrame:CGRectMake(-20,60+ self.bigV.frame.size.height/2-28, 100, 30)];
//    bottomLabel2.transform = CGAffineTransformRotate(bottomLabel2.transform, M_PI_2);
//    self.bottomLabel2 = bottomLabel2;
//    [self.bottomLabel2.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [self.bottomLabel2 setTitleColor:[UIColor colorWithRed:144/255.0 green:238/255.0 blue:144/255.0 alpha:YES] forState:UIControlStateNormal];
//    [self.bottomLabel2 setTitle:@"四角端正完整" forState:UIControlStateNormal];
//    self.bottomLabel2 = bottomLabel2;
//    [self.bigV addSubview:self.bottomLabel2];
    
}

//点击闪光灯按钮
//-(void)touchLedBtn
//{
//    [self bSetBLed:!self.bLed];
//}

//-(void)bSetBLed:(BOOL)bLed
//{
//    if (bLed == NO) {
//        [self turnOffLed];
//        self.ledBtn.selected = NO;
//    }
//    else if(bLed == YES)
//    {
//        [self turnOnLed];
//        self.ledBtn.selected = YES;
//    }
//    self.bLed = bLed;
//}

////关闭灯光
//-(void)turnOffLed {
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    if ([device hasTorch]) {
//        [device lockForConfiguration:nil];
//        [device setTorchMode: AVCaptureTorchModeOff];
//        [device unlockForConfiguration];
//    }
//}
////打开灯光
//-(void)turnOnLed {
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    if ([device hasTorch]) {
//        [device lockForConfiguration:nil];
//        [device setTorchMode: AVCaptureTorchModeOn];
//        [device unlockForConfiguration];
//    }   
//}



//下一步
-(void)next
{
//    [self bSetBLed:NO];
//    [self performSegueWithIdentifier:@"idcardResult" sender:nil];
    idCardViewController *vc = [[idCardViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.isFromHeadTest = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}
// 完成
-(void)finish
{
    SoSoIdCardVertifyViewController *vc = [[SoSoIdCardVertifyViewController alloc] init];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

// 返回
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
// 重拍
- (void)rephotograph
{
//    idCardViewController *vc = [[idCardViewController alloc] init];
//    vc.view.backgroundColor = [UIColor whiteColor];
//    vc.isFromHeadTest = NO;
//    [self.navigationController pushViewController:vc animated:YES];
    
    for (UIView *view in self.bigV.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if ([btn.titleLabel.text isEqualToString:@"下一步"] || [btn.titleLabel.text isEqualToString:@"重拍"]) {
                [btn removeFromSuperview];
            }
        }
    }
    
    [SSPersonalAuthenticationSingleton getSingleton].headDic = nil;
    [_timer setFireDate:[NSDate distantPast]];
   
    
}

//拍照
//-(void)takePicture
//{
//    self.bTakePic = YES;
//    
//    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
//    
//    //重拍处理
//    if (mode.idCardImage) {
//        self.takePictureBtn.userInteractionEnabled = NO;
//        
//        isAutomatic = NO;
//        
//        //重拍
//        [self.takePictureImageView removeFromSuperview];
//        mode.idCardImage = nil;
//        self.nextBtn.alpha = 0.5;
//        self.nextBtn.userInteractionEnabled = NO;
//        self.takePictureBtn.userInteractionEnabled = YES;
//        
//        [self.centerTitleBtn setTitle:@"\t\t\t\t\t\t\t\t\t\t\t\t拍摄身份证正面照\n证件文字需清晰可读，照片需端正" forState:UIControlStateNormal];
//        
//        
//        self.bTakePic = NO;
//        return;
//    }
//    
//    __weak typeof (self) weakSelf = self;
//    
//    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
//     {
//         weakSelf.takePictureBtn.userInteractionEnabled = NO;
//         if (error) {
//             NSLog(@"%@",error);
//             return ;
//         }
//         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//         if (imageData)
//         {
//             
//             //获取到拍照图片
//             UIImage *image = [UIImage imageWithData:imageData];
//             
//             NSData *data = UIImageJPEGRepresentation(image, 0.7);
//             
//             image = [UIImage imageWithData:data];
//             
//             
//             //赋值照片
//             mode.idCardImage = image;
//             
//             
//             UIImageView *takePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake((weakSelf.view.frame.size.width-weakSelf.previewLayer.frame.size.height*(720.0/1280.0))/2, weakSelf.previewLayer.frame.origin.y, weakSelf.previewLayer.frame.size.height*(720.0/1280.0), weakSelf.previewLayer.frame.size.height)];
//             
//             [takePictureImageView setImage:image];
//             weakSelf.takePictureImageView = takePictureImageView;
//             
//             [weakSelf.bigV addSubview:takePictureImageView];
//             [weakSelf.bigV bringSubviewToFront:weakSelf.stepView];
//             [weakSelf.centerTitleBtn setTitle:@"如不清晰，请“重拍”" forState:UIControlStateNormal];
//             [weakSelf.bigV bringSubviewToFront:weakSelf.centerTitleBtn];
//             [weakSelf.bigV bringSubviewToFront:weakSelf.bottomLabel];
//             [weakSelf.bigV bringSubviewToFront:weakSelf.bottomLabel2];
//             
//             
////             [weakSelf.bigV bringSubviewToFront:weakSelf.ledBtn];
//             [weakSelf.bigV bringSubviewToFront:weakSelf.nextBtn];
//             weakSelf.nextBtn.alpha = 1;
//             weakSelf.nextBtn.userInteractionEnabled = YES;
//             [weakSelf.bigV bringSubviewToFront:weakSelf.takePictureBtn];
//             weakSelf.takePictureBtn.userInteractionEnabled = YES;
//         }
//     }];
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;

}

//设定扫描范围的框
- (void)setupBorderView
{
    if (self.takePictureImageView.image) {
        return;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    //控制扫描范围
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(53,124,screenSize.width - 106, screenSize.height - 248)];
    
    borderView.layer.borderColor = [UIColor clearColor].CGColor;
    borderView.layer.borderWidth = 1.0f;
    borderView.layer.masksToBounds = YES;
    self.borderView = borderView;
    [self.bigV addSubview:borderView];
    
   
    // 头像
    
    if (_isFromHeadTest)
    {
        UIImageView *emblemImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emblem"]];
        emblemImageV.frame = CGRectMake(screenSize.width - 103 - 91,160, 103, 110);
        emblemImageV.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self.bigV addSubview:emblemImageV];
        
    }else
    {
        UIImageView *headImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head"]];
        headImageV.center = CGPointMake(screenSize.width/2, CGRectGetMaxY(borderView.frame) - 96);
        [self.bigV addSubview:headImageV];
    }
//    [self.previewLayer addSublayer:borderView.layer];
    
    //上方阴影
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.borderView.frame.origin.y)];
    topView.alpha = 0.5;
    topView.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    //下方阴影
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.borderView.frame.origin.y+self.borderView.frame.size.height, self.view.frame.size.width,self.previewLayer.frame.size.height - (self.borderView.frame.origin.y+self.borderView.frame.size.height))];
    bottomView.alpha = 0.5;
    bottomView.layer.backgroundColor = [UIColor blackColor].CGColor;;
    
    //左侧阴影
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, topView.frame.size.height, self.borderView.frame.origin.x, bottomView.frame.origin.y - topView.frame.size.height)];
    leftView.alpha = 0.5;
    leftView.layer.backgroundColor = [UIColor blackColor].CGColor;;
    
    //右侧阴影
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(self.borderView.frame.origin.x + self.borderView.frame.size.width  , topView.frame.size.height, leftView.frame.size.width, bottomView.frame.origin.y - topView.frame.size.height)];
    rightView.alpha = 0.5;
    rightView.layer.backgroundColor = [UIColor blackColor].CGColor;;
    
    // 框
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height, topView.frame.size.width - leftView.frame.size.width*2, leftView.frame.size.height)];
    self.imgView = imgView;
    imgView.image = [UIImage imageNamed:@"frame"];
    imgView.userInteractionEnabled = YES;
    
    // 返回按钮
    CGFloat backBtnW = 36;
    CGFloat backBtnH = 20;
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 35 - 10 ,20, backBtnH, backBtnW)];
    backBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.bigV addSubview:backBtn];
    
    
    [self.previewLayer addSublayer:imgView.layer];
    [self.previewLayer addSublayer:topView.layer];
    [self.previewLayer addSublayer:bottomView.layer];
    [self.previewLayer addSublayer:leftView.layer];
    [self.previewLayer addSublayer:rightView.layer];
    [self slideViewRefresh];
}
- (void)setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(slideViewRefresh) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
// 网格刷新
- (void)slideViewRefresh{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    //扫描网格
    UIImageView *scanV = [[UIImageView alloc]  initWithFrame:CGRectMake(screenSize.width - 106,0, 172,  screenSize.height - 248)];
    scanV.image = [UIImage imageNamed:@"Slice"];
    [self.borderView addSubview:scanV];

//   
    [UIView animateWithDuration:3 animations:^{
        CGRect frame = scanV.frame;
        frame.origin.x = -172;
        scanV.frame = frame;
    } completion:^(BOOL finished) {
        scanV.hidden = YES;
        [scanV removeFromSuperview];
    }];
    
    
}
- (void)setupOtherThings
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void) didTap:(UITapGestureRecognizer *) tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan)
    {
        [self focus];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    __weak typeof (self) weakSelf = self;
    

    //如果已经手动拍摄了
    if (weakSelf.bTakePic == YES) {
        return;
    }
    
    CFRetain(sampleBuffer);
    //按照self.previewLayer.frame 修改后的值设定
    CGFloat scale = ImageFrameHeight /[UIScreen mainScreen].bounds.size.width;
    CGRect rect = CGRectMake(weakSelf.borderView.frame.origin.y * scale, (weakSelf.previewLayer.frame.size.width - CGRectGetMaxX(weakSelf.borderView.frame)) * scale, weakSelf.borderView.frame.size.height * scale, weakSelf.borderView.frame.size.width * scale);
    
    
    //2识别
    [[ISIDCardReaderController sharedISOpenSDKController] detectCardWithOutputSampleBuffer:sampleBuffer cardRect:rect detectCardFinishHandler:^(int result, NSArray *borderPointsArray) {
        if (result > 0)//表示检测身份证成功
        {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.cardBorderLayer removeFromSuperlayer];
//                self.cardBorderLayer = nil;
//                self.borderView.layer.borderWidth = 10.0f;//设置线宽
                //[self drawBorderRectWithBorderPoints:borderPointsArray onCardBorderLayer:YES];
                self.imgView.image = [UIImage imageNamed:@"frame"];
            });
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
//                               self.borderView.layer.borderWidth = 1.0f;
//                               [self.cardBorderLayer removeFromSuperlayer];
//                               self.cardBorderLayer = nil;
                               self.imgView.image = [UIImage imageNamed:@"frame"];
                           });
        }
    } recognizeCardFinishHandler:^(NSDictionary *cardInfo) {

        if (!_isFromHeadTest)
        {
            if ([[cardInfo valueForKey:kOpenSDKCardResultTypeCardName] isEqualToString:@"第二代身份证背面"]) {
                
                //            static dispatch_once_t onceToken;
                //            dispatch_once(&onceToken, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
//
                    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noti_head-1"]];
                    imageV.center = self.bigV.center;
                    [self.bigV addSubview:imageV];
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [imageV removeFromSuperview];
                    });
                    
//                    // 证明是反面
//                    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.bigV animated:YES];
//                    HUD.mode = MBProgressHUDModeCustomView;
//                    HUD.customView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noti_head"]];
//                    HUD.square = YES;
//                    
//                    for (UIView *subView in HUD.subviews.lastObject.subviews) {
//                        if ([subView isKindOfClass:[UIImageView class]]) {
//                            subView.transform = CGAffineTransformMakeRotation(M_PI_2);
//                        }
//                        
////                        if ([subView isKindOfClass:[UIVisualEffectView class]]) {
////                            subView.backgroundColor = [UIColor clearColor];
////                        }
//                        
//                    }
////                    MBBackgroundView *view = HUD.subviews.lastObject;
////                    view.backgroundColor = [UIColor clearColor];
//
//                    [HUD hideAnimated:YES afterDelay:1];
//                    
                    
                    
                });
                //            });
                //
            }else{
                
//                [_timer invalidate];

                [_timer setFireDate:[NSDate distantFuture]];
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   
                                   [self setupNextBtn];
                                   [SSPersonalAuthenticationSingleton getSingleton].headDic = cardInfo;
                                   // 显示识别成功
//                                   MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.bigV animated:YES];
//                                   HUD.mode = MBProgressHUDModeCustomView;
//                                   HUD.customView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
//                                   HUD.square = YES;
//                                   [HUD hideAnimated:YES afterDelay:3];
                                   UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
                                   imageV.center = weakSelf.bigV.center;
                                   [weakSelf.bigV addSubview:imageV];
                                   
                                   
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       [imageV removeFromSuperview];
                                   });
                               
                               });
                
            }
        }else{// 如果第二次进入该页面
            
            if ([[cardInfo valueForKey:kOpenSDKCardResultTypeCardName] isEqualToString:@"第二代身份证"]) {
    
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // 证明是反面
                    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noti_back-1"]];
                    imageV.center = weakSelf.bigV.center;
                    [weakSelf.bigV addSubview:imageV];
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [imageV removeFromSuperview];
                    });
                });
            }else{
                [_timer invalidate];
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   [self setupNextBtn];
                                   [SSPersonalAuthenticationSingleton getSingleton].backDic = cardInfo;
                                   // 显示识别成功
//                                   MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.bigV animated:YES];
//                                   HUD.mode = MBProgressHUDModeText;
//                                   HUD.label.text = @"识别成功";
//                                   HUD.square = YES;
//                                   for (UIView *subView in HUD.subviews.lastObject.subviews) {
//                                       if ([subView isKindOfClass:[UILabel class]]) {
//                                           subView.transform = CGAffineTransformMakeRotation(M_PI_2);
//                                       }
//                                   }
//                                   [HUD hideAnimated:YES afterDelay:1];
                                   
                                   // 显示识别成功
                                   UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
                                   imageV.center = weakSelf.bigV.center;
                                   [weakSelf.bigV addSubview:imageV];
                                   
                                   
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       [imageV removeFromSuperview];
                                   });
                               });
                
            }
        }
}];
        
        // 显示下一步和重拍按钮
  
//        // 关闭动画
    
        
//        
//        if (cardInfo == nil) {
//            return;
//        }
//        
//        [weakSelf.captureSession stopRunning];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.takePictureBtn.userInteractionEnabled = NO;
//            weakSelf.nextBtn.userInteractionEnabled = NO;
//            //跳转
//            //cardInfo
//            weakSelf.info = cardInfo;
//            //跳转的代码
//            weakSelf.view.userInteractionEnabled = NO;
//            
//            isAutomatic = YES;
//            
//            weakSelf.bLed = NO;
//            
//            
////            int cardPrompt = ;
////            NSLog(@"--%@",[cardInfo valueForKey:kIDCardImageCompletenessType]);
//            
//                UIStoryboard *recSb = [UIStoryboard storyboardWithName:@"JYVivo" bundle:nil];
//                idCardResultViewController *rec = [recSb instantiateViewControllerWithIdentifier:@"result"];
//            rec.dict = cardInfo;
//            rec.str = @"YES";
//            //    [self.navigationController pushViewController:rec animated:YES];
//                [self presentViewController:rec animated:YES completion:nil];
//            
//            //跳转
////            [weakSelf performSegueWithIdentifier:@"idcardResult" sender:nil];
//            ////////////////
//            UIImageView *takePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake((weakSelf.view.frame.size.width-weakSelf.previewLayer.frame.size.height*(720.0/1280.0))/2, weakSelf.previewLayer.frame.origin.y, weakSelf.previewLayer.frame.size.height*(720.0/1280.0), weakSelf.previewLayer.frame.size.height)];
//            
////            [UIImage imageWithCGImage:[[cardInfo valueForKey:kOpenSDKCardResultTypeOriginImage] CGImage] scale:1 orientation:UIImageOrientationRight];
//            
//            [takePictureImageView setImage:[UIImage imageWithCGImage:[[cardInfo valueForKey:kOpenSDKCardResultTypeOriginImage] CGImage] scale:1 orientation:UIImageOrientationRight]];//取证件照];
//            weakSelf.takePictureImageView = takePictureImageView;
//            
//            
//            //再将这个控件添加到window，并显示在所有子视图之前
//            [weakSelf.bigV addSubview:takePictureImageView];
//            [weakSelf.bigV bringSubviewToFront:weakSelf.stepView];
//            [weakSelf.bigV bringSubviewToFront:weakSelf.centerTitleBtn];
//            [weakSelf.bigV bringSubviewToFront:weakSelf.bottomLabel];
//            [weakSelf.bigV bringSubviewToFront:weakSelf.bottomLabel2];
//            [weakSelf.centerTitleBtn setTitle:@"如不清晰，请“重拍”" forState:UIControlStateNormal];
//            
//            [weakSelf.bigV bringSubviewToFront:weakSelf.ledBtn];
//
//            /////////////////
//            weakSelf.takePictureBtn.userInteractionEnabled = YES;
//            weakSelf.nextBtn.userInteractionEnabled = YES;
//            
//            weakSelf.view.userInteractionEnabled = YES;
//        });
//    }];
    CFRelease(sampleBuffer);
}

- (void)setupNextBtn{
    // 下一步
    CGFloat nextBtnW = 66;
    CGFloat nextBtnH = 28;
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 16 - nextBtnW ,self.view.frame.size.height - 44 - nextBtnH, nextBtnW, nextBtnH)];
    nextBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    if (!_isFromHeadTest)
    {
        [nextBtn addTarget:self action:@selector(next) forControlEvents:  UIControlEventTouchUpInside];
        [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    }else
    {
        [nextBtn addTarget:self action:@selector(finish) forControlEvents:  UIControlEventTouchUpInside];
        [nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    nextBtn.layer.cornerRadius = 14;
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    nextBtn.layer.borderWidth = 0.5;
    nextBtn.backgroundColor = [UIColor orangeColor];
    self.nextBtn = nextBtn;
    [self.bigV addSubview:nextBtn];
    
    // 重拍按钮
    if (!_isFromHeadTest)
    {
        CGFloat restartBtnW = 66;
        CGFloat restartBtnH = 28;
        UIButton *restartBtn = [[UIButton alloc] initWithFrame:CGRectMake(16 ,self.view.frame.size.height - 44 - restartBtnH, restartBtnW, restartBtnH)];
        restartBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
        [restartBtn setTitle:@"重拍" forState:UIControlStateNormal];
        restartBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [restartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [restartBtn addTarget:self action:@selector(rephotograph) forControlEvents:UIControlEventTouchUpInside];
        restartBtn.layer.cornerRadius = 14;
        restartBtn.layer.masksToBounds = YES;
        restartBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        restartBtn.layer.borderWidth = 0.5;
        restartBtn.backgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.3];
        self.restartBtn = restartBtn;
        [self.bigV addSubview:restartBtn];
    }
    
}


//跳转控制器的时候传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"idcardResult"]) //如果是跳转的BarCodeNumber这个线
    {
        idCardResultViewController * theSegue = segue.destinationViewController;//获取下一个控制器
        
        if (isAutomatic) {
            theSegue.str = @"YES";
            [theSegue setDict:self.info];
        }
    }
}


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.captureSession startRunning];
    [self.cardNumberLayer removeFromSuperlayer];
    self.cardNumberLayer = nil;
}

- (void)drawBorderRectWithBorderPoints:(NSArray *)borderPoints onCardBorderLayer:(BOOL)flag
{
    if ([borderPoints count] >= 4)
    {
        CGPoint point1 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:0] CGPointValue]];
        CGPoint point2 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:1] CGPointValue]];
        CGPoint point3 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:2] CGPointValue]];
        CGPoint point4 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:3] CGPointValue]];
        
        CAShapeLayer *line = [CAShapeLayer layer];
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:point1];
        [linePath addLineToPoint:point2];
        [linePath addLineToPoint:point3];
        [linePath addLineToPoint:point4];
        [linePath addLineToPoint:point1];
        line.path = linePath.CGPath;
        line.fillColor = nil;
        line.opacity = 1.0;
        line.strokeColor = [UIColor blueColor].CGColor;
        if (flag)
        {
            self.cardBorderLayer = line;
        }
        else
        {
            self.cardNumberLayer = line;
        }
        [self.previewLayer addSublayer:line];
    }
}

- (CGPoint)convertBorderPointsInImageToPreviewLayer:(CGPoint )borderPoint
{
    //video orientation is landscape
    CGFloat y = borderPoint.x * self.previewLayer.bounds.size.height / ImageFrameWidth;
    CGFloat x = self.previewLayer.bounds.size.width - borderPoint.y * self.previewLayer.bounds.size.width / ImageFrameHeight;
    return CGPointMake(x, y);
}

#define clamp(a) (a>255?255:(a<0?0:a));

- (UIImage *) imageRefrenceFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = (uint8_t *)malloc(width * height * bytesPerPixel);
    
    for(int y = 0; y < height; y++)
    {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++)
        {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

- (NSUInteger)stringLengthForUnsignedShortArray:(unsigned short *)target maxLength:(NSUInteger)maxLength
{
    NSUInteger length = 0;
    for (NSUInteger i = 0; i < maxLength; i++)
    {
        if (target[i] == 0)
        {
            break;
        }
        length++;
    }
    return length;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
