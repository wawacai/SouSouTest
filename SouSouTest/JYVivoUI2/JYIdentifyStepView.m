//
//  JYIdentifyStepView.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/2.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "JYIdentifyStepView.h"
#import "JYDefines.h"
#import "JYVivoUIStepDelegate.h"
#import "JYResource.h"
#import "JYAVSessionHolder.h"
#import "JYProgressBar.h"
#import "JYActionImageView.h"
#import "idCardAdoptMode.h"

//人脸框frame大小
#define FACE_FRAME_IMAGEVIEW_FRAME CGRectMake(70,20+24+40+(((((size.width-140)/60)*77)-(((size.width-140)/22.26)*24.38))/2),size.width-140,((size.width-140)/22.26)*24.38)

#define ACTION_IMAGEVIEW_FRAME CGRectMake((size.width - ACTION_IMAGE_WIDTH) / 2, mTop + (hSpacing - ACTION_IMAGE_HEIGHT) / 2, ACTION_IMAGE_WIDTH, ACTION_IMAGE_HEIGHT);


// 简单包装动作信息
@interface JYActionInfo : NSObject
// 动作名称
@property (nonatomic, copy) NSString* name;
// 动作帧的图片
@property (nonatomic, strong) NSArray* images;

#ifdef SOUND_ACTION
// 动作提示音播放器
@property (nonatomic, strong) AVAudioPlayer* soundPlayer;
#endif

@end

@implementation JYActionInfo

+(id)actionNamed:(NSString*)name images:(NSArray*)images
{
    JYActionInfo *actionInfo = [JYActionInfo new];
    actionInfo.name = name;
    actionInfo.images = images;
    return actionInfo;
}

+(id)actionNamed:(NSString*)name images:(NSArray*)images sound:(NSString*)soundName
{
    JYActionInfo *actionInfo = [JYActionInfo new];
    actionInfo.name = name;
    actionInfo.images = images;
#ifdef SOUND_ACTION
    actionInfo.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:soundName withExtension:@"wav"] error:nil];
    [actionInfo.soundPlayer prepareToPlay];
#endif
    return actionInfo;
}

@end

@interface JYIdentifyStepView () <JYVivoUIStepDelegate, JYActionDelegate>
{
    JYVivoUIStepNext _next;
    CGFloat _faceFrameImageAspectRadio;
    NSArray *_actionInfos;
    BOOL _isLastHint;
}

@property (nonatomic, weak) UILabel* actionLabel;
@property (nonatomic, weak) UIImageView* faceFrameImageView;
@property (nonatomic, weak) JYProgressBar* progressBar;
@property (nonatomic, weak) JYActionImageView* actionImageView;

@property (nonatomic, weak) UILabel *actionL;

#ifdef SOUND_ACTION_RESULT
@property (nonatomic, strong) AVAudioPlayer* successPlayer;    //成功的语音
@property (nonatomic, strong) AVAudioPlayer* failPlayer;       //失败的语音
#endif

#ifdef SOUND_TICK
@property (nonatomic, strong) AVAudioPlayer* tickPlayer;        //咔咔声音
#endif
@property (nonatomic, strong) AVAudioPlayer* anearPlayer;       //请靠近摄像头声音

@property (nonatomic, strong) AVAudioPlayer* frontPlayer;       //请正对摄像头声音

@property(nonatomic ,strong) NSTimer *time;//不要提示

@end

@implementation JYIdentifyStepView


AVAudioPlayer* player =nil; //语音提示

bool lastSuccess = YES;     //记录上次

bool waiting = NO;     //等待跳转中

-(void)initSelf
{
#ifdef SOUND_ACTION_RESULT
    self.successPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"cmd_succeeded" withExtension:@"wav"] error:nil];
    
    self.failPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"cmd_failed" withExtension:@"wav"] error:nil];
    
    self.anearPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"anear" withExtension:@"wav"] error:nil];
    
    self.frontPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"cmd_front" withExtension:@"wav"] error:nil];
    
    
    [self.successPlayer prepareToPlay];
    [self.failPlayer prepareToPlay];
    [self.anearPlayer prepareToPlay];
    [self.frontPlayer prepareToPlay];
#endif
#ifdef SOUND_TICK
    self.tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[JYResource URLForResource:@"tick" withExtension:@"wav"] error:nil];
    
    [self.tickPlayer prepareToPlay];
#endif
    
    // 初始化动作类型对应的标题与动画帧数据
    _actionInfos = @[
                     [JYActionInfo new],
                     [JYActionInfo actionNamed:@"头向左转" images:nil],
                     [JYActionInfo actionNamed:@"头向右转" images:nil],
                     [JYActionInfo actionNamed:@"请点头" images:@[[JYResource imageNamed:@"action_head_normal.png"], [JYResource imageNamed:@"action_head_start.png"]] sound:@"cmd_top"],
                     [JYActionInfo actionNamed:@"低头" images:nil],
                     [JYActionInfo actionNamed:@"请张嘴" images:@[[JYResource imageNamed:@"action_mouse_normal.png"], [JYResource imageNamed:@"action_mouse_open.png"]] sound:@"cmd_mouth"],
                     [JYActionInfo actionNamed:@"请眨眼" images:@[[JYResource imageNamed:@"action_eyes_normal.png"], [JYResource imageNamed:@"action_eyes_closed.png"]] sound:@"cmd_eye"],
                     [JYActionInfo actionNamed:@"摇头" images:nil sound:@"cmd_shanke"]
                     ];
    
    
    self.backgroundColor = [UIColor clearColor];
    
    UILabel* actionLabel = [UILabel new];
//    actionLabel.textColor = [UIColor colorWithRed:.027 green:.533 blue:.792 alpha:1];
    actionLabel.textColor = [UIColor whiteColor];
    actionLabel.textAlignment = NSTextAlignmentCenter;
    actionLabel.font = [UIFont systemFontOfSize:33];

    
    UIImageView *faceFrameImageView = [UIImageView new];
    UIImage *faceFrameImage = [JYResource imageNamed:@"face_frame.png"];
    _faceFrameImageAspectRadio = faceFrameImage.size.width / faceFrameImage.size.height;
    faceFrameImageView.image = faceFrameImage;
    
    JYProgressBar* progressBar = [[JYProgressBar alloc] init];
    
    JYActionImageView* actionImageView = [JYActionImageView new];
    actionImageView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:actionLabel];
    [self addSubview:faceFrameImageView];
    [self addSubview:progressBar];
    [self addSubview:actionImageView];
    
    self.actionLabel = actionLabel;
    self.faceFrameImageView = faceFrameImageView;
    self.progressBar = progressBar;
    self.actionImageView = actionImageView;
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
    
    self.actionLabel.frame = CGRectMake(0, VIDEO_VIEW_TOP - 30, size.width, 40);
    
    CGFloat h = ((size.width-140)/60)*77;
    
    CGFloat y = 20+24+40;
    
    self.faceFrameImageView.frame = FACE_FRAME_IMAGEVIEW_FRAME; //设置脸框大小
    
    if (size.width - (size.width - VIDEO_VIEW_WIDTH) / 2 - VIDEO_VIEW_WIDTH > 56)
    {
        self.progressBar.frame = CGRectMake(size.width - 50 , y+(h/10), 46, (h/10)*8);
    } else
    {
        self.progressBar.frame = CGRectMake(size.width - 50,  y+(h/10), 46, (h/10)*8);
    }
    
    CGFloat mTop = VIDEO_VIEW_TOP + VIDEO_VIEW_HEIGHT;
    CGFloat hSpacing = size.height - mTop;
    if (hSpacing > ACTION_IMAGE_HEIGHT) {
        self.actionImageView.frame = ACTION_IMAGEVIEW_FRAME;
        
    } else {
        CGFloat p = hSpacing / ACTION_IMAGE_HEIGHT;
        CGFloat w = ACTION_IMAGE_WIDTH * p;
        CGFloat h = ACTION_IMAGE_HEIGHT * p;
        self.actionImageView.frame = CGRectMake((size.width - w) / 2, mTop, w, h);
    }
}

-(void)setActionLabel:(NSString*)label withColor:(UIColor*)textColor
{
    self.actionLabel.text = label;
    self.actionLabel.textColor = textColor;
}


-(void)stepLoad:(JYVivoUIStepNext)next
{
    _next = next;
}

-(NSString*)stepEnter
{
    [[JYAVSessionHolder instance] beginActionCheck:self];
    return @"活体检测";
}

-(void)stepExit
{
    [[JYAVSessionHolder instance] endActionCheck];
}


-(void)actionCheckCompleted:(BOOL)success
{
    
#ifdef SOUND_ACTION_RESULT
 //   [(success ? self.successPlayer : self.failPlayer) play];
#endif
    
    if (waiting == YES)//处于等待跳转中时。不发出声音
    {
        return;
    }
    
    if (success == NO&&lastSuccess == YES)
    {
        
        [self vibrate];//震动
        [self.failPlayer play];//调用失败的语音
        if (self.time!= nil)
        {
            [self.time invalidate];
            self.time = nil;
        }
//        [self.time invalidate];
    }
    if (success == YES)
    {
        [self vibrate];//震动
        [self.successPlayer play];//调用成功的语音
        
        [self.time invalidate];
    }
    lastSuccess = success;
}

-(void)actionFinishCompleted:(BOOL)success
{
    waiting = YES;
    
    //延迟1秒,无法点击返回按钮
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingToJYIdentifyStepView" object:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_next)
        {
            _next();
            waiting = NO;
        }
    });
}

-(UILabel *)actionL
{
    if (_actionL== nil)
    {
        UILabel *actionL = [[UILabel alloc] init];
        
        actionL.frame = _actionLabel.frame;
        
        [self addSubview:actionL];
        
        _actionL = actionL;
        
        _actionL.textAlignment = NSTextAlignmentCenter;//居中显示
        
        _actionL.alpha = 0;
    }
    return _actionL;
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)responseHintMsg:(int)hint
{
    if (waiting == YES)//处于等待跳转，不提示
    {
        return;
    }
    
    switch (hint)
    {
        case 1: // 请按提示指令操作
            _isLastHint = YES;
            [self setActionLabel:@"请按提示指令操作" withColor: GOOD_UICOLOR];
            break;
        case 2: // 未按提示操作，本次识别失败
            _isLastHint = YES;
            [self setActionLabel:@"未按提示操作，本次识别失败" withColor: FAIL_UICOLOR];
            [self.time invalidate];
            self.time = nil;
            break;
        case 3: // 请正对摄像头
            _isLastHint = YES;
            [self setActionLabel:@"请正对摄像头" withColor: FAIL_UICOLOR];
            [self.time invalidate];
            self.time = nil;
            [self.frontPlayer play];
            self.actionL.text = @"请正对摄像头";
            self.actionL.textColor = FAIL_UICOLOR;
            [self actionLAlpha];
            
            break;
        case 4: // 请靠近摄像头
            _isLastHint = YES;
            [self setActionLabel:@"请靠近摄像头" withColor: FAIL_UICOLOR];
            [self.time invalidate];
            self.time = nil;
            [self.anearPlayer play];
            self.actionL.text = @"请靠近摄像头";
            self.actionL.textColor = FAIL_UICOLOR;
            [self actionLAlpha];
            
            break;
        case 5: // 检测到多张人脸，重新开始
            _isLastHint = YES;
            [self setActionLabel:@"检测到多张人脸，重新开始" withColor: FAIL_UICOLOR];
            [self.time invalidate];
            self.time = nil;
            break;
        case 6: // 无人
            _isLastHint = YES;
            
            [self setActionLabel:@"无人" withColor:FAIL_UICOLOR];
            [self.time invalidate];
            self.time = nil;
            self.actionL.text = @"无人";
            self.actionL.textColor = FAIL_UICOLOR;
            
            [self actionLAlpha];

            break;
        case 7: // 超时，本次识别失败
            _isLastHint = YES;
            [self setActionLabel:@"超时，本次识别失败" withColor: FAIL_UICOLOR];
            [self.time invalidate];
            self.time = nil;
            break;
            
        default:
            if (!_isLastHint)
            {
                return;
            }
            [self setActionLabel:nil withColor: GOOD_UICOLOR];
            break;
    }
}


-(void)actionLAlpha
{
    __weak typeof (self) weakSelf = self;
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.actionL.alpha = 1;
    } completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.7 animations:^{
            weakSelf.actionL.alpha = 0;
        }];
    }];
}

//即将消失调用
-(void)didMoveToWindow
{
    [super didMoveToWindow];
    
    [self.time invalidate];
}



//重写的代理方法，可以获取到需要执行的动作指令（actionType）
-(void)requestActionType:(int)actionType
{
    JYActionInfo *actionInfo = [_actionInfos objectAtIndex:actionType];
    if (actionInfo)
    {
        [self setActionLabel:actionInfo.name withColor:GOOD_UICOLOR];
        [self.actionImageView setImages:actionInfo.images];
#ifdef SOUND_ACTION
        if (actionInfo.soundPlayer)
        {
            [actionInfo.soundPlayer play];
            lastSuccess = YES;
            
            player = actionInfo.soundPlayer;
            
            NSTimer *time = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(playerVioce) userInfo:nil repeats:YES];
            
            self.time = time;
            
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            
            [runLoop addTimer:time forMode:NSRunLoopCommonModes];
        }
#endif
    } else
    {
        [self setActionLabel:nil withColor: GOOD_UICOLOR];
        [self.actionImageView setImages: nil];
    }
    _isLastHint = NO;
}



-(void)playerVioce
{
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    if (mode.severalController == 2)
    {
        [player play];//不调用再次提示
        
        [self.time invalidate];
    }else
    {
        [self.time invalidate];
    }

}


-(void)responseActionRange:(int)actionRange
{
    NSLog(@"action range %d", actionRange);
}

-(void)responseDoneOperationRange:(int)range
{
    
    self.progressBar.currentValue = range;
}


-(void)responseClockTime:(int)time
{
#ifdef SOUND_TICK
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"switchTick"];
    if ([str  isEqual:@"NO"])
    {
        return;
    }else
    {
        
        [self.tickPlayer play];//咔咔声音播放
    }
#endif
}

@end
