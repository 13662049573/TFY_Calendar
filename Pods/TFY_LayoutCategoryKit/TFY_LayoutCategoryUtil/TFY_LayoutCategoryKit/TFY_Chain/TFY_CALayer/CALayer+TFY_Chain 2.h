//
//  CALayer+TFY_Chain.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TFY_LayerChainHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (TFY_Chain)
TFY_PROPERTY_STRONG_READONLY TFY_LayerChainModel *(^ addLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_ShaperLayerChainModel *(^ addShaperLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_EmiiterLayerChainModel *(^ addEmiiterLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_ScrollLayerChainModel *(^ addScrollLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_TextLayerChainModel *(^ addTextLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_TiledLayerChainModel *(^ addTiledLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_TransFormLayerChainModel *(^ addTransFormLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_GradientLayerChainModel *(^ addGradientLayer)(void);

TFY_PROPERTY_STRONG_READONLY TFY_ReplicatorLayerChainModel *(^ addReplicatorLayer)(void);
@end

NS_ASSUME_NONNULL_END
