//
//  TFY_BaseViewChainModel+Masonry.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"
#if __has_include(<Masonry.h>)
#import <Masonry.h>
#elif __has_include("Masonry.h")
#import "Masonry.h"
#endif
NS_ASSUME_NONNULL_BEGIN
@class MASConstraintMaker;
typedef void(^TFY_MasonryLoad)(MASConstraintMaker *make);

@interface TFY_BaseViewChainModel<ObjectType> (Masonry)

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ makeMasonry)(TFY_MasonryLoad);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ updateMasonry)(TFY_MasonryLoad);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ remakeMasonry)(TFY_MasonryLoad);
@end

NS_ASSUME_NONNULL_END
