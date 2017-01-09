//
//  JYIdentifyStepView.h
//  JYVivoUI2
//
//  Created by jock li on 16/5/2.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYIdentifyStepView;
@protocol JYIdentifyStepViewDelegate <NSObject>

- (void)identifyStepView:(JYIdentifyStepView *)identifyStepView actionString:(NSString *)actionString;
- (void)isIdentifySetpView;

@end

// 提供动作识别步骤视图
@interface JYIdentifyStepView : UIView
@property (nonatomic, weak) id<JYIdentifyStepViewDelegate> delegate;

@end
