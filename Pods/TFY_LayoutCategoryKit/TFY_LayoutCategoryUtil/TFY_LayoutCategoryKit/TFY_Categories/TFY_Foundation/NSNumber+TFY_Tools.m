//
//  NSNumber+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSNumber+TFY_Tools.h"
#import "NSString+TFY_String.h"

@implementation NSNumber (TFY_Tools)

+ (NSNumber *)tfy_numberWithString:(NSString *)string{
    NSString *str = [[string tfy_stringByTrim] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    NSNumber *num = dic[str];
    if (num) {
        if (num == (id)[NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

- (NSString *)tfy_changeStyle:(NSNumberFormatterStyle)style {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = style;
    return [formatter stringFromNumber:self];
}

- (NSString *)tfy_changeToumberFormatterNoStyle {
    return [self tfy_changeStyle:NSNumberFormatterNoStyle];
}

- (NSString *)tfy_changeToNumberFormatterDecimalStyle {
    return [self tfy_changeStyle:NSNumberFormatterDecimalStyle];
}

- (NSString *)tfy_changeToNumberFormatterCurrencyStyle {
    return [self tfy_changeStyle:NSNumberFormatterCurrencyStyle];
}

- (NSString *)tfy_changeToNumberFormatterPercentStyle {
    return [self tfy_changeStyle:NSNumberFormatterPercentStyle];
}

- (NSString *)tfy_changeToNumberFormatterScientificStyle {
    return [self tfy_changeStyle:NSNumberFormatterScientificStyle];
}

- (NSString *)tfy_changeToNumberFormatterSpellOutStyle {
    return [self tfy_changeStyle:NSNumberFormatterSpellOutStyle];
}

+ (NSNumber *)tfy_getResult:(NSNumber *)one operators:(TFY_OPERATORS)opera num:(NSNumber *)two {
    
    NSDecimalNumber *resultNum = [[NSDecimalNumber alloc] init];
    NSDecimalNumber *A = [NSDecimalNumber decimalNumberWithDecimal:one.decimalValue];
    NSDecimalNumber *B = [NSDecimalNumber decimalNumberWithDecimal:two.decimalValue];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                           scale:2
                                                raiseOnExactness:NO
                                                 raiseOnOverflow:NO
                                                raiseOnUnderflow:NO
                                             raiseOnDivideByZero:NO];

    if (opera == TFY_Add) {
        resultNum = [A decimalNumberByAdding:B withBehavior:roundingBehavior];
    }else if (opera == TFY_Sub) {
        // 减法
        resultNum = [A decimalNumberBySubtracting:B withBehavior:roundingBehavior];
    }else if (opera == TFY_Mul) {
        resultNum = [A decimalNumberByMultiplyingBy:B withBehavior:roundingBehavior];
    }else if (opera == TFY_Div) {
        // 除法
        resultNum = [A decimalNumberByDividingBy:B withBehavior:roundingBehavior];
    }
    return resultNum;
}

@end
