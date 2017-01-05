//
//  HttpService.m
//  JYVivoUI
//
//  Created by jock li on 15/1/30.
//  Copyright (c) 2015年 timedge. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "HttpService.h"


#define TIMEOUT_SECS    25 //单次联网超时时间   注：可根据需求自行设定
#define NETWORK_NUMBER  3  //尝试联网次数


@interface HttpService ()
@property (retain, nonatomic) dispatch_queue_t queue;
@end

@implementation HttpService

+(HttpService*) service
{
    static HttpService* _service = nil;
    if (_service == nil)
    {
        _service = [[HttpService alloc] init];
    }
    return _service;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("httpservice", NULL);
    }
    return self;
}


-(void)postSync:(NSURL*)serviceUrl body:(NSData*)body success:(httpServiceDoneBlock)doneBlock fail:(httpServiceErrorBlock)errorBlock
{
    @try {//抛出
        int count = 0;
        NSError *error = nil;
        while (++count <= NETWORK_NUMBER)
        {
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serviceUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT_SECS];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:body];
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)body.length] forHTTPHeaderField:@"Content-Length"];
            NSURLResponse *respose = nil;
            NSData* received = [NSURLConnection sendSynchronousRequest:request returningResponse:&respose error:&error];
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    doneBlock([(NSHTTPURLResponse*)respose statusCode]  ,received);
                    
                });
                return;
            }
        }
        if (errorBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
    }
    @catch (NSException *exception)
    {
        if (errorBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"HttpService" code:0 userInfo:@{@"exception":exception}];
                errorBlock(error);
            });
        }
    }
    @finally {
    }
}

-(void)post:(NSURL*)serviceUrl body:(NSData*)body success:(httpServiceDoneBlock)doneBlock fail:(httpServiceErrorBlock)errorBlock
{
    dispatch_async(_queue, ^{
        [self postSync:serviceUrl body:body success:doneBlock fail:errorBlock];
    });
}

@end