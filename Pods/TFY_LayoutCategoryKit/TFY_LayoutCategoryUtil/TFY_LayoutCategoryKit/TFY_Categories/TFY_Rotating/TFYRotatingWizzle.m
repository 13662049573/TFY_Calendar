//
//  TFYRotatingWizzle.m
//  ScreenRotation
//
//  Created by 田风有 on 2022/10/8.
//  Copyright © 2022 Twisted Fate. All rights reserved.
//

#import "TFYRotatingWizzle.h"
#import <objc/runtime.h>
#include <dlfcn.h>
#import <os/lock.h>
#import <libkern/OSAtomic.h>

#if !__has_feature(objc_arc)
#error This code needs ARC. Use compiler option -fobjc-arc
#endif

#pragma mark - Block Helpers

#if !defined(NS_BLOCK_ASSERTIONS)

struct KTFYBlock_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct KTFYBlock_descriptor_1 {
        unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

enum {
    KTFYBLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    KTFYBLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    KTFYBLOCK_IS_GLOBAL =         (1 << 28),
    KTFYBLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    KTFYBLOCK_HAS_SIGNATURE =     (1 << 30),
};
typedef int KTFYBlockFlags;

static const char *blockGetType(id block){
    struct KTFYBlock_literal_1 *blockRef = (__bridge struct KTFYBlock_literal_1 *)block;
    KTFYBlockFlags flags = blockRef->flags;
    if (flags & KTFYBLOCK_HAS_SIGNATURE) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);
        if (flags & KTFYBLOCK_HAS_COPY_DISPOSE) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        const char *signature = (*(const char **)signatureLocation);
        return signature;
    }
    
    return NULL;
}

static BOOL blockIsCompatibleWithMethodType(id block, const char *methodType){
    const char *blockType = blockGetType(block);
    NSMethodSignature *blockSignature;
    if (0 == strncmp(blockType, (const char *)"@\"", 2)) {
        char *quotePtr = strchr(blockType+2, '"');
        if (NULL != quotePtr) {
            ++quotePtr;
            char filteredType[strlen(quotePtr) + 2];
            memset(filteredType, 0, sizeof(filteredType));
            *filteredType = '@';
            strncpy(filteredType + 1, quotePtr, sizeof(filteredType) - 2);
            blockSignature = [NSMethodSignature signatureWithObjCTypes:filteredType];
        }else{
            return NO;
        }
    }else{
        blockSignature = [NSMethodSignature signatureWithObjCTypes:blockType];
    }
    
    NSMethodSignature *methodSignature =
    [NSMethodSignature signatureWithObjCTypes:methodType];
    
    if (!blockSignature || !methodSignature) {
        return NO;
    }
    
    if (blockSignature.numberOfArguments != methodSignature.numberOfArguments){
        return NO;
    }
    
    if (strcmp(blockSignature.methodReturnType, methodSignature.methodReturnType) != 0) {
        return NO;
    }
    
    for (int i=0; i<methodSignature.numberOfArguments; ++i){
        if (i == 0){
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], "@") != 0) {
                return NO;
            }
            if (strcmp([blockSignature getArgumentTypeAtIndex:i], "@?") != 0) {
                return NO;
            }
        } else if(i == 1){
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], ":") != 0) {
                return NO;
            }
            if (strncmp([blockSignature getArgumentTypeAtIndex:i], "@", 1) != 0) {
                return NO;
            }
        } else {
            const char *blockSignatureArg = [blockSignature getArgumentTypeAtIndex:i];
            
            if (strncmp(blockSignatureArg, "@?", 2) == 0) {
                blockSignatureArg = "@?";
            }
            else if (strncmp(blockSignatureArg, "@", 1) == 0) {
                blockSignatureArg = "@";
            }
            
            if (strncmp(blockSignatureArg,
                       [methodSignature getArgumentTypeAtIndex:i], 1) != 0)
            {
                return NO;
            }
        }
    }
    return YES;
}

static BOOL blockIsAnImpFactoryBlock(id block){
    const char *blockType = blockGetType(block);
    KTFYRotatingImpFactoryBlock dummyFactory = ^id(TFYRotatingInfo *swizzleInfo){
        return nil;
    };
    const char *factoryType = blockGetType(dummyFactory);
    return 0 == strcmp(factoryType, blockType);
}

#endif // NS_BLOCK_ASSERTIONS


#pragma mark - Swizzling

#pragma mark └ RSSwizzleInfo
typedef IMP (^KTFYSWizzleImpProvider)(void);

@interface TFYRotatingInfo()
@property (nonatomic,copy) KTFYSWizzleImpProvider impProviderBlock;
@property (nonatomic, readwrite) SEL selector;
@end

@implementation TFYRotatingInfo

-(KTFYRotatingOriginalIMP)getOriginalImplementation{
    NSAssert(_impProviderBlock,nil);
    return (KTFYRotatingOriginalIMP)_impProviderBlock();
}

@end


@implementation TFYRotatingWizzle

static void swizzle(Class classToSwizzle,
                    SEL selector,
                    KTFYRotatingImpFactoryBlock factoryBlock)
{
    Method method = class_getInstanceMethod(classToSwizzle, selector);
    
    NSCAssert(NULL != method,
              @"Selector %@ not found in %@ methods of class %@.",
              NSStringFromSelector(selector),
              class_isMetaClass(classToSwizzle) ? @"class" : @"instance",
              classToSwizzle);
    
    NSCAssert(blockIsAnImpFactoryBlock(factoryBlock),
              @"Wrong type of implementation factory block.");
#define _KTFYSwizzle(_lock_, _unlock_) \
__block IMP originalIMP = NULL;\
KTFYSWizzleImpProvider originalImpProvider = ^IMP{\
    _lock_;\
    IMP imp = originalIMP;\
    _unlock_;\
    if (NULL == imp){\
        Class superclass = class_getSuperclass(classToSwizzle);\
        imp = method_getImplementation(class_getInstanceMethod(superclass,selector));\
    }\
    return imp;\
};\
TFYRotatingInfo *swizzleInfo = [TFYRotatingInfo new];\
swizzleInfo.selector = selector;\
swizzleInfo.impProviderBlock = originalImpProvider;\
id newIMPBlock = factoryBlock(swizzleInfo);\
const char *methodType = method_getTypeEncoding(method);\
NSCAssert(blockIsCompatibleWithMethodType(newIMPBlock,methodType),\
          @"Block returned from factory is not compatible with method type.");\
IMP newIMP = imp_implementationWithBlock(newIMPBlock);\
_lock_;\
originalIMP = class_replaceMethod(classToSwizzle, selector, newIMP, methodType);\
_unlock_;\
    
    if (@available(iOS 10.0, *)) {
        __block os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
        _KTFYSwizzle(os_unfair_lock_lock(&lock), os_unfair_lock_unlock(&lock))
    }
#undef _KZRSSwizzle//(_lock_, _unlock_)
}

static NSMutableDictionary *swizzledClassesDictionary(){
    static NSMutableDictionary *swizzledClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableDictionary new];
    });
    return swizzledClasses;
}

static NSMutableSet *swizzledClassesForKey(const void *key){
    NSMutableDictionary *classesDictionary = swizzledClassesDictionary();
    NSValue *keyValue = [NSValue valueWithPointer:key];
    NSMutableSet *swizzledClasses = [classesDictionary objectForKey:keyValue];
    if (!swizzledClasses) {
        swizzledClasses = [NSMutableSet new];
        [classesDictionary setObject:swizzledClasses forKey:keyValue];
    }
    return swizzledClasses;
}

+(BOOL)swizzleInstanceMethod:(SEL)selector
                     inClass:(Class)classToSwizzle
               newImpFactory:(KTFYRotatingImpFactoryBlock)factoryBlock
                        mode:(KTFYRotatingMode)mode
                         key:(nullable const void *)key
{
    NSAssert(!(NULL == key && KTFYRotatingModeAlways != mode),
             @"Key may not be NULL if mode is not KTFYRotatingModeAlways.");
    
    @synchronized(swizzledClassesDictionary()){
        if (key){
            NSSet *swizzledClasses = swizzledClassesForKey(key);
            if (mode == KTFYRotatingModeOncePerClass) {
                if ([swizzledClasses containsObject:classToSwizzle]){
                    return NO;
                }
            }else if (mode == KTFYRotatingModeOncePerClassAndSuperclasses){
                for (Class currentClass = classToSwizzle;
                     nil != currentClass;
                     currentClass = class_getSuperclass(currentClass))
                {
                    if ([swizzledClasses containsObject:currentClass]) {
                        return NO;
                    }
                }
            }
        }
        swizzle(classToSwizzle, selector, factoryBlock);
        if (key){
            [swizzledClassesForKey(key) addObject:classToSwizzle];
        }
    }
    return YES;
}

+(void)swizzleClassMethod:(SEL)selector
                  inClass:(Class)classToSwizzle
            newImpFactory:(KTFYRotatingImpFactoryBlock)factoryBlock
{
    [self swizzleInstanceMethod:selector
                        inClass:object_getClass(classToSwizzle)
                  newImpFactory:factoryBlock
                           mode:KTFYRotatingModeAlways
                            key:NULL];
}

@end
