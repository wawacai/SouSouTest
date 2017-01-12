//
//  CustomHUD.m
//  SoSoRun
//
//  Created by bigSavage on 15/7/6.
//  Copyright (c) 2015年 SouSouRun. All rights reserved.
//

#import "CustomHUD.h"

@implementation CustomHUD

+(void)showHUDText:(NSString *)str inView:(UIView *)view{
    
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = str;
    HUD.margin = 18.f;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1.0];


}
+(void)showHUDText:(NSString *)str inView:(UIView *)view hideDelay:(NSTimeInterval)delay
{
	MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
	HUD.mode = MBProgressHUDModeText;
	HUD.labelText = str;
	HUD.margin = 18.f;
	HUD.removeFromSuperViewOnHide = YES;
	[HUD hide:YES afterDelay:delay];
}
+(void)showHUDLoadingWithText:(NSString *)str inView:(UIView *)view{
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];

    [view addSubview:HUD];
    HUD.labelText = str;
    [HUD show:YES];

}
+(void)showHUDLoadingWithText:(NSString *)str inView:(UIView *)view hideDelay:(NSTimeInterval)delay{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    
    [view addSubview:HUD];
    HUD.labelText = str;
    [HUD show:YES];
    [HUD hide:YES afterDelay:delay];
}
+(void)showHUDErrorWithText:(NSString *)str inView:(UIView *)view{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = str;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Errormark.png"]];
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];

}
+(void)showHUDSuccessWithText:(NSString *)str inView:(UIView *)view{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = str;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];

}
+(void)HideHUDFrom:(UIView *)view animated:(BOOL)animated{
//    [MBProgressHUD hideHUDForView:view animated:animated];
    [MBProgressHUD hideAllHUDsForView:view animated:animated];

}
+(void)HideHUDFrom:(UIView *)view animated:(BOOL)animated afterDelay:(NSInteger)time{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

//            [MBProgressHUD hideHUDForView:view animated:animated];
         [MBProgressHUD hideAllHUDsForView:view animated:animated];
    });
    
}

+(void)HideHUDFrom:(UIView *)view animated:(BOOL)animated afterDelay:(NSInteger)time didHide:(void (^)())block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//        [MBProgressHUD hideHUDForView:view animated:animated];
         [MBProgressHUD hideAllHUDsForView:view animated:animated];
        block();
    });
    
}




+(void)HideHUDAndShowText:(NSString *)text inView:(UIView *)view{
    [self HideHUDFrom:view animated:YES afterDelay:0.5 didHide:^{
        [self showHUDText:text inView:view];
    }];
}

+(void)HideHUDAndShowSuccess:(NSString *)text inView:(UIView *)view{
    [self HideHUDFrom:view animated:YES afterDelay:0.5 didHide:^{
        [self showHUDSuccessWithText:text inView:view];
    }];
}

@end
