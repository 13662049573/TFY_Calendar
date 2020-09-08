//
//  TFY_PinchGestureChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseGestureChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_PinchGestureChainModel;
@interface TFY_PinchGestureChainModel : TFY_BaseGestureChainModel<TFY_PinchGestureChainModel *>
TFY_PROPERTY_CHAIN_READONLY TFY_PinchGestureChainModel * (^ scale) (CGFloat scale);

@end
TFY_CATEGORY_EXINTERFACE(UIPinchGestureRecognizer, TFY_PinchGestureChainModel)
NS_ASSUME_NONNULL_END
