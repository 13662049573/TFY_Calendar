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
@end

NS_ASSUME_NONNULL_END
