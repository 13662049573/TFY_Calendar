//
//  TFY_TextTagContent.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTagContent.h"

@implementation TFY_TextTagContent

- (NSAttributedString *)getContentAttributedString {
    NSAssert(NO, @"不要直接使用TFY_TextTagContent。");
    return [NSAttributedString new];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] init];
}

@end
