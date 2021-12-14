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

#define TFY_ScreenScale ([[UIScreen mainScreen] scale])

#pragma mark - Clang

#define TFY_ArgumentToString(macro) #macro
#define TFY_ClangWarningConcat(warning_name) TFY_ArgumentToString(clang diagnostic ignored warning_name)

#define TFY_BeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(TFY_ClangWarningConcat(#warningName))
#define TFY_EndIgnoreClangWarning _Pragma("clang diagnostic pop")

#define TFY_BeginIgnorePerformSelectorLeaksWarning TFY_BeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define TFY_EndIgnorePerformSelectorLeaksWarning TFY_EndIgnoreClangWarning

#define TFY_BeginIgnoreAvailabilityWarning TFY_BeginIgnoreClangWarning(-Wpartial-availability)
#define TFY_EndIgnoreAvailabilityWarning TFY_EndIgnoreClangWarning

#define TFY_BeginIgnoreDeprecatedWarning TFY_BeginIgnoreClangWarning(-Wdeprecated-declarations)
#define TFY_EndIgnoreDeprecatedWarning TFY_EndIgnoreClangWarning


#pragma mark-------------------------------------------内联函数---------------------------------------------

/***线程****/
///异步
NS_INLINE
void TFY_GCD_QUEUE_ASYNC(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}
///延迟加载
NS_INLINE
void TFY_GCD_QUEUE_TIME(NSInteger time,dispatch_block_t _Nonnull block) {
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
NS_INLINE
void TFY_GCD_QUEUE_MAIN(dispatch_block_t _Nonnull block) {
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
CG_INLINE
void TFY_PostNotification(NSNotificationName _Nonnull name,id _Nonnull obj,NSDictionary * _Nonnull info) {
    return [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:info];
}
/** 监听通知 */
CG_INLINE
void TFY_ObserveNotification(id _Nonnull observer,SEL _Nonnull aSelector,NSNotificationName _Nonnull aName,id _Nonnull obj) {
    return [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:obj];
}
/** 移除所有通知 */
CG_INLINE
void TFY_RemoveNotification(id _Nonnull observer) API_AVAILABLE(ios(11.0)) {
    return [[NSNotificationCenter defaultCenter] removeObserver:observer];
}
/** 移除一个已知通知 */
CG_INLINE
void TFY_RemoveOneNotification(id _Nonnull observer,NSNotificationName _Nonnull aName,id _Nonnull obj) {
    return [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:obj];
}

//仅仅是状态栏的高度
CG_INLINE
CGFloat kStatusBarHeight() {
    return (TFY_SafeArea([UIApplication tfy_window]).top);
}

CG_INLINE
CGFloat kDefaultNavigationBarHeight() {
    return (TFY_SafeArea([UIApplication tfy_window]).top + 44);
}

//这个高度如果有tabbar高度则包含tabbar高度，否则不包含
CG_INLINE
CGFloat KHomeIndicatorHeight() {
    return (TFY_SafeArea([UIApplication currentTopViewController].view).bottom);
}
//这个高度只是tabbarHeight的高度
CG_INLINE
CGFloat KTabbarHeight() {
    return ([UIApplication rootViewController].tabBarController.tabBar.height);
}

//当前显示的navigationbar的高度
CG_INLINE
CGFloat kNavigationBarHeight() {
    UINavigationBar *bar = [UIApplication currentTopViewController].navigationController.navigationBar;
    return bar.isHidden?0:bar.height + kStatusBarHeight();
}

//获取最适合的控制器
CG_INLINE
UIViewController * _Nonnull TFY_getTheLatestViewController(UIViewController * _Nonnull vc) {
    if (vc.presentedViewController == nil) {return vc;}
    return TFY_getTheLatestViewController(vc.presentedViewController);
}

CG_INLINE
UIWindow * _Nonnull TFY_LastWindow() {
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

/// 最上层容器
CG_INLINE
UIViewController * _Nonnull TFY_RootpresentMenuView() {
    UIViewController *rootVC = TFY_getTheLatestViewController(TFY_LastWindow().rootViewController);
    return rootVC;
}

/// 获取当前控制器
CG_INLINE
UIViewController * _Nonnull TFY_currentViewController() {
    UIViewController* currentViewController = TFY_LastWindow().rootViewController;
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    return currentViewController;
}

/// 跳转指定控制器
CG_INLINE
void TFY_PopToViewController(UIViewController * _Nonnull vc) {
    for(UIViewController * tempvc in [UIApplication currentTopViewController].navigationController.childViewControllers){
       if([tempvc isKindOfClass:vc.class]){
          [[UIApplication currentTopViewController].navigationController popToViewController:tempvc animated:true];
       }
    }
}

/// 返回更控制器
CG_INLINE
void TFY_DismissViewController(UIViewController * _Nonnull vc){
    UIViewController * tempvc = vc.presentingViewController;
    while (tempvc.presentingViewController) {
        tempvc = tempvc.presentingViewController;
        if([tempvc isKindOfClass:[UIViewController class]]){break;}
    }
    [tempvc dismissViewControllerAnimated:true completion:nil];
}

/// 类交互
CG_INLINE
void TFY_Method_exchangeImp(Class _Nonnull _class, SEL _Nonnull _originSelector, SEL _Nonnull _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat
TFY_flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    scale = scale == 0 ? TFY_ScreenScale : scale;
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat
TFY_flat(CGFloat floatValue) {
    return TFY_flatSpecificScale(floatValue, 0);
}

/**
 *  类似flat()，只不过 flat 是向上取整，而 floorInPixel 是向下取整
 */
CG_INLINE CGFloat
TFY_floorInPixel(CGFloat floatValue) {
    CGFloat resultValue = floor(floatValue * TFY_ScreenScale) / TFY_ScreenScale;
    return resultValue;
}

CG_INLINE BOOL
TFY_between(CGFloat minimumValue, CGFloat value, CGFloat maximumValue) {
    return minimumValue < value && value < maximumValue;
}

CG_INLINE BOOL
TFY_betweenOrEqual(CGFloat minimumValue, CGFloat value, CGFloat maximumValue) {
    return minimumValue <= value && value <= maximumValue;
}

#pragma mark - CGFloat

/// 用于居中运算
CG_INLINE CGFloat
TFY_CGFloatGetCenter(CGFloat parent, CGFloat child) {
    return TFY_flat((parent - child) / 2.0);
}

#pragma mark - CGPoint

/// 两个point相加
CG_INLINE CGPoint
TFY_CGPointUnion(CGPoint point1, CGPoint point2) {
    return CGPointMake(TFY_flat(point1.x + point2.x), TFY_flat(point1.y + point2.y));
}

/// 获取rect的center，包括rect本身的x/y偏移
CG_INLINE CGPoint
TFY_CGPointGetCenterWithRect(CGRect rect) {
    return CGPointMake(TFY_flat(CGRectGetMidX(rect)), TFY_flat(CGRectGetMidY(rect)));
}

CG_INLINE CGPoint
TFY_CGPointGetCenterWithSize(CGSize size) {
    return CGPointMake(TFY_flat(size.width / 2.0), TFY_flat(size.height / 2.0));
}

#pragma mark - UIEdgeInsets

// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat
TFY_UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
TFY_UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

// 将两个UIEdgeInsets合并为一个
CG_INLINE UIEdgeInsets
TFY_UIEdgeInsetsConcat(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    insets1.top += insets2.top;
    insets1.left += insets2.left;
    insets1.bottom += insets2.bottom;
    insets1.right += insets2.right;
    return insets1;
}

CG_INLINE UIEdgeInsets
TFY_UIEdgeInsetsSetTop(UIEdgeInsets insets, CGFloat top) {
    insets.top = TFY_flat(top);
    return insets;
}

CG_INLINE UIEdgeInsets
TFY_UIEdgeInsetsSetLeft(UIEdgeInsets insets, CGFloat left) {
    insets.left = TFY_flat(left);
    return insets;
}
CG_INLINE UIEdgeInsets
TFY_UIEdgeInsetsSetBottom(UIEdgeInsets insets, CGFloat bottom) {
    insets.bottom = TFY_flat(bottom);
    return insets;
}

CG_INLINE UIEdgeInsets
TFY_UIEdgeInsetsSetRight(UIEdgeInsets insets, CGFloat right) {
    insets.right = TFY_flat(right);
    return insets;
}

#pragma mark - CGSize

/// 判断一个size是否为空（宽或高为0）
CG_INLINE BOOL
TFY_CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}

/// 将一个CGSize像素对齐
CG_INLINE CGSize
TFY_CGSizeFlatted(CGSize size) {
    return CGSizeMake(TFY_flat(size.width), TFY_flat(size.height));
}

/// 将一个 CGSize 以 pt 为单位向上取整
CG_INLINE CGSize
TFY_CGSizeCeil(CGSize size) {
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

/// 将一个 CGSize 以 pt 为单位向下取整
CG_INLINE CGSize
TFY_CGSizeFloor(CGSize size) {
    return CGSizeMake(floor(size.width), floor(size.height));
}

#pragma mark - CGRect

/// 判断一个CGRect是否存在NaN
CG_INLINE BOOL
TFY_CGRectIsNaN(CGRect rect) {
    return isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height);
}

/// 创建一个像素对齐的CGRect
CG_INLINE CGRect
TFY_CGRectFlatMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(TFY_flat(x), TFY_flat(y), TFY_flat(width), TFY_flat(height));
}

/// 对CGRect的x/y、width/height都调用一次flat，以保证像素对齐
CG_INLINE CGRect
TFY_CGRectFlatted(CGRect rect) {
    return CGRectMake(TFY_flat(rect.origin.x), TFY_flat(rect.origin.y), TFY_flat(rect.size.width), TFY_flat(rect.size.height));
}

/// 为一个CGRect叠加scale计算
CG_INLINE CGRect
TFY_CGRectApplyScale(CGRect rect, CGFloat scale) {
    return TFY_CGRectFlatted(CGRectMake(CGRectGetMinX(rect) * scale, CGRectGetMinY(rect) * scale, CGRectGetWidth(rect) * scale, CGRectGetHeight(rect) * scale));
}

/// 计算view的水平居中，传入父view和子view的frame，返回子view在水平居中时的x值
CG_INLINE CGFloat
TFY_CGRectGetMinXHorizontallyCenterInParentRect(CGRect parentRect, CGRect childRect) {
    return TFY_flat((CGRectGetWidth(parentRect) - CGRectGetWidth(childRect)) / 2.0);
}

/// 计算view的垂直居中，传入父view和子view的frame，返回子view在垂直居中时的y值
CG_INLINE CGFloat
TFY_CGRectGetMinYVerticallyCenterInParentRect(CGRect parentRect, CGRect childRect) {
    return TFY_flat((CGRectGetHeight(parentRect) - CGRectGetHeight(childRect)) / 2.0);
}

/// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持垂直居中时，layoutingRect的originY
CG_INLINE CGFloat
TFY_CGRectGetMinYVerticallyCenter(CGRect referenceRect, CGRect layoutingRect) {
    return CGRectGetMinY(referenceRect) + TFY_CGRectGetMinYVerticallyCenterInParentRect(referenceRect, layoutingRect);
}

/// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持水平居中时，layoutingRect的originX
CG_INLINE CGFloat
TFY_CGRectGetMinXHorizontallyCenter(CGRect referenceRect, CGRect layoutingRect) {
    return CGRectGetMinX(referenceRect) + TFY_CGRectGetMinXHorizontallyCenterInParentRect(referenceRect, layoutingRect);
}

/// 为给定的rect往内部缩小insets的大小
CG_INLINE CGRect
TFY_CGRectInsetEdges(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width -= TFY_UIEdgeInsetsGetHorizontalValue(insets);
    rect.size.height -= TFY_UIEdgeInsetsGetVerticalValue(insets);
    return rect;
}

/// 传入size，返回一个x/y为0的CGRect
CG_INLINE CGRect
TFY_CGRectMakeWithSize(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

CG_INLINE CGRect
TFY_CGRectFloatTop(CGRect rect, CGFloat top) {
    rect.origin.y = top;
    return rect;
}

CG_INLINE CGRect
TFY_CGRectFloatBottom(CGRect rect, CGFloat bottom) {
    rect.origin.y = bottom - CGRectGetHeight(rect);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectFloatRight(CGRect rect, CGFloat right) {
    rect.origin.x = right - CGRectGetWidth(rect);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectFloatLeft(CGRect rect, CGFloat left) {
    rect.origin.x = left;
    return rect;
}

/// 保持rect的左边缘不变，改变其宽度，使右边缘靠在right上
CG_INLINE CGRect
TFY_CGRectLimitRight(CGRect rect, CGFloat rightLimit) {
    rect.size.width = rightLimit - rect.origin.x;
    return rect;
}

/// 保持rect右边缘不变，改变其宽度和origin.x，使其左边缘靠在left上。只适合那种右边缘不动的view
/// 先改变origin.x，让其靠在offset上
/// 再改变size.width，减少同样的宽度，以抵消改变origin.x带来的view移动，从而保证view的右边缘是不动的
CG_INLINE CGRect
TFY_CGRectLimitLeft(CGRect rect, CGFloat leftLimit) {
    CGFloat subOffset = leftLimit - rect.origin.x;
    rect.origin.x = leftLimit;
    rect.size.width = rect.size.width - subOffset;
    return rect;
}

/// 限制rect的宽度，超过最大宽度则截断，否则保持rect的宽度不变
CG_INLINE CGRect
TFY_CGRectLimitMaxWidth(CGRect rect, CGFloat maxWidth) {
    CGFloat width = CGRectGetWidth(rect);
    rect.size.width = width > maxWidth ? maxWidth : width;
    return rect;
}

CG_INLINE CGRect
TFY_CGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = TFY_flat(x);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = TFY_flat(y);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectSetXY(CGRect rect, CGFloat x, CGFloat y) {
    rect.origin.x = TFY_flat(x);
    rect.origin.y = TFY_flat(y);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectSetWidth(CGRect rect, CGFloat width) {
    rect.size.width = TFY_flat(width);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectSetHeight(CGRect rect, CGFloat height) {
    rect.size.height = TFY_flat(height);
    return rect;
}

CG_INLINE CGRect
TFY_CGRectSetSize(CGRect rect, CGSize size) {
    rect.size = TFY_CGSizeFlatted(size);
    return rect;
}


