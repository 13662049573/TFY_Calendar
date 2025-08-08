//
//  TFY_TagCollectionView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_TagCollectionView;

NS_ASSUME_NONNULL_BEGIN

/**
 * Tags scroll direction
 */
typedef NS_ENUM(NSInteger, TagCollectionScrollDirection) {
    TagCollectionScrollDirectionVertical = 0, // 默认
    TagCollectionScrollDirectionHorizontal = 1
};

/**
 * Tags alignment
 */
typedef NS_ENUM(NSInteger, TagCollectionAlignment) {
    TagCollectionAlignmentLeft = 0,                           // 默认
    TagCollectionAlignmentCenter,                             // Center
    TagCollectionAlignmentRight,                              // Right
    TagCollectionAlignmentFillByExpandingSpace,               // Expand horizontal spacing and fill
    TagCollectionAlignmentFillByExpandingWidth,               // Expand width and fill
    TagCollectionAlignmentFillByExpandingWidthExceptLastLine  // Expand width and fill, except last line
};

/**
 * Tags delegate
 */
@protocol TagCollectionViewDelegate <NSObject>
@required
- (CGSize)tagCollectionView:(TFY_TagCollectionView *)tagCollectionView sizeForTagAtIndex:(NSUInteger)index;

@optional
- (BOOL)tagCollectionView:(TFY_TagCollectionView *)tagCollectionView shouldSelectTag:(UIView *)tagView atIndex:(NSUInteger)index;

- (void)tagCollectionView:(TFY_TagCollectionView *)tagCollectionView didSelectTag:(UIView *)tagView atIndex:(NSUInteger)index;

- (void)tagCollectionView:(TFY_TagCollectionView *)tagCollectionView updateContentSize:(CGSize)contentSize;
@end

/**
 * Tags dataSource
 */
@protocol TagCollectionViewDataSource <NSObject>
@required
- (NSUInteger)numberOfTagsInTagCollectionView:(TFY_TagCollectionView *)tagCollectionView;

- (UIView *)tagCollectionView:(TFY_TagCollectionView *)tagCollectionView tagViewForIndex:(NSUInteger)index;
@end

@interface TFY_TagCollectionView : UIView

@property (nonatomic, weak) id <TagCollectionViewDataSource> dataSource;
@property (nonatomic, weak) id <TagCollectionViewDelegate> delegate;

// 在滚动视图
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

// 标签滚动方向，默认为垂直。
@property (nonatomic, assign) TagCollectionScrollDirection scrollDirection;

// 标签布局对齐，默认为左对齐。
@property (nonatomic, assign) TagCollectionAlignment alignment;

// 行数。0表示没有限制，默认为垂直0，水平1。
@property (nonatomic, assign) NSUInteger numberOfLines;
// 忽略numberolines值的实际行数
@property (nonatomic, assign, readonly) NSUInteger actualNumberOfLines;

// 标签之间的水平和垂直间距，默认为4。
@property (nonatomic, assign) CGFloat horizontalSpacing;
@property (nonatomic, assign) CGFloat verticalSpacing;

// 内容插入，默认是UIEdgeInsetsMake(2,2,2,2)。
@property (nonatomic, assign) UIEdgeInsets contentInset;

// 真正的标签内容大小，只读
@property (nonatomic, assign, readonly) CGSize contentSize;

//手动设置内容高度
//默认= NO，设置将更新内容
@property (nonatomic, assign) BOOL manualCalculateHeight;
// 默认= 0，设置将更新内容
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;

// 滚动指标
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

// 轻按空白区回呼
@property (nonatomic, copy) void (^onTapBlankArea)(CGPoint location);
// 轻按所有区域回呼
@property (nonatomic, copy) void (^onTapAllArea)(CGPoint location);

/**
 * 重新加载所有标签单元格
 */
- (void)reload;

/**
 *返回位于指定点的标签的索引。
 *如果在点处没有找到项，返回NSNotFound。
 */
- (NSInteger)indexOfTagAt:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
