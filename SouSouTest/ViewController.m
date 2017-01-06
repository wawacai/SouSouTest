//
//  ViewController.m
//  SouSouTest
//
//  Created by 彭作青 on 2017/1/4.
//  Copyright © 2017年 myself. All rights reserved.
//

#import "ViewController.h"
#import "LoginController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)faceTest:(UIButton *)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"JYVivo" bundle:nil];
    LoginController *loginVc = [sb instantiateInitialViewController];
//    [self presentViewController:loginVc animated:YES completion:nil];
    [self.navigationController pushViewController:loginVc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
