//
//  TFY_TransFormLayerChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TransFormLayerChainModel.h"
#define TFY_CATEGORY_CHAIN_TRANSFORMLAYER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_LAYERCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TransFormLayerChainModel *, CATransformLayer)
@implementation TFY_TransFormLayerChainModel

@end
TFY_CATEGORY_LAYER_IMPLEMENTATION(CATransformLayer, TFY_TransFormLayerChainModel)
#undef TFY_CATEGORY_CHAIN_TRANSFORMLAYER_IMPLEMENTATION
