//
//  TFY_PopTransitioningDelegate.m
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_PopTransitioningDelegate.h"
#import "TFY_PopControllerAnimatedTransitioning.h"

@implementation TFY_PopTransitioningDelegate

- (instancetype)initWithPopController:(TFY_PopController *)popController {
    self = [super init];
    if (self) {
        _popController = popController;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[TFY_PopControllerAnimatedTransitioning alloc] initWithState:PopStatePop popController:self.popController];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[TFY_PopControllerAnimatedTransitioning alloc] initWithState:PopStateDismiss popController:self.popController];
}

@end
