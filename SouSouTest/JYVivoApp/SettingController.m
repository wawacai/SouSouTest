//
//  SettingController.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/26.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "JYVivoUI2.h"
#import "SettingController.h"
#import "PhotoNumberDialog.h"


@interface SettingController () <UIAlertViewDelegate, PhotoNumberDialogDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate> {
    BOOL _bShowProjectName, _bShowControlVersion, _bShowAppVersion;
}

@property (strong, nonatomic) IBOutlet PhotoNumberDialog *photoNumberDialog;

@property (strong,nonatomic) UITextField *projectID;


@property(strong,nonatomic) UIView *downView;

@property(strong,nonatomic) UITextView *textView;

@property(strong,nonatomic) NSMutableArray *cellArray;

@end

@implementation SettingController

-(NSMutableArray *)cellArray
{
    if (_cellArray == nil)
    {
        
        NSMutableArray *array = [NSMutableArray array];
        
        _cellArray = array;
        
    }
    return _cellArray;
}

//点击return键后
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.projectID.text forKey:@"projectID"];
    
    return YES;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.photoNumberDialog setDelegate:self];
    
    self.projectID = [[UITextField alloc] initWithFrame:CGRectMake(30, 10, self.view.bounds.size.width-50, 30)];
    self.projectID.borderStyle = UITextBorderStyleRoundedRect;
    self.projectID.placeholder = @"请输入项目ID";
    

    
    self.projectID.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"projectID"];
    
    self.projectID.returnKeyType =UIReturnKeyDone;
    self.projectID.delegate = self;
    
    //取消分割线
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}


-(void)close:(id)sender
{
    
    [[NSUserDefaults standardUserDefaults] setObject:self.projectID.text forKey:@"projectID"];
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Setting cell actions
-(void)settingProjectUrl
{
    
    //弹窗
    
    if (self.downView == nil) {
        UIView *downView = [[UIView alloc] init];
        
        self.downView = downView;
        
        self.downView.backgroundColor = [UIColor blackColor];
        
        
        //标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 40)];
        
        label.text = @"服务器URL";
        
        label.textAlignment = NSTextAlignmentCenter;//居中显示
        
        label.font = [UIFont systemFontOfSize:18];
        
        label.textColor = [UIColor whiteColor];
        
        label.backgroundColor = self.downView.backgroundColor;
        
        [self.downView addSubview:label];
        
        
        //输入框
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(3, 45 , 200-6, 75)];
        
        textView.scrollEnabled = YES; //可以滑动
        textView.editable = YES;  //是否允许编辑内容
        textView.font = [UIFont systemFontOfSize:15];
        textView.keyboardType = UIKeyboardTypeURL;//键盘类型
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;//首字母不大写
        textView.text = [[JYAVSessionHolder instance] serviceUrl];
        [self.downView addSubview:textView];
        self.textView = textView;
        self.textView.delegate = self;
        
        //确定取消按钮
        UIButton *falseBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 125, 80, 40)]; //取消
        
        UIButton *trueBtn= [[UIButton alloc] initWithFrame:CGRectMake(110, 125, 80, 40)]; //确定
        
        [falseBtn setTitle:@"取消" forState:UIControlStateNormal];
        falseBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [falseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [falseBtn addTarget:self action:@selector(touchFalseBtn) forControlEvents:UIControlEventTouchDown];
        
        [trueBtn setTitle:@"确定" forState:UIControlStateNormal];
        trueBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [trueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [trueBtn addTarget:self action:@selector(touchTrueBtn) forControlEvents:UIControlEventTouchDown];
        
        falseBtn.backgroundColor = [UIColor whiteColor];
        
        trueBtn.backgroundColor = [UIColor whiteColor];
        
        self.downView.layer.cornerRadius = 5;
        self.downView.layer.masksToBounds = YES;
        
        trueBtn.layer.cornerRadius = 5;
        trueBtn.layer.masksToBounds = YES;
        
        falseBtn.layer.cornerRadius = 5;
        falseBtn.layer.masksToBounds = YES;
        
        [self.downView addSubview:falseBtn];
        [self.downView addSubview:trueBtn];
        
        [self.view addSubview:self.downView];
        
    }
    //重新设定位置
    
    self.downView.frame = CGRectMake(-200, -300, 200, 170);
    
    self.tableView.scrollEnabled = NO;

    for (UITableViewCell *cell in self.cellArray)
    {
        cell.userInteractionEnabled = NO;
    }
    
    self.downView.transform = CGAffineTransformRotate(self.downView.transform, M_PI);
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.downView.transform = CGAffineTransformRotate(self.downView.transform, M_PI);
        
        self.downView.frame = CGRectMake(self.view.frame.size.width/2-100, 100, 200, 170);
        
    } completion:^(BOOL finished)
    {
        self.downView.transform = CGAffineTransformIdentity;
        
        self.downView.userInteractionEnabled = YES;
        self.tableView.scrollEnabled = YES;
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [self closeDownView];
}


-(void)touchTrueBtn
{
    //确定
    [[JYAVSessionHolder instance] setServiceUrl:self.textView.text];
    [self closeDownView];
}

-(void)touchFalseBtn
{
    //取消
    [self closeDownView];
}

-(void)closeDownView
{
    __weak typeof (self) weakSelf = self;
    
    self.downView.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.4 animations:^{
        
        weakSelf.downView.transform = CGAffineTransformRotate(weakSelf.downView.transform, M_PI);
        
        weakSelf.downView.frame = CGRectMake(weakSelf.tableView.frame.size.width, -300, 200, 170);
        
    } completion:^(BOOL finished)
    {
        weakSelf.downView.transform = CGAffineTransformIdentity;
        
        for (UITableViewCell *cell in weakSelf.cellArray)
        {
            cell.userInteractionEnabled = YES;
        }
        weakSelf.textView.text = [[JYAVSessionHolder instance] serviceUrl];
        
    }];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [JYAVSessionHolder instance].serviceUrl = textField.text;
    }
}

-(void)settingPhotoNumbers
{
    [self.view endEditing:YES];
    
    self.photoNumberDialog.selectedIndex = [[JYAVSessionHolder instance] savePhotoNum];
    [self.photoNumberDialog show];
}

-(void)photoNumberDialog:(PhotoNumberDialog *)photoNumberDialog selected:(NSInteger)selectedIndex
{
    [[JYAVSessionHolder instance] setSavePhotoNum:(int)selectedIndex];
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 6;
    if (_bShowProjectName)
    {
        rows++;
    }
    if (_bShowControlVersion)
    {
        rows++;
    }
    if (_bShowAppVersion)
    {
        rows++;
    }
    return rows;
}

-(NSInteger)convertToBaseRow:(NSInteger)row
{
    NSInteger mapRow = 0;
    for (NSInteger baseRow = 0; baseRow < 6; baseRow++)
    {
        if (mapRow == row)
        {
            return baseRow;
        }
        mapRow++;
        if ((_bShowProjectName && baseRow == 1) || (_bShowControlVersion && baseRow == 4) || (_bShowAppVersion && baseRow == 5))
        {
            if (mapRow == row)
            {
                return -baseRow;
            }
            mapRow++;
        }
    }
    return -1;
}

-(void)updateExpandCell:(UITableViewCell*)cell label:(NSString*)label expanded:(BOOL) expanded
{
    UILabel *uilabel = [cell viewWithTag:1];
    UIImageView *uiimageview = [cell viewWithTag:2];
    
    uilabel.text = label;
    uiimageview.transform = expanded ? CGAffineTransformRotate(CGAffineTransformIdentity, 3.1415926) : CGAffineTransformIdentity;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self convertToBaseRow: [indexPath row]];
    UITableViewCell *cell = nil;
    switch (row)
    {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            cell.textLabel.text = @"服务器URL";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            [self updateExpandCell:cell label:@"\t项目ID" expanded:_bShowProjectName];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            cell.textLabel.text = @"保存照片";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            [self updateExpandCell:cell label:@"\t控件版本号" expanded:_bShowControlVersion];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            break;
        case 5:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            [self updateExpandCell:cell label:@"\tapp版本号" expanded:_bShowAppVersion];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            break;
        case 3:
            cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            cell.textLabel.text = @"倒计时背景声";
            cell.textLabel.font = [UIFont systemFontOfSize:17];

            [cell.contentView addSubview:[self newSwitch]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case -1: // 项目ID
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetialCell"];
            //cell.textLabel.text = [[JYAVSessionHolder instance] projectName];
            cell.textLabel.text = @"";
            [cell.contentView addSubview:self.projectID];
            
            break;
        case -4: // 控件版本号详情
            
           // cell = [tableView dequeueReusableCellWithIdentifier:@"DetialCell"];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            
            cell.textLabel.text = [[JYAVSessionHolder instance] libVersion];
            cell.detailTextLabel.text =[[JYAVSessionHolder instance] projectName];
            
            [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:15]];

            break;
        case -5: // app版本号详情
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetialCell"];
            cell.textLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            break;
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            break;
    }
    
    [self.cellArray addObject:cell];
    
    return cell;
}

-(UISwitch*)newSwitch
{
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 10, 50, 30)];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"switchTick"];
    if ([str  isEqual: @"NO"])
    {
        switchView.on = NO;
    }else
    {
        switchView.on = YES;
    }
    [switchView addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    
    return switchView;
}


-(void)switchAction
{
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"switchTick"];
    if ([str  isEqual: @"NO"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"switchTick"];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"switchTick"];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self convertToBaseRow: [indexPath row]];
    return row >= 0 ? 0 : 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [self convertToBaseRow: [indexPath row]];
    switch (row)
    {
        case 0: // 服务器URL
            [self settingProjectUrl];
            break;
            
        case 1: // 项目名称
            _bShowProjectName = !_bShowProjectName;
            [tableView reloadData];
            break;
            
        case 2: // 保存照片
            [self settingPhotoNumbers];
            break;
            
        case 3: // 倒计时背景声
            break;
            
        case 4: // 控件版本号
            _bShowControlVersion = !_bShowControlVersion;
            [tableView reloadData];
            break;
            
        case 5: // app版本号
            _bShowAppVersion = !_bShowAppVersion;
            [tableView reloadData];
            break;

        default:
            break;
    }
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
