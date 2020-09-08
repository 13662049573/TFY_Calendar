//
//  TFY_CollectionViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseScrollViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_CollectionViewChainModel;
@interface TFY_CollectionViewChainModel : TFY_BaseScrollViewChainModel<TFY_CollectionViewChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ collectionViewLayout)(UICollectionViewLayout *);
TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ delegate)(id<UICollectionViewDelegate>);
TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ dataSource)(id<UICollectionViewDataSource>);
TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ allowsSelection)(BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ allowsMultipleSelection)(BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ registerCellClass)(Class cellClass, NSString *identifier);

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ registerCellNib)(UINib * nib, NSString *identifier);

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ registerViewClass)(Class viewClass, NSString *identifier, NSString *kind);

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel *(^ registerViewNib)(UINib * viewNib, NSString *identifier, NSString *kind);

TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel * (^ adJustedContentIOS11)(void);
TFY_PROPERTY_CHAIN_READONLY TFY_CollectionViewChainModel * (^ reloadData)(void);
@end

CG_INLINE UICollectionView *UICollectionViewCreateWithLayout(UICollectionViewFlowLayout *layout){
    return [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
}
TFY_CATEGORY_EXINTERFACE_(UICollectionView, TFY_CollectionViewChainModel)

NS_ASSUME_NONNULL_END
