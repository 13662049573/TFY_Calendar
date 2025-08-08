//
//  TFY_TextTagAttributedStringContent.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTagAttributedStringContent.h"

@implementation TFY_TextTagAttributedStringContent

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText {
    self = [super init];
    if (self) {
        self.attributedText = attributedText;
    }
    return self;
}

+ (instancetype)contentWithAttributedText:(NSAttributedString *)attributedText {
    return [[self alloc] initWithAttributedText:attributedText];
}

- (NSAttributedString *)getContentAttributedString {
    return self.attributedText;
}

- (NSAttributedString *)attributedText {
    return _attributedText ?: [NSAttributedString new];
}

- (id)copyWithZone:(NSZone *)zone {
    TFY_TextTagAttributedStringContent *copy = (TFY_TextTagAttributedStringContent *)[super copyWithZone:zone];
    if (copy != nil) {
        copy.attributedText = self.attributedText;
    }
    return copy;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.attributedText=%@", self.attributedText];
    [description appendString:@">"];
    return description;
}

@end
