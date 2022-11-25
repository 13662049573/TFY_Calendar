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

- (id)tfy_attribute:(NSString *)attrName atIndex:(NSUInteger)index {
    return [self tfy_attribute:attrName atIndex:index effectiveRange:NULL];
}

- (id)tfy_attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    if (!attrName || self.length == 0) {
        return nil;
    }
    
    if (index >= self.length) {
#ifdef DEBUG
        NSLog(@"%s: attribute %@'s index out of range!",__FUNCTION__,attrName);
#endif
        return nil;
    }
    return [self attribute:attrName atIndex:index effectiveRange:range];
}

- (id)tfy_attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range {
    if (!attrName || self.length == 0) {
        return nil;
    }
    
    if (index >= self.length) {
#ifdef DEBUG
        NSLog(@"%s: attribute %@'s index out of range!",__FUNCTION__,attrName);
#endif
        return nil;
    }
    return [self attribute:attrName atIndex:index longestEffectiveRange:range inRange:NSMakeRange(0, self.length)];
}

- (UIFont *)tfy_font {
    return [self tfy_fontAtIndex:0 effectiveRange:NULL];
}
- (UIFont *)tfy_fontAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSFontAttributeName atIndex:index effectiveRange:range];
}

- (UIColor *)tfy_color {
    return [self tfy_colorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)tfy_colorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSForegroundColorAttributeName atIndex:index effectiveRange:range];
}

- (UIColor *)tfy_backgroundColor {
    return [self tfy_backgroundColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)tfy_backgroundColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSBackgroundColorAttributeName atIndex:index effectiveRange:range];
}

- (NSParagraphStyle *)tfy_paragraphStyle {
    return [self tfy_paragraphStyleAtIndex:0 effectiveRange:NULL];
}
- (NSParagraphStyle *)tfy_paragraphStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:range];
}
- (NSParagraphStyle *)tfy_paragraphStyleDefaultAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:range];
    return style ? style : [NSParagraphStyle defaultParagraphStyle];
}

- (CGFloat)tfy_lineSpacing {
    return [self tfy_lineSpacingAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_lineSpacingAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.lineSpacing;
}

- (CGFloat)tfy_paragraphSpacing {
    return [self tfy_paragraphSpacingAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_paragraphSpacingAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.paragraphSpacing;
}

- (CGFloat)tfy_paragraphSpacingBefore {
    return [self tfy_paragraphSpacingBeforeAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_paragraphSpacingBeforeAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.paragraphSpacingBefore;
}

- (NSTextAlignment)tfy_alignment {
    return [self tfy_alignmentAtIndex:0 effectiveRange:NULL];
}
- (NSTextAlignment)tfy_alignmentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.alignment;
}

- (CGFloat)tfy_firstLineHeadIndent {
    return [self tfy_firstLineHeadIndentAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_firstLineHeadIndentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.firstLineHeadIndent;
}

- (CGFloat)tfy_headIndent {
    return [self tfy_headIndentAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_headIndentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.headIndent;
}

- (CGFloat)tfy_tailIndent {
    return [self tfy_tailIndentAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_tailIndentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.tailIndent;
}

- (NSLineBreakMode)tfy_lineBreakMode {
    return [self tfy_lineBreakModeAtIndex:0 effectiveRange:NULL];
}
- (NSLineBreakMode)tfy_lineBreakModeAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.lineBreakMode;
}

- (CGFloat)tfy_minimumLineHeight {
    return [self tfy_minimumLineHeightAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_minimumLineHeightAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.minimumLineHeight;
}

- (CGFloat)tfy_maximumLineHeight {
    return [self tfy_maximumLineHeightAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_maximumLineHeightAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.maximumLineHeight;
}

- (NSWritingDirection)tfy_baseWritingDirection {
    return [self tfy_baseWritingDirectionAtIndex:0 effectiveRange:NULL];
}
- (NSWritingDirection)tfy_baseWritingDirectionAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.baseWritingDirection;
}

- (CGFloat)tfy_lineHeightMultiple {
    return [self tfy_lineHeightMultipleAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_lineHeightMultipleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.lineHeightMultiple;
}

- (float)tfy_hyphenationFactor {
    return [self tfy_hyphenationFactorAtIndex:0 effectiveRange:NULL];
}
- (float)tfy_hyphenationFactorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.hyphenationFactor;
}

- (CGFloat)tfy_defaultTabInterval {
    return [self tfy_defaultTabIntervalAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_defaultTabIntervalAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self tfy_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.defaultTabInterval;
}

- (CGFloat)tfy_characterSpacing {
    return [self tfy_characterSpacingAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_characterSpacingAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSKernAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (NSUnderlineStyle)tfy_lineThroughStyle {
    return [self tfy_lineThroughStyleAtIndex:0 effectiveRange:NULL];
}
- (NSUnderlineStyle)tfy_lineThroughStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSStrikethroughStyleAttributeName atIndex:index effectiveRange:range] integerValue];
}

- (UIColor *)tfy_lineThroughColor {
    return [self tfy_lineThroughColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)tfy_lineThroughColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSStrikethroughColorAttributeName atIndex:index effectiveRange:range];
}

- (NSInteger)tfy_characterLigature {
    return [self tfy_characterLigatureAtIndex:0 effectiveRange:NULL];
}
- (NSInteger)tfy_characterLigatureAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    id attribute = [self attribute:NSLigatureAttributeName atIndex:index effectiveRange:range];
    return attribute ? [attribute integerValue] : 1;
}

- (NSUnderlineStyle)tfy_underLineStyle {
    return [self tfy_underLineStyleAtIndex:0 effectiveRange:NULL];
}
- (NSUnderlineStyle)tfy_underLineStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSUnderlineStyleAttributeName atIndex:index effectiveRange:range] integerValue];
}

- (UIColor *)tfy_underLineColor {
    return [self tfy_underLineColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)tfy_underLineColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSUnderlineColorAttributeName atIndex:index effectiveRange:range];
}

- (UIColor *)tfy_strokeColor {
    return [self tfy_strokeColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)tfy_strokeColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSStrokeColorAttributeName atIndex:index effectiveRange:range];
}

- (CGFloat)tfy_strokeWidth {
    return [self tfy_strokeWidthAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_strokeWidthAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSStrokeWidthAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (NSShadow *)tfy_shadow {
    return [self tfy_shadowAtIndex:0 effectiveRange:NULL];
}
- (NSShadow *)tfy_shadowAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSShadowAttributeName atIndex:index effectiveRange:range];
}

- (NSTextAttachment *)tfy_attachmentIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSAttachmentAttributeName atIndex:index effectiveRange:range];
}

- (id)tfy_link {
    return [self tfy_linkAtIndex:0 effectiveRange:NULL];
}
- (id)tfy_linkAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSLinkAttributeName atIndex:index effectiveRange:range];
}

- (CGFloat)tfy_baseline {
    return [self tfy_baselineAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_baselineAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSBaselineOffsetAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (NSWritingDirection)tfy_writingDirectionAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSWritingDirectionAttributeName atIndex:index effectiveRange:range] integerValue];
}

- (CGFloat)tfy_obliqueness {
    return [self tfy_obliquenessAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_obliquenessAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSObliquenessAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (CGFloat)tfy_expansion {
    return [self tfy_expansionAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)tfy_expansionAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSExpansionAttributeName atIndex:index effectiveRange:range] floatValue];
}

@end
