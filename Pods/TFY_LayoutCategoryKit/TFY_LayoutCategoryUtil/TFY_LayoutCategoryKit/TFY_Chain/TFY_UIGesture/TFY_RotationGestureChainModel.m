//
//  TFY_RotationGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_RotationGestureChainModel.h"
#define TFY_CATEGORY_CHAIN_ROTAGESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_RotationGestureChainModel *, UIRotationGestureRecognizer)
@implementation TFY_RotationGestureChainModel
TFY_CATEGORY_CHAIN_ROTAGESTURE_IMPLEMENTATION(rotation, CGFloat)
@end
TFY_CATEGORY_GESTURE_IMPLEMENTATION(UIRotationGestureRecognizer, TFY_RotationGestureChainModel)
#undef TFY_CATEGORY_CHAIN_ROTAGESTURE_IMPLEMENTATION
