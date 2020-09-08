//
//  TFY_ImageViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ImageViewChainModel;
@interface TFY_ImageViewChainModel : TFY_BaseViewChainModel<TFY_ImageViewChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ image)(UIImage *);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ highlightedImage)(UIImage *);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ highlighted)(BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ animationImages)(NSArray <UIImage *> * animationImages);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ highlightedAnimationImages)(NSArray <UIImage *> * highlightedAnimationImages);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ startAnimating)(void);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ stopAnimating)(void);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ animationRepeatCount)(NSInteger);

TFY_PROPERTY_CHAIN_READONLY TFY_ImageViewChainModel *(^ animationDuration)(NSTimeInterval);

@end

TFY_CATEGORY_EXINTERFACE(UIImageView, TFY_ImageViewChainModel)

NS_ASSUME_NONNULL_END
