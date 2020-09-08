//
//  TFY_TiledLayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_TiledLayerChainModel;
@interface TFY_TiledLayerChainModel : TFY_BaseLayerChainModel<TFY_TiledLayerChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_TiledLayerChainModel * (^ levelsOfDetail) (size_t levelsOfDetail);
TFY_PROPERTY_CHAIN_READONLY TFY_TiledLayerChainModel * (^ levelsOfDetailBias) (size_t levelsOfDetailBias);
TFY_PROPERTY_CHAIN_READONLY TFY_TiledLayerChainModel * (^ tileSize) (CGSize tileSize);
@end

TFY_CATEGORY_EXINTERFACE(CATiledLayer, TFY_TiledLayerChainModel)

NS_ASSUME_NONNULL_END
