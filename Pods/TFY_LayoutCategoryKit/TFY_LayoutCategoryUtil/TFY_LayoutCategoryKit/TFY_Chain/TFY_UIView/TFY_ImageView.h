//
//  TFY_ImageView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/1/8.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_AnimatedImage;
@protocol TFY_AnimatedImageViewDebugDelegate;

#ifndef NS_DESIGNATED_INITIALIZER
    #if __has_attribute(objc_designated_initializer)
        #define NS_DESIGNATED_INITIALIZER __attribute((objc_designated_initializer))
    #else
        #define NS_DESIGNATED_INITIALIZER
    #endif
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ImageView : UIImageView

//设置”(UIImageView。如果' image] '的值为非' nil '，将清除现有的' animateimage '。
//反之亦然，设置“animatedImage”一开始会填充“[UIImageView.]”然后开始动画并按住“currentFrame”。
@property (nonatomic, strong) TFY_AnimatedImage *animatedImage;
@property (nonatomic, copy) void(^loopCompletionBlock)(NSUInteger loopCountRemaining);

@property (nonatomic, strong, readonly) UIImage *currentFrame;
@property (nonatomic, assign, readonly) NSUInteger currentFrameIndex;

//动画运行循环模式。通过NSRunLoopCommonModes允许计时器事件(即动画)，在滚动过程中启用回放。
//为了在单核设备上保持滚动流畅，例如iPhone 3GS/4和iPod Touch第4代，默认的运行循环模式是nsdefaultultrunloopmode。否则，默认为nsdefaultultrunloopmode。
@property (nonatomic, copy) NSString *runLoopMode;

@end

extern const NSTimeInterval kAnimatedImageDelayTimeIntervalMinimum;

@interface TFY_AnimatedImage : NSObject
/**
 保证加载;通常相当于
 */
@property (nonatomic, strong, readonly) UIImage *posterImage;
/**
 The `.posterImage`'s `.size`
 */
@property (nonatomic, assign, readonly) CGSize size;
/**
 0表示无限期地重复动画
 */
@property (nonatomic, assign) NSUInteger loopCount;
/**
 类型NSTimeInterval框在NSNumber ' s中
 */
@property (nonatomic, strong, readonly) NSDictionary *delayTimesForIndexes;
/**
 有效帧数;等于' [.delayTimes count] '
 */
@property (nonatomic, assign, readonly) NSUInteger frameCount;
/**
 智能选择缓冲窗口的当前大小;可以在interval [1..frameCount]中取值。
 */
@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeCurrent;
/**
 允许设置缓存大小的上限;0表示没有特定的限制(默认值)
 */
@property (nonatomic, assign) NSUInteger frameCacheSizeMax;
/**
 //从主线程同步调用;将立即返回。
 //如果结果没有被缓存，将返回' nil ';然后调用者应该暂停回放，而不是增加帧计数器并保持轮询。
 //在初始加载时间之后，根据`frameCacheSize`，帧应该立即从缓存中可用。
 */
- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index;
/**
 传递一个' UIImage '或' TFY_ImageView '并获取它的大小
 */
+ (CGSize)sizeForImage:(id)image;
/**
 如果成功，初始化器返回一个' FLAnimatedImage '并初始化所有字段，如果失败则返回' nil '并记录一个错误。
 */
- (instancetype)initWithAnimatedGIFData:(NSData *)data;
/**
 为optimalFrameCacheSize传递0以获得默认值，预绘制是默认启用的。
 */
- (instancetype)initWithAnimatedGIFData:(NSData *)data optimalFrameCacheSize:(NSUInteger)optimalFrameCacheSize predrawingEnabled:(BOOL)isPredrawingEnabled NS_DESIGNATED_INITIALIZER;
+ (instancetype)animatedImageWithGIFData:(NSData *)data;
/**
 接收端初始化的数据;只读
 */
@property (nonatomic, strong, readonly) NSData *data;
@end

typedef NS_ENUM(NSUInteger, TFY_LogLevel) {
    TFY_LogLevelNone = 0,
    TFY_LogLevelError,
    TFY_LogLevelWarn,
    TFY_LogLevelInfo,
    TFY_LogLevelDebug,
    TFY_LogLevelVerbose
};

@interface TFY_AnimatedImage (Logging)

+ (void)setLogBlock:(void (^)(NSString *logString, TFY_LogLevel logLevel))logBlock logLevel:(TFY_LogLevel)logLevel;
+ (void)logStringFromBlock:(NSString *(^)(void))stringBlock withLevel:(TFY_LogLevel)level;

@end

#define TFY_Log(logLevel, format, ...) [TFY_AnimatedImage logStringFromBlock:^NSString *{ return [NSString stringWithFormat:(format), ## __VA_ARGS__]; } withLevel:(logLevel)]

@interface TFY_WeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end

NS_ASSUME_NONNULL_END
