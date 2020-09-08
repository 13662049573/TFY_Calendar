//
//  TFY_SwipeGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_SwipeGestureChainModel.h"
#define TFY_CATEGORY_CHAIN_SWIPEGESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_SwipeGestureChainModel *, UISwipeGestureRecognizer)
@implementation TFY_SwipeGestureChainModel
TFY_CATEGORY_CHAIN_SWIPEGESTURE_IMPLEMENTATION(numberOfTouchesRequired, NSUInteger)
TFY_CATEGORY_CHAIN_SWIPEGESTURE_IMPLEMENTATION(direction, UISwipeGestureRecognizerDirection)
@end
TFY_CATEGORY_GESTURE_IMPLEMENTATION(UISwipeGestureRecognizer, TFY_SwipeGestureChainModel)
#undef TFY_CATEGORY_CHAIN_SWIPEGESTURE_IMPLEMENTATION
