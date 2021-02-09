//
//  UIScrollView+TFYCategory.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/11/3.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "UIScrollView+TFYCategory.h"
#import <objc/runtime.h>

static const void* TFYDisableGestureHandleKey = @"TFYDisableGestureHandleKey";

@implementation UIScrollView (TFYCategory)

- (void)setTfy_disableGestureHandle:(BOOL)tfy_disableGestureHandle {
    objc_setAssociatedObject(self, TFYDisableGestureHandleKey, @(tfy_disableGestureHandle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tfy_disableGestureHandle {
    return [objc_getAssociatedObject(self, TFYDisableGestureHandleKey) boolValue];
}

#pragma mark - 解决全屏滑动时的手势冲突
// 当UIScrollView在水平方向滑动到第一个时，默认是不能全屏滑动返回的，通过下面的方法可实现其滑动返回。
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.tfy_disableGestureHandle) return YES;

    if ([self panBack:gestureRecognizer]) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.tfy_disableGestureHandle) return NO;
    
    if ([self panBack:gestureRecognizer]) return YES;
    
    return NO;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        // 设置手势滑动的位置距屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

@end
