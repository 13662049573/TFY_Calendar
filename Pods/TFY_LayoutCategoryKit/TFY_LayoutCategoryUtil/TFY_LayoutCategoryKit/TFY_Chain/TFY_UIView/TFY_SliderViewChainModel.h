//
//  TFY_SliderViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_SliderViewChainModel;
@interface TFY_SliderViewChainModel : TFY_BaseControlChainModel<TFY_SliderViewChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ value) (float);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ minimumValue) (float);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ maximumValue) (float);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ minimumValueImage) (UIImage *);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ maximumValueImage) (UIImage *);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ continuous) (BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ minimumTrackTintColor) (UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ maximumTrackTintColor) ( UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ thumbTintColor) (UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ setThumbImage) (UIImage *,UIControlState);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ setMinimumTrackImage) (UIImage *,UIControlState);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ setMaximumTrackImage) (UIImage *,UIControlState);
TFY_PROPERTY_CHAIN_READONLY TFY_SliderViewChainModel * (^ setValueAnimated) (float, BOOL);
@end

TFY_CATEGORY_EXINTERFACE(UISlider, TFY_SliderViewChainModel)

NS_ASSUME_NONNULL_END
