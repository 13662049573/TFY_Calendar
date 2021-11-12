//
//  TFY_BaseScrollViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseScrollViewChainModel.h"
#import "UIScrollView+TFY_Tools.h"
#define TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType,  id ,UIScrollView)
@implementation TFY_BaseScrollViewChainModel
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(delegate, id<UIScrollViewDelegate>)

- (id _Nonnull (^)(void))adJustedContentIOS11{
    return ^ (){
        if (@available(iOS 11.0, *)) {
            [self enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj) {
                [obj tfy_adJustedContentIOS11];
            }];
        }
        return self;
    };
}

TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(contentSize, CGSize)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(contentOffset, CGPoint)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(contentInset, UIEdgeInsets)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(bounces, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(alwaysBounceVertical, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(alwaysBounceHorizontal, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(pagingEnabled, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(scrollEnabled, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(showsHorizontalScrollIndicator, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(showsVerticalScrollIndicator, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(scrollsToTop, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(indicatorStyle, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(scrollIndicatorInsets, UIEdgeInsets)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(directionalLockEnabled, BOOL)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(minimumZoomScale, CGFloat)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(zoomScale, CGFloat)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(maximumZoomScale, CGFloat)
TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION(automaticallyAdjustsScrollIndicatorInsets, BOOL);

- (id  _Nonnull (^)(CGPoint, BOOL))contentOffsetAnimated{
    return ^ (CGPoint point, BOOL animated){
        [self enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj) {
            [obj setContentOffset:point animated:animated];
        }];
        return self;
    };
}

- (id  _Nonnull (^)(CGRect, BOOL))contentOffsetToVisible{
    return ^ (CGRect rect, BOOL animated){
        [self enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj) {
            [obj scrollRectToVisible:rect animated:animated];
        }];
        return self;
    };
}
@end
#undef TFY_CATEGORY_CHAIN_SCROLLVIEW_IMPLEMENTATION
