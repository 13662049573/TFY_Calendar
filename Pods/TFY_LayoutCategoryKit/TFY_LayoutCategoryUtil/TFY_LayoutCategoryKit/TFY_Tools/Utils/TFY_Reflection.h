//
//  TFY_Reflection.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/2/1.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger
{
    TFYReflectionResultsSuccessful = 0, // 调用成功
    TFYReflectionResultsError,          // 调用失败，类无法响应方法
    TFYReflectionResultsTarget,         // 调用失败，无target
    TFYReflectionResultsSelector        // 调用失败，无selector
} TFYReflectionResults; // 返回值结果类型；用来判断方法调用是否成功；如果需要获取调用方法的返回值，请使用returnValue参数

@interface TFY_Reflection : NSObject

/// 判断能否响应某个方法，如果能响应则调用；不获取调用方法的返回值
+ (TFYReflectionResults)performWithTarget:(id)target selectorStringAndParameter:(nullable NSString *)selString, ...;

/// 可以使用returnValue获取调用方法的返回值，如果returnValue为NULL则等同上面的方法，不获取返回值
+ (TFYReflectionResults)performWithTarget:(id)target returnValue:(nullable void *)returnValue selectorStringAndParameter:(nullable NSString *)selString, ...;

@end

NS_ASSUME_NONNULL_END
