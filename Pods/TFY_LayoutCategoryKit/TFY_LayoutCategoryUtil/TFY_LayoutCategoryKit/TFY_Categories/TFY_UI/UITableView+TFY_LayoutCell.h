//
//  UITableView+TFY_LayoutCell.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndexPathHeightCache : NSObject
/**
 *  如果您正在使用索引路径驱动的高度缓存，则自动启用
 */
@property (nonatomic, assign) BOOL tfy_automaticallyInvalidateEnabled;
/**
 *  高度缓存
 */
- (BOOL)tfy_existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)tfy_cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tfy_heightForIndexPath:(NSIndexPath *)indexPath;
- (void)tfy_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)tfy_invalidateAllHeightCache;

@end

@interface UITableView (IndexPathHeightCache)
/**
 *  高度缓存索引路径。通常，您不需要直接使用它。
 */
@property (nonatomic, strong, readonly) IndexPathHeightCache *tfy_indexPathHeightCache;
@end

@interface UITableView (IndexPathHeightCacheInvalidation)
/**
 *  当您想要重新加载数据但不想使其无效时，请调用此方法  按索引路径的所有高度缓存，例如，在底部加载更多数据
 */
- (void)tfy_reloadDataWithoutInvalidateIndexPathHeightCache;
@end

@interface KeyedHeightCache : NSObject

- (BOOL)tfy_existsHeightForKey:(id<NSCopying>)key;
- (void)tfy_cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
- (CGFloat)tfy_heightForKey:(id<NSCopying>)key;
/**
 *  失效
 */
- (void)tfy_invalidateHeightForKey:(id<NSCopying>)key;
- (void)tfy_invalidateAllHeightCache;
@end

@interface UITableView (KeyedHeightCache)
/**
 *  按键高度缓存。通常，您不需要直接使用它。
 */
@property (nonatomic, strong, readonly) KeyedHeightCache *tfy_keyedHeightCache;
@end

@interface UITableView (TemplateLayoutCellDebug)
/**
 * 帮助调试或检查这个“TemplateLayoutCell”扩展做什么， 在“创建”，“计算”，“预先缓存”或“点击缓存”时打开日志。 默认为NO，按NSLog登录。
 */
@property (nonatomic, assign) BOOL tfy_debugLogEnabled;
/**
 * 调试日志由“tfy_debugLogEnabled”控制。
 */
- (void)tfy_debugLog:(NSString *)message;

@end


@interface UITableView (TFY_LayoutCell)
/**
 *  访问给定重用标识符的内部模板布局单元格。通常，您不需要知道这些模板布局单元格。 identifier重用必须注册的单元格的标识符。
 */
- (__kindof UITableViewCell *)tfy_templateCellForReuseIdentifier:(NSString *)identifier;
/**
 *  返回由重用标识符指定并配置的类型的单元格的高度
 */
- (CGFloat)tfy_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration;
/**
 * 计算出的高度将通过其索引路径缓存，返回缓存高度 需要的时候。因此可以节省许多额外的高度计算。当数据源发生变化时，无需担心使缓存高度失效
 */
- (CGFloat)tfy_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration;
/**
 * 此方法通过模型实体的标识符缓存高度。使缓存无效并重新计算，它比“cacheByIndexPath”便宜和有效。
 */
- (CGFloat)tfy_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration;
/**
 *  执行一系列插入，删除或选择行的方法调用接收器的各个部分。
 */
- (void)tfy_updateWithBlock:(void (^)(UITableView *tableView))block;
/**
 * 将接收器滚动到屏幕上的行或节位置。 row节中的行索引。section表中的Section索引。scrollPosition标识相对位置的常量
 */
- (void)tfy_scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
/**
 * 在接收器中插入一行，并为插入设置动画。row节中的行索引。section表中的Section索引。
 */
- (void)tfy_insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  使用特定动画效果重新加载指定的行。row节中的行索引。section表中的Section索引。
 */
- (void)tfy_reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  删除具有选项的行以设置删除动画。
 */
- (void)tfy_deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  将行插入到indexPath标识的位置的接收器中，可以选择为插入设置动画。
 */
- (void)tfy_insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  使用特定动画效果重新加载指定的行。
 */
- (void)tfy_reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  删除索引路径数组指定的行，可以选择为删除设置动画。
 */
- (void)tfy_deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  在接收器中插入一个部分，可以选择为插入设置动画。
 */
- (void)tfy_insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  删除接收器中的一个部分，并选择为删除设置动画。
 */
- (void)tfy_deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  使用给定的动画效果重新加载指定的部分。
 */
- (void)tfy_reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  取消选择tableView中的所有行。动画YES表示转换动画，NO表示立即转换。
 */
- (void)tfy_clearSelectedRowsAnimated:(BOOL)animated;
/**
 * 初始一个容器
 */
+ (UITableView *)tfy_tableViewStyle:(UITableViewStyle)style;
@end

@interface UITableView (TemplateLayoutHeaderFooterView)
/**
 *  返回在表视图中使用重用标识符注册的页眉或页脚视图的高度。UITableViewHeaderFooterView的子类，它没有使用自动布局。
 */
- (CGFloat)tfy_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id headerFooterView))configuration;

@end

@interface UITableViewCell (TemplateLayoutCell)
/**
 *  表示这是一个模板布局单元格，仅供计算。配置单元格时，如果存在非UI副作用，则可能需要此项。
 */
@property (nonatomic, assign) BOOL tfy_isTemplateLayoutCell;
/**
 * 允许强制使用此模板布局单元格以使用“框架布局”而不是“自动布局”，计算模式，默认为NO。
 */
@property (nonatomic, assign) BOOL tfy_enforceFrameLayout;

@end

NS_ASSUME_NONNULL_END

