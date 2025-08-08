//
//  NSDecimalNumber+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/3/9.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "NSDecimalNumber+TFY_Tools.h"

@implementation NSDecimalNumber (TFY_Tools)

+ (NSDecimalNumber *)tfy_decimalNumberWithFloat:(float)value {
 
  return [self tfy_decimalNumberWithFloat:value scale:2];
}
 
+ (NSDecimalNumber *)tfy_decimalNumberWithFloat:(float)value scale:(short)scale {
 
  return [self tfy_decimalNumberWithFloat:value roundingMode:NSRoundBankers scale:scale];
}
 
+ (NSDecimalNumber *)tfy_decimalNumberWithFloat:(float)value roundingMode:(NSRoundingMode)roundingMode scale:(short)scale{
 
  return [[[NSDecimalNumber alloc] initWithFloat:value] tfy_decimalNumberHandlerWithRoundingMode:roundingMode scale:scale];
}
 
+ (NSDecimalNumber *)tfy_decimalNumberWithDouble:(double)value{
 
  return [self tfy_decimalNumberWithDouble:value scale:2];
}
 
+ (NSDecimalNumber *)tfy_decimalNumberWithDouble:(double)value scale:(short)scale{
 
  return [self tfy_decimalNumberWithDouble:value roundingMode:NSRoundBankers scale:scale];
}
 
+ (NSDecimalNumber *)tfy_decimalNumberWithDouble:(double)value roundingMode:(NSRoundingMode)roundingMode scale:(short)scale{
  return [[[NSDecimalNumber alloc] initWithFloat:value] tfy_decimalNumberHandlerWithRoundingMode:roundingMode scale:scale];
}
 
+ (NSString *)tfy_formatterNumber:(NSNumber *)number {
  return [self tfy_formatterNumber:number fractionDigits:2];
}
 
+ (NSString *)tfy_formatterNumber:(NSNumber *)number fractionDigits:(NSUInteger)fractionDigits {
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setMaximumFractionDigits:fractionDigits];
  [numberFormatter setMinimumFractionDigits:fractionDigits];
  return [numberFormatter stringFromNumber:number];
}

- (NSDecimalNumber *)tfy_decimalNumberHandler {
  return [self tfy_decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2];
}
 
- (NSDecimalNumber *)tfy_decimalNumberHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale {
   NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:roundingMode
                                               scale:scale
                                         raiseOnExactness:NO
                                          raiseOnOverflow:YES
                                         raiseOnUnderflow:YES
                                        raiseOnDivideByZero:YES];
  return [self decimalNumberByRoundingAccordingToBehavior:handler];
}



@end
