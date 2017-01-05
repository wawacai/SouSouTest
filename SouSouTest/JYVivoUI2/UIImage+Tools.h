//
//  UIImage(Tools).h
//  JYVivoUI2
//
//  Created by jock li on 16/5/1.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIImageRotate) {
    UIImageRotateCW90,
    UIImageRotate180,
    UIImageRotateCCW90,
};

@interface UIImage (Tools)

// 获取一个修正旋转的图片副本
-(UIImage*)rotateFixedImage;

-(UIImage*)rotateImage:(NSUInteger)rotate;

@end
