//
//  CustomAccessoryView.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/26.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

// 提供一个自定义的输入选项

@class CustomAccessoryView;

@protocol CustomAccessoryViewDelegate <NSObject>

@optional
-(void)customAccessoryView:(CustomAccessoryView*) customAccessoryView selectedOption:(NSString*) option;

@end

@interface CustomAccessoryView : UIControl

@property (nonatomic,retain) IBOutlet id<CustomAccessoryViewDelegate> delegate;

@property NSArray* options;

@end
