//
//  NSString+Expression.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_ExpressionManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSString (Expression)
- (NSAttributedString*)expressionAttributedStringWithExpression:(TFY_Expression*)expression;
@end

NS_ASSUME_NONNULL_END
