//
//  SSStepView.m
//  SouSouTest
//
//  Created by 彭作青 on 2017/1/7.
//  Copyright © 2017年 myself. All rights reserved.
//

#import "SSStepView.h"
#import "Masonry.h"
#import "UIColor+HexString.h"

@interface SSStepView ()
@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArrM;

@end

@implementation SSStepView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _btnArrM = [NSMutableArray arrayWithCapacity:3];
        [self setupUI];
    }
    return self;
}

#pragma mark - private method

- (UIButton *)makeButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton new];
    [self addSubview:btn];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 19;
    btn.clipsToBounds = YES;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1;
    btn.alpha = 1;
    [_btnArrM addObject:btn];
    return btn;
}

- (void)makeLineWithNumber:(NSInteger)number {
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
    [self addSubview:imageV];
    
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(self.btnArrM[number].mas_right).offset(7);
        make.right.equalTo(self.btnArrM[number+1].mas_left).offset(-8);
        make.height.mas_equalTo(6.5);
    }];
}

#pragma mark - 搭建界面

- (void)setupUI {
    // 按钮
    [self makeButtonWithTitle:@"1"];
    [self makeButtonWithTitle:@"2"];
    [self makeButtonWithTitle:@"3"];
    
    [_btnArrM mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:45 leadSpacing:0 tailSpacing:0];
    [_btnArrM mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(38, 38));
    }];
    
    // 虚线
    [self makeLineWithNumber:0];
    [self makeLineWithNumber:1];
}

- (void)setFinishNumber:(NSInteger)finishNumber {
    _finishNumber = finishNumber;
    
    if (finishNumber != 0) {
        for (NSInteger i = 0; i < finishNumber; i++) {
            _btnArrM[i].backgroundColor = [UIColor colorWithHexString:@"#ff8903"];
        }
    } else {
        for (NSInteger i = 0; i < 3; i++) {
            _btnArrM[i].backgroundColor = [UIColor grayColor];
        }
    }
    
}

@end
