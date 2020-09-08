//
//  TFY_PickerViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_PickerViewChainModel.h"
#define TFY_CATEGORY_CHAIN_PICKER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_PickerViewChainModel *,UIPickerView)
TFY_CATEGORY_VIEW_IMPLEMENTATION(UIPickerView, TFY_PickerViewChainModel)
@implementation TFY_PickerViewChainModel

TFY_CATEGORY_CHAIN_PICKER_IMPLEMENTATION(dataSource, id<UIPickerViewDataSource>)
TFY_CATEGORY_CHAIN_PICKER_IMPLEMENTATION(delegate, id<UIPickerViewDelegate>)
TFY_CATEGORY_CHAIN_PICKER_IMPLEMENTATION(showsSelectionIndicator, BOOL)

- (NSInteger (^)(NSInteger))numberOfRowsInComponent{
    return ^ (NSInteger n){
        return [(UIPickerView *)self.view numberOfRowsInComponent:1];
    };
}

- (TFY_PickerViewChainModel * _Nonnull (^)(void))reloadAllComponents{
    return ^ (){
        [self enumerateObjectsUsingBlock:^(UIPickerView * _Nonnull obj) {
            [obj reloadAllComponents];
        }];
        return self;
    };
}

- (CGSize (^)(NSInteger))rowSizeForComponent{
    return ^ (NSInteger n){
        return [(UIPickerView *)self.view rowSizeForComponent:1];
    };
}

- (TFY_PickerViewChainModel * _Nonnull (^)(NSInteger))reloadComponent{
    return ^ (NSInteger n){
        [self enumerateObjectsUsingBlock:^(UIPickerView * _Nonnull obj) {
            [obj reloadComponent:n];
        }];
        
        return self;
    };
}

- (UIView * _Nonnull (^)(NSInteger, NSInteger))viewForRowComponent{
    return ^ (NSInteger n, NSInteger n1){
        return [(UIPickerView *)self.view viewForRow:n forComponent:n1];
    };
}

- (TFY_PickerViewChainModel * _Nonnull (^)(NSInteger, NSInteger, BOOL))selectRowInComponent{
    return ^ (NSInteger a, NSInteger b, BOOL c){
        [(UIPickerView *)self.view selectRow:a inComponent:b animated:c];
        return self;
    };
}

- (NSInteger (^)(NSInteger))selectedRowInComponent{
    return ^ (NSInteger n){
       return [(UIPickerView *)self.view selectedRowInComponent:1];
    };
}

@end
#undef TFY_CATEGORY_CHAIN_PICKER_IMPLEMENTATION

