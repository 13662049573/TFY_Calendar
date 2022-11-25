//
//  TFY_TextView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_TextRender.h"

@class TFY_TextView;
@protocol TextViewDelegate <UITextViewDelegate>
@optional

// 插入文本
- (BOOL)textView:(TFY_TextView *_Nonnull)textView shouldInsertText:(NSString *_Nonnull)text;
- (BOOL)textView:(TFY_TextView *_Nonnull)textView shouldInsertAttributedText:(NSAttributedString *_Nonnull)attributedText;

// 编辑文本
- (void)textView:(TFY_TextView *_Nonnull)textView processEditingForTextStorage:(NSTextStorage *_Nonnull)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange;

// 当文本编辑为NO时，用户点击文本突出显示
- (void)textView:(TFY_TextView *_Nonnull)textView didTappedTextHighlight:(TFY_TextHighlight *_Nonnull)textHighlight;

// 用户长按文本高亮，当文本编辑为NO时
- (void)textView:(TFY_TextView *_Nonnull)textView didLongPressedTextHighlight:(TFY_TextHighlight *_Nonnull)textHighlight;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextView : UITextView

@property (nonatomic, strong, readonly) TFY_TextRender *textRender;

//文本相关属性
@property (nonatomic, assign) CGFloat characterSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

/**
 忽略上面与文本相关的属性。默认不
 忽略上面的文本相关属性设置.
 */
@property (nonatomic, assign) BOOL ignoreAboveTextRelatedPropertys;

/**
 用户长按期间将呼叫委托。默认的2.0
 */
@property (nonatomic, assign) CGFloat longPressDuring;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame textRender:(TFY_TextRender *)textRender;

/**
 在显示的文本中插入一个字符。
 */
- (void)insertText:(NSString *)text;
/**
 在显示的文本中插入带属性字符串。
 */
- (void)insertAttributedText:(NSAttributedString *)attributedText;

@end

@class TFY_GrowingTextView;
@protocol GrowingTextDelegate <NSObject>

// 文本高度确实发生了变化
- (void)growingTextView:(TFY_GrowingTextView *)growingTextView didChangeTextHeight:(CGFloat)textHeight;

// 文本做了改变
- (void)growingTextViewDidChangeText:(TFY_GrowingTextView *)growingTextView;

@end

// 增长高度文本视图
@interface TFY_GrowingTextView : TFY_TextView

@property (nonatomic, weak) id<GrowingTextDelegate> growingTextDelegate;

// 占位符
@property (nonatomic, weak, readonly) UILabel *placeHolderLabel;
@property (nonatomic, assign) UIEdgeInsets placeHolderEdge;

// 最大文本行数默认为0
@property (nonatomic, assign) NSUInteger maxNumOfLines;
// 最大文本长度默认为0
@property (nonatomic, assign) NSInteger maxTextLength;

// 默认不
@property (nonatomic, assign) BOOL fisrtCharacterIgnoreBreak;

@end

NS_ASSUME_NONNULL_END
