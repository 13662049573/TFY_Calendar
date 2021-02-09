//
//  TFY_PanGestureChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseGestureChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_PanGestureChainModel;
@interface TFY_PanGestureChainModel : TFY_BaseGestureChainModel<TFY_PanGestureChainModel *>
TFY_PROPERTY_CHAIN_READONLY TFY_PanGestureChainModel * (^ minimumNumberOfTouches) (NSUInteger minimumNumberOfTouches);
TFY_PROPERTY_CHAIN_READONLY TFY_PanGestureChainModel * (^ maximumNumberOfTouches) (NSUInteger maximumNumberOfTouches);
TFY_PROPERTY_CHAIN_READONLY TFY_PanGestureChainModel * (^ translation) (CGPoint translation,UIView *view);
@end
TFY_CATEGORY_EXINTERFACE(UIPanGestureRecognizer, TFY_PanGestureChainModel)
NS_ASSUME_NONNULL_END
