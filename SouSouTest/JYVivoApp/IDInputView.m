//
//  IDInputView.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/27.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "IDInputView.h"

#import <AudioToolbox/AudioToolbox.h>

@interface IDInputView()

@property (nonatomic, weak) UIButton* button0;
@property (nonatomic, weak) UIButton* button1;
@property (nonatomic, weak) UIButton* button2;
@property (nonatomic, weak) UIButton* button3;
@property (nonatomic, weak) UIButton* button4;
@property (nonatomic, weak) UIButton* button5;
@property (nonatomic, weak) UIButton* button6;
@property (nonatomic, weak) UIButton* button7;
@property (nonatomic, weak) UIButton* button8;
@property (nonatomic, weak) UIButton* button9;
@property (nonatomic, weak) UIButton* buttonX;
@property (nonatomic, weak) UIButton* buttonDelete;

@end

@implementation IDInputView

-(UIButton*)addButtonWithTitle:(NSString*)title font:(UIFont*)font
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundColor:[UIColor colorWithRed:.992 green:.992 blue:.996 alpha:1]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    [button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
    return button;
}

-(void)keyPressed:(id)sender
{
    if (_textField)
    {
        AudioServicesPlaySystemSound(1104);
        [_textField insertText:[sender titleLabel].text];
    }
}

-(void)deletePressed:(id)sender
{
    if (_textField)
    {
        AudioServicesPlaySystemSound(1104);
        [_textField deleteBackward];
    }
}

-(void)initSelf
{
    UIFont *font = [UIFont boldSystemFontOfSize:24];
    self.button0 = [self addButtonWithTitle:@"0" font:font];
    self.button1 = [self addButtonWithTitle:@"1" font:font];
    self.button2 = [self addButtonWithTitle:@"2" font:font];
    self.button3 = [self addButtonWithTitle:@"3" font:font];
    self.button4 = [self addButtonWithTitle:@"4" font:font];
    self.button5 = [self addButtonWithTitle:@"5" font:font];
    self.button6 = [self addButtonWithTitle:@"6" font:font];
    self.button7 = [self addButtonWithTitle:@"7" font:font];
    self.button8 = [self addButtonWithTitle:@"8" font:font];
    self.button9 = [self addButtonWithTitle:@"9" font:font];
    self.buttonX = [self addButtonWithTitle:@"X" font:font];
    
    UIButton* buttonDelete = [UIButton buttonWithType:UIButtonTypeSystem];
    [buttonDelete setImage:[UIImage imageNamed:@"DeleteKey.png"] forState:UIControlStateNormal];
    buttonDelete.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    [buttonDelete addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:buttonDelete];
    
    self.buttonDelete = buttonDelete;
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

-(void)layoutSubviews
{
    CGSize size = self.frame.size;
    CGFloat itemWidth = (size.width - 2) / 3;
    CGFloat itemHeight = (size.height - 3) / 4;
    
    CGFloat row0 = 0;
    CGFloat row1 = itemHeight + 1;
    CGFloat row2 = row1*2;
    CGFloat row3 = row1*3;
    
    CGFloat col0 = 0;
    CGFloat col1 = itemWidth + 1;
    CGFloat col2 = col1 * 2;
    
    self.button1.frame = CGRectMake(col0, row0, itemWidth, itemHeight);
    self.button2.frame = CGRectMake(col1, row0, itemWidth, itemHeight);
    self.button3.frame = CGRectMake(col2, row0, itemWidth, itemHeight);
    self.button4.frame = CGRectMake(col0, row1, itemWidth, itemHeight);
    self.button5.frame = CGRectMake(col1, row1, itemWidth, itemHeight);
    self.button6.frame = CGRectMake(col2, row1, itemWidth, itemHeight);
    self.button7.frame = CGRectMake(col0, row2, itemWidth, itemHeight);
    self.button8.frame = CGRectMake(col1, row2, itemWidth, itemHeight);
    self.button9.frame = CGRectMake(col2, row2, itemWidth, itemHeight);
    self.buttonX.frame = CGRectMake(col0, row3, itemWidth, itemHeight);
    self.button0.frame = CGRectMake(col1, row3, itemWidth, itemHeight);
    self.buttonDelete.frame = CGRectMake(col2, row3, itemWidth, itemHeight);
}

@end
