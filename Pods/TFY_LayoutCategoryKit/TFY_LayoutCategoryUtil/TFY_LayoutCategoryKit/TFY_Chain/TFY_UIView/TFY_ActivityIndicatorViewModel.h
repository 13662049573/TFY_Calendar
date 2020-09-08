//
//  TFY_ActivityIndicatorViewModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ActivityIndicatorViewModel;
@interface TFY_ActivityIndicatorViewModel : TFY_BaseViewChainModel<TFY_ActivityIndicatorViewModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_ActivityIndicatorViewModel * (^ activityIndicatorViewStyle) (UIActivityIndicatorViewStyle activityIndicatorViewStyle);
TFY_PROPERTY_CHAIN_READONLY TFY_ActivityIndicatorViewModel * (^ hidesWhenStopped) (BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_ActivityIndicatorViewModel * (^ color) (UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_ActivityIndicatorViewModel * (^ startAnimating) (void);
TFY_PROPERTY_CHAIN_READONLY TFY_ActivityIndicatorViewModel * (^ stopAnimating) (void);
@end

TFY_CATEGORY_EXINTERFACE(UIActivityIndicatorView, TFY_ActivityIndicatorViewModel)

NS_ASSUME_NONNULL_END
