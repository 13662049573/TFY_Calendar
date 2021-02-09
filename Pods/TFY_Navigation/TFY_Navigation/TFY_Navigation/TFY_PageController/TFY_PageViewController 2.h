//
//  TFY_PageViewController.h
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_PageBasicTitleView.h"

@class TFY_PageViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_PageViewControllerDelegate <NSObject>

/**
 当页面切换完成时回调该方法，返回切换到的位置

 @param pageViewController 实例
 @param index 切换的位置
 */
- (void)pageViewController:(TFY_PageViewController *)pageViewController didSelectedAtIndex:(NSInteger)index;

@end

@protocol TFY_PageViewControllerDataSrouce <NSObject>

@required

/**
 根据index返回对应的ViewController

 @param pageViewController TFY_PageViewController实例
 @param index 当前位置
 @return 返回要展示的ViewController
 */
- (UIViewController *)pageViewController:(TFY_PageViewController *)pageViewController viewControllerForIndex:(NSInteger)index;

/**
 根据index返回对应的标题

 @param pageViewController TFY_PageViewController实例
 @param index 当前位置
 @return 返回要展示的标题
 */
- (NSString *)pageViewController:(TFY_PageViewController *)pageViewController titleForIndex:(NSInteger)index;

/**
 要展示分页数

 @return 返回分页数
 */
- (NSInteger)pageViewControllerNumberOfPage;

@optional

/**
 自定义cell方法
 */
- (__kindof TFY_PageTitleCell *)pageViewController:(TFY_PageViewController *)pageViewController titleViewCellForItemAtIndex:(NSInteger)index;

@end

@interface TFY_PageViewController : UIViewController
/**
 代理
 */
@property (nonatomic, weak) id <TFY_PageViewControllerDelegate> delegate;

/**
 数据源
 */
@property (nonatomic, weak) id <TFY_PageViewControllerDataSrouce> dataSource;

/**
 当前位置 默认是0
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 滚动开关 默认 开
 */
@property (nonatomic, assign) BOOL scrollEnabled;

/**
 添加识别其它手势的代理类
 */
@property (nonatomic, strong) NSArray <NSString *>* respondOtherGestureDelegateClassList;

/**
 标题栏右侧View
 */
@property (nonatomic, strong) UIView *rightView;;

/**
 初始化方法

 @param config 配置信息
 @return TFY_PageViewController 实例
 */
- (instancetype)initWithConfig:(TFY_PageControllerConfig *)config;

/**
 刷新方法，当标题改变时，执行此方法
 */
- (void)reloadData;

/**
 自定义标题栏cell时用到
 */
- (void)registerClass:(Class)cellClass forTitleViewCellWithReuseIdentifier:(NSString *)identifier;

/**
 自定义标题栏cell时用到
 返回复用的cell
 */
- (__kindof TFY_PageTitleCell *)dequeueReusableTitleViewCellWithIdentifier:(NSString *)identifier forIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
