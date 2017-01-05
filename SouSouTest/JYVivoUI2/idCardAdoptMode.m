//
//  idCardAdoptMode.m
//  JYVivoUI2
//
//  Created by junyufr on 16/5/25.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "idCardAdoptMode.h"

@implementation idCardAdoptMode

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static idCardAdoptMode *adoptMode;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        if(adoptMode == nil)
        {

            adoptMode = [super allocWithZone:zone];
            
        }
    });
    return adoptMode;
    
}


-(NSMutableArray *)btnArray
{
    if (_btnArray == nil)
    {
        NSMutableArray *btnArray = [NSMutableArray array];
        
        _btnArray = btnArray;
    }
    
    return _btnArray;
}


@end
