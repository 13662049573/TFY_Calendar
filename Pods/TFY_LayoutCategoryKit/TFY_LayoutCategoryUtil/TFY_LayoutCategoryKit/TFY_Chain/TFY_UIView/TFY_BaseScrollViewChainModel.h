//
//  TFY_BaseScrollViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BaseScrollViewChainModel<__covariant ObjectType> : TFY_BaseViewChainModel<ObjectType>
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentSize) (CGSize);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentOffset) (CGPoint);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentInset) (UIEdgeInsets);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ bounces) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ alwaysBounceVertical) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ alwaysBounceHorizontal) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ pagingEnabled) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ scrollEnabled) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ showsHorizontalScrollIndicator) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ showsVerticalScrollIndicator) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ scrollsToTop) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ indicatorStyle) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ scrollIndicatorInsets) (UIEdgeInsets);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ directionalLockEnabled) (BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ minimumZoomScale) (CGFloat);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ maximumZoomScale) (CGFloat);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ zoomScale) (CGFloat);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentOffsetAnimated)(CGPoint, BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentOffsetToVisible)(CGRect, BOOL);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ delegate) (id <UIScrollViewDelegate>);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ adJustedContentIOS11)(void);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ automaticallyAdjustsScrollIndicatorInsets) (BOOL) API_AVAILABLE(ios(13.0));
@end

NS_ASSUME_NONNULL_END
