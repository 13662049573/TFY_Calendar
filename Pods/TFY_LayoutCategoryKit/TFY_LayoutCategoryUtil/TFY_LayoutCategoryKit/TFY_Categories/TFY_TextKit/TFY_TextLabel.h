//
//  TFY_TextLabel.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_TextRender.h"

@class TFY_TextLabel;
@protocol LabelDelegate <NSObject>
@optional

/**
 当用户点击文本突出显示
 */
- (void)label:(TFY_TextLabel *_Nonnull)label didTappedTextHighlight:(TFY_TextHighlight *_Nonnull)textHighlight;

/**
 当用户长按文本时突出显示
 */
- (void)label:(TFY_TextLabel *_Nonnull)label didLongPressedTextHighlight:(TFY_TextHighlight *_Nonnull)textHighlight;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextLabel : UIView

@property (nonatomic, weak, nullable) id<LabelDelegate> delegate;

/**
 视图层的异步显示。默认是的
 */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/**
 清除层的内容，然后异步显示。默认是的
 */
@property (nonatomic, assign) BOOL clearContentBeforeAsyncDisplay;

// text
@property (nonatomic, strong, nullable) NSString *text;
//如果设置了，标签将忽略公共属性。看到ignoreLabelCommonPropertys。
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nullable) NSTextStorage *textStorage;

// 在xib上，自动布局选择最大宽度
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;

/**
 textkit渲染引擎。默认值为nil，如果设置为nil，标签将忽略常见属性。看到ignoreAboveLabelRelatePropertys。
 */
@property (nonatomic, strong, nullable) TFY_TextRender *textRender;

@property (nonatomic, strong, nullable) UIFont      *font;       // 默认为nil(17字号)
@property (nonatomic, strong, nullable) UIColor     *textColor; // 默认为零
@property (nonatomic, strong, nullable) NSShadow    *shadow;   // 默认为零
@property (nonatomic, assign) NSTextAlignment    textAlignment;   // default是NSTextAlignmentNatural(在iOS 9之前，默认是 NSTextAlignmentLeft)
@property (nonatomic, assign) CGFloat            characterSpacing;//默认为零
@property (nonatomic, assign) CGFloat            lineSpacing;     // 默认为零
//  如果你设置了attributedtext && textstorage&& & textrender，将忽略上面的相关属性
@property (nonatomic, assign) BOOL ignoreAboveAtrributedRelatePropertys;

@property (nonatomic, assign) NSLineBreakMode    lineBreakMode;   // 默认是NSLineBreakByTruncatingTail。用于单行和多行文本
@property (nonatomic, assign) TextVerticalAlignment verticalAlignment; // 垂直对齐文本。默认的中心
@property(nullable, nonatomic, copy) NSAttributedString *truncationToken;
// 值为0表示没有限制
// 如果文本的高度达到# of lines，或者视图的高度小于允许的# of lines，文本将使用换行模式被截断。
@property (nonatomic, assign) NSInteger numberOfLines;
//  如果你设置了textRender，将忽略上面的标签相关属性
@property (nonatomic, assign) BOOL ignoreAboveRenderRelatePropertys;

/**
 用户长按期间将呼叫委托。默认的2.0
 */
@property (nonatomic, assign) CGFloat longPressDuring;

/**
 下一个运行循环，层重绘私有线程
 */
- (void)setDisplayNeedRedraw;

/**
 在主线上重新绘制图层
 */
- (void)immediatelyDisplayRedraw;

@end

NS_ASSUME_NONNULL_END
