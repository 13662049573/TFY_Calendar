//
//  TFY_TextStorage.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_TextParse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextStorage : NSTextStorage

@property (nonatomic, strong, nullable) id<TextParse> textParse;

// 使用copy attributedString初始化
- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;

// 使用强attributedString初始化，而不是复制，你确保不会在其他地方使用它
- (instancetype)initWithMutableAttributedString:(NSMutableAttributedString *)attrStr;

@end

@interface NSTextStorage (TFY_TextKit)

- (NSTextStorage *)tfy_deepCopy;

@end

NS_ASSUME_NONNULL_END
