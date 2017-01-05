//
//  UIResultItemLabel.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/2.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "UIResultItemLabel.h"


@interface UIResultItemLabel ()
{
    BOOL _success;
    NSString* _label;
    UIImage* _icon;
    UIFont* _font;
}

@end

@implementation UIResultItemLabel

-(id)initWithLabel:(NSString *)label success:(BOOL)success
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.label = label;
        self.success = success;
        _icon = [self getIcon];
    }
    return self;
}

- (UIImage*)getIcon
{
    return [UIImage imageNamed: _success ? @"right_bg.png" : @"erro_bg.png"];
}

- (void)drawRect:(CGRect)rect
{
    CGSize size = self.frame.size;
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    
    UIFont *font = self.font;
    if (_success)
    {
        [[UIColor colorWithRed:.027 green:.533 blue:.792 alpha:1] set];
    } else
    {
        [[UIColor colorWithRed:.914 green:.012 blue:.204 alpha:1] set];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 1, size.width - 2, size.height - 2) cornerRadius:MIN(size.width, size.height) / 2];
    CGContextSetLineWidth(cxt, 4);
    [path stroke];
    
    if (_icon)
    {
        [_icon drawInRect:CGRectMake(8, (size.height - _icon.size.height) / 2, _icon.size.width, _icon.size.height)];
    }
    
    if (_label)
    {
        [_label drawAtPoint:CGPointMake(48 , (size.height - font.lineHeight) / 2) withFont:font];
    }
}

-(BOOL)isSuccess
{
    return _success;
}

-(void)setSuccess:(BOOL)success
{
    _success = success;
    [self setNeedsDisplay];
}

-(NSString*) label
{
    return _label;
}

-(void)setLabel:(NSString *)label
{
    _label = [label copy];
    [self setNeedsDisplay];
}

-(UIFont*)font
{
    if (_font == nil)
    {
        return [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return _font;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    [self setNeedsDisplay];
}

@end
