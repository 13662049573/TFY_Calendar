//
//  TFY_ScrollViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseScrollViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ScrollViewChainModel;
@interface TFY_ScrollViewChainModel : TFY_BaseScrollViewChainModel<TFY_ScrollViewChainModel*>

@end
TFY_CATEGORY_EXINTERFACE(UIScrollView, TFY_ScrollViewChainModel)
NS_ASSUME_NONNULL_END
