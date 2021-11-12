//
//  TFY_Inlinefunction.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/2/8.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/message.h>
#import "UIApplication+TFY_Tools.h"
#import "UIView+TFY_Tools.h"

#pragma mark-------------------------------------------内联函数---------------------------------------------

/***线程****/
///异步
NS_INLINE void TFY_GCD_QUEUE_ASYNC(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}
///延迟加载
NS_INLINE void TFY_GCD_QUEUE_TIME(NSInteger time,dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);//并发队列-延迟执行
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
        dispatch_after(when, queue, ^{
            block();
        });
    } else {
        dispatch_queue_t queuetime = dispatch_get_main_queue();//主队列--延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), queuetime, ^{
            block();
        });
    }
}
///主线程
NS_INLINE void TFY_GCD_QUEUE_MAIN(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        }else{
            dispatch_sync(queue, block);
        }
    }
}

/** 发送通知 */
CG_INLINE void TFY_PostNotification(NSNotificationName _Nonnull name,id _Nonnull obj,NSDictionary * _Nonnull info) {
    return [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:info];
}
/** 监听通知 */
CG_INLINE void TFY_ObserveNotification(id _Nonnull observer,SEL _Nonnull aSelector,NSNotificationName _Nonnull aName,id _Nonnull obj) {
    return [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:obj];
}
/** 移除所有通知 */
CG_INLINE void TFY_RemoveNotification(id _Nonnull observer) API_AVAILABLE(ios(11.0)) {
    return [[NSNotificationCenter defaultCenter] removeObserver:observer];
}
/** 移除一个已知通知 */
CG_INLINE void TFY_RemoveOneNotification(id _Nonnull observer,NSNotificationName _Nonnull aName,id _Nonnull obj) {
    return [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:obj];
}

//仅仅是状态栏的高度
CG_INLINE CGFloat kStatusBarHeight() {
    return (TFY_SafeArea([UIApplication tfy_window]).top);
}

CG_INLINE CGFloat kDefaultNavigationBarHeight() {
    return (TFY_SafeArea([UIApplication tfy_window]).top + 44);
}

//这个高度如果有tabbar高度则包含tabbar高度，否则不包含
CG_INLINE CGFloat KHomeIndicatorHeight() {
    return (TFY_SafeArea([UIApplication currentTopViewController].view).bottom);
}
//这个高度只是tabbarHeight的高度
CG_INLINE CGFloat KTabbarHeight() {
    return ([UIApplication rootViewController].tabBarController.tabBar.height);
}

//当前显示的navigationbar的高度
CG_INLINE CGFloat kNavigationBarHeight() {
    UINavigationBar *bar = [UIApplication currentTopViewController].navigationController.navigationBar;
    return bar.isHidden?0:bar.height + kStatusBarHeight();
}

//获取最适合的控制器
CG_INLINE UIViewController * _Nonnull TFY_getTheLatestViewController(UIViewController * _Nonnull vc) {
    if (vc.presentedViewController == nil) {return vc;}
    return TFY_getTheLatestViewController(vc.presentedViewController);
}

CG_INLINE UIWindow * _Nonnull TFY_LastWindow() {
    NSEnumerator  *frontToBackWindows = [[TFY_Scene defaultPackage].windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha>0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        if (windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {return window;}
    }
    return [UIApplication tfy_keyWindow];
}

//最上层容器
CG_INLINE UIViewController * _Nonnull TFY_RootpresentMenuView() {
    UIViewController *rootVC = TFY_getTheLatestViewController(TFY_LastWindow().rootViewController);
    return rootVC;
}

//跳转指定控制器
CG_INLINE void TFY_PopToViewController(UIViewController * _Nonnull vc) {
    for(UIViewController * tempvc in [UIApplication currentTopViewController].navigationController.childViewControllers){
       if([tempvc isKindOfClass:vc.class]){
          [[UIApplication currentTopViewController].navigationController popToViewController:tempvc animated:true];
       }
    }
}

//返回更控制器
CG_INLINE void TFY_DismissViewController(UIViewController * _Nonnull vc){
    UIViewController * tempvc = vc.presentingViewController;
    while (tempvc.presentingViewController) {
        tempvc = tempvc.presentingViewController;
        if([tempvc isKindOfClass:[UIViewController class]]){break;}
    }
    [tempvc dismissViewControllerAnimated:true completion:nil];
}

//方法和类交互
CG_INLINE void TFY_Method_exchangeImp(Class _Nonnull _class, SEL _Nonnull _originSelector, SEL _Nonnull _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}



