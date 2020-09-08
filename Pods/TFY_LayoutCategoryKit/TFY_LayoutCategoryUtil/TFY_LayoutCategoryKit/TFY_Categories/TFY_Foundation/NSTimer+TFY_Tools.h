//
//  NSTimer+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (TFY_Tools)
 /**
  * 自动开始
  */
+ (NSTimer *)tfy_scheduledTimerWithBlock:(void (^) (NSTimer *timer))block timeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats;

/**
  * 需要手动开始
 */
+ (NSTimer *)tfy_timerWithBlock:(void (^) (NSTimer *timer))block timeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats;
@end

NS_ASSUME_NONNULL_END
