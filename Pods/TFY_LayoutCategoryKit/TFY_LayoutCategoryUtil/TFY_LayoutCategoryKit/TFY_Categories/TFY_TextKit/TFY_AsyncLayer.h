//
//  TFY_AsyncLayer.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

CGFloat tfy_text_screen_scale(void);

@class TFY_AsyncLayerDisplayTask;
@protocol AsyncLayerDelegate <NSObject>
@required

- (TFY_AsyncLayerDisplayTask *_Nonnull)newAsyncDisplayTask;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AsyncLayer : CALayer

/**
 委托用于层的异步显示。
 */
@property (nonatomic, weak) id<AsyncLayerDelegate> asyncDelegate;

/**
 异步显示层在后台线程。默认是的
 */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/**
 显示层在主线程上。
 */
- (void)displayImmediately;

/**
 取消任何挂起的异步显示。
 */
- (void)cancelAsyncDisplay;

@end

@interface TFY_AsyncLayerDisplayTask : NSObject


/**
 将显示层在主线程。
 */
@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);


/**
 正在显示层的内容，将被调用在主或后台线程。
 */
@property (nullable, nonatomic, copy) void (^displaying)(CGContextRef context, CGSize size, BOOL isAsynchronously, BOOL(^isCancelled)(void));


/**
 在主线程上显示层。如果取消显示，完成是NO。
 */
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
