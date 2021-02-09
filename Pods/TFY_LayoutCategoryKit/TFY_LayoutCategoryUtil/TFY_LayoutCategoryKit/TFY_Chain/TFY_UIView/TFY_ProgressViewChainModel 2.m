//
//  TFY_ProgressViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ProgressViewChainModel.h"
#define TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ProgressViewChainModel *,UIProgressView)
TFY_CATEGORY_VIEW_IMPLEMENTATION(UIProgressView, TFY_ProgressViewChainModel)
@implementation TFY_ProgressViewChainModel

TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(progressViewStyle, UIProgressViewStyle)
TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(progress, float)
TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(progressTintColor, UIColor*)
TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(trackTintColor, UIColor*)
TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(progressImage, UIImage*)
TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(trackImage, UIImage*)
TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION(observedProgress, NSProgress *)

- (TFY_ProgressViewChainModel * _Nonnull (^)(float, BOOL))setProgressAnimated{
    return ^ (float p, BOOL a){
        [self enumerateObjectsUsingBlock:^(UIProgressView * _Nonnull obj) {
            [obj setProgress:p animated:a];
        }];
        return self;
    };
}

@end
#undef TFY_CATEGORY_CHAIN_PROGRESS_IMPLEMENTATION
