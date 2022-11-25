//
//  NSMutableAttributedString+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/11.
//  Copyright © 2020 田风有. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (TFY_Tools)
/**
 *  字符串初始化
 */
NSMutableAttributedString *tfy_MutableString(NSString *string);
/**
 *  副本初始化
 */
NSMutableAttributedString *tfy_MutableAttributedString(NSAttributedString *attrStr);
/**
 *  字体大小  value是UIFont对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_FontName)(id value,NSRange range);
/**
 *  字体间距  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_KernName)(id value,NSRange range);
/**
 *  字体颜色  value是UIFont对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ForegroundColorName)(id value,NSRange range);
/**
 *  字符连体  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_LigatureName)(id value,NSRange range);
/**
 *   段落格式  绘图的风格（居中，换行模式，间距等诸多风格），value是NSParagraphStyle对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ParagraphStyleName)(id value,NSRange range);
/**
 *  背景颜色  value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_BackgroundColorName)(id value,NSRange range);
/**
 *  删除线格式  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrikethroughStyleName)(id value,NSRange range);
/**
 *  下划线  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_UnderlineStyleName)(id value,NSRange range);
/**
 *  下划线的颜色
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_UnderlineColorName)(id value,NSRange range);
/**
 *  描绘边颜色  value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrokeColorName)(id value,NSRange range);
/**
 *  描边宽度 value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrokeWidthName)(id value,NSRange range);
/**
 *  阴影，value是NSShadow对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ShadowName)(id value,NSRange range);
/**
 *  文字效果，value是NSString
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_TextEffectName)(id value,NSRange range);
/**
 *  附属，value是NSTextAttachment 对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_AttachmentName)(id value,NSRange range);
/**
 *  链接，value是NSURL or NSString
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_LinkName)(id value,NSRange range);
/**
 *  基础偏移量，value是NSNumber对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_BaselineOffsetName)(id value,NSRange range);
/**
 *  删除线颜色，value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrikethroughColorName)(id value,NSRange range);
/**
 *  字体倾斜
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ObliquenessName)(id value,NSRange range);
/**
 *  字体扁平化
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ExpansionName)(id value,NSRange range);
/**
 *  垂直或者水平，value是 NSNumber，0表示水平，1垂直
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_VerticalGlyphFormName)(id value,NSRange range);
/**
 *  文字的书写方向
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_WritingDirectionName)(id value,NSRange range);
/**
 * 删除不需要的约束
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_removeAttributeStringKey)(NSAttributedStringKey name,NSRange range);
/**
 *   替换属性字符串中某个位置,某个长度的字符串;或者从某个属性字符串某个位置插入.
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_replacewithString)(NSRange range,NSString *String);
/**
 *   替换属性<NSAttributedString>中某个位置,某个长度的字符串;
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_replaceAttributedString)(NSRange range,NSAttributedString *attrString);

/**
 *   或者从某个属性字符串某个位置插入.
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_insertString)(NSAttributedString *attrString,NSUInteger atIndex);
/**
 *   添加新的参数
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_appendString)(NSAttributedString *attrString);
/**
 * 删除对应的长度
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_deleteInRange)(NSRange range);


- (void)tfy_addAttribute:(NSString *)name value:(id)value range:(NSRange)range;

- (void)tfy_removeAttribute:(NSString *)name range:(NSRange)range;

@property (nonatomic, strong, readwrite, nullable) UIFont *tfy_font;
@property (nonatomic, strong, readwrite, nullable) UIColor *tfy_color;
@property (nonatomic, strong, readwrite, nullable) UIColor *tfy_backgroundColor;
// paragraphStyle
@property (nonatomic, strong, readwrite, nullable) NSParagraphStyle *tfy_paragraphStyle;
@property (nonatomic, assign, readwrite) CGFloat tfy_lineSpacing;
@property (nonatomic, assign, readwrite) CGFloat tfy_paragraphSpacing;
@property (nonatomic, assign, readwrite) CGFloat tfy_paragraphSpacingBefore;
@property (nonatomic, assign, readwrite) NSTextAlignment tfy_alignment;
@property (nonatomic, assign, readwrite) CGFloat tfy_firstLineHeadIndent;
@property (nonatomic, assign, readwrite) CGFloat tfy_headIndent;
@property (nonatomic, assign, readwrite) CGFloat tfy_tailIndent;
@property (nonatomic, assign, readwrite) NSLineBreakMode tfy_lineBreakMode;
@property (nonatomic, assign, readwrite) CGFloat tfy_minimumLineHeight;
@property (nonatomic, assign, readwrite) CGFloat tfy_maximumLineHeight;
@property (nonatomic, assign, readwrite) NSWritingDirection tfy_baseWritingDirection;
@property (nonatomic, assign, readwrite) CGFloat tfy_lineHeightMultiple;
@property (nonatomic, assign, readwrite) float tfy_hyphenationFactor;
@property (nonatomic, assign, readwrite) CGFloat tfy_defaultTabInterval;

@property (nonatomic, assign, readwrite) CGFloat tfy_characterSpacing;
@property (nonatomic, assign, readwrite) NSUnderlineStyle tfy_lineThroughStyle;
@property (nonatomic, strong, readwrite, nullable) UIColor *tfy_lineThroughColor;
@property (nonatomic, assign, readwrite) NSInteger tfy_characterLigature;
@property (nonatomic, assign, readwrite) NSUnderlineStyle tfy_underLineStyle;
@property (nonatomic, strong, readwrite, nullable) UIColor *tfy_underLineColor;
@property (nonatomic, assign, readwrite) CGFloat tfy_strokeWidth;
@property (nonatomic, strong, readwrite, nullable) UIColor *tfy_strokeColor;
@property (nonatomic, strong, readwrite, nullable) NSShadow *tfy_shadow;
@property (nonatomic, strong, readwrite, nullable) id tfy_link;
@property (nonatomic, assign, readwrite) CGFloat tfy_baseline;
@property (nonatomic, assign, readwrite) CGFloat tfy_obliqueness;
@property (nonatomic, assign, readwrite) CGFloat tfy_expansion;

#pragma mark - Add Attribute At Range

/**
 添加文本字体
 */
- (void)tfy_addFont:(UIFont *)font range:(NSRange)range;

/**
 添加文本颜色
 */
- (void)tfy_addColor:(UIColor *)color range:(NSRange)range;

/**
 添加文本背景色
 */
- (void)tfy_addBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range;

/**
 添加文本段落格式
 */
- (void)tfy_addParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range;

/**
 添加文本段落行高
 */
- (void)tfy_addLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

/**
 添加文本段落底部间距
 */
- (void)tfy_addParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range;

/**
 添加文本段落顶部间距
 */
- (void)tfy_addParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range ;

/**
 添加段落文本对齐
 */
- (void)tfy_addAlignment:(NSTextAlignment)alignment range:(NSRange)range;

/**
 添加段落文本首行缩进
 */
- (void)tfy_addFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range;

/**
 添加段落文本首部缩进
 */
- (void)tfy_addHeadIndent:(CGFloat)headIndent range:(NSRange)range;

/**
 添加段落文本尾部缩进
 */
- (void)tfy_addTailIndent:(CGFloat)tailIndent range:(NSRange)range;

/**
 添加段落文本断行方式
 */
- (void)tfy_addLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

/**
 添加段落文本最小行高
 */
- (void)tfy_addMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range;

/**
 添加段落文本最大行高
 */
- (void)tfy_addMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range;

/**
 添加段落文本书写方法
 */
- (void)tfy_addBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range;

/**
 添加段落文本可变行高,乘因数
 */
- (void)tfy_addLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range;

/**
 添加段落文本连字符属性
 */
- (void)tfy_addHyphenationFactor:(float)hyphenationFactor range:(NSRange)range;

/**
 添加段落文本制表符(\t)间隔
 */
- (void)tfy_addDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range;

/**
 添加文本字间距
 */
- (void)tfy_addCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range;

/**
 添加文本删除线
 */
- (void)tfy_addLineThroughStyle:(NSUnderlineStyle)style range:(NSRange)range;

/**
 添加文本删除线颜色
 */
- (void)tfy_addLineThroughColor:(UIColor *)color range:(NSRange)range;

/**
 添加文本下划线
 */
- (void)tfy_addUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range;

/**
 添加文本下划线颜色
 */
- (void)tfy_addUnderLineColor:(UIColor *)color range:(NSRange)range;

/**
 添加文本连字符
 */
- (void)tfy_addCharacterLigature:(NSInteger)characterLigature range:(NSRange)range;

/**
 添加文本边框颜色
 */
- (void)tfy_addStrokeColor:(UIColor *)color range:(NSRange)range;

/**
 添加文本边框宽度
 */
- (void)tfy_addStrokeWidth:(CGFloat)strokeWidth range:(NSRange)range;

/**
 添加文本阴影
 */
- (void)tfy_addShadow:(NSShadow *)shadow range:(NSRange)range;

/**
 添加文本附件
 */
- (void)tfy_addAttachment:(NSTextAttachment *)attachment range:(NSRange)range;

/**
 添加文本链接
 */
- (void)tfy_addLink:(id)link range:(NSRange)range;

/**
 添加文本基线偏移值
 */
- (void)tfy_addBaseline:(CGFloat)baseline range:(NSRange)range;

/**
 添加文本书写方向
 */
- (void)tfy_addWritingDirection:(NSWritingDirection)writingDirection range:(NSRange)range;

/**
 添加文本字形倾斜度
 */
- (void)tfy_addObliqueness:(CGFloat)obliqueness range:(NSRange)range;

/**
 添加文本字横向拉伸
 */
- (void)tfy_addExpansion:(CGFloat)expansion range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
