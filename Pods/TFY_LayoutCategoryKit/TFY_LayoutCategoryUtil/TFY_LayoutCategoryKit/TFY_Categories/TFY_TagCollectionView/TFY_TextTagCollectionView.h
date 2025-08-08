//
//  TFY_TextTagCollectionView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_TagCollectionView.h"
#import "TFY_TextTag.h"
#import "TFY_TextTagStringContent.h"
#import "TFY_TextTagAttributedStringContent.h"

@class TFY_TextTagCollectionView;

NS_ASSUME_NONNULL_BEGIN

/// Delegate
@protocol TextTagCollectionViewDelegate <NSObject>
@optional

- (BOOL)textTagCollectionView:(TFY_TextTagCollectionView *)textTagCollectionView
                    canTapTag:(TFY_TextTag *)tag
                      atIndex:(NSUInteger)index;

- (void)textTagCollectionView:(TFY_TextTagCollectionView *)textTagCollectionView
                    didTapTag:(TFY_TextTag *)tag
                      atIndex:(NSUInteger)index;

- (void)textTagCollectionView:(TFY_TextTagCollectionView *)textTagCollectionView
            updateContentSize:(CGSize)contentSize;
@end

@interface TFY_TextTagCollectionView : UIView

/// Delegate
@property (weak, nonatomic) id <TextTagCollectionViewDelegate> delegate;

/// 在滚动视图
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/// 定义标签是否可以被选择。
@property (assign, nonatomic) BOOL enableTagSelection;

/// 标签滚动方向，默认为垂直。
@property (nonatomic, assign) TagCollectionScrollDirection scrollDirection;

/// 标签布局对齐，默认为左对齐。
@property (nonatomic, assign) TagCollectionAlignment alignment;

/// 行数。0表示没有限制，默认为垂直0，水平1。
@property (nonatomic, assign) NSUInteger numberOfLines;
/// 忽略numberolines值的实际行数
@property (nonatomic, assign, readonly) NSUInteger actualNumberOfLines;

/// 标签选择限制，默认为0，表示没有限制
@property (nonatomic, assign) NSUInteger selectionLimit;

/// 标签之间的水平和垂直间距，默认为4。
@property (assign, nonatomic) CGFloat horizontalSpacing;
@property (assign, nonatomic) CGFloat verticalSpacing;

/// 内容插入，比如填充，默认是UIEdgeInsetsMake(2,2,2,2)。
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// 真正的标签内容大小，只读
@property (nonatomic, assign, readonly) CGSize contentSize;

///手动设置内容高度
///默认= NO，设置将更新内容
@property (nonatomic, assign) BOOL manualCalculateHeight;
/// 默认= 0，设置将更新内容
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;

/// 滚动指标
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

/// 轻按空白区回呼
@property (nonatomic, copy) void (^onTapBlankArea)(CGPoint location);
/// 轻按所有区域回呼
@property (nonatomic, copy) void (^onTapAllArea)(CGPoint location);

/// 重新加载
- (void)reload;

/// Add
- (void)addTag:(TFY_TextTag *)tag;
- (void)addTags:(NSArray <TFY_TextTag *> *)tags;

/// Insert
- (void)insertTag:(TFY_TextTag *)tag atIndex:(NSUInteger)index;
- (void)insertTags:(NSArray <TFY_TextTag *> *)tags atIndex:(NSUInteger)index;

/// Update
- (void)updateTagAtIndex:(NSUInteger)index selected:(BOOL)selected;
- (void)updateTagAtIndex:(NSUInteger)index withNewTag:(TFY_TextTag *)tag;

/// Remove
- (void)removeTag:(TFY_TextTag *)tag;
- (void)removeTagById:(NSUInteger)tagId;
- (void)removeTagAtIndex:(NSUInteger)index;
- (void)removeAllTags;

/// Get tag
- (TFY_TextTag *)getTagAtIndex:(NSUInteger)index;
- (NSArray <TFY_TextTag *> *)getTagsInRange:(NSRange)range;

/// Get all
- (NSArray <TFY_TextTag *> *)allTags;
- (NSArray <TFY_TextTag *> *)allSelectedTags;
- (NSArray <TFY_TextTag *> *)allNotSelectedTags;

/**
 *返回位于指定点的标签的索引。
 *如果在点处没有找到项，返回NSNotFound。
 */
- (NSInteger)indexOfTagAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
