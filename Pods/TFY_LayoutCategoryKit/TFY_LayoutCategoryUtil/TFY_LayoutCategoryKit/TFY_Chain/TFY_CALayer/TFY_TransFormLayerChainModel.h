//
//  TFY_TransFormLayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_TransFormLayerChainModel;
@interface TFY_TransFormLayerChainModel : TFY_BaseLayerChainModel<TFY_TransFormLayerChainModel *>

@end
TFY_CATEGORY_EXINTERFACE(CATransformLayer, TFY_TransFormLayerChainModel)
NS_ASSUME_NONNULL_END
