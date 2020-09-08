//
//  TFY_ControlChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_ControlChainModel;
@interface TFY_ControlChainModel : TFY_BaseControlChainModel<TFY_ControlChainModel*>

@end
TFY_CATEGORY_EXINTERFACE(UIControl, TFY_ControlChainModel)
NS_ASSUME_NONNULL_END
