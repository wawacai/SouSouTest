//
//  JYVivoUIStepDelegate.h
//  JYVivoUI2
//
//  Created by jock li on 16/5/1.
//  Copyright © 2016年 timedge. All rights reserved.
//


#import <Foundation/Foundation.h>

// 为下一步动作提供调用点
typedef void (^JYVivoUIStepNext)(void);

// 为操作步骤状态提供回调
@protocol JYVivoUIStepDelegate <NSObject>

@optional
// 初始化，提供一个可触发下一步操作的回调
-(void)stepLoad:(JYVivoUIStepNext)next;
// 进入步骤时触发，返回此步骤的标题
-(NSString*)stepEnter;
// 离开步骤时触发
-(void)stepExit;
// 释放无用资源
-(void)stepUnload;

@end
