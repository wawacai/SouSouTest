//
//  SSSuccessPromptView.m
//  SouSouTest
//
//  Created by 彭作青 on 2017/1/12.
//  Copyright © 2017年 myself. All rights reserved.
//

#import "SSSuccessPromptView.h"
#import "Masonry.h"
#import "UIColor+HexString.h"

@implementation SSSuccessPromptView

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        self.layer.cornerRadius = 6;
    }
    return self;
}

#pragma mark - 搭建界面
- (void)setupUI {
    // 图片
    UIImageView *imageView = [UIImageView new];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"identifySuccess"];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(20);
    }];
    
    // 文字
    UILabel *label = [UILabel new];
    [self addSubview:label];
    label.text = @"识别成功";
    label.textColor = [UIColor colorWithHexString:@"#ff8903"];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(imageView.mas_bottom).offset(19);
    }];
}

@end
