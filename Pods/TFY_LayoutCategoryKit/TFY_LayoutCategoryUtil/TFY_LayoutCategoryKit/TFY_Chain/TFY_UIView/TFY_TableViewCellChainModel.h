//
//  TFY_TableViewCellChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_TableViewCellChainModel;
@interface TFY_TableViewCellChainModel : TFY_BaseViewChainModel<TFY_TableViewCellChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ selectionStyle) (UITableViewCellSelectionStyle);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ accessoryType) (UITableViewCellAccessoryType);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ separatorInset) (UIEdgeInsets);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ editing) (BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ editingWithAnimated) (BOOL, BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ focusStyle)(UITableViewCellFocusStyle) API_AVAILABLE(ios(9.0));
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewCellChainModel * (^ userInteractionEnabledWhileDragging)(BOOL) API_AVAILABLE(ios(11.0));

@end

CG_INLINE UITableViewCell * UITableViewCellCreateWithStyleAndIndentify(UITableViewCellStyle style, NSString *identifier){
    return [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
}

TFY_CATEGORY_EXINTERFACE(UITableViewCell, TFY_TableViewCellChainModel)

NS_ASSUME_NONNULL_END
