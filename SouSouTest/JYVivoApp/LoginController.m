//
//  ViewController.m
//  JYVivoApp
//
//  Created by jock li on 16/4/24.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "LoginController.h"
#import "LoginTextField.h"
#import "CustomAccessoryView.h"
#import "IDInputView.h"
#import "Person.h"
#import "LoginCheckBox.h"
#import "idCardAdoptMode.h"
#import "RecognitionController.h"
#import "Masonry.h"
#import "UIColor+HexString.h"

#define DISPLACEMENT_VIEW_HIGHT -154


@interface LoginController () <UITextFieldDelegate, CustomAccessoryViewDelegate,UIAlertViewDelegate>
{
//    NSMutableArray* _accessoryNameSources;
//    NSMutableArray* _accessoryIdSources;
}


@property (strong, nonatomic) IBOutlet CustomAccessoryView *customAccessoryView;
@property (strong, nonatomic) IBOutlet IDInputView *idInputView;
@property (strong, nonatomic) IBOutlet Person *personInfo;

//登陆按钮属性
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation LoginController



bool projectIDIsNil = YES;

static NSString *phoneNumber;

static NSString *password;




-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noRememberView" object:self];
}


//点击开始
- (IBAction)start:(id)sender {

    NSString *projectID = [[NSUserDefaults standardUserDefaults] objectForKey:@"projectID"];
    
    
    bool projectIDExist = YES;
    
    if ([projectID  isEqual: @""] || projectID == (NULL))
        projectIDExist = NO;
    
    if (projectIDExist == NO && projectIDIsNil == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未填写“项目ID”,无法联网检测,是否跳转并设置“项目ID”?" delegate:self cancelButtonTitle:@"去设置" otherButtonTitles:@"继续检测", nil];
        alert.delegate = self;
        [alert show];
        return;
    }
    projectIDIsNil = YES;
    
//    [self performSegueWithIdentifier:@"startL" sender:nil];
    UIStoryboard *recSb = [UIStoryboard storyboardWithName:@"JYVivo" bundle:nil];
    RecognitionController *rec = [recSb instantiateViewControllerWithIdentifier:@"rec"];
//    [self.navigationController pushViewController:rec animated:YES];
    [self presentViewController:rec animated:YES completion:nil];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //setUp
        [self performSegueWithIdentifier:@"setUp" sender:nil];
    }
    else if(buttonIndex == 1)
    {
        //登陆
//        projectIDIsNil = NO;
        [self performSegueWithIdentifier:@"startL" sender:nil];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"projectID"]==nil) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"projectID"];
//    }

    //登陆按钮圆角
    self.loginBtn.layer.cornerRadius = 6;
    self.loginBtn.layer.masksToBounds = YES;
    
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    mode.numberOne = 0;
    
//    //左边的白线
//    UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(20, self.titleView.frame.origin.y+130+(self.titleView.frame.size.height/2), self.view.frame.size.width/2-60-20-1, 2)];
//    leftLineView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:leftLineView];
//    
//    //右边的白线
//    UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+self.titleView.frame.size.width/2, self.titleView.frame.origin.y+130+(self.titleView.frame.size.height/2), self.view.frame.size.width/2-60-20-1, 2)];
//    rightLineView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:rightLineView];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.title = @"人脸认证";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    [self setupUI];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    mode.idCardImage = nil;
}

// 过滤源数组
- (NSArray*)getOptions:(NSArray*)source filter:(NSString*)filter
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString* item in source)
    {
        if ([item hasPrefix:filter])
        {
            [array addObject:item];
        }
    }
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return array;
}

- (void)onIdChanged:(id)sender
{
//    self.customAccessoryView.options = [self getOptions:_accessoryIdSources filter:self.loginIDField.textField.text];
}

- (void)onNameChanged:(id)sender {
//    self.customAccessoryView.options = [self getOptions:_accessoryNameSources filter:self.loginNameField.textField.text];
}

- (void)closeKeyboard
{
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    mode.writingIdNumber = NO;
    

}

//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    // 偏移视图来保持软键盘开启时输入框区域可见
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.transform = CGAffineTransformMakeTranslation(0, DISPLACEMENT_VIEW_HIGHT);
//    }];
//    
//}
//
//-(void)textFieldDidEndEditing:(UITextField *)textField {
//
//    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
//    mode.writingIdNumber = NO;
//    
//    // 还原对视图的偏移
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.transform = CGAffineTransformIdentity;
//    }];
//}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


- (void)showError:(NSString*)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}



- (void)saveOptionsIfNeed:(NSString*)option to:(NSMutableArray*)target saveKey:(NSString*)key
{
    if (![target containsObject:option])
    {
        [target addObject:option];
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:target forKey:key];
        [userDefaults synchronize];
    }
}

// 用于在结果页面直接导航返回到本页面的 segue 点
- (IBAction)unwindSegueToLoginController:(UIStoryboardSegue*)segue
{
    
}

#pragma mark - private method
- (UILabel *)labelWithTitle:(NSString *)title bgColorStr:(NSString *)bgColorStr textColorStr:(NSString *)textColorStr font:(CGFloat)font {
    UILabel *label = [UILabel new];
    label.text = title;
    label.backgroundColor = [UIColor colorWithHexString:bgColorStr];
    label.textColor = [UIColor colorWithHexString:textColorStr];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:font];
    return label;
}

#pragma mark - setter and getter
- (void)setupUI {
//    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    // 上部进度指示
    UIImageView *imageView = [UIImageView new];
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"Group_1"];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.height.mas_equalTo(20);
    }];
    
    // 提示文字
    UILabel *promptLabel = [self labelWithTitle:@"请将脸部置于提示框内，并按提示做动作" bgColorStr:@"#ffffff" textColorStr:@"#666666" font:16];
    [self.view addSubview:promptLabel];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(imageView.mas_bottom).offset(0.096 * screenH);
    }];
    
    // 头像图片
    UIImageView *iconImageView = [UIImageView new];
    [self.view addSubview:iconImageView];
    iconImageView.image = [UIImage imageNamed:@"scan"];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(promptLabel.mas_bottom).offset(0.09 * screenH);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(-15);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(-0.075 * screenH);
    }];
}



@end
