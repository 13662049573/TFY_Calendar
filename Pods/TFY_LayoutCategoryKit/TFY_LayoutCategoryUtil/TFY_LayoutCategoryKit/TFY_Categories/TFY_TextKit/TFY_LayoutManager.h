//
//  TFY_LayoutManager.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_LayoutManager;
@protocol LayoutManagerEditRender<NSObject>

// 绘制给定符号范围中的符号，该符号范围必须完全位于单个文本容器中。
- (void)layoutManager:(TFY_LayoutManager *_Nonnull)layoutManager drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin;

// 从NSTextStorage方法processsediting发送来通知布局管理器一个编辑操作。
- (void)layoutManager:(TFY_LayoutManager *_Nonnull)layoutManager processEditingForTextStorage:(NSTextStorage *_Nonnull)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_LayoutManager : NSLayoutManager

@property (nonatomic, weak) id<LayoutManagerEditRender> render;

@property (nonatomic, assign) CGFloat highlightBackgroudRadius;
@property (nonatomic, assign) UIEdgeInsets highlightBackgroudInset;

- (void)configureHighlightBackgroundRange:(NSRange)range radius:(CGFloat)radius inset:(UIEdgeInsets)inset;

@end

NS_ASSUME_NONNULL_END
