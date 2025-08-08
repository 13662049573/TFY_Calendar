//
//  TFY_TextTag.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_TextTagStyle.h"
#import "TFY_TextTagContent.h"

NS_ASSUME_NONNULL_BEGIN

/// 标记选择状态更改回调
typedef void (^OnSelectStateChanged)(bool selected);

@interface TFY_TextTag : NSObject<NSCopying>

/// ID
@property (nonatomic, assign, readonly) NSUInteger tagId; // 增加。标记的唯一标识符和主键

/// 附件对象。您可以使用它将任何对象绑定到每个标记。
@property (nonatomic, strong) id _Nullable attachment;

/// 正常状态的内容和样式
@property (nonatomic, copy) TFY_TextTagContent * _Nonnull content;
@property (nonatomic, copy) TFY_TextTagStyle * _Nonnull style;

/// 选定的状态内容和样式
@property (nonatomic, copy) TFY_TextTagContent * _Nullable selectedContent;
@property (nonatomic, copy) TFY_TextTagStyle * _Nullable selectedStyle;

///选择状态
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) OnSelectStateChanged _Nullable onSelectStateChanged; // 状态改变回调

/// 可访问性
@property (nonatomic, assign) BOOL isAccessibilityElement; // 默认 NO
@property (nonatomic, copy) NSString * _Nullable accessibilityIdentifier; // 默认 = nil
@property (nonatomic, copy) NSString * _Nullable accessibilityLabel; // 默认 nil
@property (nonatomic, copy) NSString * _Nullable accessibilityHint; // 默认 nil
@property (nonatomic, copy) NSString * _Nullable accessibilityValue; // 默认 nil
@property (nonatomic, assign) UIAccessibilityTraits accessibilityTraits; //默认 UIAccessibilityTraitNone

///自动检测可访问性
///当enableAutoDetectAccessibility = YES时，下面的属性将自动设置
/// ----------------------------
/// isaccessibilitelement = YES
/// accessbilitylabel = (selected ?)getcontentattributedstring .string
/// accessbilitytraits = selected ?UIAccessibilityTraitSelected: UIAccessibilityTraitButton
/// ----------------------------
///但是:accessibilityHint和accessibilityValue仍然保持自定义值;
@property (nonatomic, assign) BOOL enableAutoDetectAccessibility; // Default = NO

/// Init

/**
 使用单一的内容和样式进行初始化

 内容内容分为正常状态和选择状态。
 正常状态和选择状态的样式。
 */
- (instancetype _Nonnull)initWithContent:(TFY_TextTagContent *_Nonnull)content
                                   style:(TFY_TextTagStyle *_Nonnull)style;

/**
 不同内容和风格的Init

 Content正常状态下的内容
 Style正常状态的样式
 selectedContent选择状态的内容
 selectedStyle选择状态的样式
 */
- (instancetype _Nonnull)initWithContent:(TFY_TextTagContent *_Nonnull)content
                                   style:(TFY_TextTagStyle *_Nonnull)style
                         selectedContent:(TFY_TextTagContent *_Nullable)selectedContent
                           selectedStyle:(TFY_TextTagStyle *_Nullable)selectedStyle;

/**
 具有单一内容和样式的标签

 内容内容分为正常状态和选择状态。
 正常状态和选择状态的样式。
 */
+ (instancetype _Nonnull)tagWithContent:(TFY_TextTagContent *_Nonnull)content
                                  style:(TFY_TextTagStyle *_Nonnull)style;

/**
 标签有不同的内容和样式

 Content正常状态下的内容
 Style正常状态的样式
 selectedContent选择状态的内容
 selectedStyle选择状态的样式
 */
+ (instancetype _Nonnull)tagWithContent:(TFY_TextTagContent *_Nonnull)content
                                  style:(TFY_TextTagStyle *_Nonnull)style
                        selectedContent:(TFY_TextTagContent *_Nullable)selectedContent
                          selectedStyle:(TFY_TextTagStyle *_Nullable)selectedStyle;

/**
 获取当前状态的合法内容
 */
- (TFY_TextTagContent *_Nonnull)getRightfulContent;

/**
 获取当前状态的正确样式
 */
- (TFY_TextTagStyle *_Nonnull)getRightfulStyle;

/// 基本系统方法
- (BOOL)isEqual:(id _Nullable)other;
- (BOOL)isEqualToTag:(TFY_TextTag *_Nullable)tag;
- (NSUInteger)hash;

/// Copy
- (id _Nonnull)copyWithZone:(NSZone *_Nullable)zone;

@end

NS_ASSUME_NONNULL_END
