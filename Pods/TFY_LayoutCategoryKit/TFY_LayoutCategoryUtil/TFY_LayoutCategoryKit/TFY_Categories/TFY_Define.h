//
//  TFY_Define.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#ifndef TFY_Define_h
#define TFY_Define_h

#import <UIKit/UIKit.h>
#import <objc/message.h>
#import "UIApplication+TFY_Tools.h"
#import "UIView+TFY_Tools.h"

#pragma mark-------------------------------------------线程---------------------------------------------
/***线程****/
#define TFY_queueGlobalStart dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
// 当所有队列执行完成之后
#define TFY_group_notify dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

#define TFY_queueMainStart dispatch_async(dispatch_get_main_queue(), ^{

#define TFY_QueueStartAfterTime(time) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){

#define TFY_queueEnd  });


// 创建队列组，可以使多个网络请求异步执行，执行完之后再进行操作
//这段放在for循环外
#define TFY_dispatch_group dispatch_group_t group = dispatch_group_create(); \
                          dispatch_queue_t queue = dispatch_get_global_queue(0, 0); \
                          dispatch_group_async(group, queue, ^{

//这段放在for循环中
#define TFY_Forwait   dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

//这段放在for循环任务执行中也是网络请求结果中使用
#define TFY_semaphore dispatch_semaphore_signal(semaphore);

//信号量减1，如果>0，则向下执行，否则等待
#define TFY_semaphore_wait  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

//这段放在for循环结束
#define TFY_semaphoreEnd  });


#ifdef DEBUG

#define NSLog(FORMAT, ...) fprintf(stderr, "\n\n******(class)%s(begin)******\n(SEL)%s\n(line)%d\n(data)%s\n******(class)%s(end)******\n\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __FUNCTION__, __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String], [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String])

#else

#define NSLog(FORMAT, ...) nil

#endif

#pragma mark-------------------------------------------单例---------------------------------------------

#define TFY_SafeArea(view)\
({\
UIEdgeInsets safeInsets = UIEdgeInsetsMake(20, 0, 0, 0);\
      if(view){\
          static IMP imp = _objc_msgForward;\
          static dispatch_once_t onceToken;\
          dispatch_once(&onceToken, ^{\
                  Method method = class_getInstanceMethod([view class], sel_registerName("safeAreaInsets"));\
                  if (method) {\
                     imp = method_getImplementation(method);\
                  }\
          });\
      if (imp != _objc_msgForward) {\
          safeInsets = ((UIEdgeInsets (*)(id, SEL))imp)(view,sel_registerName("safeAreaInsets"));\
     }\
  }\
 safeInsets;\
})

#define  TFY_adjustsScrollViewInsets_NO(scrollView,vc)\
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
     NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
     NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
     NSInteger argument = 2;\
     invocation.target = scrollView;\
     invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
     [invocation setArgument:&argument atIndex:2];\
     [invocation invoke];\
} else {\
    vc.automaticallyAdjustsScrollViewInsets = NO;\
}\
_Pragma("clang diagnostic pop") \
} while (0)


/** 单例（声明）.h */
#define TFY_SingtonInterface + (instancetype)sharedInstance;

/** 单例（实现）.m */
#define TFY_SingtonImplement(class) \
\
static class *sharedInstance_; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance_ = [super allocWithZone:zone]; \
    }); \
    return sharedInstance_; \
} \
\
+ (instancetype)sharedInstance { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance_ = [[class alloc] init]; \
    }); \
    return sharedInstance_; \
} \
\
- (id)copyWithZone:(NSZone *)zone { \
    return sharedInstance_; \
}

#pragma mark-------------------------------------------循环引用处理---------------------------------------------

/** weakSelf */
#ifndef tfy_weakify
   #if DEBUG
       #if __has_feature(objc_arc)
           #define tfy_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
       #else
           #define tfy_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
      #endif
   #else
#if __has_feature(objc_arc)
          #define tfy_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
      #else
          #define tfy_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
      #endif
   #endif
#endif

/** strongSelf */
#ifndef tfy_strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define tfy_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define tfy_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
#if __has_feature(objc_arc)
           #define tfy_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
           #define tfy_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

#define TFY_WEAK  __weak typeof(self)weakSelf = self;

#define TFY_STRONG  __strong typeof(weakSelf)self = weakSelf;

#pragma mark-------------------------------------------内联函数---------------------------------------------

/** 发送通知 */
CG_INLINE void TFY_PostNotification(NSNotificationName name,id obj,NSDictionary *info) {
    return [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:info];
}
/** 监听通知 */
CG_INLINE void TFY_ObserveNotification(id observer,SEL aSelector,NSNotificationName aName,id obj) {
    return [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:obj];
}
/** 移除所有通知 */
CG_INLINE void TFY_RemoveNotification(id observer) API_AVAILABLE(ios(11.0)) {
    return [[NSNotificationCenter defaultCenter] removeObserver:observer];
}
/** 移除一个已知通知 */
CG_INLINE void TFY_RemoveOneNotification(id observer,NSNotificationName aName,id obj) {
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

CG_INLINE void TFY_Method_exchangeImp(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

#endif /* TFY_Define_h */

/**
rand() ----随机数
abs() / labs() ----整数绝对值
fabs() / fabsf() / fabsl() ----浮点数绝对值
floor() / floorf() / floorl() ----向下取整
ceil() / ceilf() / ceill() ----向上取整
round() / roundf() / roundl() ----四舍五入
sqrt() / sqrtf() / sqrtl() ----求平方根
fmax() / fmaxf() / fmaxl() ----求最大值
fmin() / fminf() / fminl() ----求最小值
hypot() / hypotf() / hypotl() ----求直角三角形斜边的长度
fmod() / fmodf() / fmodl() ----求两数整除后的余数
modf() / modff() / modfl() ----浮点数分解为整数和小数
frexp() / frexpf() / frexpl() ----浮点数分解尾数和二为底的指数
sin() / sinf() / sinl() ----求正弦值
sinh() / sinhf() / sinhl() ----求双曲正弦值
cos() / cosf() / cosl() ----求余弦值
cosh() / coshf() / coshl() ----求双曲余弦值
tan() / tanf() / tanl() ----求正切值
tanh() / tanhf() / tanhl() ----求双曲正切值
asin() / asinf() / asinl() ----求反正弦值
asinh() / asinhf() / asinhl() ----求反双曲正弦值
acos() / acosf() / acosl() ----求反余弦值
acosh() / acoshf() / acoshl() ----求反双曲余弦值
atan() / atanf() / atanl() ----求反正切值
atan2() / atan2f() / atan2l() ----求坐标值的反正切值
atanh() / atanhf() / atanhl() ----求反双曲正切值
注:要消除链式编程的警告

要在Buildding Settings 把CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF 设为NO
*/
