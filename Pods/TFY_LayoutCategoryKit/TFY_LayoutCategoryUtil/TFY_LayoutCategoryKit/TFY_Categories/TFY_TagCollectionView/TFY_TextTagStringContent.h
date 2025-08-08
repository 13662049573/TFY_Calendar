//
//  TFY_TextTagStringContent.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTagContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextTagStringContent : TFY_TextTagContent

/// Text
@property (nonatomic, copy) NSString * _Nonnull text;
/// Text font
@property (nonatomic, copy) UIFont * _Nonnull textFont;
/// Text color
@property (nonatomic, copy) UIColor * _Nonnull textColor;

/// Init
- (instancetype _Nonnull)initWithText:(NSString *_Nonnull)text;
- (instancetype _Nonnull)initWithText:(NSString *_Nonnull)text
                             textFont:(UIFont *_Nullable)textFont
                            textColor:(UIColor *_Nullable)textColor;

/// Content
+ (instancetype _Nonnull)contentWithText:(NSString *_Nonnull)text;
+ (instancetype _Nonnull)contentWithText:(NSString *_Nonnull)text
                                textFont:(UIFont *_Nullable)textFont
                               textColor:(UIColor *_Nullable)textColor;

/// Base system methods
- (id _Nonnull)copyWithZone:(NSZone *_Nullable)zone;
- (NSString *_Nonnull)description;

@end

NS_ASSUME_NONNULL_END
