//
//  SSPersonalAuthenticationSingleton.m
//  SouSouTest
//
//  Created by 肖培德 on 17/1/11.
//  Copyright © 2017年 myself. All rights reserved.
//

#import "SSPersonalAuthenticationSingleton.h"

@implementation SSPersonalAuthenticationSingleton

+(instancetype)getSingleton{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}



@end
