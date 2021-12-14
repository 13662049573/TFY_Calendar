//
//  TFY_TableViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TableViewChainModel.h"
#import "UIScrollView+TFY_Tools.h"
#define TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TableViewChainModel *,UITableView)
@implementation TFY_TableViewChainModel

TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(delegate, id<UITableViewDelegate>)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(dataSource, id<UITableViewDataSource>)
- (TFY_TableViewChainModel * _Nonnull (^)(void))adJustedContentIOS11{
    return ^ (){
        if (@available(iOS 11.0, *)) {
            [self enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj) {
                [obj tfy_adJustedContentIOS11];
            }];
        }
        return self;
    };
}

TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(rowHeight, CGFloat)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionHeaderHeight, CGFloat)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionFooterHeight, CGFloat)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(estimatedRowHeight, CGFloat)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(estimatedSectionHeaderHeight, CGFloat)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(estimatedSectionFooterHeight, CGFloat)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(separatorInset, UIEdgeInsets)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(editing, BOOL)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsSelection, BOOL)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsMultipleSelection, BOOL)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsSelectionDuringEditing, BOOL)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsMultipleSelectionDuringEditing, BOOL)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(separatorStyle, UITableViewCellSeparatorStyle)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(separatorColor, UIColor *)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(tableHeaderView, UIView *)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(tableFooterView, UIView *)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionIndexBackgroundColor, UIColor *)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionIndexColor, UIColor *)
TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionHeaderTopPadding,CGFloat);

- (TFY_TableViewChainModel * _Nonnull (^)(UINib * _Nonnull, NSString * _Nonnull))registerCellNib{
    return ^ (UINib *nib, NSString *identifier){
        [self enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj) {
            [obj registerNib:nib forCellReuseIdentifier:identifier];
        }];
        return self;
    };
}

- (TFY_TableViewChainModel * _Nonnull (^)(UINib * _Nonnull, NSString * _Nonnull))registerViewNib{
    return ^ (UINib *nib, NSString *identifier){
        [self enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj) {
            [obj registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
        }];
        
        return self;
    };
}

- (TFY_TableViewChainModel * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull))registerCellClass{
    return ^ (Class class, NSString *identifier){
        [self enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj) {
            [obj registerClass:class forCellReuseIdentifier:identifier];
        }];
        return self;
    };
}

- (TFY_TableViewChainModel * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull))registerViewClass{
    return ^ (Class class, NSString *identifier){
        
        [self enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj) {
            [obj registerClass:class forHeaderFooterViewReuseIdentifier:identifier];
        }];
        return self;
    };
}

@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UITableView, TFY_TableViewChainModel)
#undef TFY_CATEGORY_CHAIN_TABLEVIEW_IMPLEMENTATION

