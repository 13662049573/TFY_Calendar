//
//  TFY_TextAttribute.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString * _Nonnull const TFY_TextAttributeName;
UIKIT_EXTERN NSString * _Nonnull const TFY_TextHighlightAttributeName;

@class TFY_TextAttribute;
@class TFY_TextHighlight;
@interface NSAttributedString (TFY_TextAttribute)

- (TFY_TextAttribute *__nullable)textAttributeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

- (TFY_TextHighlight *__nullable)textHighlightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

- (NSString *_Nonnull)plainTextForRange:(NSRange)range;

@end


@interface NSMutableAttributedString (TFY_TextAttribute)

- (void)addTextAttribute:(TFY_TextAttribute *_Nonnull)textAttribute range:(NSRange)range;

- (void)addTextHighlightAttribute:(TFY_TextHighlight *_Nonnull)textAttribute range:(NSRange)range;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextAttribute : NSObject<NSCoding, NSCopying>

+ (instancetype)stringWithString:(nullable NSString *)string;
@property (nullable, nonatomic, copy) NSString *string;

@property (nonatomic, strong , readonly) NSString *attributeName;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *attributes;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;

// underline
@property (nonatomic, assign) NSUnderlineStyle underLineStyle;
@property (nonatomic, strong, nullable) UIColor *underLineColor;

// line through
@property (nonatomic, assign) NSUnderlineStyle lineThroughStyle;
@property (nonatomic, strong, nullable) UIColor *lineThroughColor;

// stroke
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong, nullable) UIColor *strokeColor;

// shadow
@property (nonatomic, strong, nullable) NSShadow *shadow;

@end

@interface TFY_TextHighlight : TFY_TextAttribute

@property (nonatomic, assign) UIEdgeInsets backgroudInset;
@property (nonatomic, assign) CGFloat backgroudRadius;

@end

NS_ASSUME_NONNULL_END
