//
//  NSMutableAttributedString+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/11.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSMutableAttributedString+TFY_Tools.h"
#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation NSMutableAttributedString (TFY_Tools)
@dynamic tfy_alignment;
@dynamic tfy_backgroundColor;
@dynamic tfy_baseline;
@dynamic tfy_baseWritingDirection;
@dynamic tfy_characterLigature;
@dynamic tfy_characterSpacing;
@dynamic tfy_color;
@dynamic tfy_defaultTabInterval;
@dynamic tfy_expansion;
@dynamic tfy_firstLineHeadIndent;
@dynamic tfy_font;
@dynamic tfy_headIndent;
@dynamic tfy_hyphenationFactor;
@dynamic tfy_lineBreakMode;
@dynamic tfy_lineHeightMultiple;
@dynamic tfy_lineSpacing;
@dynamic tfy_lineThroughColor;
@dynamic tfy_lineThroughStyle;
@dynamic tfy_link;
@dynamic tfy_maximumLineHeight;
@dynamic tfy_minimumLineHeight;
@dynamic tfy_obliqueness;
@dynamic tfy_paragraphSpacing;
@dynamic tfy_paragraphSpacingBefore;
@dynamic tfy_paragraphStyle;
@dynamic tfy_shadow;
@dynamic tfy_strokeColor;
@dynamic tfy_strokeWidth;
@dynamic tfy_tailIndent;
@dynamic tfy_underLineColor;
@dynamic tfy_underLineStyle;

#define tfy_setParagraphStyleProperty(_property_,_range_) \
[self enumerateAttribute:NSParagraphStyleAttributeName inRange:_range_ options:kNilOptions usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {\
    NSMutableParagraphStyle *style = nil;\
    if (!value) {\
        style = [[NSMutableParagraphStyle alloc]init];\
        if (style._property_ == _property_) {\
            return ;\
        }\
    } else {\
        if (value._property_ == _property_) {\
        return ;\
        }\
        if ([value isKindOfClass:[NSMutableParagraphStyle class]]) {\
            style = (NSMutableParagraphStyle *)value;\
        }else {\
            style = [value mutableCopy];\
        }\
    }\
    style._property_ = _property_;\
    [self tfy_addParagraphStyle:style range:subRange];\
}];\

/**
 *  初始化
 */
NSMutableAttributedString *tfy_MutableString(NSString *string){
    return [[NSMutableAttributedString alloc] initWithString:string];
}
/**
 *  副本初始化
 */
NSMutableAttributedString *tfy_MutableAttributedString(NSAttributedString *attrStr){
    return [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
}
/**
 *  字体大小
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_FontName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSFontAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体间距
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_KernName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSKernAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ForegroundColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSForegroundColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字符连体
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_LigatureName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSLigatureAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  段落格式
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ParagraphStyleName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSParagraphStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  背景颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_BackgroundColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSBackgroundColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  删除线格式
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrikethroughStyleName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrikethroughStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  下划线
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_UnderlineStyleName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSUnderlineStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  下划线的颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_UnderlineColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSUnderlineStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  描绘边颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrokeColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrokeColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  描边宽度，value是NSNumber
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrokeWidthName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrokeWidthAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  阴影，value是NSShadow对象
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ShadowName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSShadowAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  文字效果，value是NSString
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_TextEffectName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSTextEffectAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  附属，value是NSTextAttachment 对象
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_AttachmentName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSAttachmentAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  链接，value是NSURL or NSString
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_LinkName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSLinkAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  链接，value是NSURL or NSString
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_BaselineOffsetName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSBaselineOffsetAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  删除线颜色，value是UIColor
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrikethroughColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrikethroughColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体倾斜
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ObliquenessName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSObliquenessAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体扁平化
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ExpansionName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSExpansionAttributeName value:value range:range];
        return myself;
    };
}

/**
 *  垂直或者水平，value是 NSNumber，0表示水平，1垂直
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_VerticalGlyphFormName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSVerticalGlyphFormAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  文字的书写方向
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_WritingDirectionName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSWritingDirectionAttributeName value:value range:range];
        return myself;
    };
}

/**
 * 删除不需要的约束
 */
-(NSMutableAttributedString *(^)(NSAttributedStringKey name,NSRange range))tfy_removeAttributeStringKey{
    WSelf(myself);
    return ^(NSAttributedStringKey name,NSRange range){
        [myself removeAttribute:name range:range];
        return myself;
    };
}

/**
 *  替换属性字符串中某个位置,某个长度的字符串;
 */
-(NSMutableAttributedString *(^)(NSRange range,NSString *String))tfy_replacewithString{
    WSelf(myself);
    return ^(NSRange range,NSString *String){
        [myself replaceCharactersInRange:range withString:String];
        return myself;
    };
}
/**
 *  替换属性<NSAttributedString>中某个位置,某个长度的字符串;或者从某个属性字符串某个位置插入.
 */
-(NSMutableAttributedString *(^)(NSRange range,NSAttributedString *attrString))tfy_replaceAttributedString{
    WSelf(myself);
    return ^(NSRange range,NSAttributedString *attrString){
        [myself replaceCharactersInRange:range withAttributedString:attrString];
        return myself;
    };
}
/**
 *  或者从某个属性字符串某个位置插入.
 */
-(NSMutableAttributedString *(^)(NSAttributedString *attrString,NSUInteger atIndex))tfy_insertString{
    WSelf(myself);
    return ^(NSAttributedString *attrString,NSUInteger atIndex){
        [myself insertAttributedString:attrString atIndex:atIndex];
        return myself;
    };
}
/**
*   添加新的参数
*/
-(NSMutableAttributedString *(^)(NSAttributedString *attrString))tfy_appendString{
    WSelf(myself);
    return ^(NSAttributedString *attrString){
        [myself appendAttributedString:attrString];
        return myself;
    };
}
/**
* 删除对应的长度
*/
-(NSMutableAttributedString *(^)(NSRange range))tfy_deleteInRange{
    WSelf(myself);
    return ^(NSRange range){
        [myself deleteCharactersInRange:range];
        return myself;
    };
}

- (void)tfy_addAttribute:(NSString *)attrName value:(id)value range:(NSRange)range {
    if (!attrName || [NSNull isEqual:attrName]) {
        return;
    }
    if (!value || [NSNull isEqual:value]) {
        [self removeAttribute:attrName range:range];
        return;
    }
    [self addAttribute:attrName value:value range:range];
}

- (void)tfy_removeAttribute:(NSString *)attrName range:(NSRange)range {
    if (!attrName || [NSNull isEqual:attrName]) {
        return;
    }
    [self removeAttribute:attrName range:range];
}

#pragma mark - Add Attribute

- (void)setTfy_font:(UIFont *)font {
    [self tfy_addFont:font range:NSMakeRange(0, self.length)];
}
- (void)tfy_addFont:(UIFont *)font range:(NSRange)range {
    [self tfy_addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setTfy_color:(UIColor *)color {
    [self tfy_addColor:color range:NSMakeRange(0, self.length)];
}
- (void)tfy_addColor:(UIColor *)color range:(NSRange)range {
    [self tfy_addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)setTfy_backgroundColor:(UIColor *)backgroundColor {
    [self tfy_addBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}
- (void)tfy_addBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self tfy_addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)setTfy_paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    [self tfy_addParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}
- (void)tfy_addParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self tfy_addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

- (void)setTfy_lineSpacing:(CGFloat)lineSpacing {
    [self tfy_addLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}
- (void)tfy_addLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    tfy_setParagraphStyleProperty(lineSpacing,range);
}

- (void)setTfy_paragraphSpacing:(CGFloat)paragraphSpacing {
    [self tfy_addParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}
- (void)tfy_addParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    tfy_setParagraphStyleProperty(paragraphSpacing,range);
}

- (void)setTfy_paragraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self tfy_addParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}
- (void)tfy_addParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    tfy_setParagraphStyleProperty(paragraphSpacingBefore,range);
}

- (void)setTfy_alignment:(NSTextAlignment)alignment {
    [self tfy_addAlignment:alignment range:NSMakeRange(0, self.length)];
}
- (void)tfy_addAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    tfy_setParagraphStyleProperty(alignment,range);
}

- (void)setTfy_firstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self tfy_addFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}
- (void)tfy_addFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    tfy_setParagraphStyleProperty(firstLineHeadIndent,range);
}

- (void)setTfy_headIndent:(CGFloat)headIndent {
    [self tfy_addHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}
- (void)tfy_addHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    tfy_setParagraphStyleProperty(headIndent,range);
}

- (void)setTfy_tailIndent:(CGFloat)tailIndent {
    [self tfy_addTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}
- (void)tfy_addTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    tfy_setParagraphStyleProperty(tailIndent,range);
}

- (void)setTfy_lineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self tfy_addLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}
- (void)tfy_addLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    tfy_setParagraphStyleProperty(lineBreakMode,range);
}

- (void)setTfy_minimumLineHeight:(CGFloat)minimumLineHeight {
    [self tfy_addMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}
- (void)tfy_addMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    tfy_setParagraphStyleProperty(minimumLineHeight,range);
}

- (void)setTfy_maximumLineHeight:(CGFloat)maximumLineHeight {
    [self tfy_addMinimumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}
- (void)tfy_addMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    tfy_setParagraphStyleProperty(maximumLineHeight,range);
}

- (void)setTfy_baseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self tfy_addBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}
- (void)tfy_addBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    tfy_setParagraphStyleProperty(baseWritingDirection,range);
}

- (void)setTfy_lineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self tfy_addLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}
- (void)tfy_addLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    tfy_setParagraphStyleProperty(lineHeightMultiple,range);
}

- (void)setTfy_hyphenationFactor:(float)hyphenationFactor {
    [self tfy_addHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}
- (void)tfy_addHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    tfy_setParagraphStyleProperty(hyphenationFactor,range);
}

- (void)setTfy_defaultTabInterval:(CGFloat)defaultTabInterval {
    [self tfy_addDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}
- (void)tfy_addDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    tfy_setParagraphStyleProperty(defaultTabInterval,range);
}

- (void)setTfy_characterSpacing:(CGFloat)characterSpacing {
    [self tfy_addCharacterSpacing:characterSpacing range:NSMakeRange(0, self.length)];
}
- (void)tfy_addCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range {
    [self tfy_addAttribute:NSKernAttributeName value:@(characterSpacing) range:range];
}

- (void)setTfy_lineThroughStyle:(NSUnderlineStyle)lineThroughStyle {
    [self tfy_addLineThroughStyle:lineThroughStyle range:NSMakeRange(0, self.length)];
}
- (void)tfy_addLineThroughStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self tfy_addAttribute:NSStrikethroughStyleAttributeName value:@(style) range:range];
}

- (void)setTfy_lineThroughColor:(UIColor *)lineThroughColor {
    [self tfy_addLineThroughColor:lineThroughColor range:NSMakeRange(0, self.length)];
}
- (void)tfy_addLineThroughColor:(UIColor *)color range:(NSRange)range {
    [self tfy_addAttribute:NSStrikethroughColorAttributeName value:color range:range];
}

- (void)setTfy_underLineStyle:(NSUnderlineStyle)underLineStyle {
    [self tfy_addUnderLineStyle:underLineStyle range:NSMakeRange(0, self.length)];
}
- (void)tfy_addUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self tfy_addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

- (void)setTfy_underLineColor:(UIColor *)underLineColor {
    [self tfy_addUnderLineColor:underLineColor range:NSMakeRange(0, self.length)];
}
- (void)tfy_addUnderLineColor:(UIColor *)color range:(NSRange)range {
    [self tfy_addAttribute:NSUnderlineColorAttributeName value:color range:range];
}

- (void)setTfy_characterLigature:(NSInteger)characterLigature {
    [self tfy_addCharacterLigature:characterLigature range:NSMakeRange(0, self.length)];
}
- (void)tfy_addCharacterLigature:(NSInteger)characterLigature range:(NSRange)range {
    [self tfy_addAttribute:NSLigatureAttributeName value:@(characterLigature) range:range];
}

- (void)setTfy_strokeColor:(UIColor *)strokeColor {
    [self tfy_addStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}
- (void)tfy_addStrokeColor:(UIColor *)color range:(NSRange)range {
    [self tfy_addAttribute:NSStrokeColorAttributeName value:color range:range];
}

- (void)setTfy_strokeWidth:(CGFloat)strokeWidth {
    [self tfy_addStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}
- (void)tfy_addStrokeWidth:(CGFloat)strokeWidth range:(NSRange)range {
    [self tfy_addAttribute:NSStrokeWidthAttributeName value:@(strokeWidth) range:range];
}

- (void)setTfy_shadow:(NSShadow *)shadow {
    [self tfy_addShadow:shadow range:NSMakeRange(0, self.length)];
}
- (void)tfy_addShadow:(NSShadow *)shadow range:(NSRange)range {
    [self tfy_addAttribute:NSShadowAttributeName value:shadow range:range];
}

- (void)tfy_addAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    [self tfy_addAttribute:NSAttachmentAttributeName value:attachment range:range];
}

- (void)setTfy_link:(id)link {
    [self tfy_addLink:link range:NSMakeRange(0, self.length)];
}
- (void)tfy_addLink:(id)link range:(NSRange)range {
    [self tfy_addAttribute:NSLinkAttributeName value:link range:range];
}

- (void)setTfy_baseline:(CGFloat)baseline {
    [self tfy_addBaseline:baseline range:NSMakeRange(0, self.length)];
}
- (void)tfy_addBaseline:(CGFloat)baseline range:(NSRange)range {
    [self tfy_addAttribute:NSBaselineOffsetAttributeName value:@(baseline) range:range];
}

- (void)tfy_addWritingDirection:(NSWritingDirection)writingDirection range:(NSRange)range {
    [self tfy_addAttribute:NSWritingDirectionAttributeName value:@(writingDirection) range:range];
}

- (void)setTfy_obliqueness:(CGFloat)obliqueness {
    [self tfy_addObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}
- (void)tfy_addObliqueness:(CGFloat)obliqueness range:(NSRange)range {
    [self tfy_addAttribute:NSObliquenessAttributeName value:@(obliqueness) range:range];
}

- (void)setTfy_expansion:(CGFloat)expansion {
    [self tfy_addExpansion:expansion range:NSMakeRange(0, self.length)];
}
- (void)tfy_addExpansion:(CGFloat)expansion range:(NSRange)range {
    [self tfy_addAttribute:NSExpansionAttributeName value:@(expansion) range:range];
}

@end
