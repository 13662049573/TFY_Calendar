//
//  TFY_PanGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_PanGestureChainModel.h"
#define TFY_CATEGORY_CHAIN_PANGESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_PanGestureChainModel *, UIPanGestureRecognizer)

@implementation TFY_PanGestureChainModel

TFY_CATEGORY_CHAIN_PANGESTURE_IMPLEMENTATION(minimumNumberOfTouches, NSUInteger)
TFY_CATEGORY_CHAIN_PANGESTURE_IMPLEMENTATION(maximumNumberOfTouches, NSUInteger)

- (TFY_PanGestureChainModel * _Nonnull (^)(CGPoint, UIView * _Nonnull))translation{
    return ^ (CGPoint translation, UIView *view){
        [self enumerateObjectsUsingBlock:^(UIPanGestureRecognizer * _Nonnull obj) {
            [obj setTranslation:translation inView:view];
        }];
        return self;
    };
}
@end
TFY_CATEGORY_GESTURE_IMPLEMENTATION(UIPanGestureRecognizer, TFY_PanGestureChainModel)
#undef TFY_CATEGORY_CHAIN_PANGESTURE_IMPLEMENTATION
