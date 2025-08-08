//
//  UIView+Snapshot.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/4/12.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_SnapshotKitProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Snapshot)<TFY_SnapshotKitProtocol>

/**
 对指定区域截图
 */
- (UIImage *)takeSnapshotOfFullContentForCroppingRect:(CGRect)croppingRect;

@end

NS_ASSUME_NONNULL_END
