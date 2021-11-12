//
//  UINavigationController+Push.h
//  Push
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface UINavigationController (Push)
@property (nonatomic, assign, getter=tfy_isInteractivePushEnabled) IBInspectable BOOL tfy_enableInteractivePush;
@property (nonatomic, readonly, nullable) UIPanGestureRecognizer *tfy_interactivePushGestureRecognizer;
@end

@interface UIViewController (Push)
- (nullable __kindof UIViewController *)tfy_nextSiblingController;
@end
NS_ASSUME_NONNULL_END
