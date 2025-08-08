//
//  TFY_TextTagAttributedStringContent.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTagContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextTagAttributedStringContent : TFY_TextTagContent

/// Attributed text
@property (nonatomic, copy) NSAttributedString * _Nonnull attributedText;

/// Init with rich text
- (instancetype _Nonnull)initWithAttributedText:(NSAttributedString *_Nonnull)attributedText;

/// Content with rich text
+ (instancetype _Nonnull)contentWithAttributedText:(NSAttributedString *_Nonnull)attributedText;

/// Base system methods
- (id _Nonnull)copyWithZone:(NSZone *_Nullable)zone;
- (NSString *_Nonnull)description;

@end

NS_ASSUME_NONNULL_END
