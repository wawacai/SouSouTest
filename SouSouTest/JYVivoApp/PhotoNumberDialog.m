//
//  PhotoNumberDialog.m
//  JYVivoUI2
//
//  Created by jock li on 16/4/29.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "PhotoNumberDialog.h"


@interface PhotoNumberDialog() <UITableViewDataSource, UITableViewDelegate> {
    NSArray* list;
}
@property (strong, nonatomic) UIView* maskView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIWindow *ownerWindow;


@end

@implementation PhotoNumberDialog

- (void)initSelf
{
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
    list = @[@"1张（省流量、速度快）", @"2张（适中）", @"3张（耗流量，速度慢）"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

- (void)show
{
    self.ownerWindow = [[UIApplication sharedApplication] keyWindow];
    if (_maskView == nil)
    {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    
    CGSize size = self.ownerWindow.frame.size;
    _maskView.frame = CGRectMake(0, 0, size.width, size.height);
    self.center = CGPointMake(size.width / 2, size.height / 2);
    
    [self.ownerWindow addSubview:_maskView];
    [self.ownerWindow addSubview:self];
}

- (void)dismiss
{
    [self removeFromSuperview];
    [self.maskView removeFromSuperview];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row != _selectedIndex)
    {
        [tableView beginUpdates];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
         [tableView endUpdates];
         _selectedIndex = row;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    cell.accessoryType = row == _selectedIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = [list objectAtIndex:row];
    return cell;
}

- (IBAction)onCancel:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(photoNumberDialogCancel:)])
    {
        [_delegate photoNumberDialogCancel:self];
    }
    [self dismiss];
}
- (IBAction)onOK:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(photoNumberDialog:selected:)]) {
        [_delegate photoNumberDialog:self selected:_selectedIndex];
    }
    [self dismiss];
}
@end
