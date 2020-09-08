//
//  UIScrollView+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (TFY_Tools)
- (void)adJustedContentIOS11;
/**
 * 头部缩放视图图片
 */
@property (nonatomic, strong)UIImage *_Nonnull tfy_headerScaleImage;
/**
 * 头部缩放视图图片高度 默认200
 */
@property (nonatomic, assign)CGFloat tfy_headerScaleImageHeight;
/**
 * 生成图片
 */
- (void)tfy_screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;
/**
 * 生成图片
 */
+(UIImage *_Nonnull)tfy_screenSnapshotWithSnapshotView:(UIView *_Nonnull)snapshotView;
/**
 * 生成图片
 */
+(UIImage *_Nonnull)tfy_screenSnapshotWithSnapshotView:(UIView *_Nonnull)snapshotView snapshotSize:(CGSize)snapshotSize;

@end

NS_ASSUME_NONNULL_END
