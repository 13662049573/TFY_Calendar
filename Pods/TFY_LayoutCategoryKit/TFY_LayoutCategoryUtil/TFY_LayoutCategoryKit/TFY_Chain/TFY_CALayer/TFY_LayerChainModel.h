//
//  TFY_LayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_LayerChainModel;
@interface TFY_LayerChainModel : TFY_BaseLayerChainModel<TFY_LayerChainModel *>

@end
TFY_CATEGORY_EXINTERFACE(CALayer, TFY_LayerChainModel)
NS_ASSUME_NONNULL_END
