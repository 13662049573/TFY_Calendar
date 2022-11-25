//
//  TFY_BaseLabel+Override.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "TFY_BaseLabel.h"

NS_ASSUME_NONNULL_BEGIN

@class TFY_LabelLayoutManager;

@interface TFY_BaseLabel (Override)

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) TFY_LabelLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@property (nonatomic, strong) NSAttributedString *lastAttributedText;
@property (nonatomic, assign) TFYLastTextType lastTextType;

//初始化
- (void)commonInit;

//复写这个可以最终文本改变
- (NSMutableAttributedString*)attributedTextForTextStorageFromLabelProperties;

//获取绘制起点
- (CGPoint)textOffsetWithTextSize:(CGSize)textSize;

//可以完全重绘当前label
- (void)reSetText;

@end

NS_ASSUME_NONNULL_END
