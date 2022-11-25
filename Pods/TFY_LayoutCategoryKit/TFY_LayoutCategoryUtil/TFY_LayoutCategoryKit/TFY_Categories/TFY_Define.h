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

#define TFY_WEAK  __weak typeof(self)weakSelf = self;

#define TFY_STRONG  __strong typeof(weakSelf)self = weakSelf;

/** weak对象 */
#define TFY_Weak(o) __weak typeof(o) weak_##o = o;

/**
*  完美解决Xcode NSLog打印不全的宏
*/
#ifdef DEBUG

#define NSLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )

#else

#define NSLog(format, ...)

#endif


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

/// 消除警告
#define TFY_SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#pragma mark-------------------------------------------单例---------------------------------------------

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
