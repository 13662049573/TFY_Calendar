//
//  NSString+Expression.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "NSString+Expression.h"

@implementation NSString (Expression)

- (NSAttributedString*)expressionAttributedStringWithExpression:(TFY_Expression*)expression;
{
    return [TFY_ExpressionManager expressionAttributedStringWithString:self expression:expression];
}

@end
