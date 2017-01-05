//
//  LoginTextField.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/26.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginTextField : UIView

@property (nonatomic, weak) UILabel *label;

@property (nonatomic, weak) UITextField *textField;

@property IBInspectable NSString* labelText;

@property IBInspectable CGFloat labelWidth;

@property IBInspectable CGFloat cornerRadius;

@property IBInspectable UIReturnKeyType returnKeyType;

@property IBInspectable CGFloat rightPadding;

@property(nonatomic,weak)UIButton *deleteTxtBtn;//清空身份证按钮

@property IBOutlet id<UITextFieldDelegate> delegate;


@end
