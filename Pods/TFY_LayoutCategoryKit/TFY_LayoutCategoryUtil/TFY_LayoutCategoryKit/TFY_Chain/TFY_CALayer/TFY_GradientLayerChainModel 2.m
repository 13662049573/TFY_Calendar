//
//  TFY_GradientLayerChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_GradientLayerChainModel.h"
#define TFY_CATEGORY_CHAIN_GRADIENTLAYER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_LAYERCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_GradientLayerChainModel *, CAGradientLayer)
@implementation TFY_GradientLayerChainModel

TFY_CATEGORY_CHAIN_GRADIENTLAYER_IMPLEMENTATION(locations, NSArray<NSNumber *> *)
TFY_CATEGORY_CHAIN_GRADIENTLAYER_IMPLEMENTATION(startPoint, CGPoint)
TFY_CATEGORY_CHAIN_GRADIENTLAYER_IMPLEMENTATION(endPoint, CGPoint)


- (TFY_GradientLayerChainModel * _Nonnull (^)(NSArray * _Nonnull))colors{
    return ^ (NSArray *colors){
        NSMutableArray *bridgeColors = [NSMutableArray array];
        for (id color in colors) {
            if ([color isKindOfClass:[UIColor class]]) {
                [bridgeColors addObject:(__bridge id)[color CGColor]];
            }else{
                [bridgeColors addObject:color];
            }
        }
        [self enumerateObjectsUsingBlock:^(CAGradientLayer * _Nonnull obj) {
            [obj setColors:bridgeColors];
        }];
        return self;
    };
}
@end
TFY_CATEGORY_LAYER_IMPLEMENTATION(CAGradientLayer, TFY_GradientLayerChainModel)
#undef TFY_CATEGORY_CHAIN_GRADIENTLAYER_IMPLEMENTATION

