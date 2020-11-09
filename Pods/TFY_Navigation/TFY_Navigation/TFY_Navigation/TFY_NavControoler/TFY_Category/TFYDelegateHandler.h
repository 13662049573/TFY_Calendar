//
//  TFYDelegateHandler.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFYPopTransitionAnimation.h"
#import "TFYPushTransitionAnimation.h"
#import "UIViewController+TFYCategory.h"
#import "UINavigationController+TFYCategory.h"

NS_ASSUME_NONNULL_BEGIN

@class TFYNavigationControllerDelegate;
// 此类用于处理UIGestureRecognizerDelegate的代理方法
@interface TFYPopGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

// 系统返回手势的target
@property (nonatomic, weak) id systemTarget;

@property (nonatomic, weak) TFYNavigationControllerDelegate *customTarget;

@end

// 此类用于处理UINavigationControllerDelegate的代理方法
@interface TFYNavigationControllerDelegate : NSObject<UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

// 手势Action
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)gesture;

@end


NS_ASSUME_NONNULL_END
