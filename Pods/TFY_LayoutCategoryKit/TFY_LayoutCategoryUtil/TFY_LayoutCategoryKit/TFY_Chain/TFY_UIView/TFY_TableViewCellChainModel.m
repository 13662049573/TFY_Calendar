//
//  TFY_TableViewCellChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TableViewCellChainModel.h"
#define TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TableViewCellChainModel *,UITableViewCell)
@implementation TFY_TableViewCellChainModel

TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(selectionStyle, UITableViewCellSelectionStyle)
TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(accessoryType, UITableViewCellAccessoryType)
TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(separatorInset, UIEdgeInsets)
TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(editing, BOOL)
TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(focusStyle, UITableViewCellFocusStyle)
TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(userInteractionEnabledWhileDragging, BOOL)

- (TFY_TableViewCellChainModel * _Nonnull (^)(BOOL, BOOL))editingWithAnimated{
    return ^ (BOOL editing, BOOL animated){
        [self enumerateObjectsUsingBlock:^(UITableViewCell * _Nonnull obj) {
            [obj setEditing:editing animated:animated];
        }];
        return self;
    };
}
@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UITableViewCell, TFY_TableViewCellChainModel)
#undef TFY_CATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION
