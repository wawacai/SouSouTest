//
//  ViewController.m
//  SouSouTest
//
//  Created by 彭作青 on 2017/1/4.
//  Copyright © 2017年 myself. All rights reserved.
//

#import "ViewController.h"
#import "LoginController.h"
#import "SoSoIdCardVertifyViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"JYVivo" bundle:nil];
    LoginController *loginVc = [sb instantiateInitialViewController];
    //    [self presentViewController:loginVc animated:YES completion:nil];
    [self.navigationController pushViewController:loginVc animated:YES];
}
- (IBAction)faceTest:(UIButton *)sender {
//    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"JYVivo" bundle:nil];
//    LoginController *loginVc = [sb instantiateInitialViewController];
////    [self presentViewController:loginVc animated:YES completion:nil];
//    [self.navigationController pushViewController:loginVc animated:YES];
    
    SoSoIdCardVertifyViewController *vc = [[SoSoIdCardVertifyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
