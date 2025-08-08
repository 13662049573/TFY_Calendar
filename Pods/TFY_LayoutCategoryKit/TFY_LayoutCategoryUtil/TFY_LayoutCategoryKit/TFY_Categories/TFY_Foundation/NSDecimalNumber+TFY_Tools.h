//
//  NSDecimalNumber+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/3/9.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (TFY_Tools)

+ (NSDecimalNumber *)tfy_decimalNumberWithFloat:(float)value;

+ (NSDecimalNumber *)tfy_decimalNumberWithFloat:(float)value scale:(short)scale;

+ (NSDecimalNumber *)tfy_decimalNumberWithFloat:(float)value roundingMode:(NSRoundingMode)roundingMode scale:(short)scale;

+ (NSDecimalNumber *)tfy_decimalNumberWithDouble:(double)value;

+ (NSDecimalNumber *)tfy_decimalNumberWithDouble:(double)value scale:(short)scale;

+ (NSDecimalNumber *)tfy_decimalNumberWithDouble:(double)value roundingMode:(NSRoundingMode)roundingMode scale:(short)scale;

+ (NSString *)tfy_formatterNumber:(NSNumber *)number;

+ (NSString *)tfy_formatterNumber:(NSNumber *)number fractionDigits:(NSUInteger)fractionDigits;

@end

NS_ASSUME_NONNULL_END
