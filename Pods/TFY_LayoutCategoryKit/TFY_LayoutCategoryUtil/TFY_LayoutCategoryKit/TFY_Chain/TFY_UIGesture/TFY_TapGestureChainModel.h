//
//  TFY_TapGestureChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseGestureChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_TapGestureChainModel;
@interface TFY_TapGestureChainModel : TFY_BaseGestureChainModel<TFY_TapGestureChainModel *>
TFY_PROPERTY_CHAIN_READONLY TFY_TapGestureChainModel * (^ numberOfTapsRequired) (NSUInteger numberOfTapsRequired);
@end

TFY_CATEGORY_EXINTERFACE(UITapGestureRecognizer, TFY_TapGestureChainModel)

CG_INLINE UITapGestureRecognizer *_Nonnull UITapGestureRecognizerCreateWithTarget(void (^ targetBlock) (id ges)){
    return UITapGestureRecognizerSet().makeChain.addTargetBlock(targetBlock).gesture;
}

NS_ASSUME_NONNULL_END
