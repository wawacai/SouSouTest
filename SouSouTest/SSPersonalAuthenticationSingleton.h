//
//  SSPersonalAuthenticationSingleton.h
//  SouSouTest
//
//  Created by 肖培德 on 17/1/11.
//  Copyright © 2017年 myself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSPersonalAuthenticationSingleton : NSObject
@property(nonatomic,strong) NSDictionary *headDic;
@property(nonatomic,strong) NSDictionary *backDic;
+(instancetype)getSingleton;
@end
