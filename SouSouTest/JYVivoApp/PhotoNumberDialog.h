//
//  PhotoNumberDialog.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/29.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoNumberDialog;

@protocol PhotoNumberDialogDelegate <NSObject>

@optional
-(void)photoNumberDialogCancel:(PhotoNumberDialog*) photoNumberDialog;
-(void)photoNumberDialog:(PhotoNumberDialog*) photoNumberDialog selected:(NSInteger)selectedIndex;

@end

@interface PhotoNumberDialog : UIView

@property NSInteger selectedIndex;
@property (nonatomic, weak) id<PhotoNumberDialogDelegate> delegate;

-(void)show;

@end
