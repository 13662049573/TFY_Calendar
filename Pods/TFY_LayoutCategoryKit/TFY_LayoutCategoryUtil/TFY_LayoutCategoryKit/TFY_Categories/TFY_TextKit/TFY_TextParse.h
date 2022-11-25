//
//  TFY_TextParse.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TextParse <NSObject>
@required
/**
 处理解析编辑文本
 editedRange文本编辑变化的范围，当没有变化时，{NSNotFound, 0}
 */
- (void)parseAttributedText:(nullable NSMutableAttributedString *)attributedText editedRange:(NSRange)editedRange;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextParse : NSObject<TextParse>

@end

NS_ASSUME_NONNULL_END
