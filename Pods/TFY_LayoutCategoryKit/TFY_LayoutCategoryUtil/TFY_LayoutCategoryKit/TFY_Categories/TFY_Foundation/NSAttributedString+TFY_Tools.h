//
//  NSAttributedString+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (TFY_Tools)

- (CGSize)tfy_sizeWithLimitSize:(CGSize)size;

- (CGSize)tfy_sizeWithoutLimitSize;

/**
 在给定索引处具有给定字符名称的属性
 */
- (nullable id)tfy_attribute:(NSString *)attrName atIndex:(NSUInteger)index;
- (nullable id)tfy_attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;
- (nullable id)tfy_attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(nullable NSRangePointer)range;

//属性属性的getter

@property (nonatomic, strong, readonly, nullable) UIFont *tfy_font;          // 字体
@property (nonatomic, strong, readonly, nullable) UIColor *tfy_color;        // 颜色
@property (nonatomic, strong, readonly, nullable) UIColor *tfy_backgroundColor; // 背景颜色
// paragraphStyle
@property (nonatomic, strong, readonly, nullable) NSParagraphStyle *tfy_paragraphStyle;//  段落样式
@property (nonatomic, assign, readonly) CGFloat tfy_lineSpacing;             // 行高
@property (nonatomic, assign, readonly) CGFloat tfy_paragraphSpacing;        // 段落底部高度
@property (nonatomic, assign, readonly) CGFloat tfy_paragraphSpacingBefore;  // 段落顶部高度
@property (nonatomic, assign, readonly) NSTextAlignment tfy_alignment;       // 文本对齐
@property (nonatomic, assign, readonly) CGFloat tfy_firstLineHeadIndent;     // 首行缩进
@property (nonatomic, assign, readonly) CGFloat tfy_headIndent;              // 首部缩进
@property (nonatomic, assign, readonly) CGFloat tfy_tailIndent;              // 尾部缩进
@property (nonatomic, assign, readonly) NSLineBreakMode tfy_lineBreakMode;   // 换行模式
@property (nonatomic, assign, readonly) CGFloat tfy_minimumLineHeight;       // 最小行高
@property (nonatomic, assign, readonly) CGFloat tfy_maximumLineHeight;       // 最大行高
@property (nonatomic, assign, readonly) NSWritingDirection tfy_baseWritingDirection; // 文本书写方向
@property (nonatomic, assign, readonly) CGFloat tfy_lineHeightMultiple;      // 多行高
@property (nonatomic, assign, readonly) float tfy_hyphenationFactor;         // 连字符
@property (nonatomic, assign, readonly) CGFloat tfy_defaultTabInterval;      // \t制表符间距

@property (nonatomic, assign, readonly) CGFloat tfy_characterSpacing;        // 字符间距
@property (nonatomic, assign, readonly) NSUnderlineStyle tfy_lineThroughStyle;// 删除线类型
@property (nonatomic, strong, readonly, nullable) UIColor *tfy_lineThroughColor;//删除线颜色
@property (nonatomic, assign, readonly) NSInteger tfy_characterLigature;// 连字符 default 1
@property (nonatomic, assign, readonly) NSUnderlineStyle tfy_underLineStyle; // 下划线类型
@property (nonatomic, strong, readonly, nullable) UIColor *tfy_underLineColor;// 下划线颜色
@property (nonatomic, assign, readonly) CGFloat tfy_strokeWidth;             // 文字边线宽度
@property (nonatomic, strong, readonly, nullable) UIColor *tfy_strokeColor;  // 文字边线颜色
@property (nonatomic, strong, readonly, nullable) NSShadow *tfy_shadow;      // 文字阴影
@property (nonatomic, strong, readonly, nullable) id tfy_link;               // 链接
@property (nonatomic, assign, readonly) CGFloat tfy_baseline;                // 文字基线偏移
@property (nonatomic, assign, readonly) CGFloat tfy_obliqueness;             // 字形倾斜度
@property (nonatomic, assign, readonly) CGFloat tfy_expansion;            // 文本横向拉伸属性

#pragma mark - Get Attribute At Index

/**
 获取索引处的文本字体属性
 */
- (UIFont *)tfy_fontAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本颜色属性
 */
- (UIColor *)tfy_colorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本背景颜色属性
 */
- (UIColor *)tfy_backgroundColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本段落样式属性
 */
- (NSParagraphStyle *)tfy_paragraphStyleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本段落行间距
 */
- (CGFloat)tfy_lineSpacingAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 在索引处获得文本段落底部间距
 */
- (CGFloat)tfy_paragraphSpacingAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取文本段落顶部索引间距
 */
- (CGFloat)tfy_paragraphSpacingBeforeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本段落对齐
 */
- (NSTextAlignment)tfy_alignmentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 得到文本段落firstlineheadent在索引
 */
- (CGFloat)tfy_firstLineHeadIndentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取文本段落标题在索引处缩进
 */
- (CGFloat)tfy_headIndentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 得到文本段落尾部缩进在索引
 */
- (CGFloat)tfy_tailIndentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取文本段落在索引处的lineBreak
 */
- (NSLineBreakMode)tfy_lineBreakModeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 在索引处获取文本段落的最小长度
 */
- (CGFloat)tfy_minimumLineHeightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;
/**
 获取索引处文本段落的最大长度
 */
- (CGFloat)tfy_maximumLineHeightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 得到文本段落写作方向在索引
 */
- (NSWritingDirection)tfy_baseWritingDirectionAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取文本段落lineHeightMultiple在索引
 */
- (CGFloat)tfy_lineHeightMultipleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 在索引处获取文本段落的连字符因子
 */
- (float)tfy_hyphenationFactorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取文本段落索引处的Tab间距
 */
- (CGFloat)tfy_defaultTabIntervalAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本字符间距属性
 */
- (CGFloat)tfy_characterSpacingAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 通过index的样式属性获取文本行
 */
- (NSUnderlineStyle)tfy_lineThroughStyleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 通过index处的颜色属性获取文本行
 */
- (UIColor *)tfy_lineThroughColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本字符连接属性
 */
- (NSInteger)tfy_characterLigatureAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本下划线样式属性
 */
- (NSUnderlineStyle)tfy_underLineStyleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 在索引处获取文本下划线颜色属性
 */
- (UIColor *)tfy_underLineColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本笔画宽度属性
 */
- (CGFloat)tfy_strokeWidthAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本描边颜色属性
 */
- (UIColor *)tfy_strokeColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本阴影属性
 */
- (NSShadow *)tfy_shadowAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本附件属性
 */
- (NSTextAttachment *)tfy_attachmentIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本链接属性
 */
- (id)tfy_linkAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本基线属性
 */
- (CGFloat)tfy_baselineAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本书写方向属性
 */
- (NSWritingDirection)tfy_writingDirectionAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本倾斜属性
 */
- (CGFloat)tfy_obliquenessAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 获取索引处的文本扩展属性
 */
- (CGFloat)tfy_expansionAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

@end

NS_ASSUME_NONNULL_END
