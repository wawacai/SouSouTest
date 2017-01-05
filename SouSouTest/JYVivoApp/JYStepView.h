//
//  UIStepView.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/28.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYStepViewDelegate <NSObject>

// 当最后一个步骤中调用 next 时发生
-(void)onStepComplete;

@end

// 用于显示步骤的控件
@interface JYStepView : UIView

// 可选步骤完成处理协议
@property (nonatomic, weak) IBOutlet id<JYStepViewDelegate> delegate;

// 可选的标题控件，在步骤改变时自动更新标题文字
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;

// 可选的被动同步步骤的步骤控件
@property (nonatomic, weak) IBOutlet JYStepView* syncStepView;

// 当前步骤
@property NSInteger step;

@end
