//
//  TFYRotatingWizzle.h
//  ScreenRotation
//
//  Created by 田风有 on 2022/10/8.
//  Copyright © 2022 Twisted Fate. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Macros Based API

#define KTFYSWReturnType(type) type
#define KTFYSWArguments(arguments...) _KTFYSWArguments(arguments)
#define KTFYSWReplacement(code...) code
#define KTFYSWCallOriginal(arguments...) _KTFYSWCallOriginal(arguments)

#pragma mark └ Swizzle Instance Method

#define KTFYSwizzleInstanceMethod(classToSwizzle, \
                                selector, \
                                KTFYSWReturnType, \
                                KTFYSWArguments, \
                                KTFYSWReplacement, \
                                KTFYSwizzleMode, \
                                key) \
    _KTFYSwizzleInstanceMethod(classToSwizzle, \
                             selector, \
                             KTFYSWReturnType, \
                             _KTFYSWWrapArg(KTFYSWArguments), \
                             _KTFYSWWrapArg(KTFYSWReplacement), \
                             KTFYSwizzleMode, \
                             key)

#pragma mark └ Swizzle Class Method

#define KTFYSwizzleClassMethod(classToSwizzle, \
                             selector, \
                             KTFYSWReturnType, \
                             KTFYSWArguments, \
                             KTFYSWReplacement) \
    _TFYSwizzleClassMethod(classToSwizzle, \
                          selector, \
                          KTFYSWReturnType, \
                          _KTFYSWWrapArg(KTFYSWArguments), \
                          _KTFYSWWrapArg(KTFYSWReplacement))

#pragma mark - Main API

/**
 指向混合方法的原始实现的函数指针。
 */
typedef void (*KTFYRotatingOriginalIMP)(void /* id, SEL, ... */ );

/**
 在新的实现块中使用RSSwizzleInfo来获取和调用swizzed方法的原始实现。
 */
@interface TFYRotatingInfo : NSObject

/**
 返回混合方法的原始实现。
 如果混合后的类实现了方法本身，那么它实际上就是一个原始实现;或者从一个超类中获取一个超实现。
 在调用时，必须始终将返回的实现转换为适当的函数指针。
 一个指向swizzed方法原始实现的函数指针。
 */
-(KTFYRotatingOriginalIMP)getOriginalImplementation;

/// 混合方法的选择器。
@property (nonatomic, readonly) SEL selector;

@end

typedef id _Nonnull (^KTFYRotatingImpFactoryBlock)(TFYRotatingInfo *swizzleInfo);

typedef NS_ENUM(NSUInteger, KTFYRotatingMode) {
    /// 总是做搅拌。
    KTFYRotatingModeAlways = 0,
    /// 如果相同的类之前已经用相同的键进行了混合，则不进行混合。
    KTFYRotatingModeOncePerClass = 1,
    /// 如果同一个类或它的一个超类在之前已经用相同的键进行了混合，则不进行混合。
    /// 不能保证每个方法调用只调用一次实现。如果混合的顺序是:第一个继承类，第二个超类，那么两个混合都将被执行，新的实现将被调用两次。
    KTFYRotatingModeOncePerClassAndSuperclasses = 2
};


@interface TFYRotatingWizzle : NSObject

+(BOOL)swizzleInstanceMethod:(SEL)selector
                     inClass:(Class)classToSwizzle
               newImpFactory:(KTFYRotatingImpFactoryBlock)factoryBlock
                        mode:(KTFYRotatingMode)mode
                         key:(nullable const void *)key;


+(void)swizzleClassMethod:(SEL)selector
                  inClass:(Class)classToSwizzle
            newImpFactory:(KTFYRotatingImpFactoryBlock)factoryBlock;

@end

#pragma mark - Implementation details

#define _KTFYSWWrapArg(args...) args
#define _KTFYSWDel2Arg(a1, a2, args...) a1, ##args
#define _KTFYSWDel3Arg(a1, a2, a3, args...) a1, a2, ##args
#define _KTFYSWArguments(arguments...) DEL, ##arguments

#define _KTFYSwizzleInstanceMethod(classToSwizzle, \
                                 selector, \
                                 KTFYSWReturnType, \
                                 KTFYSWArguments, \
                                 KTFYSWReplacement, \
                                 KTFYSwizzleMode, \
                                 KEY) \
    [TFYRotatingWizzle \
     swizzleInstanceMethod:selector \
     inClass:[classToSwizzle class] \
     newImpFactory:^id(KTFYSwizzleInfo *swizzleInfo) { \
        KTFYSWReturnType (*originalImplementation_)(_KTFYSWDel3Arg(__unsafe_unretained id, \
                                                               SEL, \
                                                               KTFYSWArguments)); \
        SEL selector_ = selector; \
        return ^KTFYSWReturnType (_KTFYSWDel2Arg(__unsafe_unretained id self, \
                                             KTFYSWArguments)) \
        { \
            KTFYSWReplacement \
        }; \
     } \
     mode:KTFYSwizzleMode \
     key:KEY];

#define _KTFYSwizzleClassMethod(classToSwizzle, \
                              selector, \
                              KTFYSWReturnType, \
                              KTFYSWArguments, \
                              KTFYSWReplacement) \
    [TFYRotatingWizzle \
     swizzleClassMethod:selector \
     inClass:[classToSwizzle class] \
     newImpFactory:^id(KTFYSwizzleInfo *swizzleInfo) { \
        KTFYSWReturnType (*originalImplementation_)(_KTFYSWDel3Arg(__unsafe_unretained id, \
                                                               SEL, \
                                                               KTFYSWArguments)); \
        SEL selector_ = selector; \
        return ^KTFYSWReturnType (_KTFYSWDel2Arg(__unsafe_unretained id self, \
                                             KTFYSWArguments)) \
        { \
            KTFYSWReplacement \
        }; \
     }];

#define _KTFYSWCallOriginal(arguments...) \
    ((__typeof(originalImplementation_))[swizzleInfo \
                                         getOriginalImplementation])(self, \
                                                                     selector_, \
                                                                     ##arguments)


NS_ASSUME_NONNULL_END
