//
//  LoginTextField.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/26.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "LoginTextField.h"
#import "rememberNameView.h"
#import "idCardAdoptMode.h"


#define TEXTFIELD_FRAME CGRectMake(_labelWidth, 0, size.width - _labelWidth - _rightPadding, size.height)
#define CONTEXT_RECT   CGRectMake(size.width - _rightPadding, 0, _rightPadding, size.height)

#define REMEMBERNAMEVIEW_FRAME  CGRectMake(self.label.frame.size.width,self.frame.size.height, self.textField.frame.size.width, 30 * number)

#define REMEMBERNAMEVIEW_FRAME_AT_NOW  CGRectMake(self.label.frame.size.width,self.frame.size.height, self.textField.frame.size.width, 30 * mutableArray.count)




@interface LoginTextField ()<UITextFieldDelegate> {
    BOOL _inited;
    CGFloat _labelWidth;
    CGFloat _rightPadding;
}

@property(nonatomic,weak)UIView *rememberNameView;
@property(nonatomic,strong)NSMutableArray *btnArray;



@end

@implementation LoginTextField


//姓名
NSString *name1;
NSString *name2;
NSString *name3;
NSString *name4;
NSString *name5;

NSMutableArray *mutableArray;



-(void)initSelf
{
    if (_inited)
    {
        return;
    }
    _inited = YES;
    _labelWidth = 40;
    _rightPadding = 10;
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
    UILabel *label = [UILabel new];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    UITextField *textField = [UITextField new];
    textField.returnKeyType = UIReturnKeyNext;
    [self addSubview:textField];
    
    self.label = label;
    self.textField = textField;
    
    if (self.tag == 10)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification" object:self.textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNO1) name:@"setNO.1" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNO2) name:@"setNO.2" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNO3) name:@"setNO.3" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNO4) name:@"setNO.4" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNO5) name:@"setNO.5" object:nil];
        
        
        //添加一键清除功能
        CGRect rx = [ UIScreen mainScreen ].bounds;
        
        UIButton *deleteTxtBtn = [[UIButton alloc] initWithFrame:CGRectMake(rx.size.width-80, 12, 20, 20)];
        [deleteTxtBtn setImage:[UIImage imageNamed:@"deleteTxt"] forState:UIControlStateNormal];
        
        [deleteTxtBtn addTarget:self action:@selector(touchDeleteTxtBtn) forControlEvents:UIControlEventTouchUpInside];
        deleteTxtBtn.backgroundColor = [UIColor whiteColor];
        
        deleteTxtBtn.layer.cornerRadius = 10;
        deleteTxtBtn.layer.masksToBounds = YES;
        self.deleteTxtBtn = deleteTxtBtn;
        
        if (self.textField.text.length == 0)
        {
            self.deleteTxtBtn.alpha = 0;
        }
        
        [self addSubview:deleteTxtBtn];

    }
    if (self.tag == 11)
    {
        [self.textField addTarget:self  action:@selector(touchesBeginSelf)  forControlEvents:UIControlEventTouchDown];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(touchesSelf)
                                                    name:@"UITextFieldTextDidChangeNotification" object:nil];
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        self.clipsToBounds = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchOneBtn) name:@"touchOneBtn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchTwoBtn) name:@"touchTwoBtn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchThreeBtn) name:@"touchThreeBtn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchFourBtn) name:@"touchFourBtn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchFiveBtn) name:@"touchFiveBtn" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noRememberView) name:@"noRememberView" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLoadView) name:@"reLoadView" object:nil];
        
        
//        ////////v  以下这段记得删 测试使用
//        //临时设置账户
//        [[NSUserDefaults standardUserDefaults] setObject:@"张三" forKey:@"name:NO.1"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"李四" forKey:@"name:NO.2"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"王五" forKey:@"name:NO.3"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"马六" forKey:@"name:NO.4"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"周七" forKey:@"name:NO.5"];
//        //临时密码
//        [[NSUserDefaults standardUserDefaults] setObject:@"111111111111111111" forKey:@"password:NO.1"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"222222222222222222" forKey:@"password:NO.2"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"333333333333333333" forKey:@"password:NO.3"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"444444444444444444" forKey:@"password:NO.4"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"555555555555555555" forKey:@"password:NO.5"];
//        ////////^
        
        
        
        //获取
        name1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.1"];//取出用户名
        name2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.2"];
        name3 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.3"];
        name4 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.4"];
        name5 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.5"];
        
        
        UIView *rememberNameView = [self newRememberNameView];
        self.rememberNameView = rememberNameView;
        [self addSubview:self.rememberNameView];
        self.rememberNameView.alpha = 0;
        
    }
}


//清空身份证
-(void)touchDeleteTxtBtn
{
    self.textField.text = @"";
    self.deleteTxtBtn.alpha = 0;
}

-(void)noRememberView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.rememberNameView.alpha == 1)
        {
            [UIView animateWithDuration:0.4 animations:^{
                self.rememberNameView.alpha = 0;
            }];
        }
    });
}

-(void)setNO1
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password:NO.1"];
        if (self.textField.text.length!=0)
        {
            self.deleteTxtBtn.alpha = 1;
        }
    });
}

-(void)setNO2
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password:NO.2"];
        if (self.textField.text.length!=0)
        {
            self.deleteTxtBtn.alpha = 1;
        }
    });
}

-(void)setNO3
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password:NO.3"];
        if (self.textField.text.length!=0)
        {
            self.deleteTxtBtn.alpha = 1;
        }
    });
}

-(void)setNO4
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password:NO.4"];
        if (self.textField.text.length!=0)
        {
            self.deleteTxtBtn.alpha = 1;
        }
    });
}

-(void)setNO5
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password:NO.5"];
        if (self.textField.text.length!=0)
        {
            self.deleteTxtBtn.alpha = 1;
        }
    });
}


-(void)touchOneBtn
{
    for (UIButton *btn in _btnArray)
    {
        if (btn.frame.origin.y == 0 && btn.alpha ==1)
        {
            self.textField.text = btn.titleLabel.text;
            if (btn.titleLabel.text == name1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.1" object:self];
            }
            if (btn.titleLabel.text == name2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.2" object:self];
            }
            if (btn.titleLabel.text == name3)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.3" object:self];
            }
            if (btn.titleLabel.text == name4)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.4" object:self];
            }
            if (btn.titleLabel.text == name5)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.5" object:self];
            }
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.rememberNameView.alpha = 0;
    }];
}
-(void)touchTwoBtn
{
    for (UIButton *btn in _btnArray)
    {
        if (btn.frame.origin.y == 30 && btn.alpha ==1)
        {
            self.textField.text = btn.titleLabel.text;
            if (btn.titleLabel.text == name1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.1" object:self];
            }
            if (btn.titleLabel.text == name2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.2" object:self];
            }
            if (btn.titleLabel.text == name3)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.3" object:self];
            }
            if (btn.titleLabel.text == name4)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.4" object:self];
            }
            if (btn.titleLabel.text == name5)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.5" object:self];
            }
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.rememberNameView.alpha = 0;
    }];
}

-(void)touchThreeBtn
{
    for (UIButton *btn in _btnArray) {
        if (btn.frame.origin.y == 60 && btn.alpha ==1)
        {
            self.textField.text = btn.titleLabel.text;
            if (btn.titleLabel.text == name1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.1" object:self];
            }
            if (btn.titleLabel.text == name2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.2" object:self];
            }
            if (btn.titleLabel.text == name3)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.3" object:self];
            }
            if (btn.titleLabel.text == name4)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.4" object:self];
            }
            if (btn.titleLabel.text == name5)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.5" object:self];
            }
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.rememberNameView.alpha = 0;
    }];
}

-(void)touchFourBtn
{
    for (UIButton *btn in _btnArray)
    {
        if (btn.frame.origin.y == 90 && btn.alpha ==1)
        {
            self.textField.text = btn.titleLabel.text;
            if (btn.titleLabel.text == name1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.1" object:self];
            }
            if (btn.titleLabel.text == name2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.2" object:self];
            }
            if (btn.titleLabel.text == name3)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.3" object:self];
            }
            if (btn.titleLabel.text == name4)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.4" object:self];
            }
            if (btn.titleLabel.text == name5)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.5" object:self];
            }
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.rememberNameView.alpha = 0;
    }];
}
-(void)touchFiveBtn
{
    for (UIButton *btn in _btnArray)
    {
        if (btn.frame.origin.y == 120 && btn.alpha ==1)
        {
            self.textField.text = btn.titleLabel.text;
            if (btn.titleLabel.text == name1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.1" object:self];
            }
            if (btn.titleLabel.text == name2)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.2" object:self];
            }
            if (btn.titleLabel.text == name3)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.3" object:self];
            }
            if (btn.titleLabel.text == name4)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.4" object:self];
            }
            if (btn.titleLabel.text == name5)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setNO.5" object:self];
            }
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.rememberNameView.alpha = 0;
    }];
}


-(void)touchesBeginSelf
{
    
    if (self.rememberNameView != nil)
    {
        if (self.textField.text.length==0)
        {
            int number = 0;
            
            for (UIButton *btn in self.btnArray)
            {
                if (btn.titleLabel.text.length>0)
                {
                    btn.alpha = 1;
                    
                    [UIView animateWithDuration:0.4 animations:^{
                        
                        btn.frame = CGRectMake(0,30*number ,self.textField.frame.size.width , 30);
                        
                    }];
                    
                    number++;
                }
            }
            self.rememberNameView.frame = REMEMBERNAMEVIEW_FRAME;
            
        }
        
        [UIView animateWithDuration:0.4 animations:^{
            self.rememberNameView.alpha = !self.rememberNameView.alpha;
        }];
        
        return;
    }else
    {
        //每次点击，获取偏好
        name1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.1"];//取出用户名
        name2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.2"];
        name3 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.3"];
        name4 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.4"];
        name5 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.5"];
        
        if (self.rememberNameView == nil)
        {
            UIView *rememberNameView = [self newRememberNameView];
            self.rememberNameView = rememberNameView;
            [self addSubview:self.rememberNameView];
            
            [self insertSubview:rememberNameView atIndex:0];
            
            [UIView animateWithDuration:0.4 animations:^{
                self.rememberNameView.alpha = 1;
            }];
        }
    }
}


-(NSMutableArray *)btnArray
{
    if (_btnArray == nil)
    {
        NSMutableArray *btnArray = [NSMutableArray array];
        
        _btnArray = btnArray;
    }
    
    return _btnArray;
}

-(UIView *)newRememberNameView
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (name1!= nil)
    {
        [array addObject:name1];
    }
    if (name2!= nil)
    {
        [array addObject:name2];
    }
    if (name3!= nil)
    {
        [array addObject:name3];
    }
    if (name4!= nil)
    {
        [array addObject:name4];
    }
    if (name5!= nil)
    {
        [array addObject:name5];
    }
    
    UIView *rememberNameV = [[rememberNameView alloc] initWithFrame:CGRectMake(self.label.frame.size.width,self.frame.size.height, self.textField.frame.size.width, 30 * array.count)];
    
    for (int num = 0; num < 5; num++)
    {
        UIButton * btn = [[UIButton alloc] init];
        
        btn.frame = CGRectMake(0,30*num ,self.textField.frame.size.width , 30);
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        btn.backgroundColor = [UIColor grayColor];
        
        [btn setTag:num];
        
        [self.btnArray addObject:btn];
        
        [rememberNameV addSubview:btn];
        
        
        
        if (num>=array.count)
        {
            btn.alpha = 0;
            btn.titleLabel.text = @"";
        }else
        {
            [btn setTitle:array[num] forState:UIControlStateNormal];
            
            btn.alpha = 1;
        }
    }
    rememberNameV.backgroundColor = [UIColor clearColor];
    rememberNameV.alpha = 0;
    rememberNameV.userInteractionEnabled = YES;
    
    return rememberNameV;
}



-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil && self.rememberNameView.alpha==1)
    {
        CGPoint tempoint = [self.rememberNameView convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.rememberNameView.bounds, tempoint))
        {
            view = self.rememberNameView;
        }
    }
    return view;
}




-(void)touchesSelf
{
    NSString *nameText = self.textField.text;
    
    long n = [self.textField.text length];
    
    if (mutableArray == nil) {
        mutableArray = [NSMutableArray array];
    }else
    {
        [mutableArray removeAllObjects];
    }
    
    if (name1 != nil) {
        for (int index = 0; index < n && index < name1.length; index++) {
            if ([nameText characterAtIndex:index] != [name1 characterAtIndex:index]) {
                break;
            }else{
                if (index==n-1||index==name1.length-1) {
                    [mutableArray addObject:name1];
                }
            }
        }
    }
    
    if (name2 != nil) {
        for (int index = 0; index < n && index < name2.length; index++) {
            if ([nameText characterAtIndex:index] != [name2 characterAtIndex:index]) {
                break;
            }else{
                if (index==n-1||index==name2.length-1) {
                    [mutableArray addObject:name2];
                }
            }
        }
    }
    if (name3 != nil) {
        for (int index = 0; index < n && index < name3.length; index++) {
            if ([nameText characterAtIndex:index] != [name3 characterAtIndex:index]) {
                break;
            }else{
                if (index==n-1||index==name3.length-1) {
                    [mutableArray addObject:name3];
                }
            }
        }
    }
    if (name4 != nil) {
        for (int index = 0; index < n && index < name4.length; index++) {
            if ([nameText characterAtIndex:index] != [name4 characterAtIndex:index]) {
                break;
            }else{
                if (index==n-1||index==name4.length-1) {
                    [mutableArray addObject:name4];
                }
            }
        }
    }
    if (name5 != nil) {
        for (int index = 0; index < n && index < name5.length; index++) {
            if ([nameText characterAtIndex:index] != [name5 characterAtIndex:index]) {
                break;
            }else{
                if (index==n-1||index==name5.length-1) {
                    [mutableArray addObject:name5];
                }
            }
        }
    }
    
    if (self.textField.text.length==0)
    {
        
        int number = 0;
        
        for (UIButton *btn in self.btnArray)
        {
            if (btn.titleLabel.text.length>0)
            {
                
                btn.alpha = 1;
                
                [UIView animateWithDuration:0.4 animations:^{
                    btn.frame = CGRectMake(0,30*number ,self.textField.frame.size.width , 30);
                }];
                
                number++;
            }
        }
        self.rememberNameView.frame = REMEMBERNAMEVIEW_FRAME;
        
        idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
        if (mode.writingIdNumber == NO)
        {
            
            self.rememberNameView.alpha = 1;
            
        }else
        {
            self.rememberNameView.alpha = 0;
        }
        
        return;
    }
    
    // 按顺序列出
    if (mutableArray.count == 0)
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.rememberNameView.alpha = 0;
        }];
        return;
    }
    
    self.rememberNameView.frame = REMEMBERNAMEVIEW_FRAME_AT_NOW;
    

    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    
    if (mode.writingIdNumber == NO)
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.rememberNameView.alpha = 1;
            
        }];
    }else
    {
        self.rememberNameView.alpha = 0;
    }
    
    
    
    
    
    for (int i = 0; i<5; i++)
    {
        UIButton *btn = self.btnArray[i];
        
        btn.alpha = 0;
    }
    
    for (int i = 0; i<mutableArray.count; i++)
    {
        
        if (mutableArray[i] == name1)
        {
            UIButton *btn = self.btnArray[0];
            
            btn.alpha = 1;
            
        }
        if (mutableArray[i] == name2)
        {
            UIButton *btn = self.btnArray[1];
            btn.alpha = 1;
            
        }
        if (mutableArray[i] == name3)
        {
            UIButton *btn = self.btnArray[2];
            btn.alpha = 1;
            
        }
        if (mutableArray[i] == name4)
        {
            UIButton *btn = self.btnArray[3];
            btn.alpha = 1;
            
        }
        if (mutableArray[i] == name5)
        {
            UIButton *btn = self.btnArray[4];
            btn.alpha = 1;
            
        }
    }
    
    int number = 0;
    for (int i = 0; i<5; i++)
    {
        UIButton *btn = self.btnArray[i];
        
        
        if (btn.alpha == 1)
        {
            
            [UIView animateWithDuration:0.4 animations:^{
                
                btn.frame = CGRectMake(0,30*number ,self.textField.frame.size.width , 30);
            }];
            
            number++;
        }
    }
}

-(void)reLoadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super didMoveToWindow];
        //每次点击，获取偏好
        name1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.1"];//取出用户名
        name2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.2"];
        name3 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.3"];
        name4 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.4"];
        name5 = [[NSUserDefaults standardUserDefaults] objectForKey:@"name:NO.5"];
        
        for (int num = 0; num < 5; num++)
        {
            
            UIButton * btn = self.btnArray[num];
            if (self.btnArray.count == 0)
            {
                break;
            }
            if (btn.tag == 0 && name1!=nil)
            {
                [btn setTitle:name1 forState:UIControlStateNormal];
                btn.alpha = 1;
            }else{
                btn.alpha =0;
            }
            if (btn.tag == 1 && name2!=nil)
            {
                [btn setTitle:name2 forState:UIControlStateNormal];
                btn.alpha = 1;
            }else{
                btn.alpha =0;
            }
            if (btn.tag == 2 && name3!=nil)
            {
                [btn setTitle:name3 forState:UIControlStateNormal];
                btn.alpha = 1;
            }else{
                btn.alpha =0;
            }
            if (btn.tag == 3 && name4!=nil)
            {
                [btn setTitle:name4 forState:UIControlStateNormal];
                btn.alpha = 1;
            }else{
                btn.alpha =0;
            }
            if (btn.tag == 4 && name5!=nil)
            {
                [btn setTitle:name5 forState:UIControlStateNormal];
                btn.alpha = 1;
            }else
            {
                btn.alpha =0;
            }
        }
        [self touchesSelf];
        self.rememberNameView.alpha = 0;
    });
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    //正在输入密码
    if (self.textField.text.length == 0)
    {
        self.deleteTxtBtn.alpha = 0;
    }else
    {
        self.deleteTxtBtn.alpha = 1;
    }

    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];
    if (mode.writingIdNumber!=YES)
    {
        mode.writingIdNumber = YES;
    }
    
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    
    if (toBeString.length > 18)
    {
        textField.text = [toBeString substringToIndex:18];
    }
}


-(id)init
{
    self = [super init];
    if (self)
    {
        [self initSelf];
    }
    return self;
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

-(id<UITextFieldDelegate>)delegate
{
    return self.textField.delegate;
}

-(void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.textField.delegate = delegate;
}

-(CGFloat)rightPadding
{
    return _rightPadding;
}

-(void)setRightPadding:(CGFloat)rightPadding
{
    _rightPadding = rightPadding;
    [self setNeedsLayout];
}

-(UIReturnKeyType)returnKeyType
{
    return self.textField.returnKeyType;
}

-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    self.textField.returnKeyType = returnKeyType;
}

-(CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

-(CGFloat)labelWidth
{
    return _labelWidth;
}

-(void)setLabelWidth:(CGFloat)labelWidth
{
    _labelWidth = labelWidth;
    [self setNeedsLayout];
}

-(NSString*)labelText
{
    return self.label.text;
}

-(void)setLabelText:(NSString *)labelText
{
    self.label.text = labelText;
}

-(void)layoutSubviews
{
    CGSize size = self.frame.size;
    self.label.frame = CGRectMake(0, 0, _labelWidth, size.height);
    self.textField.frame = TEXTFIELD_FRAME;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    
    [[UIColor colorWithWhite:1 alpha:.5] set];
    CGContextFillRect(cxt, rect);
    
    CGSize size = self.frame.size;
    CGContextFillRect(cxt, CGRectMake(0, 0, _labelWidth, size.height));
    CGContextFillRect(cxt, CONTEXT_RECT);
}

@end
