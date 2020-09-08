//
//  TFY_PinchGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_PinchGestureChainModel.h"
#define TFY_CATEGORY_CHAIN_PINGESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_PinchGestureChainModel *, UIPinchGestureRecognizer)
@implementation TFY_PinchGestureChainModel
TFY_CATEGORY_CHAIN_PINGESTURE_IMPLEMENTATION(scale, CGFloat)
@end
TFY_CATEGORY_GESTURE_IMPLEMENTATION(UIPinchGestureRecognizer, TFY_PinchGestureChainModel)
#undef TFY_CATEGORY_CHAIN_PINGESTURE_IMPLEMENTATION
