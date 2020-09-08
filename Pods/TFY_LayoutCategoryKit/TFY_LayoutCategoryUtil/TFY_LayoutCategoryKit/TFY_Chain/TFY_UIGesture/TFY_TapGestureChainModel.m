//
//  TFY_TapGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TapGestureChainModel.h"
#define TFY_CATEGORY_CHAIN_TAPGESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TapGestureChainModel *, UITapGestureRecognizer)
@implementation TFY_TapGestureChainModel
TFY_CATEGORY_CHAIN_TAPGESTURE_IMPLEMENTATION(numberOfTapsRequired,NSUInteger)
@end
TFY_CATEGORY_GESTURE_IMPLEMENTATION(UITapGestureRecognizer, TFY_TapGestureChainModel)
#undef TFY_CATEGORY_CHAIN_TAPGESTURE_IMPLEMENTATION

