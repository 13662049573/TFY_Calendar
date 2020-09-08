//
//  TFY_GradientLayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_GradientLayerChainModel;
@interface TFY_GradientLayerChainModel : TFY_BaseLayerChainModel<TFY_GradientLayerChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_GradientLayerChainModel * (^ colors) (NSArray * colors);
TFY_PROPERTY_CHAIN_READONLY TFY_GradientLayerChainModel * (^ locations) (NSArray<NSNumber *> * locations);
TFY_PROPERTY_CHAIN_READONLY TFY_GradientLayerChainModel * (^ startPoint) (CGPoint startPoint);
TFY_PROPERTY_CHAIN_READONLY TFY_GradientLayerChainModel * (^ endPoint) (CGPoint endPoint);
@end

TFY_CATEGORY_EXINTERFACE(CAGradientLayer, TFY_GradientLayerChainModel)

NS_ASSUME_NONNULL_END
