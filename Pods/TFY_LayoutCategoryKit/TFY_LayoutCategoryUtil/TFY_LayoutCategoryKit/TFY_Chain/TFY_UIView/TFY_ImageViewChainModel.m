//
//  TFY_ImageViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ImageViewChainModel.h"
#define TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ImageViewChainModel *,UIImageView)
@implementation TFY_ImageViewChainModel

TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(image, UIImage *);
TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(highlightedImage, UIImage *);
TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(highlighted, BOOL);
TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(animationImages, NSArray<UIImage *> *)
TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(highlightedAnimationImages, NSArray<UIImage *> *)
TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(animationDuration, NSTimeInterval)
TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION(animationRepeatCount, NSInteger)

- (TFY_ImageViewChainModel * _Nonnull (^)(void))startAnimating{
    return ^ (){
        [self enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj) {
            [obj startAnimating];
        }];
        return self;
    };
}

- (TFY_ImageViewChainModel * _Nonnull (^)(void))stopAnimating{
    return ^ (){
        [self enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj) {
            [obj stopAnimating];
        }];
        return self;
    };
}

@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UIImageView, TFY_ImageViewChainModel)
#undef TFY_CATEGORY_CHAIN_IMAGEVIEW_IMPLEMENTATION

