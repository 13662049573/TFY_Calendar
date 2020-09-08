//
//  CALayer+TFY_Chain.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "CALayer+TFY_Chain.h"
#define TFY_CATEGORY_ADDSUBLAYER(method, ModelClass, LayerClass)\
- (ModelClass * _Nonnull (^)(void))method{\
return ^ (){\
LayerClass *layer = [LayerClass layer];\
ModelClass *chainModel = [[ModelClass alloc] initWithLayer:layer modelClass:[LayerClass class]];\
[self addSublayer:layer];\
return chainModel;\
};\
}
@implementation CALayer (TFY_Chain)

TFY_CATEGORY_ADDSUBLAYER(addLayer, TFY_LayerChainModel, CALayer)
TFY_CATEGORY_ADDSUBLAYER(addShaperLayer, TFY_ShaperLayerChainModel, CAShapeLayer)
TFY_CATEGORY_ADDSUBLAYER(addEmiiterLayer, TFY_EmiiterLayerChainModel, CAEmitterLayer)
TFY_CATEGORY_ADDSUBLAYER(addScrollLayer, TFY_ScrollLayerChainModel, CAScrollLayer)
TFY_CATEGORY_ADDSUBLAYER(addTextLayer, TFY_TextLayerChainModel, CATextLayer)
TFY_CATEGORY_ADDSUBLAYER(addTiledLayer, TFY_TiledLayerChainModel, CATiledLayer)
TFY_CATEGORY_ADDSUBLAYER(addTransFormLayer, TFY_TransFormLayerChainModel, CATransformLayer)
TFY_CATEGORY_ADDSUBLAYER(addGradientLayer, TFY_GradientLayerChainModel, CAGradientLayer)
TFY_CATEGORY_ADDSUBLAYER(addReplicatorLayer, TFY_ReplicatorLayerChainModel, CAReplicatorLayer)
@end
#undef TFY_CATEGORY_ADDSUBLAYER
