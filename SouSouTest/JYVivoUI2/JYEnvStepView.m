//
//  JYEnvStepView.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/1.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "JYEnvStepView.h"
#import "JYDefines.h"
#import "JYVivoUIStepDelegate.h"
#import "JYResource.h"
#import "JYAVSessionHolder.h"
#import "FaceModuleHead.h"
#import "idCardAdoptMode.h"


@interface JYEnvStepView () <JYVivoUIStepDelegate>
{
    JYVivoUIStepNext _next;
    CGFloat _faceFrameImageAspectRadio;
    BOOL _animing;
    NSDate* _dateEnter; // 进入时间
}

@property (nonatomic, weak) UIImageView* faceFrameImageView;
@property (nonatomic, weak) UIView* scanlineClipView;
@property (nonatomic, weak) UIImageView* scanlineImageView;
@property (nonatomic, weak) UILabel* statusLabel;


#ifdef JYDEBUG
@property (weak, nonatomic) UIImageView *debugImageView;
#endif

@property (nonatomic, strong)AVAudioPlayer* dingPlayer;//跳转活体检测的声音

@property (nonatomic, strong)NSTimer *timer;

@end

@implementation JYEnvStepView


UIImageView * tmpImageview;

UIActivityIndicatorView *testActivityIndicator; //正在载入旋转控件


-(void)initSelf
{
    
    UIImageView *faceFrameImageView = [UIImageView new];
    UIImage *faceFrameImage = [JYResource imageNamed:@"face_frame.png"];
    _faceFrameImageAspectRadio = faceFrameImage.size.width / faceFrameImage.size.height;
    faceFrameImageView.image = faceFrameImage;
    
    UIView *scanlineClipView = [UIView new];
    scanlineClipView.clipsToBounds = YES;
    
    UIImageView *scanlineImageView = [UIImageView new];
    scanlineImageView.image = [JYResource imageNamed:@"scanline3.png"];
    scanlineImageView.clipsToBounds = YES;
    
    UILabel* statusLabel = [UILabel new];
    statusLabel.font = [UIFont systemFontOfSize:14];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    
#ifdef JYDEBUG
    UIImageView *debugImageView = [UIImageView new];
    debugImageView.contentMode = UIViewContentModeScaleAspectFit;
#endif
    
    [scanlineClipView addSubview:scanlineImageView];
    
    [self addSubview:faceFrameImageView];
    [self addSubview:scanlineClipView];
    [self addSubview:statusLabel];
#ifdef JYDEBUG
    [self addSubview:debugImageView];
#endif
    
    self.faceFrameImageView = faceFrameImageView;
    self.scanlineClipView = scanlineClipView;
    self.scanlineImageView = scanlineImageView;
    self.statusLabel = statusLabel;
#ifdef JYDEBUG
    self.debugImageView = debugImageView;
#endif
    
    self.dingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"ding" withExtension:@"mp3"] error:nil];
    
    [self.dingPlayer prepareToPlay];//叮声音准备
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStop) name:@"returnIDPhotoView" object:nil];
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    mode.severalController = 0;//@@这一句！！！
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

-(void)layoutSubviews
{
    CGSize size = self.frame.size;

//    self.faceFrameImageView.frame = CGRectMake(70,20+24+40+(((((size.width-140)/60)*77)-(((size.width-140)/22.26)*24.38))/2),size.width-140,((size.width-140)/22.26)*24.38);//人脸框大小
//    self.scanlineClipView.frame =  CGRectMake(70,20+24+40,size.width-140,((size.width-140)/60)*77);//扫描线高度
//    
//    self.scanlineImageView.frame = CGRectMake(0, 0, size.width-140,((size.width-140)/60)*77);//扫描线宽度
//    self.statusLabel.frame = CGRectMake(0, self.scanlineClipView.frame.origin.y+self.scanlineClipView.frame.size.height+20, size.width, 20);
    
    self.faceFrameImageView.frame = CGRectMake(0, size.height * 0.205, size.width, size.width / _faceFrameImageAspectRadio);//人脸框大小
    self.scanlineClipView.frame = CGRectMake(0, size.height * 0.205, size.width, size.width / _faceFrameImageAspectRadio);//扫描线高度
    
    self.scanlineImageView.frame = CGRectMake(0, 0, size.width, size.width / _faceFrameImageAspectRadio);//扫描线宽度
    self.statusLabel.frame = CGRectMake(0, self.scanlineClipView.frame.origin.y+self.scanlineClipView.frame.size.height+20, size.width, 20);
    
#ifdef JYDEBUG
    self.debugImageView.frame = self.scanlineClipView.frame;
#endif
}


-(void)stepLoad:(JYVivoUIStepNext)next
{
    _next = next;
}

-(void)scanlineAnim
{
    __weak typeof (self) weakSelf = self;
    
    
    self.scanlineImageView.transform = CGAffineTransformMakeTranslation(0, -VIDEO_VIEW_HEIGHT);
    [UIView animateWithDuration:SCANLINE_DURATION animations:^{
        weakSelf.scanlineImageView.transform = CGAffineTransformMakeTranslation(0, VIDEO_VIEW_HEIGHT);
    } completion:^(BOOL finished)
    {
        if (_animing)
        {
            
            [weakSelf scanlineAnim];
        }
    }];
}

-(void)startScanlineAnim
{
    
    _animing = YES;
    [self scanlineAnim];
}

-(void)setStatusText:(NSString*)text success:(BOOL)success
{
    
    self.statusLabel.textColor = success ? GOOD_UICOLOR : FAIL_UICOLOR;
    self.statusLabel.text = text;
    
    if (success)
    {
        // 按需要停留一定时间后进入下一步
        NSTimeInterval useInterval = [[NSDate date] timeIntervalSinceDate:_dateEnter];
        if (useInterval < SCANLIE_STEP_MIN_REMAIN - SCANLIE_STEP_DONE_DELAY) {
            useInterval = SCANLIE_STEP_MIN_REMAIN - useInterval;
        }else
        {
            useInterval = SCANLIE_STEP_DONE_DELAY;
        }

        //进入过渡
        [self.dingPlayer play];//检测到人脸 叮一声
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingToJYIdentifyStepView" object:self];
        tmpImageview = [[UIImageView alloc] init];
        tmpImageview.contentMode = UIViewContentModeScaleAspectFit;
        tmpImageview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        tmpImageview.backgroundColor = [UIColor blackColor];
        tmpImageview.alpha = 0.5;
        [self addSubview:tmpImageview];
        
        
//        //毛玻璃效果，有需要可以使用
//        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
//        
//        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//        
//        effectview.frame = tmpImageview.frame;
//        
//        [tmpImageview addSubview:effectview];
        
        
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2-100, self.frame.size.height/2-80, 200, 50)];
        tmpLabel.textAlignment = NSTextAlignmentCenter;//居中显示
        tmpLabel.textColor = [UIColor whiteColor];
        tmpLabel.font = [UIFont systemFontOfSize:20];
        tmpLabel.text = @"即将活体检测";
        [tmpImageview addSubview:tmpLabel];
            
            
        //载入旋转
        testActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        testActivityIndicator.center = self.center;//设置中心
        [self addSubview:testActivityIndicator];
        testActivityIndicator.color = [UIColor yellowColor]; // 改变颜色
        [testActivityIndicator startAnimating]; // 开始旋转
        self.userInteractionEnabled = NO;
        
        
        //发送进入下个界面的通知
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(next) userInfo:nil repeats:NO];
    }
}

-(void)next
{
    if (_next)
    {
        [testActivityIndicator stopAnimating]; // 结束旋转
        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [tmpImageview removeFromSuperview];
        self.userInteractionEnabled = YES;
        
        _next();
    }
}

-(void)updatePhotoType:(int)photoType
{
    switch (photoType)
    {
        case eCSPT_OK:
            [self setStatusText:@"环境正常" success:YES];
            break;
        case eCSPT_Small:
            [self setStatusText:@"人脸过小，请近距离拍照" success:NO];
            break;
        case eCSPT_Pose:
            [self setStatusText:@"人脸姿态不正确，请对准摄像头" success:NO];
            break;
        case eCSPT_Biased:
            [self setStatusText:@"人脸位置不正确，请对准头像框" success:NO];
            break;
        case eCSPT_MoreFace:
            [self setStatusText:@"检测到多张人脸，只能拍取单个人脸" success:NO];
            break;
        case eCSPT_NoFace:
            [self setStatusText:@"检测人脸失败，请对准头像框" success:NO];
            break;
        case eCSPT_Positive:
            [self setStatusText:@"人脸位置不正确，请对准头像框" success:NO];
            break;
        case eCSPT_Dusky:
            [self setStatusText:@"光线昏暗" success:NO];
            break;
        case eCSPT_Sidelight:
            [self setStatusText:@"侧面光线过强" success:NO];
            break;
        default:
            [self setStatusText:@"环境错误，请重新开始" success:NO];//返回的-2
            break;
    }
}


-(NSString*)stepEnter
{
    

    [[JYAVSessionHolder instance] setDevicePosition:AVCaptureDevicePositionFront];//设置摄像头方向
    [self startScanlineAnim];
#ifdef JYDEBUG
    
    __weak typeof (self) weakSelf = self;
    
    
    [[JYAVSessionHolder instance] debugGrayImage:^(id some)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.debugImageView.image = some;
            
        });
    }];
    
#endif
    _dateEnter = [NSDate date];
    self.statusLabel.text = @"";//返回时清空上次的环境正常
    
    //延迟2.5秒,环境检测的线刷过一次后开始检测
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.5 target:self selector:@selector(startSO) userInfo:nil repeats:NO];
    self.timer = timer;
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];

    return @"环境检测";
}

-(void)timerStop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer invalidate];
    });
}

//-(void)startSO
//{
//    
//    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
//    
//    if (mode.severalController == 1)//当前如果是环境扫描控制器并且没有开始环境扫描
//    {
//        [[JYAVSessionHolder instance] beginCheckSelfPhoto:^(int photoType)
//        {
//            
//            [self updatePhotoType:photoType];
//        }];
//    }
//}

-(void)startSO  //如需去掉证件照界面，可更换
{
     __weak typeof (self) weakSelf = self;
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    
    if (mode.severalController == 0)//当前如果是环境扫描控制器并且没有开始环境扫描
    {
        [[JYAVSessionHolder instance] beginCheckSelfPhoto:^(int photoType)
         {
             
             [weakSelf updatePhotoType:photoType];
         }];
    }
}



-(void)stepExit
{
    
    [[JYAVSessionHolder instance] endCheckSelfPhoto];
    
    _animing = NO;
}

@end
