//
//  JYVivoResult.h
//  JYVivoUI2
//
//  Created by jock li on 16/5/7.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import <Foundation/Foundation.h>

// 表示识别结果信息，可以通过 [[JYAVSessionHolder instance] result] 来获取
@interface JYVivoResult : NSObject

// 是否已通过本地检测
@property (nonatomic) BOOL success;

// 打包待上传数据
@property (nonatomic, strong) NSData* packagedData;

// 自拍照片
@property (nonatomic, strong) NSData* jpgData;

// 证件照片
@property (nonatomic, strong) NSData* idJpgData;

// 保存的图片
@property (nonatomic, strong) NSArray* photos;

@end
