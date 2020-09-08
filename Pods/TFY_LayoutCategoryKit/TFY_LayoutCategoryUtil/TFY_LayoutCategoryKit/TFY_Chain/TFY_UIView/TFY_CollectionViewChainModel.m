//
//  TFY_CollectionViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_CollectionViewChainModel.h"
#define TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_CollectionViewChainModel *,UICollectionView)
@implementation TFY_CollectionViewChainModel

TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION(collectionViewLayout, UICollectionViewLayout *)
TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION(delegate, id<UICollectionViewDelegate>)
TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION(dataSource, id<UICollectionViewDataSource>)

TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION(allowsSelection, BOOL)
TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION(allowsMultipleSelection, BOOL)

- (TFY_CollectionViewChainModel * _Nonnull (^)(void))adJustedContentIOS11{
    return ^ (){
        if (@available(iOS 11.0, *)) {
            [self enumerateObjectsUsingBlock:^(UICollectionView * _Nonnull obj) {
                [obj setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
            }];
        }
        return self;
    };
}

- (TFY_CollectionViewChainModel * _Nonnull (^)(UINib * _Nonnull, NSString * _Nonnull))registerCellNib{
    return ^ (UINib *nib, NSString *identifier){
        [self enumerateObjectsUsingBlock:^(UICollectionView * _Nonnull obj) {
            [obj registerNib:nib forCellWithReuseIdentifier:identifier];
        }];
        return self;
    };
}

- (TFY_CollectionViewChainModel * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull))registerCellClass{
    return ^ (Class class, NSString *identifier){
        [self enumerateObjectsUsingBlock:^(UICollectionView * _Nonnull obj) {
            [obj registerClass:class forCellWithReuseIdentifier:identifier];
        }];
        return self;
    };
}

- (TFY_CollectionViewChainModel * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, NSString * _Nonnull))registerViewClass{
    return ^ (Class class, NSString *identifier, NSString *kind){
        [(UICollectionView *)self.view registerClass:class forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
        return self;
    };
}
- (TFY_CollectionViewChainModel * _Nonnull (^)(UINib * _Nonnull, NSString * _Nonnull, NSString * _Nonnull))registerViewNib{
    return ^ (UINib * nib, NSString *identifier, NSString *kind){
        [(UICollectionView *)self.view registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
        return self;
    };
}

- (TFY_CollectionViewChainModel * _Nonnull (^)(void))reloadData{
    return ^ (){
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [(UICollectionView *)self.view reloadData];
        [CATransaction commit];
        return self;
    };
}

@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UICollectionView, TFY_CollectionViewChainModel)
#undef TFY_CATEGORY_CHAIN_COLLECTIONVIEW_IMPLEMENTATION
