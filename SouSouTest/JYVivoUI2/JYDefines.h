//
//  JYDefines.h
//  JYVivoUI2
//
//  Created by jock li on 16/4/24.
//  Copyright © 2016年 timedge. All rights reserved.
//

#ifndef JYDefines_h
#define JYDefines_h

// 使用调试时辅助视图（取消下行注释将在环境检测与活体检测中显示出进入内核库的灰度图片）
//#define JYDEBUG

// 当前视频流的质量，请参考 Video Input Presets 常量，注意，当前核心识别库不支持宽度或高度大于 1000 像素。
#define JYVIDEO_PRESET AVCaptureSessionPreset640x480 

//AVCaptureSessionPreset352x288

// 正确结果的文本颜色
#define GOOD_UICOLOR [UIColor colorWithRed:.027 green:.533 blue:.792 alpha:1]

// 失败结果的文本颜色
#define FAIL_UICOLOR [UIColor redColor]
//[UIColor colorWithRed:.914 green:.012 blue:.204 alpha:1]

// 预览视图相对步骤视图区的高度
#define VIDEO_VIEW_TOP 84

// 预览视图的宽度
#define VIDEO_VIEW_WIDTH 240

// 预览视图的高度
#define VIDEO_VIEW_HEIGHT 308

// 扫描（环境检测）界面的最小停留时间（秒）
#define SCANLIE_STEP_MIN_REMAIN 3

// 扫描（环境检测）界面成功后保留时间（秒）
#define SCANLIE_STEP_DONE_DELAY 1

// 扫描线一次扫描时间（秒）
#define SCANLINE_DURATION 1.2

// 环境检测每次自拍的时间间隔（秒）
#define SELF_CHECK_DELAY 1

// 进度条最小值对应的 bar 图片 y 轴位置
#define PROGRESS_MIN_Y 218

// 进度条最大值对应的 bar 图片 y 轴位置
#define PROGRESS_MAX_Y 0

// 进度条指示器的指示参照线 y 轴位置
#define PROGRESS_ARROW_Y 9

// 动作图片的逻辑宽度
#define ACTION_IMAGE_WIDTH 110

// 动作图片的逻辑高度
#define ACTION_IMAGE_HEIGHT 116

// 动作图片的帧延时(秒)
#define ACTION_FRAME_DELAY 0.6

// 使用动作提示音（注释下行将不产生提示音）
#define SOUND_ACTION
// 使用动作结果成功或失败提示音（注释下行将不产生提示音）
#define SOUND_ACTION_RESULT
// 使用计时音（注释下行将不产生计时音）
#define SOUND_TICK

// 默认的服务器地址（可在设置界面变更）
#define SERVICE_URL @"https://122.112.217.80:9444/AuthAppServerProject/"


#endif /* JYDefines_h */























