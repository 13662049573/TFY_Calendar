//
//  TFY_SliderViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_SliderViewChainModel.h"

#define TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_SliderViewChainModel *,UISlider)

#define TFY_CATEGORY_CHAIN_SLIDER_METHOND_IMPLEMENTATION(MehodName)\
- (TFY_SliderViewChainModel * _Nonnull (^)(UIImage * _Nonnull, UIControlState))MehodName{\
return ^ (UIImage *image, UIControlState state){\
    [(UISlider *)self.view MehodName:image forState:state];\
    return self;\
};\
}

TFY_CATEGORY_VIEW_IMPLEMENTATION(UISlider, TFY_SliderViewChainModel)
@implementation TFY_SliderViewChainModel

TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(value ,float);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(minimumValue ,float);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(maximumValue ,float);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(minimumValueImage ,UIImage *);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(maximumValueImage, UIImage *);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(continuous, BOOL);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(minimumTrackTintColor, UIColor *);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(maximumTrackTintColor ,UIColor *);
TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION(thumbTintColor ,UIColor *);

- (TFY_SliderViewChainModel * _Nonnull (^)(float, BOOL))setValueAnimated{
    return ^ (float v, BOOL a){
        [self enumerateObjectsUsingBlock:^(UISlider * _Nonnull obj) {
            [obj setValue:v animated:a];
        }];
        return self;
    };
}



TFY_CATEGORY_CHAIN_SLIDER_METHOND_IMPLEMENTATION(setThumbImage)
TFY_CATEGORY_CHAIN_SLIDER_METHOND_IMPLEMENTATION(setMinimumTrackImage);
TFY_CATEGORY_CHAIN_SLIDER_METHOND_IMPLEMENTATION(setMaximumTrackImage);

@end
#undef TFY_CATEGORY_CHAIN_SLIDER_IMPLEMENTATION
#undef TFY_CATEGORY_CHAIN_SLIDER_METHOND_IMPLEMENTATION

