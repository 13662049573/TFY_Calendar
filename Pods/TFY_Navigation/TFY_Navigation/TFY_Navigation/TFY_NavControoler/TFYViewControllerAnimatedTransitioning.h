//
//  TFYViewControllerAnimatedTransitioning.h
//  TFYViewControllerAnimatedTransitioning
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TFYViewControllerAnimatedTransitioning <UIViewControllerAnimatedTransitioning>

- (id<UIViewControllerInteractiveTransitioning>)tfy_interactiveTransitioning;

@end

NS_ASSUME_NONNULL_END

