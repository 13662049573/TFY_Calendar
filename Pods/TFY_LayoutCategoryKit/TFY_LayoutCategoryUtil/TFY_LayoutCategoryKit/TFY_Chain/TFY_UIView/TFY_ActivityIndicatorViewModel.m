//
//  TFY_ActivityIndicatorViewModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ActivityIndicatorViewModel.h"
#define TFY_CATEGORY_CHAIN_ACTIVITY_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ActivityIndicatorViewModel *,UIActivityIndicatorView)
@implementation TFY_ActivityIndicatorViewModel

TFY_CATEGORY_CHAIN_ACTIVITY_IMPLEMENTATION(activityIndicatorViewStyle,UIActivityIndicatorViewStyle)
TFY_CATEGORY_CHAIN_ACTIVITY_IMPLEMENTATION(hidesWhenStopped,BOOL)
TFY_CATEGORY_CHAIN_ACTIVITY_IMPLEMENTATION(color,UIColor *)

- (TFY_ActivityIndicatorViewModel * _Nonnull (^)(void))startAnimating{
    return ^()
    {
        [self enumerateObjectsUsingBlock:^(UIActivityIndicatorView * _Nonnull obj) {
            [obj startAnimating];
        }];
        return self;
    };
}


- (TFY_ActivityIndicatorViewModel * _Nonnull (^)(void))stopAnimating{
    return ^()
    {
        [self enumerateObjectsUsingBlock:^(UIActivityIndicatorView * _Nonnull obj) {
            [obj stopAnimating];
        }];
        return self;
    };
}
@end

TFY_CATEGORY_VIEW_IMPLEMENTATION(UIActivityIndicatorView, TFY_ActivityIndicatorViewModel)
#undef TFY_CATEGORY_CHAIN_ACTIVITY_IMPLEMENTATION
