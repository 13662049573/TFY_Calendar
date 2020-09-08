//
//  NSTimer+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSTimer+TFY_Tools.h"

@implementation NSTimer (TFY_Tools)
+ (void)tfy_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)tfy_scheduledTimerWithBlock:(void (^) (NSTimer *timer))block timeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats{
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(tfy_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)tfy_timerWithBlock:(void (^) (NSTimer *timer))block timeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats{
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(tfy_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

@end
