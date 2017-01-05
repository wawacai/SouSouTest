//
//  JYProgressBar.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/3.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "JYProgressBar.h"
#import "JYResource.h"
//#import "JYDefines.h"

@interface JYProgressBar ()

@property(nonatomic,weak)UIImageView* backgroundImage;//条

@property(nonatomic,weak)UIImageView* arrowImage;//标签

@property(nonatomic,weak)UILabel* numberLabel;//标签上的数字

//@property(nonatomic,weak)CADisplayLink *link;

@end

@implementation JYProgressBar

float tmpHeight;



-(instancetype)init
{
    self = [super init];
    
    return self;
}

-(void)initSelf
{
    
    UIImageView *backgroundImage =[[UIImageView alloc] init];
    
    UIImageView *arrowImage = [[UIImageView alloc] init];
    
    UILabel *numberLabel = [[UILabel alloc] init];
    
    self.backgroundImage = backgroundImage;
    self.arrowImage = arrowImage;
    self.numberLabel = numberLabel;
    
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    
    self.backgroundImage.image = [JYResource imageNamed:@"progress_bar.png"];

    self.arrowImage.image = [JYResource imageNamed:@"progress_arrow.png"];      //标签
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    
    tmpHeight = (((rx.size.width - 140)/60)*77)/10*8;
    
    float width = 46;
    
    
    self.backgroundImage.frame = CGRectMake(0,0, width/3,tmpHeight);
    
    self.arrowImage.frame = CGRectMake(width/3, tmpHeight, width/3*2, 15);
    
    self.numberLabel.frame = CGRectMake(10, 3, width/3*2-13, 10);//不变
    
    self.numberLabel.font = [UIFont systemFontOfSize:8];
    
    [self addSubview:self.backgroundImage];
    [self addSubview:self.arrowImage];
    [self.arrowImage addSubview:numberLabel];
    
//    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(setArrowImageFrameY)];
//    
//    self.link = link;
//    
//    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

//-(void)setArrowImageFrameY
//{
//    if (1>=((self.arrowImage.frame.origin.y-tmpHeight)*(-100/tmpHeight))-2)
//    {
//        self.numberLabel.text = @"0";
//        
//    }else
//    {
//        self.numberLabel.text = [NSString stringWithFormat:@"%1.0f",(((int)self.arrowImage.frame.origin.y - (int)tmpHeight)*(-100/tmpHeight))-2];
//    }
//}


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
    [super layoutSubviews];
    
}


-(void)setCurrentValue:(CGFloat)currentValue//变化值
{
    if (currentValue <= 150)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.arrowImage.frame = CGRectMake(46/3, tmpHeight - (currentValue*(tmpHeight/150))-7 , 46/3*2, 15);
        }];
        
        if (currentValue < 100)
        {
            self.numberLabel.textColor = [UIColor redColor];
        }
        else if(currentValue >= 100)
        {
            self.numberLabel.textColor = [UIColor greenColor];
        }
        
    }else{
        //大于不超出
        self.arrowImage.frame = CGRectMake(46/3, tmpHeight - (150*(tmpHeight/150))-7 , 46/3*2, 15);
        self.numberLabel.textColor = [UIColor greenColor];
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%1.0f",currentValue];//设置显示数字
}



@end
