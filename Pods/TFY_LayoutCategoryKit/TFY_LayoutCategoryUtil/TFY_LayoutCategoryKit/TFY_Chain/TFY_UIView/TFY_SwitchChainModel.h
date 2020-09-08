//
//  TFY_SwitchChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_SwitchChainModel;
@interface TFY_SwitchChainModel : TFY_BaseControlChainModel<TFY_SwitchChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_SwitchChainModel *(^ on)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_SwitchChainModel *(^ onTintColor)(UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_SwitchChainModel *(^ thumbTintColor)(UIColor *);

TFY_PROPERTY_CHAIN_READONLY TFY_SwitchChainModel *(^ onImage)(UIImage *);
TFY_PROPERTY_CHAIN_READONLY TFY_SwitchChainModel *(^ offImage)(UIImage *);

@end

TFY_CATEGORY_EXINTERFACE(UISwitch, TFY_SwitchChainModel)

NS_ASSUME_NONNULL_END
