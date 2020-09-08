//
//  NSAttributedString+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSAttributedString+TFY_Tools.h"

@implementation NSAttributedString (TFY_Tools)

- (CGSize)tfy_sizeWithLimitSize:(CGSize)size{
    CGRect strRect = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    return strRect.size;
}

- (CGSize)tfy_sizeWithoutLimitSize{
    return [self tfy_sizeWithLimitSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}

@end
