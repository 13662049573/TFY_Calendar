//
//  TFY_PageBasicTitleView.h
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_PageTitleCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_PageTitleViewDataSrouce <NSObject>

@required

/**
 根据index返回对应的标题
 
 @param index 当前位置
 @return 返回要展示的标题
 */
- (NSString *)pageTitleViewTitleForIndex:(NSInteger)index;

/**
 要展示分页数
 
 @return 返回分页数
 */
- (NSInteger)pageTitleViewNumberOfTitle;

/**
 自定义cell方法
 */
- (__kindof TFY_PageTitleCell *)pageTitleViewCellForItemAtIndex:(NSInteger)index;

@end

@protocol TFY_PageTitleViewDelegate <NSObject>

/**
 选中位置代理方法

 @param index 所选位置
 */
- (BOOL)pageTitleViewDidSelectedAtIndex:(NSInteger)index;

@end

@interface TFY_PageBasicTitleView : UIView
/**
 数据源
 */
@property (nonatomic, weak) id <TFY_PageTitleViewDataSrouce> dataSource;

/**
 代理方法
 */
@property (nonatomic, weak) id <TFY_PageTitleViewDelegate> delegate;

/**
 选中位置
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 上一次选中的位置
 */
@property (nonatomic, assign) NSInteger lastSelectedIndex;

/**
 动画的进度
 */
@property (nonatomic, assign) CGFloat animationProgress;

/**
 停止动画，在手动设置位置时，不显示动画效果
 */
@property (nonatomic, assign) BOOL stopAnimation;

/**
 右侧按钮
 */
@property (nonatomic, strong) UIView *rightView;

/**
 初始化方法

 @param config 配置信息
 @return TitleView 实例
 */
- (instancetype)initWithConfig:(TFY_PageControllerConfig *)config;

/**
 刷新数据，当标题信息改变时调用
 */
- (void)reloadData;

/**
 自定义标题栏时用到
 */
- (void)registerClass:(Class)cellClass forTitleViewCellWithReuseIdentifier:(NSString *)identifier;

/**
 cell 复用方法
 */
- (__kindof TFY_PageTitleCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
