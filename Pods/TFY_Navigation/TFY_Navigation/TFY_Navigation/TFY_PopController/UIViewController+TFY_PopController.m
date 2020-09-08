//
//  UIViewController+TFY_PopController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UIViewController+TFY_PopController.h"
#import <objc/runtime.h>

@implementation UIViewController (TFY_PopController)
@dynamic contentSizeInPop;
@dynamic contentSizeInPopWhenLandscape;
@dynamic popController;

static inline BOOL HW_FLOAT_VALUE_IS_ZERO(CGFloat value) {
    return (value > -FLT_EPSILON) && (value < FLT_EPSILON);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tfy_swizzleInstanceMethod:@selector(viewDidLoad) with:@selector(tfy_DidLoad)];
        [self tfy_swizzleInstanceMethod:@selector(presentViewController:animated:completion:) with:@selector(tfy_presentViewController:animated:completion:)];
        [self tfy_swizzleInstanceMethod:@selector(dismissViewControllerAnimated:completion:) with:@selector(tfy_dismissViewControllerAnimated:completion:)];
    });
}

+ (BOOL)tfy_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;

    class_addMethod(self,
            originalSel,
            class_getMethodImplementation(self, originalSel),
            method_getTypeEncoding(originalMethod));
    class_addMethod(self,
            newSel,
            class_getMethodImplementation(self, newSel),
            method_getTypeEncoding(newMethod));

    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
            class_getInstanceMethod(self, newSel));
    return YES;
}

- (void)tfy_DidLoad {

    [self tfy_DidLoad];

    CGSize contentSize;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:{
            contentSize = self.contentSizeInPopWhenLandscape;
            if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
                contentSize = self.contentSizeInPop;
            }
        }
            break;
        default:{
            contentSize = self.contentSizeInPop;
        }
            break;
    }

    if (!CGSizeEqualToSize(contentSize, CGSizeZero)) {
        self.view.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    }

}

- (void)tfy_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (!self.popController) {
        [self tfy_presentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    
    [[self.popController valueForKey:@"containerViewController"] tfy_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)tfy_dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    if (!self.popController) {
        [self tfy_dismissViewControllerAnimated:flag completion:completion];
        return;
    }
    
    [self.popController dismissWithCompletion:completion];
}

#pragma mark - props

- (CGSize)contentSizeInPop {
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    return [value CGSizeValue];
}

- (void)setContentSizeInPop:(CGSize)contentSizeInPop {
    if (!CGSizeEqualToSize(contentSizeInPop, CGSizeZero) && HW_FLOAT_VALUE_IS_ZERO(contentSizeInPop.width)) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:{
                contentSizeInPop.width = [UIScreen mainScreen].bounds.size.height;
            }
                break;
            default: {
                contentSizeInPop.width = [UIScreen mainScreen].bounds.size.width;
            }
                break;

        }
    }

    objc_setAssociatedObject(self, @selector(contentSizeInPop), [NSValue valueWithCGSize:contentSizeInPop], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)contentSizeInPopWhenLandscape {
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    return [value CGSizeValue];
}

- (void)setContentSizeInPopWhenLandscape:(CGSize)contentSizeInPopWhenLandscape {
    if (!CGSizeEqualToSize(contentSizeInPopWhenLandscape, CGSizeZero) && HW_FLOAT_VALUE_IS_ZERO(contentSizeInPopWhenLandscape.width)) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:{
                contentSizeInPopWhenLandscape.width = [UIScreen mainScreen].bounds.size.width;
            }
                break;
            default: {
                contentSizeInPopWhenLandscape.width = [UIScreen mainScreen].bounds.size.height;
            }
                break;

        }
    }

    objc_setAssociatedObject(self, @selector(contentSizeInPopWhenLandscape), [NSValue valueWithCGSize:contentSizeInPopWhenLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TFY_PopController *)popController {
    TFY_PopController *popController = objc_getAssociatedObject(self, _cmd);
    return popController;
}

- (void)setPopController:(TFY_PopController *)popController {
    objc_setAssociatedObject(self, @selector(popController), popController, OBJC_ASSOCIATION_ASSIGN);
}


@end

UIViewController *HWGetTopMostViewController() {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topVC = keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }

    if ([topVC isKindOfClass:[UINavigationController class]]) {
        topVC = ((UINavigationController *) topVC).topViewController;
    }

    if ([topVC isKindOfClass:[UITabBarController class]]) {
        topVC = ((UITabBarController *) topVC).selectedViewController;
    }

    return topVC;
}

@implementation UIViewController (Pop)

- (TFY_PopController *)popup {
     return [self popupWithPopType:PopTypeGrowIn dismissType:DismissTypeFadeOut position:PopPositionCenter inViewController:HWGetTopMostViewController() dismissOnBackgroundTouch:YES];
}

- (TFY_PopController *)popupWithPopType:(PopType)popType dismissType:(DismissType)dismissType{
    return [self popupWithPopType:popType dismissType:dismissType position:PopPositionCenter];
}

- (TFY_PopController *)popupWithPopType:(PopType)popType
                          dismissType:(DismissType)dismissType
                             position:(PopPosition)popPosition {
    return [self popupWithPopType:popType dismissType:dismissType position:popPosition inViewController:HWGetTopMostViewController() dismissOnBackgroundTouch:YES];
}

- (TFY_PopController *)popupWithPopType:(PopType)popType
                          dismissType:(DismissType)dismissType
                             position:(PopPosition)popPosition
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch {
    return [self popupWithPopType:popType dismissType:dismissType position:popPosition inViewController:HWGetTopMostViewController() dismissOnBackgroundTouch:shouldDismissOnBackgroundTouch];
}

- (TFY_PopController *)popupWithPopType:(PopType)popType
                          dismissType:(DismissType)dismissType
                             position:(PopPosition)popPosition
                     inViewController:(UIViewController *)inViewController
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch {
    TFY_PopController *popController = [[TFY_PopController alloc] initWithViewController:self];
    popController.popType = popType;
    popController.dismissType = dismissType;
    popController.popPosition = popPosition;
    popController.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
    [popController presentInViewController:inViewController];
    return popController;
}
@end
