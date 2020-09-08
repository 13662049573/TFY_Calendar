//
//  UITableViewCell+TFY_Chain.h
//  TFY_Category
//
//  Created by tiandengyou on 2019/12/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (TFY_Chain)
@property(nonatomic, strong, readonly) UITableView *tfy_parentTableView;
#pragma mark - 用xib实例化cell
+ (instancetype)tfy_cellHeaderFromXib;
/**
 * 从tableView获取重用的cell，如果没有可复用的从定义好的xib里创建一个，该方法有一下默认参数
 * 1、默认参数xibName:实例化化的xib名称,使用Cell的类的名称
 * 2、默认参数identifier：cell的重用ID，使用Cell的类的名称
 * tableView 使用的tableView
 * 重用或创建的一个cell
 */
+ (instancetype)tfy_cellFromXibWithTableView:(UITableView *)tableView;

/**
 * 从tableView获取重用的cell，如果没有可复用的从定义好的xib里创建一个，该方法有以下默认参数
 * 1、默认参数xibName:实例化化的xib名称,使用Cell的类的名称
 * tableView 使用的tableView
 * identifier cell的重用ID
 * 重用或创建的一个cell
 */
+ (instancetype)tfy_cellFromXibWithTableView:(UITableView *)tableView identifer:(NSString *)identifier;

/**
 * 从tableView获取重用的cell，如果没有可复用的从定义好的xib里创建一个
 * tableView 使用的tableView
 * xibName 实例化化的xib名称
 * identifier cell的重用ID
 * 重用或创建的一个cell
 */
+ (instancetype)tfy_cellFromXibTableView:(UITableView *)tableView xibName:(NSString *)xibName identifer:(NSString *)identifier;
#pragma mark - 代码实例化一个cell
+ (instancetype)tfy_cellFromCodeWithTableView:(UITableView *)tableView;
+ (instancetype)tfy_cellFromCodeWithTableView:(UITableView *)tableView identifier:(NSString *)identifier;
@end

@interface UICollectionViewCell (TFY_Chain)
@property(nonatomic, strong, readonly) UICollectionView *tfy_parentCollectionView;
@end


NS_ASSUME_NONNULL_END
