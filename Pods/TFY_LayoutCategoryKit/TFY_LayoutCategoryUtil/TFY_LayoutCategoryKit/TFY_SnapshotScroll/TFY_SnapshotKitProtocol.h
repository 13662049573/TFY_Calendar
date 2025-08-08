//
//  TFY_SnapshotKitProtocol.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/4/12.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_SnapshotKitProtocol <NSObject>
@optional

/**
 同步获取视图可见内容的快照
 */
- (UIImage * _Nullable)takeSnapshotOfVisibleContent;

/**
 同步获取视图全部内容的快照
 重要提示:当视图的全部内容的大小很小时，使用此方法进行快照
 */
- (UIImage * _Nullable)takeSnapshotOfFullContent;

/**
 异步获取视图全部内容的快照
 重要提示:当视图的全部内容很大时，使用此方法进行快照
 */
- (void)asyncTakeSnapshotOfFullContent:(void(^_Nullable)(UIImage *_Nullable image))completion;

@end

NS_ASSUME_NONNULL_END
