//
//  TFY_Timer.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Timer : NSObject
/**
  start 开始时间
  interval 间隔多少秒执行下一次
  repeats 是否开启循环执行
  async 选择主线程还是子线程执行
 */
+ (NSString *)timerWithStartTime:(NSTimeInterval)start
                        interval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                       mainQueue:(BOOL)async
                      completion:(void (^)(void))completion;

/**
 target 那个对象需要执行
 selector 执行方法
 start 开始时间
 interval 间隔多少秒执行下一次
 repeats 是否开启循环执行
 async 选择主线程还是子线程执行
 */
+ (NSString *)timerWithTarget:(id)target
                     selector:(SEL)selector
                    StartTime:(NSTimeInterval)start
                     interval:(NSTimeInterval)interval
                      repeats:(BOOL)repeats
                    mainQueue:(BOOL)async;

/**取消定时器，通过上面返回ID*/
+ (void)cancel:(NSString *)timerID;
@end

NS_ASSUME_NONNULL_END
