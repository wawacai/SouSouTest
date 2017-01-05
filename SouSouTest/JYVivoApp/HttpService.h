//
//  HttpService.h
//  JYVivoUI
//
//  Created by jock li on 15/1/30.
//  Copyright (c) 2015年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^httpServiceErrorBlock)(NSError* error);

typedef void (^httpServiceDoneBlock)(NSInteger statusCode, NSData* body);

/**
 提供 Http 服务访问工具
 */
@interface HttpService : NSObject

/**
 返回当前 http 服务独立实例
 */
+(HttpService*) service;

/**
 发送一个 POST 请求
 */
-(void)post:(NSURL*)serviceUrl body:(NSData*)body success:(httpServiceDoneBlock)doneBlock fail:(httpServiceErrorBlock)errorBlock;

@end
