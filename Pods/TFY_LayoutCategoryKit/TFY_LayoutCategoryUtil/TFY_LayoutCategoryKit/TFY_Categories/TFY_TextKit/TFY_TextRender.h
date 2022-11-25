//
//  TFY_TextRender.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_TextRenderHerder.h"

typedef NS_ENUM(NSUInteger, TextVerticalAlignment) {
    TextVerticalAlignmentCenter,
    TextVerticalAlignmentTop,
    TextVerticalAlignmentBottom,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextRender : NSObject

@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

// 使用在textView,textStorage可以编辑
@property (nonatomic, assign) BOOL editable;

/**
 呈现大小
 */
@property (nonatomic, assign) CGSize size;

/**
 垂直对齐文本。默认的中心
 */
@property (nonatomic, assign) TextVerticalAlignment verticalAlignment;

// 文本被插入行片段矩形中。default 0
@property (nonatomic, assign) CGFloat lineFragmentPadding;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) NSUInteger maximumNumberOfLines;
@property(nullable, nonatomic, copy) NSAttributedString *truncationToken;

// 文本突出显示。支持TFY_LayoutManager
@property (nonatomic, assign) CGFloat highlightBackgroudRadius;// default 4.0
@property (nonatomic, assign) UIEdgeInsets highlightBackgroudInset;// default zero

/**
 默认是NO，如果是，只设置渲染大小将计算文本边界和缓存
如果YES缓存文本边界将优化性能，否则每次调用-(CGRect)textBound将重新计算文本边界。
 */
@property (nonatomic, assign) BOOL onlySetRenderSizeWillGetTextBounds;

/**
 可见文本绑定
 render在调用之前应该设置大小，你只能设置setrendersizewillgettextbounds YES，将缓存文本边界
 */
@property (nonatomic, assign, readonly) CGRect textBound;

/**
 默认是，如果不是，每次调用textStorage'attachViews将重新获得attachViews。
 */
@property (nonatomic, assign) BOOL onlySetTextStorageWillGetAttachViews;
/**
 文本属性包含附件视图或层
 */
@property (nonatomic, strong, readonly, nullable) NSArray<TFY_TextAttachment *> *attachmentViews;
@property (nonatomic, strong, readonly, nullable) NSSet<TFY_TextAttachment *> *attachmentViewSet;

// 初始化
- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText;
- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;
// 如果使用textView编辑= YES
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer editable:(BOOL)editable;

/**
 如果maxumnumberoflines为0，则返回text max size，否则返回maxumnumberoflines文本大小
 renderWidth文本渲染宽度
 */
- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth;

/**
 可见文本范围，必须设置渲染大小
 */
- (NSRange)visibleCharacterRange;

/**
 文本的行
 */
- (NSInteger)numberOfLines;

/**
 文本绑定字符范围，必须设置渲染大小
 */
- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange;
- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange;

/**
 点处的文本字符索引
 */
- (NSInteger)characterIndexForPoint:(CGPoint)point;

/**
 索引处的文本突出显示
*/
- (TFY_TextHighlight *)textHighlightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 在点处绘制文本
 */
- (void)drawTextAtPoint:(CGPoint)point;

@end


@interface TFY_TextRender (Rendering)

/**
 文本矩形渲染
 当文本呈现时显示，将有值
 */
@property (nonatomic, assign, readonly) CGRect textRectOnRender;

/**
 渲染时可见文本范围
 当文本呈现时显示，将有值
 */
@property (nonatomic, assign, readonly) NSRange visibleCharacterRangeOnRender;

/**
 文本在渲染时被截断的范围
 当显示文本时，如果文本被截断，则范围的长度> 0
 */
@property (nonatomic, assign, readonly) NSRange truncatedCharacterRangeOnRender;

/**
 设置文本截断
*/
- (void)setTextStorageTruncationToken;
/**
 设置文本突出显示
 */
- (void)setTextHighlight:(TFY_TextHighlight *)textHighlight range:(NSRange)range;

/**
 在点处绘制文本
 */
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled;

@end

NS_ASSUME_NONNULL_END
