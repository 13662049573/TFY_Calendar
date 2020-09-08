//
//  TFY_PickerViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_PickerViewChainModel;
@interface TFY_PickerViewChainModel : TFY_BaseViewChainModel<TFY_PickerViewChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_PickerViewChainModel * (^ dataSource) (id<UIPickerViewDataSource>);
TFY_PROPERTY_CHAIN_READONLY TFY_PickerViewChainModel * (^ delegate) (id<UIPickerViewDelegate>);
TFY_PROPERTY_CHAIN_READONLY TFY_PickerViewChainModel * (^ showsSelectionIndicator) (BOOL);
TFY_PROPERTY_CHAIN_READONLY NSInteger (^ numberOfRowsInComponent) (NSInteger);
TFY_PROPERTY_CHAIN_READONLY CGSize (^ rowSizeForComponent) (NSInteger);
TFY_PROPERTY_CHAIN_READONLY UIView * (^ viewForRowComponent) (NSInteger row, NSInteger component);
TFY_PROPERTY_CHAIN_READONLY TFY_PickerViewChainModel * (^ reloadAllComponents) (void);
TFY_PROPERTY_CHAIN_READONLY TFY_PickerViewChainModel * (^ reloadComponent) (NSInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_PickerViewChainModel * (^ selectRowInComponent) (NSInteger row, NSInteger component, BOOL animated);
TFY_PROPERTY_CHAIN_READONLY NSInteger (^ selectedRowInComponent) (NSInteger);

@end
TFY_CATEGORY_EXINTERFACE(UIPickerView, TFY_PickerViewChainModel)

NS_ASSUME_NONNULL_END
