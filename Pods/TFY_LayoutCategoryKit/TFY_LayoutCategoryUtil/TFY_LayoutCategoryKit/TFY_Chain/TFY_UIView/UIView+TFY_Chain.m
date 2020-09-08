//
//  UIView+TFY_Chain.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIView+TFY_Chain.h"

#define TFY_CATEGORY_ADDVIEW(method, ModelClass, ViewClass)\
- (ModelClass * (^)(NSInteger tag))method    \
{   \
    return ^(NSInteger tag) {      \
        ViewClass *view = [[ViewClass alloc] init];       \
        [self addSubview:view];                            \
        ModelClass *chainModel = [[ModelClass alloc] initWithTag:tag andView:view modelClass:[ViewClass class]]; \
        return chainModel;      \
    };      \
}
#define TFY_CATEGORY_ADDLAYER(method, ModelClass, LayerClass)\
- (ModelClass * _Nonnull (^)(void))method{\
return ^ (){\
    LayerClass *layer = [LayerClass layer];\
    ModelClass *chainModel = [[ModelClass alloc] initWithLayer:layer modelClass:[LayerClass class]];\
    [self.layer addSublayer:layer];\
    return chainModel;\
};\
}


@implementation UIView (TFY_Chain)

TFY_CATEGORY_ADDVIEW(addView, TFY_ViewChainModel, UIView);
TFY_CATEGORY_ADDVIEW(addLabel, TFY_LabelChainModel, UILabel);
TFY_CATEGORY_ADDVIEW(addImageView, TFY_ImageViewChainModel, UIImageView);
TFY_CATEGORY_ADDVIEW(addControl, TFY_ControlChainModel, UIControl);
TFY_CATEGORY_ADDVIEW(addTextField, TFY_TextFieldChainModel, UITextField);
TFY_CATEGORY_ADDVIEW(addButton, TFY_ButtonChainModel, UIButton);
TFY_CATEGORY_ADDVIEW(addSwitch, TFY_SwitchChainModel, UISwitch);
TFY_CATEGORY_ADDVIEW(addScrollView, TFY_ScrollViewChainModel, UIScrollView);
TFY_CATEGORY_ADDVIEW(addTextView, TFY_TextViewChainModel, UITextView);
TFY_CATEGORY_ADDVIEW(addTableView, TFY_TableViewChainModel, UITableView);

- (TFY_CollectionViewChainModel * (^)(NSInteger tag))addCollectionView
{
    return ^(NSInteger tag) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = layout.minimumLineSpacing = 0;
        layout.headerReferenceSize = layout.footerReferenceSize = CGSizeZero;
        layout.sectionInset = UIEdgeInsetsZero;
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self addSubview:view];
        TFY_CollectionViewChainModel *chainModel = [[TFY_CollectionViewChainModel alloc] initWithTag:tag andView:view modelClass:[UICollectionView class]];
        return chainModel;
    };
}

TFY_CATEGORY_ADDLAYER(addLayer, TFY_LayerChainModel, CALayer)
TFY_CATEGORY_ADDLAYER(addShaperLayer, TFY_ShaperLayerChainModel, CAShapeLayer)
TFY_CATEGORY_ADDLAYER(addEmiiterLayer, TFY_EmiiterLayerChainModel, CAEmitterLayer)
TFY_CATEGORY_ADDLAYER(addScrollLayer, TFY_ScrollLayerChainModel, CAScrollLayer)
TFY_CATEGORY_ADDLAYER(addTextLayer, TFY_TextLayerChainModel, CATextLayer)
TFY_CATEGORY_ADDLAYER(addTiledLayer, TFY_TiledLayerChainModel, CATiledLayer)
TFY_CATEGORY_ADDLAYER(addTransFormLayer, TFY_TransFormLayerChainModel, CATransformLayer)
TFY_CATEGORY_ADDLAYER(addGradientLayer, TFY_GradientLayerChainModel, CAGradientLayer)
TFY_CATEGORY_ADDLAYER(addReplicatorLayer, TFY_ReplicatorLayerChainModel, CAReplicatorLayer)

@end
#undef TFY_CATEGORY_ADDVIEW
#undef TFY_CATEGORY_ADDLAYER

