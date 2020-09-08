//
//  TFY_ShaperLayerChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseLayerChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ShaperLayerChainModel;
@interface TFY_ShaperLayerChainModel : TFY_BaseLayerChainModel<TFY_ShaperLayerChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ path) (CGPathRef path);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ fillColor) (CGColorRef fillColor);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ fillRule) (CAShapeLayerFillRule fillRule);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ strokeColor) (CGColorRef strokeColor);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ strokeStart) (CGFloat strokeStart);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ strokeEnd) (CGFloat strokeEnd);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ lineWidth) (CGFloat lineWidth);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ miterLimit) (CGFloat miterLimit);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ lineCap) (CAShapeLayerLineCap lineCap);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ lineJoin) (CAShapeLayerLineJoin lineJoin);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ lineDashPhase) (CGFloat lineDashPhase);
TFY_PROPERTY_CHAIN_READONLY TFY_ShaperLayerChainModel * (^ lineDashPattern) (NSArray<NSNumber *> * lineDashPattern);
@end

TFY_CATEGORY_EXINTERFACE(CAShapeLayer, TFY_ShaperLayerChainModel)

NS_ASSUME_NONNULL_END
