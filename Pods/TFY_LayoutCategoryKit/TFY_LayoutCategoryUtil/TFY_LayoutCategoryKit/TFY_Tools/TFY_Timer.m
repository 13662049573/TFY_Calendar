//
//  TFY_Timer.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_Timer.h"

@implementation TFY_Timer
static int i = 0;
// 创建保存timer的容器
static NSMutableDictionary *timers;
dispatch_semaphore_t sem;

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers = [NSMutableDictionary dictionary];
        sem = dispatch_semaphore_create(1);
    });
}

+ (NSString *)timerWithTarget:(id)target selector:(SEL)selector StartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats mainQueue:(BOOL)async{
    if (!target || !selector) {
        return nil;
    }
    return [self timerWithStartTime:start interval:interval repeats:repeats mainQueue:async completion:^{
        if ([target respondsToSelector:selector]) {
            [target performSelector:selector withObject:nil afterDelay:start];
        }
    }];
}

+ (NSString *)timerWithStartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats mainQueue:(BOOL)async completion:(void (^)(void))completion {
    if (!completion || start < 0 ||  interval <= 0) {
        return nil;
    }
    // 创建定时器
    dispatch_queue_t queue = !async ? dispatch_queue_create("gcd.timer.queue", NULL) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );
    // 设置时间,从什么时候开始，间隔多少，下面相当于2s后开始，每隔一秒一次
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSString *timerId = [NSString stringWithFormat:@"%d",i++];
    timers[timerId]=timer;
    dispatch_semaphore_signal(sem);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        if (completion) {
            completion();
        }
        // 不重复执行就取消timer
        if (!repeats) {
            [self cancel:timerId];
        }
    });
    dispatch_resume(timer);
    return timerId;
}

+ (void)cancel:(NSString *)timerID{
    if (!timerID || timerID.length <= 0) {
        return;
    }
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timers[timerID];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers removeObjectForKey:timerID];
    }
    dispatch_semaphore_signal(sem);
}

@end
