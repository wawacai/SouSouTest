//
//  idCardResultViewController.m
//  JYVivoUI2
//
//  Created by junyufr on 16/8/31.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "idCardResultViewController.h"
#import "idCardAdoptMode.h"
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>

@interface idCardResultViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) UITextField *name;
@property (strong, nonatomic) UITextField *idCardNumber;

@property (strong, nonatomic) NSDictionary *infoDic;

@property (strong, nonatomic) UITextField *nameTextField;//姓名框

@property (strong, nonatomic) UITextField *idCardNumberTextField;//证件号框

@property (strong, nonatomic) UIImage *idCardImage;//证件照全图
@property (strong, nonatomic) UIImage *idCardImageShear;//剪切后的证件照


@property (strong, nonatomic) NSString *sName;//如果有传值记录姓名(扫描获取才有)
@property (strong, nonatomic) NSString *sNumber;//如果有传值记录证件号



@property (strong, nonatomic) NSString *gender;//性别
@property (strong, nonatomic) NSString *nation;//民族
@property (strong, nonatomic) NSString *birthday;//生日
@property (strong, nonatomic) NSString *address;//住址


//显示其他信息的label
@property(nonatomic,weak) UILabel *sexLabel;//性别
@property(nonatomic,weak) UILabel *forkLabel;//民族
@property(nonatomic,weak) UILabel *birthdayLabel;//生日
@property(nonatomic,weak) UILabel *addressLabel;//地址

@end

@implementation idCardResultViewController


-(void)setDict:(NSDictionary *)dict
{
    
    if (dict == nil) {
        return;
    }
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    
    
    
    self.infoDic = [dict objectForKey:kOpenSDKCardResultTypeCardItemInfo];
//    self.idCardImage = [dict valueForKey:kOpenSDKCardResultTypeOriginImage];//取证件照
    mode.idCardImage = [dict valueForKey:kOpenSDKCardResultTypeImage];//取剪切后的证件照
    
    NSData *data = UIImageJPEGRepresentation(mode.idCardImage, 0.7);
    
    mode.idCardImage = [UIImage imageWithData:data];
    
    NSLog(@"%lf--%lf",mode.idCardImage.size.width,mode.idCardImage.size.height);

    
    //证件照类型（一代，二代，正面反面）
    NSString *cardType = [dict valueForKey:kOpenSDKCardResultTypeCardName];
    if ([cardType  isEqual: @"第二代身份证背面"]) {
        //如果是背面
        [self downloadBox];
    }
    
//    mode.idCardImage = self.idCardImageShear;//证件照赋值给模型
    
    NSString *nameString = [self.infoDic valueForKey:kCardItemName];
    if (nameString == nil)
    {
        nameString = @"";
    }
    _sName = nameString;
    
    NSString *idNumber = [self.infoDic valueForKey:kCardItemIDNumber];
    if (idNumber == nil)
    {
        idNumber = @"";
    }
    _sNumber = idNumber;
    //性别
    NSString *gender = [self.infoDic valueForKey:kCardItemGender];
    if (gender == nil)
    {
        gender = @"";
    }
    _gender = gender;
    
    
    //民族
    NSString *nation = [self.infoDic valueForKey:kCardItemNation];
    if (nation == nil)
    {
        nation = @"";
    }
    _nation = nation;
    
    //生日
    NSString *birthday = [self.infoDic valueForKey:kCardItemBirthday];
    if (birthday == nil)
    {
        birthday = @"";
    }
    _birthday = birthday;
    
    //住址
    NSString *address = [self.infoDic valueForKey:kCardItemAddress];
    if (address == nil)
    {
        address = @"";
    }
    _address = address;
}


//选择窗口
-(void)downloadBox
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请拍摄身份证正面！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    alert.delegate = self;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        
    }
    else if(buttonIndex == 1)
    {
        //选择确定，返回上个界面
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    if (toBeString.length > 18)
    {
        textField.text = [toBeString substringToIndex:18];
    }
}


//点击空白收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //收起键盘 （这句有效！）
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor colorWithRed:7/255.0 green:136/255.0 blue:202/255.0 alpha:1];//7,136,202
    
    
    
    //开始按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/10*8.5, 100, 40)];
    button.layer.cornerRadius = 15;//圆角
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(touchBtn) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor grayColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    //请输入登录信息字样
    UILabel *titleLable = [[UILabel alloc ] initWithFrame:CGRectMake((self.view.frame.size.width-210)/2, 150 , 210, 20)];
    titleLable.text = @"请仔细核对信息，如果有误请点击";
    titleLable.textAlignment = NSTextAlignmentCenter;//居中显示
    titleLable.font = [UIFont systemFontOfSize:13];
    [titleLable setTextColor:[UIColor whiteColor]];
    [self.view addSubview:titleLable];
    
    //左边的白线
    UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleLable.frame.origin.y +(titleLable.frame.size.height/2),titleLable.frame.origin.x , 2)];
    leftLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:leftLineView];
    
    //右边的白线
    UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(titleLable.frame.origin.x + titleLable.frame.size.width  ,titleLable.frame.origin.y +(titleLable.frame.size.height/2) ,self.view.frame.size.width-40 - titleLable.frame.size.width -(titleLable.frame.origin.x - 20)+20, 2)];
    rightLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightLineView];
    
    
    //头部
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    topView.backgroundColor = [UIColor colorWithRed:17/255.0 green:115/255.0 blue:191/255.0 alpha:1];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, topView.frame.size.width-120, topView.frame.size.height -20)];
    titleLabel.text = @"信息核对";
    titleLabel.font = [UIFont systemFontOfSize:22];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;//居中显示
    [topView addSubview:titleLabel];
    
    [self.view addSubview:topView];
    
    //返回按钮
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 60)];
    [backButton addTarget:self action:@selector(touchBackBtn) forControlEvents:UIControlEventTouchUpInside];
//    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor colorWithRed:17/255.0 green:115/255.0 blue:191/255.0 alpha:1]];
    [backButton setImage:[UIImage imageNamed:@"BackWhite"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [topView addSubview:backButton];
    
    
    //姓名的背景
    UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 130 - 10, leftLineView.frame.origin.y + leftLineView.frame.size.height + 40, 200 + 60 + 20 , 30)];
    nameView.backgroundColor = [UIColor colorWithRed:94/255.0 green:200/255.0 blue:210/255.0 alpha:1];
    [self.view addSubview:nameView];
    nameView.layer.cornerRadius = 5;//圆角
    nameView.layer.masksToBounds = YES;
    
    //卡号的背景
    UIView *numberView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 130 - 10, nameView.frame.origin.y + 50, 200 + 60 + 20 , 30)];
    numberView.backgroundColor = [UIColor colorWithRed:94/255.0 green:200/255.0 blue:210/255.0 alpha:1];
    [self.view addSubview:numberView];
    numberView.layer.cornerRadius = 5;//圆角
    numberView.layer.masksToBounds = YES;
    
    
    
    //姓名标题
    UILabel *nameLabel = [[UILabel alloc ]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 130, nameView.frame.origin.y, 60, 30)];
    nameLabel.text = @"姓名";
    nameLabel.textAlignment = NSTextAlignmentCenter;//居中显示
    nameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nameLabel];
    
    //姓名框
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 70, nameView.frame.origin.y, 200, 30)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;//显示边框样式
    nameTextField.keyboardType=UIKeyboardTypeDefault;//键盘样式
    self.name = nameTextField;
    self.nameTextField = nameTextField;
    [self.view addSubview:nameTextField];
    if (_sName&&[self.str  isEqual: @"YES"]) {
        nameTextField.text = _sName;
    }
    
    
    
    
    //卡号标题
    UILabel *idCardNumberLabel = [[UILabel alloc ]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 130, numberView.frame.origin.y, 60, 30)];
    idCardNumberLabel.text = @"身份证";
    idCardNumberLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:idCardNumberLabel];
    
    //证件号框
    UITextField *idCardNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 70, numberView.frame.origin.y, 200, 30)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:idCardNumberTextField];
    idCardNumberTextField.font = [UIFont systemFontOfSize:13];
    idCardNumberTextField.borderStyle = UITextBorderStyleRoundedRect;//显示边框样式
    idCardNumberTextField.keyboardType=UIKeyboardTypeNumberPad;//键盘样式
    self.idCardNumber = idCardNumberTextField;
    self.idCardNumberTextField = idCardNumberTextField;
    [self.view addSubview:idCardNumberTextField];
    if (_sNumber&&[self.str  isEqual: @"YES"]) {
        idCardNumberTextField.text = _sNumber;
    }
    
    //重新开始按钮
    UIButton *reStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(numberView.frame.origin.x + numberView.frame.size.width - 100, numberView.frame.origin.y + numberView.frame.size.height + 10,100, 20)];
    reStartBtn.backgroundColor = self.view.backgroundColor;
    reStartBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [reStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reStartBtn setTitle:@"重新拍摄" forState:UIControlStateNormal];
    reStartBtn.titleLabel.textAlignment = NSTextAlignmentLeft;//靠右显示
    [reStartBtn addTarget:self action:@selector(touchBackBtn) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:reStartBtn];
    
    
    //    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    //    //显示剪切后的证件照
    //    UIImageView *idCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/6, 100, self.view.frame.size.width/6*4, (self.view.frame.size.width/6*4)/85.0*54.0)];
    //
    //    idCardImageView.image = [UIImage imageWithCGImage:mode.idCardImage.CGImage scale:1 orientation:UIImageOrientationUp];
    //    [self.view addSubview:idCardImageView];
    //显示其他信息
    //性别
    UILabel *sexL = [[UILabel alloc]initWithFrame:CGRectMake(numberView.frame.origin.x, numberView.frame.origin.y + numberView.frame.size.height + 35 , 50, 20)];
    sexL.font = [UIFont systemFontOfSize:12];
    sexL.text = @"性别：";
    sexL.textColor = [UIColor blackColor];
    sexL.textAlignment = NSTextAlignmentLeft;//右边显示
    UILabel *sexL2 = [[UILabel alloc]initWithFrame:CGRectMake(sexL.frame.origin.x+sexL.frame.size.width, sexL.frame.origin.y, 50, 20)];
    sexL2.font = [UIFont systemFontOfSize:12];
    sexL2.textColor = [UIColor colorWithRed:220/255.0 green:207/255.0 blue:197/255.0 alpha:1];
    self.sexLabel = sexL2;
//    [self.view addSubview:sexL];
//    [self.view addSubview:sexL2];
    if (_gender&&[self.str  isEqual: @"YES"]) {
        sexL2.text = _gender;
    }
    
    //民族
    UILabel *forkL = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, numberView.frame.origin.y + numberView.frame.size.height + 35, 50, 20)];
    forkL.font = [UIFont systemFontOfSize:12];
    forkL.text = @"民族：";
    forkL.textColor = [UIColor blackColor];
    forkL.textAlignment = NSTextAlignmentLeft;//右边显示
    UILabel *forkL2 = [[UILabel alloc]initWithFrame:CGRectMake(forkL.frame.origin.x+forkL.frame.size.width, forkL.frame.origin.y, 50, 20)];
    forkL2.font = [UIFont systemFontOfSize:12];
    forkL2.textColor = [UIColor colorWithRed:220/255.0 green:207/255.0 blue:197/255.0 alpha:1];
    self.forkLabel = forkL2;
//    [self.view addSubview:forkL];
//    [self.view addSubview:forkL2];
    if (_nation&&[self.str  isEqual: @"YES"]) {
        forkL2.text = _nation;
    }
    
    //出生日期
    UILabel *birthdayL = [[UILabel alloc]initWithFrame:CGRectMake(numberView.frame.origin.x, forkL.frame.origin.y+forkL.frame.size.height, 50, 20)];
    birthdayL.font = [UIFont systemFontOfSize:12];
    birthdayL.text = @"出生：";
    birthdayL.textColor = [UIColor blackColor];
    birthdayL.textAlignment = NSTextAlignmentLeft;//右边显示
    UILabel *birthdayL2 = [[UILabel alloc]initWithFrame:CGRectMake(birthdayL.frame.origin.x+birthdayL.frame.size.width, birthdayL.frame.origin.y, 180, 20)];
    birthdayL2.font = [UIFont systemFontOfSize:12];
    birthdayL2.textColor = [UIColor colorWithRed:220/255.0 green:207/255.0 blue:197/255.0 alpha:1];
    self.birthdayLabel = birthdayL2;
//    [self.view addSubview:birthdayL];
//    [self.view addSubview:birthdayL2];
    if (_birthday&&[self.str  isEqual: @"YES"]) {
        birthdayL2.text = _birthday;
    }
    
    //住址
    UILabel *addressL = [[UILabel alloc]initWithFrame:CGRectMake(numberView.frame.origin.x, birthdayL.frame.origin.y+birthdayL.frame.size.height, 50, 40)];
    addressL.font = [UIFont systemFontOfSize:12];
    addressL.text = @"住址：";
    addressL.textColor = [UIColor blackColor];
    addressL.textAlignment = NSTextAlignmentLeft;//右边显示
    UILabel *addressL2 = [[UILabel alloc]initWithFrame:CGRectMake(addressL.frame.origin.x+addressL.frame.size.width, addressL.frame.origin.y, nameView.frame.size.width + self.nameTextField.frame.size.width - addressL.frame.size.width, 40)];
    addressL2.font = [UIFont systemFontOfSize:12];
    addressL2.numberOfLines = 0;
    addressL2.textColor = [UIColor colorWithRed:220/255.0 green:207/255.0 blue:197/255.0 alpha:1];
    self.addressLabel = addressL2;
//    [self.view addSubview:addressL];
//    [self.view addSubview:addressL2];
    if (_address&&[self.str  isEqual: @"YES"]) {
        addressL2.text = _address;
    }

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


//返回按钮
-(void)touchBackBtn
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


//弹窗
-(void)messageBoxWithString:(NSString *)string
{
    //收起键盘 （这句有效！）
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.delegate = self;
    // 2.显示在屏幕上
    [alert show];
}

//点继续按钮
- (void)touchBtn
{
    if (self.idCardNumberTextField.text.length!=18) {
        [self messageBoxWithString:@"证件号格式不正确"];
        return;
    }
    
    if (self.idCardNumberTextField.text.length == 0||self.nameTextField.text.length == 0) {
        [self messageBoxWithString:@"姓名和证件号为必填项"];
        return;
    }
    
    idCardAdoptMode *mode =[[idCardAdoptMode alloc] init];
    mode.name = self.name.text;
    mode.idCardNumber = self.idCardNumber.text;
    
    //进入活体检测
    [self performSegueWithIdentifier:@"login" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
