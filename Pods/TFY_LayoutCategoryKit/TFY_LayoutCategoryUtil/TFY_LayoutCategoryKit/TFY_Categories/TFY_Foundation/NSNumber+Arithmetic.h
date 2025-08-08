//
//  NSNumber+Arithmetic.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/11.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Arithmetic.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (Arithmetic)

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
@property (nonatomic, copy, readonly) NSString *(^tfy_roundDown)(short scale);//向下保留(只舍不入)
/**
 只舍不入（小数位数）末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundDownWithZeroFill)(short scale);//向下保留(只舍不入)
/**
 只入不舍（小数位数）
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundUp)(short scale);//向上保留（只入不舍）
/**
 只入不舍（小数位数）末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_roundUpWithZeroFill)(short scale);//向上保留（只入不舍）

#pragma mark 千分位格式化
/**
 四舍五入（小数位数）千分位格式化输出（逗号分割），末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_formatToThousandsWithRoundPlain)(short scale);
/**
 只舍不入（小数位数）千分位格式化输出（逗号分割），末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_formatToThousandsWithRoundDown)(short scale);
/**
 只入不舍（小数位数）千分位格式化输出（逗号分割），末尾有0补位
 */
@property (nonatomic, copy, readonly) NSString *(^tfy_formatToThousandsWithRoundUp)(short scale);

#pragma mark 大小比较
/**
 比较（NaNError：操作数不是数字；OrderedAscending：self<num；OrderedSame：self==num；OrderedDescending：self>num）
 */
@property (nonatomic, copy, readonly) ComparisonResult (^tfy_compare)(id num);

@end

NS_ASSUME_NONNULL_END
