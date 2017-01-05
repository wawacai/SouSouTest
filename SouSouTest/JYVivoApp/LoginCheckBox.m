//
//  LoginCheckBox.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/26.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "LoginCheckBox.h"


#define CHECK_BOX_FRAME CGRectMake(23, 12, 15, 15)



@implementation LoginCheckBox

- (void)initSelf
{
    [self addTarget:self action:@selector(touchIn:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
    
    //偏好设置是否记住密码
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"rememberPassword"];
    if ([str  isEqual:@"YES"])
    {
        self.selected = YES;
        self.rememberPassword = YES;
    }
}

- (void)touchIn:(id)sender
{
    self.highlighted = YES;
    [self setNeedsDisplay];
}

- (void)touchOut:(id)sender
{
    self.highlighted = NO;
    self.selected = !self.selected;
    if (self.selected == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"rememberPassword"];
        self.rememberPassword = YES;
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"rememberPassword"];
        self.rememberPassword = NO;
    }
    
    [self setNeedsDisplay];
}

- (void)touchCancel:(id)sender
{
    self.highlighted = NO;
    [self setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initSelf];
    return self;
}

- (UIImage*) drawingImage
{
    if (self.highlighted)
    {
        return self.selected ? _imageOnPressed : _imageOffPressed;
    } else
    {
        return self.selected ? _imageOn : _imageOff;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGSize size = self.frame.size;
    
    UIImage* image = [self drawingImage];
    if (image)
    {
        [image drawInRect:CHECK_BOX_FRAME];
    }
    if (_title)
    {
        [[UIColor whiteColor] set];
        UIFont *font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
        CGSize titleSize = [_title sizeWithFont:font constrainedToSize:CGSizeMake(size.width - size.height, size.height)];
        [_title drawAtPoint:CGPointMake(size.height, (size.height - titleSize.height) / 2) withFont:font];
    }
}

@end
