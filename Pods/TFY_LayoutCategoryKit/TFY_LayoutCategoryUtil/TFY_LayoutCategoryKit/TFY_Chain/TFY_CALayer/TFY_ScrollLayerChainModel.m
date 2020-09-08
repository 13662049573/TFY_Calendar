//
//  TFY_ScrollLayerChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ScrollLayerChainModel.h"
#define TFY_CATEGORY_CHAIN_SCROLLLAYER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_LAYERCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ScrollLayerChainModel *, CAScrollLayer)
@implementation TFY_ScrollLayerChainModel

TFY_CATEGORY_CHAIN_SCROLLLAYER_IMPLEMENTATION(scrollMode, CAScrollLayerScrollMode)

- (TFY_ScrollLayerChainModel * _Nonnull (^)(CGRect))scrollToRect{
    return ^ (CGRect rect){
        [self enumerateObjectsUsingBlock:^(CAScrollLayer * _Nonnull obj) {
            [obj scrollToRect:rect];
        }];
        return self;
    };
}

- (TFY_ScrollLayerChainModel * _Nonnull (^)(CGPoint))scrollToPoint{
    return ^ (CGPoint point){
        [self enumerateObjectsUsingBlock:^(CAScrollLayer * _Nonnull obj) {
            [obj scrollToPoint:point];
        }];
        return self;
    };
}

@end
TFY_CATEGORY_LAYER_IMPLEMENTATION(CAScrollLayer, TFY_ScrollLayerChainModel)
#undef TFY_CATEGORY_CHAIN_SCROLLLAYER_IMPLEMENTATION
