//
//  TFY_TextAttribute.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "TFY_TextAttribute.h"
#import "NSMutableAttributedString+TFY_Tools.h"
#import "NSAttributedString+TFY_Tools.h"

NSString *const TFY_TextAttributeName = @"TFY_TextAttribute";
NSString *const TFY_TextHighlightAttributeName = @"TFY_TextHighlightAttribute";

@implementation NSAttributedString (TFY_TextAttribute)

- (TFY_TextAttribute *)textAttributeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range {
    return [self tfy_attribute:TFY_TextAttributeName atIndex:index longestEffectiveRange:range];
}

- (TFY_TextHighlight *)textHighlightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range {
    return [self tfy_attribute:TFY_TextHighlightAttributeName atIndex:index longestEffectiveRange:range];
}

- (NSString *)plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound ||range.length == NSNotFound) return nil;
    NSMutableString *result = [NSMutableString string];
    if (range.length == 0) return result;
    NSString *string = self.string;
    [self enumerateAttribute:TFY_TextAttributeName inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        TFY_TextAttribute *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        } else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

@end

@implementation NSMutableAttributedString (TFY_TextAttribute)

- (void)addTextAttribute:(TFY_TextAttribute *)textAttribute range:(NSRange)range {
    NSDictionary *attributes = textAttribute.attributes;
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [self tfy_addAttribute:key value:value range:range];
    }];
    [self tfy_addAttribute:textAttribute.attributeName value:textAttribute range:range];
}

- (void)addTextHighlightAttribute:(TFY_TextHighlight *)textAttribute range:(NSRange)range {
    [self tfy_addAttribute:textAttribute.attributeName value:textAttribute range:range];
}

@end

@implementation TFY_TextAttribute

- (instancetype)init {
    if (self=[self initWithAttributes:nil]) {
    }
    return self;
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        _attributes = attributes ? [[NSMutableDictionary alloc]initWithDictionary:attributes] : [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)stringWithString:(NSString *)string {
    TFY_TextAttribute *one = [self new];
    one.string = string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _string = [aDecoder decodeObjectForKey:@"string"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.string = self.string;
    return one;
}

#pragma mark - getter && setter

- (NSString *)attributeName {
    return TFY_TextAttributeName;
}

- (UIColor *)color {
    return _attributes[NSForegroundColorAttributeName];
}
- (void)setColor:(UIColor *)color {
    ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = color;
}

-(UIFont *)font {
    return _attributes[NSFontAttributeName];
}
- (void)setFont:(UIFont *)font {
    ((NSMutableDictionary *)_attributes)[NSFontAttributeName] = font;
}

- (UIColor *)backgroundColor {
    return _attributes[NSBackgroundColorAttributeName];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    ((NSMutableDictionary *)_attributes)[NSBackgroundColorAttributeName] = backgroundColor;
}

- (NSUnderlineStyle)underLineStyle {
    return [_attributes[NSUnderlineStyleAttributeName] integerValue];
}
- (void)setUnderLineStyle:(NSUnderlineStyle)underLineStyle {
    ((NSMutableDictionary *)_attributes)[NSUnderlineStyleAttributeName] = @(underLineStyle);
}

- (UIColor *)underLineColor {
    return _attributes[NSUnderlineColorAttributeName];
}
- (void)setUnderLineColor:(UIColor *)underLineColor {
    ((NSMutableDictionary *)_attributes)[NSUnderlineColorAttributeName] = underLineColor;
}

- (NSUnderlineStyle)lineThroughStyle {
    return [_attributes[NSStrikethroughStyleAttributeName] integerValue];
}
- (void)setLineThroughStyle:(NSUnderlineStyle)lineThroughStyle {
    ((NSMutableDictionary *)_attributes)[NSStrikethroughStyleAttributeName] = @(lineThroughStyle);
}

- (UIColor *)lineThroughColor {
    return _attributes[NSStrikethroughColorAttributeName];
}
- (void)setLineThroughColor:(UIColor *)lineThroughColor {
    ((NSMutableDictionary *)_attributes)[NSStrikethroughColorAttributeName] = lineThroughColor;
}

- (CGFloat)strokeWidth {
    return [_attributes[NSStrokeWidthAttributeName] floatValue];
}
- (void)setStrokeWidth:(CGFloat)strokeWidth {
     ((NSMutableDictionary *)_attributes)[NSStrokeWidthAttributeName] = @(strokeWidth);
}

- (UIColor *)strokeColor {
    return _attributes[NSStrokeColorAttributeName];
}
- (void)setStrokeColor:(UIColor *)strokeColor {
    ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = strokeColor;
}

- (NSShadow *)shadow {
    return _attributes[NSShadowAttributeName];
}
- (void)setShadow:(NSShadow *)shadow {
    ((NSMutableDictionary *)_attributes)[NSShadowAttributeName] = shadow;
}

@end

@implementation TFY_TextHighlight

- (NSString *)attributeName {
    return TFY_TextHighlightAttributeName;
}

@end
