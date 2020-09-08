//
//  TFY_SwipeGestureChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseGestureChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_SwipeGestureChainModel;
@interface TFY_SwipeGestureChainModel : TFY_BaseGestureChainModel<TFY_SwipeGestureChainModel *>
TFY_PROPERTY_CHAIN_READONLY TFY_SwipeGestureChainModel * (^ numberOfTapsRequired) (NSUInteger numberOfTapsRequired);
TFY_PROPERTY_CHAIN_READONLY TFY_SwipeGestureChainModel * (^ direction) (UISwipeGestureRecognizerDirection direction);

@end
TFY_CATEGORY_EXINTERFACE(UISwipeGestureRecognizer, TFY_SwipeGestureChainModel)
NS_ASSUME_NONNULL_END
