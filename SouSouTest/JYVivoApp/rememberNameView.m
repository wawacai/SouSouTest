//
//  rememberNameView.m
//  JYVivoUI2
//
//  Created by junyufr on 16/5/27.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "rememberNameView.h"
#import "idCardAdoptMode.h"

@interface rememberNameView ()


@end

@implementation rememberNameView


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    
    if (point.y <30)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchOneBtn" object:self];
    }
    if (point.y <60 && point.y>30)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchTwoBtn" object:self];
    }
    if (point.y <90 && point.y>60)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchThreeBtn" object:self];
    }
    if (point.y <120 && point.y>90)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchFourBtn" object:self];
    }
    if (point.y <150 && point.y>120)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchFiveBtn" object:self];
    }
}

@end
