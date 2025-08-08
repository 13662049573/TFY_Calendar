//
//  TFY_TextTagStyle.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextTagStyle : NSObject<NSCopying>

/// 背景颜色
@property (nonatomic, copy) UIColor * _Nonnull backgroundColor; // 默认 [UIColor lightGrayColor]

/// 字体格式
@property (nonatomic, assign) NSTextAlignment textAlignment; // 默认 NSTextAlignmentCenter

/// 渐变背景色
@property (nonatomic, assign) BOOL enableGradientBackground; // 默认 NO
@property (nonatomic, copy) UIColor * _Nonnull gradientBackgroundStartColor;
@property (nonatomic, copy) UIColor * _Nonnull gradientBackgroundEndColor;
@property (nonatomic, assign) CGPoint gradientBackgroundStartPoint;
@property (nonatomic, assign) CGPoint gradientBackgroundEndPoint;

/// 圆弧半径
@property (nonatomic, assign) CGFloat cornerRadius; // 默认 4
@property (nonatomic, assign) Boolean cornerTopRight;
@property (nonatomic, assign) Boolean cornerTopLeft;
@property (nonatomic, assign) Boolean cornerBottomRight;
@property (nonatomic, assign) Boolean cornerBottomLeft;

/// 边框
@property (nonatomic, assign) CGFloat borderWidth; // 默认 [UIColor whiteColor]
@property (nonatomic, copy) UIColor * _Nonnull borderColor; // 默认 1

/// 阴影
@property (nonatomic, copy) UIColor * _Nonnull shadowColor;    // 默认 [UIColor blackColor]
@property (nonatomic, assign) CGSize shadowOffset;   // 默认 is (2, 2)
@property (nonatomic, assign) CGFloat shadowRadius;  // 默认 is 2f
@property (nonatomic, assign) CGFloat shadowOpacity; // 默认 is 0.3f

/// 额外的宽度和高度空间，将扩大每个标签的大小
@property (nonatomic, assign) CGSize extraSpace;

/// 文本标签的最大宽度。0及以下表示没有最大宽度。
@property (nonatomic, assign) CGFloat maxWidth;
/// 文本标签的最小宽度。0及以下表示没有最小宽度。
@property (nonatomic, assign) CGFloat minWidth;

/// 文本标签的最大高度。0及以下表示没有最大高度。
@property (nonatomic, assign) CGFloat maxHeight;
/// 文本标签的最小高度。0及以下表示没有最小高度。
@property (nonatomic, assign) CGFloat minHeight;

/// 准确的宽度。0及以下表示不做功
@property (nonatomic, assign) CGFloat exactWidth;
/// 准确的高度。0及以下表示不做功
@property (nonatomic, assign) CGFloat exactHeight;

/// Copy
- (id _Nonnull)copyWithZone:(NSZone *_Nullable)zone;

@end

NS_ASSUME_NONNULL_END
