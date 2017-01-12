//
//  CustomHUD.h
//  SoSoRun
//
//  Created by bigSavage on 15/7/6.
//  Copyright (c) 2015年 SouSouRun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CustomHUD : NSObject

/**
 * 显示HUD  纯文本
 */
+(void)showHUDText:(NSString *)str inView:(UIView *)view;
/**
 * 显示HUD  纯文本 在指定时间隐藏
 */
+(void)showHUDText:(NSString *)str inView:(UIView *)view hideDelay:(NSTimeInterval)delay;
/**
 * 显示HUD  加载中
 */
+(void)showHUDLoadingWithText:(NSString *)str inView:(UIView *)view;
+(void)showHUDLoadingWithText:(NSString *)str inView:(UIView *)view hideDelay:(NSTimeInterval)delay;
/**
 * 显示HUD  错误信息
 */
+(void)showHUDErrorWithText:(NSString *)str inView:(UIView *)view;
/**
 * 显示HUD  成功信息
 */
+(void)showHUDSuccessWithText:(NSString *)str inView:(UIView *)view;
/**
 * 隐藏所有HUD
 */
+(void)HideHUDFrom:(UIView *)view animated:(BOOL)animated;
/**
 * 隐藏所有HUD 然后显示出HUD纯文本
 */
+(void)HideHUDAndShowText:(NSString *)text inView:(UIView *)view;
/**
 * 隐藏所有HUD 然后显示出HUD成功信息
 */
+(void)HideHUDAndShowSuccess:(NSString *)text inView:(UIView *)view;

@end
