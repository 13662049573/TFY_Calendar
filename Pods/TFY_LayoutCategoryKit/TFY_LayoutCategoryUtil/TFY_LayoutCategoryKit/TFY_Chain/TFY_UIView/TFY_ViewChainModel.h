//
//  TFY_ViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ViewChainModel,UIView;
@interface TFY_ViewChainModel : TFY_BaseViewChainModel<TFY_ViewChainModel *>

@end
TFY_CATEGORY_EXINTERFACE(UIView, TFY_ViewChainModel)
NS_ASSUME_NONNULL_END
