//
//  NSNumber+Arithmetic.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/11.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "NSNumber+Arithmetic.h"

@implementation NSNumber (Arithmetic)

-(NSString *(^)(id))tfy_itself
{
    return self.stringValue.tfy_itself;
}

- (NSString *(^)(id))tfy_add
{
    return self.stringValue.tfy_add;
}

- (NSString *(^)(id))tfy_sub
{
    return self.stringValue.tfy_sub;
}

- (NSString *(^)(id))tfy_mul
{
    return self.stringValue.tfy_mul;
}

- (NSString *(^)(id))tfy_div
{
    return self.stringValue.tfy_div;
}

- (NSString *(^)(short))tfy_roundPlain
{
    return self.stringValue.tfy_roundPlain;
}

- (NSString *(^)(short))tfy_roundPlainWithZeroFill
{
    return self.stringValue.tfy_roundPlainWithZeroFill;
}

- (NSString *(^)(short))tfy_formatToThousandsWithRoundPlain
{
    return self.stringValue.tfy_formatToThousandsWithRoundPlain;
}

- (NSString *(^)(short))tfy_roundUp
{
    return self.stringValue.tfy_roundUp;
}

- (NSString *(^)(short))tfy_roundUpWithZeroFill
{
    return self.stringValue.tfy_roundUpWithZeroFill;
}

- (NSString *(^)(short))tfy_formatToThousandsWithRoundUp
{
    return self.stringValue.tfy_formatToThousandsWithRoundUp;
}

- (NSString *(^)(short))tfy_roundDown
{
    return self.stringValue.tfy_roundDown;
}

- (NSString *(^)(short))tfy_roundDownWithZeroFill
{
    return self.stringValue.tfy_roundDownWithZeroFill;
}

- (NSString *(^)(short))tfy_formatToThousandsWithRoundDown
{
    return self.stringValue.tfy_formatToThousandsWithRoundDown;
}

- (ComparisonResult (^)(id))tfy_compare {
    return self.stringValue.tfy_compare;
}

@end
