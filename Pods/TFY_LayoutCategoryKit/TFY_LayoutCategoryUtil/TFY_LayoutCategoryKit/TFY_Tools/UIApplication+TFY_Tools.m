//
//  UIApplication+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIApplication+TFY_Tools.h"
#import <pthread.h>
#import <objc/message.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <objc/runtime.h>

#ifndef SYNTH_DYNAMIC_PROPERTY_OBJECT

#define SYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}

#endif

#define kNetworkIndicatorDelay (1/30.0)

@interface _UIApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation _UIApplicationNetworkIndicatorInfo
@end


@implementation UIApplication (TFY_Tools)

+ (id)tfy_currentScene{
    return [TFY_Scene defaultPackage].currentScene;
}

+ (id)tfy_currentSceneDelegate{
    if ([self tfy_currentScene]) {
        return ((id (*)(id, SEL))objc_msgSend)([self tfy_currentScene],sel_registerName("delegate"));
    }
    return nil;
}

+ (BOOL)tfy_isSceneApp{
    return [TFY_Scene defaultPackage].isSceneApp;
}

+ (CGRect)tfy_statusBarFrame{
    return [TFY_Scene defaultPackage].statusBarFrame;
}

+ (UIWindow *)tfy_currentWindow{
    id wi = nil;
    for (UIWindow *window in [TFY_Scene defaultPackage].windows) {
        if (window.hidden == NO) {
            wi = window;
            break;
        }
    }
    return wi;
}

+ (UIWindow *)tfy_window{
    return [TFY_Scene defaultPackage].window;
}

+ (UIWindow *)tfy_currentKeyWindow{
    return [TFY_Scene defaultPackage].keyWindow;
}

+ (id)delegate{
    return [UIApplication sharedApplication].delegate;
}

+ (__kindof UIViewController *)rootViewController{
    return ([self tfy_keyWindow]?:[self tfy_window]).rootViewController;
}

+ (__kindof UIViewController *)currentTopViewController{
    
    UIViewController *vc = [self rootViewController];
    Class naVi = [UINavigationController class];
    Class tabbarClass = [UITabBarController class];
    BOOL isNavClass = [vc isKindOfClass:naVi];
    BOOL isTabbarClass = NO;
    if (!isNavClass) {
        isTabbarClass = [vc isKindOfClass:tabbarClass];
    }
    while (isNavClass || isTabbarClass) {
        UIViewController * top;
        if (isNavClass) {
          top = [(UINavigationController *)vc topViewController];
        }else{
          top = [(UITabBarController *)vc selectedViewController];
        }
        if (top) {
            vc = top;
        }else{
            break;
        }
        isNavClass = [vc isKindOfClass:naVi];
        if (!isNavClass) {
            isTabbarClass = [vc isKindOfClass:tabbarClass];
        }
    }
    return vc;
}

+ (UINavigationController *)currentToNavgationController{
    return [self currentTopViewController].view.navigationController;
}

+ (UIWindow *)tfy_keyWindow{
    return [TFY_Scene defaultPackage].keyWindow;
}

@end

@implementation UIView (Navigation_Chain)

- (UINavigationController *_Nonnull)navigationController
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)next;
            
        }
        next = next.nextResponder;
    } while (next);
    return nil;
    
}


@end
