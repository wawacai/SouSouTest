//
//  JYActionImageView.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/3.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "JYActionImageView.h"
#import "JYDefines.h"

@interface JYActionImageView ()
{
    NSTimer *_animTimer;
    NSArray* _images;
    NSUInteger _pos;
}

@end

@implementation JYActionImageView

-(void)setImages:(NSArray *)images
{
    _images = images;
    _pos = 0;
    [self runAnim];
}

-(NSArray*)images
{
    return _images;
}

-(void)runAnim
{
    if (_animTimer)
    {
        return;
    }
    _animTimer = [NSTimer scheduledTimerWithTimeInterval:ACTION_FRAME_DELAY target:self selector:@selector(updateDisplay) userInfo:nil repeats:YES];
}

-(void)updateDisplay
{
    [self setNeedsDisplay];
    if (_images && _images.count > 0)
    {
        _pos++;
        _pos%=_images.count;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGSize size = self.frame.size;
    if (_images && _images.count > _pos)
    {
        [[_images objectAtIndex:_pos] drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }
}

@end
