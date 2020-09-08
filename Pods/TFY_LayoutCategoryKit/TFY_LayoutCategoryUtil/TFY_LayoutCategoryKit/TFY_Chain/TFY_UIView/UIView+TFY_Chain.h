//
//  UIView+TFY_Chain.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CALayer+TFY_Chain.h"
#import "TFY_ViewHeader.h"
#import "TFY_GestureChainHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TFY_Chain)
/**生成一个View模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ViewChainModel *(^ addView)(NSInteger);
/**生成一个Lable模型*/
TFY_PROPERTY_STRONG_READONLY TFY_LabelChainModel *(^ addLabel)(NSInteger);
/**生成一个imageView模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ImageViewChainModel *(^ addImageView)(NSInteger);
/**生成一个Control模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ControlChainModel *(^ addControl)(NSInteger);
/**生成一个TextField模型*/
TFY_PROPERTY_STRONG_READONLY TFY_TextFieldChainModel *(^ addTextField)(NSInteger);
/**生成一个Button模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ButtonChainModel *(^ addButton)(NSInteger);
/**生成一个Switch模型*/
TFY_PROPERTY_STRONG_READONLY TFY_SwitchChainModel *(^ addSwitch)(NSInteger);
/**生成一个ScrollView模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ScrollViewChainModel *(^ addScrollView)(NSInteger);
/**生成一个TextView模型*/
TFY_PROPERTY_STRONG_READONLY TFY_TextViewChainModel *(^ addTextView)(NSInteger);
/**生成一个TableView模型*/
TFY_PROPERTY_STRONG_READONLY TFY_TableViewChainModel *(^ addTableView)(NSInteger);
/**生成一个CollectionView模型*/
TFY_PROPERTY_STRONG_READONLY TFY_CollectionViewChainModel *(^ addCollectionView)(NSInteger);
/**生成一个Layer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_LayerChainModel *(^ addLayer)(void);
/**生成一个ShaperLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ShaperLayerChainModel *(^ addShaperLayer)(void);
/**生成一个EmiiterLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_EmiiterLayerChainModel *(^ addEmiiterLayer)(void);
/**生成一个ScrollLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ScrollLayerChainModel *(^ addScrollLayer)(void);
/**生成一个TextLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_TextLayerChainModel *(^ addTextLayer)(void);
/**生成一个TiledLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_TiledLayerChainModel *(^ addTiledLayer)(void);
/**生成一个TransFormLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_TransFormLayerChainModel *(^ addTransFormLayer)(void);
/**生成一个GradientLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_GradientLayerChainModel *(^ addGradientLayer)(void);
/**生成一个ReplicatorLayer模型*/
TFY_PROPERTY_STRONG_READONLY TFY_ReplicatorLayerChainModel *(^ addReplicatorLayer)(void);
@end

NS_ASSUME_NONNULL_END
