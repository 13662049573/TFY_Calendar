//
//  TFY_AudioPlayer.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/3/22.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ImageModel : NSObject
@property(nonatomic , strong)UIImage *image;
@property(nonatomic , assign)CGFloat imageH;
@property(nonatomic , assign)CGSize imageSize;
@property(nonatomic , copy)NSString *imageUrl;
@property(nonatomic , strong)NSData *imageData;
@end

@interface TFY_AudioPlayer : NSObject

/// 播放音乐
+(BOOL)playMusic:(NSString*)filename;
/// 暂停音乐
+(void)pauseMusic:(NSString*)filename;
/// 停止音乐
+(void)stopMusic:(NSString*)filename;
/// 播放系统音频
+(void)playSound:(NSString*)filename;
/// 停止系统音频
+(void)disposeSound:(NSString*)filename;
/// 批量图片下载，带缓存 imageWidth 等比图片宽度
+ (void)creatGroupUrl:(NSArray<NSString *> *)urlArray widthImage:(CGFloat)imageWidth imageArr:(void(^)(NSArray<TFY_ImageModel *> *images))imageHandle;

@end

NS_ASSUME_NONNULL_END
