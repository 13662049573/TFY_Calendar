//
//  TFY_TextTagStringContent.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTagStringContent.h"

@implementation TFY_TextTagStringContent

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.text = text;
    }
    return self;
}

+ (instancetype)contentWithText:(NSString *)text {
    return [[self alloc] initWithText:text];
}

- (instancetype)initWithText:(NSString *)text
                    textFont:(UIFont *)textFont
                   textColor:(UIColor *)textColor {
    self = [super init];
    if (self) {
        self.text = text;
        self.textFont = textFont;
        self.textColor = textColor;
    }
    return self;
}

+ (instancetype)contentWithText:(NSString *)text
                       textFont:(UIFont *)textFont
                      textColor:(UIColor *)textColor {
    return [[self alloc] initWithText:text
                             textFont:textFont
                            textColor:textColor];
}

- (NSAttributedString *)getContentAttributedString {
    return [[NSAttributedString alloc] initWithString:self.text
                                           attributes:@{NSForegroundColorAttributeName: self.textColor,
                                                        NSFontAttributeName: self.textFont}];
}

- (NSString *)text {
    return _text ?: @"";
}

- (UIFont *)textFont {
    return _textFont ?: [UIFont systemFontOfSize:14];
}

- (UIColor *)textColor {
    return _textColor ?: [UIColor blackColor];
}

- (id)copyWithZone:(NSZone *)zone {
    TFY_TextTagStringContent *copy = (TFY_TextTagStringContent *)[super copyWithZone:zone];
    if (copy != nil) {
        copy.text = self.text;
        copy.textFont = self.textFont;
        copy.textColor = self.textColor;
    }
    return copy;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.text=%@", self.text];
    [description appendString:@">"];
    return description;
}

@end
