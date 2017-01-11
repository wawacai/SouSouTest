//
//  JYEnvStepView.h
//  JYVivoUI2
//
//  Created by jock li on 16/5/1.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>
// 新加
#import "SSPromptView.h"

// 提供环境检测步骤视图
@interface JYEnvStepView : UIView

// 错误提示框
@property (nonatomic, weak) SSPromptView *promptView;

-(NSString*)stepEnter;

@end
