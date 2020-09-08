//
//  TFY_ScrollLayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ScrollLayerChainModel;
@interface TFY_ScrollLayerChainModel : TFY_BaseLayerChainModel<TFY_ScrollLayerChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_ScrollLayerChainModel * (^ scrollToPoint) (CGPoint point);
TFY_PROPERTY_CHAIN_READONLY TFY_ScrollLayerChainModel * (^ scrollToRect) (CGRect rect);
TFY_PROPERTY_CHAIN_READONLY TFY_ScrollLayerChainModel * (^ scrollMode) (CAScrollLayerScrollMode scrollMode);
@end

TFY_CATEGORY_EXINTERFACE(CAScrollLayer, TFY_ScrollLayerChainModel)

NS_ASSUME_NONNULL_END
