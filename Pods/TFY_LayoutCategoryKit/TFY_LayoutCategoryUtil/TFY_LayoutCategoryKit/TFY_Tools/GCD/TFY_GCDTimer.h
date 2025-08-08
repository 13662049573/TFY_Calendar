//
//  TFY_GCDTimer.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/1/29.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_GCDQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_GCDTimer : NSObject

@property (strong, readonly, nonatomic) dispatch_source_t dispatchSource;

#pragma 初始化
- (instancetype)init;
- (instancetype)initInQueue:(TFY_GCDQueue *)queue;

#pragma mark - 用法
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval;
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs;
- (void)start;
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
