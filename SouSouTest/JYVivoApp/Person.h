//
//  Person.h
//  JYVivoUI
//
//  Created by jock li on 15/2/1.
//  Copyright (c) 2015年 timedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodeInfo : NSObject
@property (nonatomic) int code;
@property (nonatomic, strong) NSString* info;
@end

@interface Person : NSObject

// 授权使用的APP项目编号字符串。由上海骏聿分配。
@property (nonatomic, retain) NSString *projectNum;

// guid
@property (nonatomic, retain) NSString *taskGuid;

// 身份证
@property (nonatomic, retain) NSString *personId;

// 姓名
@property (nonatomic, retain) NSString *personName;

// 自拍照
@property (nonatomic, retain) NSData *jpgBuffer;

// 证件照
@property (nonatomic, retain) NSData *idJpgBuffer;

// 打包数量
@property (nonatomic, retain) NSData *packagedData;

// 活体检测结果
@property (nonatomic) BOOL bodySuccess;

// 比对完成标记
@property (nonatomic) BOOL compareFinish;

// 比对显示结果
@property (nonatomic, retain) NSString *compareResult;

// 生成用于 post 的内容
@property (readonly) NSData* postBody;

// 比对结果，0成功，-1失败(默认)，1无法判定修改为0成功，-1无法判定，<-1失败
@property (nonatomic) int compareSuccess;

// 结果信息
@property (nonatomic, retain) NSString* resultInfo;
// 服务器三通测试结果信息
@property (nonatomic, retain) NSArray* resultInfos;
// 源三图
@property (nonatomic, retain) NSArray* photos;

-(instancetype)initWithId:(NSString*)personId name:(NSString*)personName;

// 处理服务器返回的 json 结果
-(BOOL)handleResult:(NSDictionary*)json;

@end
