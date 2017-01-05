//
//  RecognitionController.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/27.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface RecognitionController : UIViewController //用于身份证翻牌照，环境检测，活体检测3个界面的控制器

@property(nonatomic, retain) Person* personInfo;

@end
