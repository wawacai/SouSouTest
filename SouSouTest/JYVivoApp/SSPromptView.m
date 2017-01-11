//
//  SSPromptView.m
//  SouSouTest
//
//  Created by 彭作青 on 2017/1/10.
//  Copyright © 2017年 myself. All rights reserved.
//

#import "SSPromptView.h"
#import "Masonry.h"
#import "UIColor+HexString.h"

@implementation SSPromptView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        [self setupUI];
    }
    return self;
}

#pragma mark - event response

- (void)cancelButtonClick {
    self.promptViewButton(YES);
}

- (void)sureButtonClick {
    self.promptViewButton(NO);
}

#pragma mark - private method

- (UILabel *)makeImageTitle:(NSString *)title {
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = [UIColor colorWithHexString:@"#666666"];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIButton *)makeButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitleColor:[UIColor colorWithHexString:@"#ff8903"] forState:UIControlStateNormal];
    return btn;
}

#pragma mark - 搭建界面

- (void)setupUI {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // MARK: 标题
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    titleLabel.text = @"验证失败，请重试";
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(20);
    }];
    
    // MARK: 光线
    UIImageView *lightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light"]];
    [self addSubview:lightImageView];
    [lightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(54.0 / 375 * screenW);
        make.top.equalTo(titleLabel.mas_bottom).offset(37);
    }];
    
    UILabel *lightLabel = [self makeImageTitle:@"光线充足"];
    [self addSubview:lightLabel];
    [lightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(lightImageView);
        make.top.equalTo(lightImageView.mas_bottom).offset(12);
    }];
    
    // MARK: 人脸识别
    UIImageView *identifyFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"identifyFace"]];
    [self addSubview:identifyFaceImageView];
    [identifyFaceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(lightImageView);
    }];
    
    UILabel *identifyFaceLabel = [self makeImageTitle:@"人脸识别"];
    [self addSubview:identifyFaceLabel];
    [identifyFaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lightLabel);
        make.centerX.offset(0);
    }];
    
    // MARK: 放慢动作
    UIImageView *actionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"action"]];
    [self addSubview:actionImageView];
    [actionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(identifyFaceImageView);
        make.right.offset(-54.0 / 375 * screenW);
    }];
    
    UILabel *actionLabel = [self makeImageTitle:@"放慢动作"];
    [self addSubview:actionLabel];
    [actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(actionImageView);
        make.centerY.equalTo(identifyFaceLabel);
    }];
    
    // MARK: 水平灰色的线
    CGFloat lineH = 2 / [UIScreen mainScreen].scale;
    UIView *horizontalLineView = [UIView new];
    [self addSubview:horizontalLineView];
    horizontalLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [horizontalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.offset(0);
        make.top.equalTo(lightLabel.mas_bottom).offset(31);
        make.height.mas_equalTo(lineH);
    }];
    
    // MARK: 垂直灰色的线
    UIView *verticalLineView = [UIView new];
    [self addSubview:verticalLineView];
    verticalLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(horizontalLineView.mas_bottom);
        make.bottom.offset(0);
        make.width.mas_equalTo(lineH);
    }];
    
    // MARK: 取消按钮
    UIButton *cancelBtn = [self makeButtonWithTitle:@"取消"];
    [self addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(horizontalLineView.mas_bottom).offset(22.5);
        make.centerX.equalTo(self.mas_centerX).multipliedBy(0.5);
        make.size.mas_equalTo(CGSizeMake(156, 45));
    }];

    // MARK: 确定按钮
    UIButton *sureBtn = [self makeButtonWithTitle:@"确定"];
    [self addSubview:sureBtn];
    [sureBtn addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelBtn);
        make.centerX.equalTo(self.mas_centerX).multipliedBy(1.5);
        make.size.mas_equalTo(CGSizeMake(156, 45));
    }];
}

@end
