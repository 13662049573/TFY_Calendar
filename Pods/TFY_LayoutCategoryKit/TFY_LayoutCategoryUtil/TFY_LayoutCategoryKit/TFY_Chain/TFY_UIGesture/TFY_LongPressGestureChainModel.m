//
//  TFY_LongPressGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_LongPressGestureChainModel.h"

#define TFY_CATEGORY_CHAIN_LONGGESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_LongPressGestureChainModel *, UILongPressGestureRecognizer)

@implementation TFY_LongPressGestureChainModel

TFY_CATEGORY_CHAIN_LONGGESTURE_IMPLEMENTATION(numberOfTapsRequired, NSUInteger)
TFY_CATEGORY_CHAIN_LONGGESTURE_IMPLEMENTATION(minimumPressDuration, NSTimeInterval)
TFY_CATEGORY_CHAIN_LONGGESTURE_IMPLEMENTATION(allowableMovement, CGFloat)

@end

TFY_CATEGORY_GESTURE_IMPLEMENTATION(UILongPressGestureRecognizer, TFY_LongPressGestureChainModel)

#undef TFY_CATEGORY_CHAIN_LONGGESTURE_IMPLEMENTATION


