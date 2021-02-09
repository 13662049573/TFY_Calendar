//
//  TFY_PageTitleCell.h
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_PageControllerUtil.h"

//动画类行，已选cell/将要成为已选的cell
typedef NS_ENUM (NSInteger ,TFY_PageTitleCellAnimationType) {
    TFY_PageTitleCellAnimationTypeSelected = 0,
    TFY_PageTitleCellAnimationTypeWillSelected = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PageTitleCell : UICollectionViewCell
//配置信息 默认样式时用到
@property (nonatomic, strong) TFY_PageControllerConfig *config;

//标题label
@property (nonatomic, strong) UILabel *textLabel;

//配置cell
/**
 配置cell选中/未选中UI
 
 @param selected 已选中/未选中
 */
- (void)configCellOfSelected:(BOOL)selected;

/**
 执行动画方法，默认样式中有标题颜色过渡的方法，用户如需添加其他动画，可在此方法中添加
 
 @param progress 动画进度 0~1
 @param type cell类行，已选中cell/将要选中cell
 */
- (void)showAnimationOfProgress:(CGFloat)progress type:(TFY_PageTitleCellAnimationType)type;
@end

NS_ASSUME_NONNULL_END
