//
//  TFY_IndexView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/6/8.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_IndexViewConfiguration.h"

@class TFY_IndexView;

@protocol IndexViewDelegate <NSObject>

@optional

/**
 当点击或者滑动索引视图时，回调这个方法

 indexView 索引视图
 section   索引位置
 */
- (void)indexView:(TFY_IndexView *_Nonnull)indexView didSelectAtSection:(NSUInteger)section;

/**
 当滑动tableView时，索引位置改变，你需要自己返回索引位置时，实现此方法。
 不实现此方法，或者方法的返回值为 SCIndexViewInvalidSection 时，索引位置将由控件内部自己计算。

 indexView 索引视图
 tableView 列表视图
          索引位置
 */
- (NSUInteger)sectionOfIndexView:(TFY_IndexView *_Nonnull)indexView tableViewDidScroll:(UITableView *_Nonnull)tableView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_IndexView : UIControl

@property (nonatomic, weak) id<IndexViewDelegate> delegate;

// 索引视图数据源
@property (nonatomic, copy) NSArray<NSString *> *dataSource;

// 当前索引位置
@property (nonatomic, assign) NSInteger currentSection;

// tableView在NavigationBar上是否半透明
@property (nonatomic, assign) BOOL translucentForTableViewInNavigationBar;

// tableView从第几个section开始使用索引 Default = 0
@property (nonatomic, assign) NSUInteger startSection;

// 索引视图的配置
@property (nonatomic, strong, readonly) TFY_IndexViewConfiguration *configuration;

// TFY_IndexView 会对 tableView 进行 strong 引用，请注意，防止“循环引用”
- (instancetype)initWithTableView:(UITableView *)tableView configuration:(TFY_IndexViewConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
