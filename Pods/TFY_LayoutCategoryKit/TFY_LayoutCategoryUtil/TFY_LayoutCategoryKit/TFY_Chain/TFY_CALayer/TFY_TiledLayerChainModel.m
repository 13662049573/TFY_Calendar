//
//  TFY_TiledLayerChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TiledLayerChainModel.h"
#define TFY_CATEGORY_CHAIN_TILEDLAYER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_LAYERCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TiledLayerChainModel *, CATiledLayer)

@implementation TFY_TiledLayerChainModel
TFY_CATEGORY_CHAIN_TILEDLAYER_IMPLEMENTATION(levelsOfDetail, size_t)
TFY_CATEGORY_CHAIN_TILEDLAYER_IMPLEMENTATION(levelsOfDetailBias,size_t)
TFY_CATEGORY_CHAIN_TILEDLAYER_IMPLEMENTATION(tileSize,CGSize)
@end
TFY_CATEGORY_LAYER_IMPLEMENTATION(CATiledLayer, TFY_TiledLayerChainModel)
#undef TFY_CATEGORY_CHAIN_TILEDLAYER_IMPLEMENTATION

