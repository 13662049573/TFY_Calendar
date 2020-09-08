//
//  TFY_NavAnimatedTransitioning.h
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_PopController.h"

@class TFY_NavAnimatedTransitioning;
NS_ASSUME_NONNULL_BEGIN

@interface TFY_NavAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) PopState state;

- (instancetype)initWithState:(PopState)state NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
