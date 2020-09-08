//
//  TFY_RotationGestureChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseGestureChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_RotationGestureChainModel;
@interface TFY_RotationGestureChainModel : TFY_BaseGestureChainModel<TFY_RotationGestureChainModel *>
TFY_PROPERTY_CHAIN_READONLY TFY_RotationGestureChainModel * (^ rotation) (CGFloat rotation);
@end
TFY_CATEGORY_EXINTERFACE(UIRotationGestureRecognizer, TFY_RotationGestureChainModel)
NS_ASSUME_NONNULL_END

