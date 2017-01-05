//
//  CustomAccessoryView.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/26.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "CustomAccessoryView.h"

@interface CustomAccessoryView () {
    NSArray* _options;
}

@property (nonatomic, weak) UIScrollView* scrollView;

@property (nonatomic, weak) UIButton* buttonClose;

@property (nonatomic, retain) NSArray* buttons;

@end

@implementation CustomAccessoryView

-(void)initSelf
{
    UIButton *buttonClose = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonClose.backgroundColor = [UIColor clearColor];
    [buttonClose setBackgroundImage:[UIImage imageNamed:@"CloseKeyboard.png"] forState:UIControlStateNormal];
    [self addSubview:buttonClose];
    
    self.buttonClose = buttonClose;
    
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    self.scrollView = scrollView;
    
    NSMutableArray *array = [NSMutableArray new];
    for (int i=0; i<10; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = [UIColor colorWithRed:.992 green:.992 blue:.996 alpha:1];
        //button.titleLabel.textColor = [UIColor blackColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(touchOption:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [array addObject:button];
    }
    self.buttons = array;
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

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

-(NSArray*)options
{
    return _options;
}

-(void)setOptions:(NSArray *)options
{
    _options = options;
    if (_options)
    {
        for (size_t i=0; i<self.buttons.count; i++)
        {
            UIButton* button = [self.buttons objectAtIndex:i];
            if (_options.count > i)
            {
                [button setTitle: [_options objectAtIndex:i] forState:UIControlStateNormal];
                button.hidden = NO;
            } else
            {
                button.hidden = YES;
            }
        }
    }
    [self relayout];
}

-(void)relayout
{
    const CGFloat buttonPadding = 10;
    if (_options)
    {
        CGSize size = self.frame.size;
        CGFloat totalWidth = 0;
        for (size_t i=0; i<self.buttons.count; i++)
        {
            UIButton* button = [self.buttons objectAtIndex:i];
            if (_options.count > i)
            {
                button.hidden = NO;
                CGSize buttonSize = [button sizeThatFits:size];
                if (i>0)
                {
                    totalWidth++; // 间隔
                }
                buttonSize.width += buttonPadding;
                button.frame = CGRectMake(totalWidth, 1, buttonSize.width, size.height - 2);
                totalWidth += buttonSize.width;
            } else
            {
                button.hidden = YES;
            }
        }
        [self.scrollView setContentSize:CGSizeMake(totalWidth, size.height)];
    } else
    {
        for (UIButton* button in self.buttons)
        {
            button.hidden = YES;
        }
    }
}

-(void)layoutSubviews
{
    CGSize size = self.frame.size;
    self.scrollView.frame = CGRectMake(0, 0, size.width - 40, size.height);
    self.buttonClose.frame = CGRectMake(size.width - 40, 0, 40, size.height);
}

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.buttonClose addTarget:target action:action forControlEvents:controlEvents];
}

-(void)touchOption:(id)sender
{
    NSString *option = [[sender titleLabel] text];
    if (_delegate)
    {
        [_delegate customAccessoryView:self selectedOption:option];
    }
}

@end
