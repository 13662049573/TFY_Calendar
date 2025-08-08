//
//  NSString+Arithmetic.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/11.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ErrorResult @""
#define NotAnNum @"NaN"
#define NOT_NULL(num) num == nil ? NotAnNum : num
#define ITSELF(num) @"0".itself(num)

typedef NS_ENUM(NSInteger, ComparisonResult) {NaNError = INT_MIN, OrderedAscending = -1L, OrderedSame, OrderedDescending};

@interface NSString (Arithmetic)

#pragma mark 四则运算
/**
 加法（NSString或NSNumber）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_add)(id num);
/**
 减法（NSString或NSNumber）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_sub)(id num);
/**
 乘法（NSString或NSNumber）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_mul)(id num);
/**
 除法（NSString或NSNumber）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_div)(id num);
/**
 返回本身（NSString或NSNumber）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_itself)(id num);

#pragma mark 格式化输出
/**
 四舍五入（小数位数）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundPlain)(short scale);
/**
 四舍五入（小数位数）末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundPlainWithZeroFill)(short scale);
/**
 只舍不入（小数位数）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundDown)(short scale);
/**
 只舍不入（小数位数）末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundDownWithZeroFill)(short scale);
/**
 只入不舍（小数位数）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundUp)(short scale);
/**
 只入不舍（小数位数）末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundUpWithZeroFill)(short scale);

#pragma mark 千分位格式化
/**
 四舍五入（小数位数）千分位格式化输出（逗号分割），小数末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_formatToThousandsWithRoundPlain)(short scale);
/**
 只舍不入（小数位数）千分位格式化输出（逗号分割），小数末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_formatToThousandsWithRoundDown)(short scale);
/**
 只入不舍（小数位数）千分位格式化输出（逗号分割），小数末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_formatToThousandsWithRoundUp)(short scale);

#pragma mark 大小比较
/**
 比较（RLNaNError：操作数不是数字；RLOrderedAscending：self<num；RLOrderedSame：self==num；RLOrderedDescending：self>num）
 */
@property (nonatomic, copy, readonly) ComparisonResult (^tfy_compare)(id num);

@end

#pragma mark ------------------------------------------------------------
#pragma mark 用于格式化的分类方法
@interface NSDecimalNumber (Round)

- (NSString *)tfy_roundingWithMode:(NSRoundingMode)mode scale:(short)scale;
- (NSString *)tfy_roundingZeroFillWithMode:(NSRoundingMode)mode scale:(short)scale;
- (NSString *)tfy_formatToThousandsWithRoundingMode:(NSRoundingMode)mode scale:(short)scale;

@end

NS_ASSUME_NONNULL_END
