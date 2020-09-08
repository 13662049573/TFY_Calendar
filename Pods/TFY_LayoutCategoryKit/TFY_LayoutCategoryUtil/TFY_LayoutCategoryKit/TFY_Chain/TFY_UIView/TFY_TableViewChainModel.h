//
//  TFY_TableViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseScrollViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_TableViewChainModel;
@interface TFY_TableViewChainModel : TFY_BaseScrollViewChainModel<TFY_TableViewChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel * (^ delegate) (id <UITableViewDelegate>);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel * (^ dataSource) (id <UITableViewDataSource>);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel * (^ adJustedContentIOS11)(void);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ rowHeight)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ sectionHeaderHeight)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ sectionFooterHeight)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ estimatedRowHeight)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ estimatedSectionHeaderHeight)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ estimatedSectionFooterHeight)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ separatorInset)(UIEdgeInsets);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ editing)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ allowsSelection)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ allowsMultipleSelection)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ allowsSelectionDuringEditing)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ allowsMultipleSelectionDuringEditing)(BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ separatorStyle)(UITableViewCellSeparatorStyle);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ separatorColor)(UIColor *);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ tableHeaderView)(UIView *);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ tableFooterView)(UIView *);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ sectionIndexBackgroundColor)(UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ sectionIndexColor)(UIColor *);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ registerCellClass)(Class cellClass, NSString *identifier);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ registerCellNib)(UINib * nib, NSString *identifier);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ registerViewClass)(Class viewClass, NSString *identifier);

TFY_PROPERTY_CHAIN_READONLY TFY_TableViewChainModel *(^ registerViewNib)(UINib * viewNib, NSString *identifier);

@end

CG_INLINE UITableView * UITableViewCreateWithStyle(UITableViewStyle style){
    return [[UITableView alloc]initWithFrame:CGRectZero style:style];
}
TFY_CATEGORY_EXINTERFACE(UITableView, TFY_TableViewChainModel)

NS_ASSUME_NONNULL_END
