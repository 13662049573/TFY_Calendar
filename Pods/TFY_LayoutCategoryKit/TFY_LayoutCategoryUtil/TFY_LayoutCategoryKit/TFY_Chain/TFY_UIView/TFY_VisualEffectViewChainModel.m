//
//  TFY_VisualEffectViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_VisualEffectViewChainModel.h"
#define TFY_CATEGORY_CHAIN_VISUALEFFECT_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_VisualEffectViewChainModel *,UIVisualEffectView)
TFY_CATEGORY_VIEW_IMPLEMENTATION(UIVisualEffectView, TFY_VisualEffectViewChainModel)
@implementation TFY_VisualEffectViewChainModel
TFY_CATEGORY_CHAIN_VISUALEFFECT_IMPLEMENTATION(effect,UIVisualEffect*)
@end
#undef TFY_CATEGORY_CHAIN_VISUALEFFECT_IMPLEMENTATION
