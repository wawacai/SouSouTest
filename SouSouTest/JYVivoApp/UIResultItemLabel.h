//
//  UIResultItemLabel.h
//  JYVivoUI2
//
//  Created by jock li on 16/5/2.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

// 用于显示详细结果中的正确与错误条目

@interface UIResultItemLabel : UIView

@property IBInspectable UIFont *font;
@property IBInspectable (getter=isSuccess) BOOL success;
@property IBInspectable NSString* label;

-(id)initWithLabel:(NSString*)label success:(BOOL)success;

@end
