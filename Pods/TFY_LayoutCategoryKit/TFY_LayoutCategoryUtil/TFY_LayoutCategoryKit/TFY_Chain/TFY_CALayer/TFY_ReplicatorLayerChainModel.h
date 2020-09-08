//
//  TFY_ReplicatorLayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ReplicatorLayerChainModel;
@interface TFY_ReplicatorLayerChainModel : TFY_BaseLayerChainModel<TFY_ReplicatorLayerChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceCount) (NSInteger instanceCount);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ preservesDepth) (BOOL preservesDepth);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceDelay) (CFTimeInterval instanceDelay);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceTransform) (CATransform3D instanceTransform);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceColor) (CGColorRef instanceColor);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceRedOffset) (float instanceRedOffset);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceGreenOffset) (float instanceGreenOffset);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceBlueOffset) (float instanceBlueOffset);
TFY_PROPERTY_CHAIN_READONLY TFY_ReplicatorLayerChainModel * (^ instanceAlphaOffset) (float instanceAlphaOffset);
@end

TFY_CATEGORY_EXINTERFACE(CAReplicatorLayer, TFY_ReplicatorLayerChainModel)

NS_ASSUME_NONNULL_END
