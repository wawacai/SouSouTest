//
//  JYResource.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/1.
//  Copyright © 2016年 timedge. All rights reserved.
//

//#import "JYResource.h"
//
//static NSBundle* jyResourceBundle = nil;
//
//@implementation JYResource
//
//+(NSBundle*) bundle
//{
//    if (jyResourceBundle == nil)
//    {
//        NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:@"JYVivoUI2Res" withExtension:@"bundle"];
//        jyResourceBundle = [NSBundle bundleWithURL:bundleUrl];
//    }
//    return jyResourceBundle;
//}
//
//+(NSURL*)URLForResource:(NSString*)name withExtension:(NSString*)extension
//{
//    return [[JYResource bundle] URLForResource:name withExtension:extension];
//}
//
//+(UIImage*)imageNamed:(NSString*)name
//{
//    return [UIImage imageNamed:name inBundle:[JYResource bundle] compatibleWithTraitCollection:nil];
//}
//
//@end


#import "JYResource.h"

static NSBundle* jyResourceBundle = nil;

@implementation JYResource
+(NSBundle*) bundle
{
    if (jyResourceBundle == nil)
    {
        NSURL *bundleUrl = [[NSBundle mainBundle] bundleURL];
        jyResourceBundle = [NSBundle bundleWithURL:bundleUrl];
    }
    return jyResourceBundle;
}

+(NSURL*)URLForResource:(NSString*)name withExtension:(NSString*)extension
{
    return [[JYResource bundle] URLForResource:name withExtension:extension];
}

+(UIImage*)imageNamed:(NSString*)name
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil]; // @"png"
//    return [UIImage imageWithContentsOfFile:path];
    return [UIImage imageNamed:name];
}

@end

