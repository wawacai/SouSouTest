//
//  Person.m
//  JYVivoUI
//
//  Created by jock li on 15/2/1.
//  Copyright (c) 2015年 timedge. All rights reserved.
//

#import "Person.h"
#import "o_ResponseMode.h"
#import "idCardAdoptMode.h"

@implementation CodeInfo

+(id)codeInfoFromDictionary:(NSDictionary*)json
{
    CodeInfo* codeInfo = [CodeInfo new];
    id code = [json objectForKey:@"code"];
    if (code)
    {
        codeInfo.code = [code intValue];
    }
    codeInfo.info = [json objectForKey:@"info"];
    return codeInfo;
}

@end

@implementation Person

-(instancetype)initWithId:(NSString*)personId name:(NSString*)personName
{
    self = [super init];
    if (self)
    {
        self.compareSuccess = -123;
        self.taskGuid = [[NSUUID UUID] UUIDString];
        idCardAdoptMode *mode = [[idCardAdoptMode alloc]init];
        mode.taskGuid = [[NSUUID UUID] UUIDString];
        self.personId = personId;
        self.personName = personName;
    }
    return self;
}

-(BOOL)handleResult:(NSDictionary*)json
{
    self.compareSuccess = -1;
    
    if (json)
    {
        id netResult = [json objectForKey:@"result"];
        if (netResult)
        {
            self.compareSuccess = [netResult intValue];
            NSMutableArray* infos = [NSMutableArray new];
            NSDictionary* o_response = [json objectForKey:@"o_response"];
            if (o_response)
            {
                for (int i=1; i<=3; i++)
                {
                    NSString *key = [NSString stringWithFormat:@"response_l%d", i];
                    NSDictionary *item =[o_response objectForKey:key];
                    o_ResponseMode *mode = [[o_ResponseMode alloc] init];
                    if (item)
                    {
                        mode.o_response = item;
                        mode.o_responseNumber = i;
                    }
                    if (mode.o_response)
                    {
                        [infos addObject:mode];
                    }
                }
            }
            self.resultInfos = infos;
        }
    } else
    {
        self.resultInfo = @"服务器错误";
    }
    
    return self.compareSuccess == 0;
}

-(NSData*)postBody {
    NSMutableData *data = [[NSMutableData alloc] init];
    idCardAdoptMode *mode =[[idCardAdoptMode alloc] init];
    
//    NSLog(@"证件号：%@",mode.idCardNumber);
    
    [data appendData:[[NSString stringWithFormat:@"strProjectNum=%@&", self.projectNum] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"strTaskGuid=%@&", self.taskGuid] dataUsingEncoding:NSUTF8StringEncoding]];

    [data appendData:[[NSString stringWithFormat:@"strPersonName=%@&", mode.name] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"strPersonId=%@&", mode.idCardNumber] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"bAliveCheck=true&" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[@"strPhotoBase64=" stringByAppendingString:[mode.packagedData base64Encoding]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    if (mode.idCardImage)
    {
        [data appendData:[[@"&strIDPhotoBase64=" stringByAppendingString:[ UIImageJPEGRepresentation(mode.idCardImage, 0.7) base64Encoding]] dataUsingEncoding:NSUTF8StringEncoding]];

    } else
    {
        [data appendData:[@"&strIDPhotoBase64=" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return data;
}

@end
