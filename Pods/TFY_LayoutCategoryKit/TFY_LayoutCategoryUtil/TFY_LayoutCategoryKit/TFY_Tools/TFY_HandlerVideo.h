//
//  TFY_HandlerVideo.h
//  TFY_Category
//
//  Created by 田风有 on 2019/7/12.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

typedef void(^SplitCompleteBlock)(BOOL success, NSMutableArray * _Nonnull splitimgs);
typedef void(^CompCompletedBlock)(BOOL success);
typedef void(^CompFinalCompletedBlock)(BOOL success, NSString * _Nonnull errorMsg);
typedef void(^CompProgressBlcok)(CGFloat progress);

typedef enum {
    VideoSpeedTypeNormal,
    VideoSpeedTypeFast,
    VideoSpeedTypeSlow
} VideoSpeedType;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_HandlerVideo : NSObject
+ (instancetype)sharedInstance;

/**
 *  图片合成视频 videoFullPath 合成路径 frameImgs 图片数组 fps 帧率 progressImageBlock 进度回调  completedBlock 完成回调
 */
- (void)composesVideoFullPath:(NSString *)videoFullPath frameImgs:(NSArray<UIImage *> *)frameImgs fps:(int32_t)fps progressImageBlock:(CompProgressBlcok)progressImageBlock completedBlock:(CompCompletedBlock)completedBlock;

/**
 *  多个小视频合成大视频 subsectionPaths 视频地址数组 videoFullPath 合成视频路径 isHaveAudio 视频是有声音，YES:创建音频轨道 NO:不创建音频轨道 completedBlock 完成回调
 */
- (void)combinationVideosWithVideoPath:(NSArray<NSString *> *)subsectionPaths videoFullPath:(NSString *)videoFullPath isHavaAudio:(BOOL)isHaveAudio progressBlock:(CompProgressBlcok)progressBlock completedBlock:(CompFinalCompletedBlock)completedBlock;

/**
 *  MP4 将视频分解成图片 fileUrl 视频路径 fps 帧率 progressImageBlock 进度回调 splitCompleteBlock 分解完成回调
 */
- (void)splitVideo:(NSURL *)fileUrl fps:(float)fps progressImageBlock:(CompProgressBlcok)progressImageBlock splitCompleteBlock:(SplitCompleteBlock) splitCompleteBlock;


/**
 * 视频添加静态图片水印 watermaskImg 水印图片 videoFullPath 合成视频路径 completedBlock 完成回调
 */
- (void)addWatermaskVideoWithWatermaskImg:(UIImage *)watermaskImg inputVideoPath:(NSString *)inputVideoPath outputVideoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock;


/**
 * 设置视频导出速率 speedType 速率类型 inputVideoPath 视频源路径 videoFullPath 导出路径 completedBlock 完成回调
 */
- (void)setVideoSpeed:(VideoSpeedType)speedType inputVideoPath:(NSString *)inputVideoPath outputVideoFullPath:(NSString *)videoFullPath completedBlock:(CompFinalCompletedBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
