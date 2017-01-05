//
//  UIStepView.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/28.
//  Copyright © 2016年 timedge. All rights reserved.
//


#import "JYStepView.h"
#import "JYVivoUIStepDelegate.h"
#import "idCardAdoptMode.h"



@interface JYStepView()
{
    NSInteger _step;
}


@end

@implementation JYStepView

- (void)initSelf
{
    _step = -1;
    self.backgroundColor = [UIColor clearColor];
}

- (void)exitCurrentStep
{
    
    
    if (_step < self.subviews.count)
    {

        UIView* stepView = [self.subviews objectAtIndex:_step];
        if ([stepView conformsToProtocol:@protocol(JYVivoUIStepDelegate)] && [stepView respondsToSelector:@selector(stepExit)])
        {
            [(id<JYVivoUIStepDelegate>)stepView stepExit];
        }
    }
}

-(void)enterCurrentStep
{
    
    if (_step < self.subviews.count)
    {
        UIView* stepView = [self.subviews objectAtIndex:_step];
        if ([stepView conformsToProtocol:@protocol(JYVivoUIStepDelegate)] && [stepView respondsToSelector:@selector(stepEnter)])
        {
            NSString* title = [(id<JYVivoUIStepDelegate>)stepView stepEnter];
            if (title && _titleLabel)
            {
                _titleLabel.text = title;
            }
        }
    }
}

- (void)setStep:(NSInteger)step
{
    
    if (_step != step)
    {

        [self exitCurrentStep];
        _step = step;
        [self enterCurrentStep];
        if(_syncStepView)
        {
            _syncStepView.step = step;
        }
    }
    [self setNeedsLayout];
}

- (NSInteger)step
{
    return _step;
}

- (void) layoutSubviews
{
    
    CGSize size = self.frame.size;
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    for (NSUInteger i = 0;i < self.subviews.count; i++)
    {
        UIView* child = [self.subviews objectAtIndex:i];
        child.hidden = i != _step;
        child.frame = frame;
    }
}

- (void)next
{
    
    idCardAdoptMode *mode = [[idCardAdoptMode alloc] init];

    if (_step < self.subviews.count - 1)
    {
        self.step ++;
        
        mode.numberOne = 1;
        
        if(_step == 0)
        {
            mode.severalController = 0;//设置当前所在位置为翻牌照界面
        }
        else if (_step == 1)
        {
            mode.severalController = 1;//设置当前所在位置为环境检测界面
        }
        else if (_step == 2)
        {
            mode.severalController = 2;//设置当前所在位置为活体检测界面
        }
    } else
    {
        if(_delegate)
        {
            [_delegate onStepComplete];
            
            mode.severalController = -1;
        }
    }
}

#pragma mark - JYVivoUIStepDelegate caller

- (void)didAddSubview:(UIView *)subview
{
    __weak typeof (self) weakSelf = self;
    
    [super didAddSubview:subview];
    if ([subview conformsToProtocol:@protocol(JYVivoUIStepDelegate)] && [subview respondsToSelector:@selector(stepLoad:)])
    {
        
        
        
        [(id<JYVivoUIStepDelegate>)subview stepLoad:^()
        {
            [weakSelf next];
        }];
    }
    if (_step == -1 && self.subviews.count == 1)
    {
        self.step = 0;
    }
}

- (void)willRemoveSubview:(UIView *)subview
{
    
    if ([subview conformsToProtocol:@protocol(JYVivoUIStepDelegate)] && [subview respondsToSelector:@selector(stepUnload)])
    {
        [(id<JYVivoUIStepDelegate>)subview stepUnload];
    }
}

@end
