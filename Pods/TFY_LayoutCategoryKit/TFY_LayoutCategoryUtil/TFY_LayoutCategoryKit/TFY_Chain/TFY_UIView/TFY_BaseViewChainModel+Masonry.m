//
//  TFY_BaseViewChainModel+Masonry.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel+Masonry.h"

#define   TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION(methodName, masonryMethod) \
- (id (^)( void (^constraints)(MASConstraintMaker *)) )methodName    \
{   \
     return ^id ( void (^constraints)(MASConstraintMaker *) ) {  \
     [self enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj) {\
     if (obj.superview) { \
     [obj masonryMethod:constraints];\
    }\
  }];\
  return self;\
};  \
}
#define     TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION_NULL(methodName, masonryMethod) \
- (id (^)( void (^constraints)(MASConstraintMaker *)) )methodName    \
{   \
return ^id ( void (^constraints)(MASConstraintMaker *) ) {  \
return self;    \
};  \
}
@implementation TFY_BaseViewChainModel (Masonry)

#if __has_include(<Masonry.h>) || __has_include("Masonry.h")

TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION(makeMasonry, mas_makeConstraints);
TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION(updateMasonry, mas_updateConstraints);
TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION(remakeMasonry, mas_remakeConstraints);

#else

TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION_NULL(makeMasonry, mas_makeConstraints);
TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION_NULL(updateMasonry, mas_updateConstraints);
TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION_NULL(remakeMasonry, mas_remakeConstraints);

#endif

@end
#undef TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION
#undef TFY_CATEGORY_CHAIN_MASONRY_IMPLEMENTATION_NULL
