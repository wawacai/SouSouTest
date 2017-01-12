//
//  RecognitionController.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/27.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "RecognitionController.h"
#import "JYVivoUI2.h"
#import "UIStepView.h"
#import "IDPhotoStepView.h"
#import "idCardAdoptMode.h"
// 添加
#import "Masonry.h"
#import "SSStepView.h"
#import "SSPromptView.h"
#import "CustomHUD.h"
#import "SSSuccessPromptView.h"

@interface RecognitionController () <JYStepViewDelegate, JYIdentifyStepViewDelegate, JYActionDelegate>
@property (weak, nonatomic) IBOutlet JYAVSessionHolder *sessionHolder;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIStepView *stepView;
@property (weak, nonatomic) IBOutlet UIStepView *stepNumberView;

@property (strong, nonatomic) IBOutlet UIButton *reButton;

@property (weak, nonatomic) IDPhotoStepView *idPhotoStepView;

// 新加
@property (nonatomic, weak) UILabel *actionLabel;
@property (nonatomic, weak) SSStepView *actionFinishNumberView;
@property (nonatomic, weak) SSPromptView *promptView;
@property (nonatomic, weak) JYEnvStepView *envStepView;
@property (nonatomic, weak) UIButton *voiceBtn;
@property (nonatomic, assign) BOOL isStartVoice;
@property (nonatomic, weak) JYIdentifyStepView *identifyStepView;
@property (nonatomic, weak) SSSuccessPromptView *successPromptView;

@end

@implementation RecognitionController

- (void)viewDidLoad
{
    _sessionHolder = [JYAVSessionHolder instance];
    
    [super viewDidLoad];
    
    // 初始化空步骤以进行进入处理
    self.stepView.step = -1;
    
    // 步骤初始化，可自定义步骤
    // 第一步：身份证拍照
//    [_stepNumberView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_number_1.png"]]];
//    IDPhotoStepView *idPhotoStepView = [IDPhotoStepView new];
//    [_stepView addSubview:idPhotoStepView];
//    self.idPhotoStepView = idPhotoStepView;
    
    // 第二步：环境检测
//    [_stepNumberView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_number_2.png"]]];
//    [_stepView addSubview:[JYEnvStepView new]];
    JYEnvStepView *envStepView = [JYEnvStepView new];
    [_stepView addSubview:envStepView];
    _envStepView = envStepView;
    
    
    // 第三步：活体检测
//    [_stepNumberView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_number_3.png"]]];
    JYIdentifyStepView *isv = [JYIdentifyStepView new];
    isv.delegate = self;
//    [_stepView addSubview:[JYIdentifyStepView new]];
    [_stepView addSubview:isv];
    _identifyStepView = isv;
    
    
    self.reButton.userInteractionEnabled = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingToJYIdentifyStepView) name:@"loadingToJYIdentifyStepView" object:nil];

    [self setupUI];
    envStepView.promptView = self.promptView;
    
    __weak typeof(self) weakSelf = self;
    [_promptView setPromptViewButton:^(BOOL isCancelButton) {
        if (isCancelButton) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else {
            weakSelf.actionFinishNumberView.finishNumber = 0;
            weakSelf.promptView.hidden = YES;
            [weakSelf.sessionHolder beginActionCheck:isv];
            weakSelf.reButton.userInteractionEnabled = YES;
            [weakSelf startEnvStepView];
        }
    }];
    
    _isStartVoice = YES;
}


- (void)loadingToJYIdentifyStepView
{
    if (_stepView.step == 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //正在进入活体时候，让返回键无法点击
            self.reButton.userInteractionEnabled = NO;
        });
        //延迟1秒,无法点击返回按钮
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.reButton.userInteractionEnabled = YES;
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //正在进入活体时候，让返回键无法点击
            self.reButton.userInteractionEnabled = NO;
        });
        //延迟2秒,无法点击返回按钮
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.reButton.userInteractionEnabled = YES;
        });
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_sessionHolder start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_sessionHolder stop];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender
{
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];

    if(_stepView.step == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        mode.severalController = -1;//设置为不在任何控制器
    }
    if(_stepView.step == 1)
    {
        
        mode.severalController = 0;//设置为正在翻牌照
        
        _stepView.step = 0;
        
    }
}

#pragma mark - JYStepViewDelegate

- (void)onStepComplete
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_sessionHolder stop2];
        // 步骤已结束，导航到结果显示界面
        self.stepView.step = -1;
        
        [self performSegueWithIdentifier:@"result" sender:nil];
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"result"])
    {
        [segue.destinationViewController setPersonInfo:self.personInfo];
    }
    [super prepareForSegue:segue sender:sender];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_sessionHolder stop2];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];//关闭通知
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    mode.severalController = -1;
    
    self.stepView.step = -1;
}


#pragma mark - delegate 

- (void)isIdentifySetpView {
    _actionLabel.hidden = YES;
    _actionFinishNumberView.finishNumber = 1;
}

- (void)totalSuccessCount:(NSInteger)count {
    _promptView.hidden = YES;
    if (count == 0) {
        [_sessionHolder endActionCheck];
        self.reButton.userInteractionEnabled = NO;
        _promptView.hidden = NO;
        return;
    }
    if (count == 3) {
        NSLog(@"验证成功");
        _successPromptView.hidden = NO;
        return;
    }
	
    _actionFinishNumberView.finishNumber = count + 1;
}

- (void)actionCheckCompleted:(BOOL)success {
    
}

- (void)actionFinishCompleted:(BOOL)success {
    
}

#pragma mark - event response

- (void)voiceButtomClick {
    _isStartVoice = (_isStartVoice == YES) ? NO: YES;
    _envStepView.isAllowPlayVoice = _isStartVoice;
    _identifyStepView.isStartActionVoice = _isStartVoice;
    NSString *imageName = (_isStartVoice == YES) ? @"startVoice": @"stopVoice";
    [_voiceBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

#pragma mark - private method

- (void)startEnvStepView {
    [self.envStepView stepEnter];
}

#pragma mark - setter and getter

- (void)setupUI {
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 标题
    UILabel *actionLabel = [UILabel new];
    actionLabel.font = [UIFont systemFontOfSize:33];
    actionLabel.text = @"请凝视屏幕";
    actionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:actionLabel];
    _actionLabel = actionLabel;
    [actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(0.078 * screenH);
    }];
    
    // 下面步骤完成进度
    SSStepView *actionFinishNumberView = [[SSStepView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:actionFinishNumberView];
    [actionFinishNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.mas_equalTo(-0.087 * screenH);
        make.size.mas_equalTo(CGSizeMake(204, 38));
    }];
    
    // 错误提示框
    SSPromptView *promptView = [SSPromptView new];
    [self.view addSubview:promptView];
    promptView.hidden = YES;
    [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_equalTo(CGSizeMake(315.0 / 375 * screenW, 208));
    }];
    
    // 声音控制按钮
    UIButton *voiceBtn = [UIButton new];
    [self.view addSubview:voiceBtn];
    [voiceBtn setImage:[UIImage imageNamed:@"startVoice"] forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(voiceButtomClick) forControlEvents:UIControlEventTouchUpInside];
    [voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-15);
        make.centerY.equalTo(_titleLabel);
    }];
    
    // 识别成功提示框
    SSSuccessPromptView *successPromptView = [SSSuccessPromptView new];
    [self.view addSubview:successPromptView];
    successPromptView.hidden = YES;
    
    [successPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_equalTo(CGSizeMake(110, 100));
    }];
    
    _actionFinishNumberView = actionFinishNumberView;
    _promptView = promptView;
    _voiceBtn = voiceBtn;
    _successPromptView = successPromptView;
}

@end
