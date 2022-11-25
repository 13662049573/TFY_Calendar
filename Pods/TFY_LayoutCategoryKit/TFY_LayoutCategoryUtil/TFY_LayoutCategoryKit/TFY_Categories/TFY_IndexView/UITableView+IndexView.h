//
//  UITableView+IndexView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/6/8.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_IndexView.h"

@protocol TableViewSectionIndexDelegate

/**
 当点击或者滑动索引视图时，回调这个方法
 
 tableView 列表视图
 section   索引位置
 */
- (void)tableView:(UITableView *_Nonnull)tableView didSelectIndexViewAtSection:(NSUInteger)section;

/**
 当滑动tableView时，索引位置改变，你需要自己返回索引位置时，实现此方法。
 不实现此方法，或者方法的返回值为 SCIndexViewInvalidSection 时，索引位置将由控件内部自己计算。
 
 tableView 列表视图
  索引位置
 */
- (NSUInteger)sectionOfTableViewDidScroll:(UITableView *_Nonnull)tableView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (IndexView)

@property (nonatomic, weak) id<TableViewSectionIndexDelegate> tfy_indexViewDelegate;

// 索引视图数据源
@property (nonatomic, copy) NSArray<NSString *> *tfy_indexViewDataSource;

// tableView在NavigationBar上是否半透明
@property (nonatomic, assign) BOOL tfy_translucentForTableViewInNavigationBar;

// tableView从第几个section开始使用索引 Default = 0
@property (nonatomic, assign) NSUInteger tfy_startSection;

// 索引视图的配置
@property (nonatomic, strong) TFY_IndexViewConfiguration *tfy_indexViewConfiguration;


@end

NS_ASSUME_NONNULL_END
