//
//  JYResource.h
//  JYVivoUI2
//
//  Created by jock li on 16/5/1.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYResource : NSObject

+(NSBundle*) bundle;

+(NSURL*)URLForResource:(NSString*)name withExtension:(NSString*)extension;

+(UIImage*)imageNamed:(NSString*)name;

@end
