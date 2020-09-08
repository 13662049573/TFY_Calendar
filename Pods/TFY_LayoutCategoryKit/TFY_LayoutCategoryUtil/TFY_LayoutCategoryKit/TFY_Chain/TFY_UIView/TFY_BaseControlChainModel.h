//
//  TFY_BaseControlChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TFY_TargetActionBlock)(__kindof UIControl *sender);
@interface TFY_BaseControlChainModel<__covariant ObjectType> : TFY_BaseViewChainModel<ObjectType>
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ enabled)(BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ selected)(BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ highlighted)(BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentVerticalAlignment)(UIControlContentVerticalAlignment);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentHorizontalAlignment)(UIControlContentHorizontalAlignment);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addTargetBlock)(TFY_TargetActionBlock, UIControlEvents);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ setTargetBlock)(TFY_TargetActionBlock, UIControlEvents);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addTarget)(id, SEL, UIControlEvents);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ setTarget)(id, SEL, UIControlEvents);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeTarget) (id,SEL, UIControlEvents);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeAllTarget)(void);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeAllTargetBlock)(UIControlEvents);
@end

NS_ASSUME_NONNULL_END
