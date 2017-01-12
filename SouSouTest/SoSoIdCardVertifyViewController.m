//
//  SoSoIdCardVertifyViewController.m
//  SouSouTest
//
//  Created by 肖培德 on 17/1/10.
//  Copyright © 5017年 myself. All rights reserved.
//

#import "SoSoIdCardVertifyViewController.h"
#import "idCardViewController.h"
#import "SSPersonalAuthenticationSingleton.h"
@interface SoSoIdCardVertifyViewController ()
@property (weak, nonatomic) IBOutlet UIButton *rephotographBtn;
@property (weak, nonatomic) IBOutlet UIButton *rephotograph_backBtn;
@property (weak, nonatomic) IBOutlet UIImageView *head_image;
@property (weak, nonatomic) IBOutlet UIImageView *back_image;

@property (weak, nonatomic) IBOutlet UIButton *startOrSubmitBtn;
@end

@implementation SoSoIdCardVertifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _head_image.layer.cornerRadius = 5;
    _head_image.layer.masksToBounds = YES;
    _back_image.layer.cornerRadius = 5;
    _back_image.layer.masksToBounds = YES;
    _startOrSubmitBtn.layer.cornerRadius = 5;
    _startOrSubmitBtn.layer.masksToBounds = YES;
  
    _rephotographBtn.layer.cornerRadius = 5;
    _rephotographBtn.layer.masksToBounds = YES;
    
    _rephotograph_backBtn.layer.cornerRadius = 5;
    _rephotograph_backBtn.layer.masksToBounds = YES;
    
    NSDictionary *headDic = [SSPersonalAuthenticationSingleton getSingleton].headDic;
    NSDictionary *backDic = [SSPersonalAuthenticationSingleton getSingleton].backDic;
    if ([headDic count] == 0 || [backDic count] == 0)
    {
        _rephotograph_backBtn.hidden = YES;
        _rephotographBtn.hidden = YES;
        
    }else{
        _rephotograph_backBtn.hidden = NO;
        _rephotographBtn.hidden = NO;
        _head_image.image = headDic[@"kOpenSDKCardResultTypeImage"];
        _back_image.image = backDic[@"kOpenSDKCardResultTypeImage"];
        [_startOrSubmitBtn setTitle:@"提交" forState: UIControlStateNormal];
        
    }
    
}

- (IBAction)beginIdVertify:(id)sender
{
    idCardViewController *vc = [[idCardViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)rephotographDidClick:(UIButton *)sender
{
//    [SSPersonalAuthenticationSingleton getSingleton].headDic = nil;
    idCardViewController *vc = [[idCardViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}
- (IBAction)rephotographBackDidClick:(UIButton *)sender
{
    [SSPersonalAuthenticationSingleton getSingleton].backDic = nil;
    idCardViewController *vc = [[idCardViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.isFromHeadTest = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
