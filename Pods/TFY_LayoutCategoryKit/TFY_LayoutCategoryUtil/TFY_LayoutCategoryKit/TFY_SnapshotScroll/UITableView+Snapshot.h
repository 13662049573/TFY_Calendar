//
//  UITableView+Snapshot.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/4/12.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_SnapshotKitProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Snapshot)<TFY_SnapshotKitProtocol>

- (UIImage * _Nullable)takeSnapshotOfTableHeaderView;

- (UIImage * _Nullable)takeSnapshotOfTableFooterView;

- (UIImage * _Nullable)takeSnapshotOfSectionHeaderView:(NSInteger)section;

- (UIImage * _Nullable)takeSnapshotOfSectionFooterView:(NSInteger)section;

- (UIImage * _Nullable)takeSnapshotOfCell:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
