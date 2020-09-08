//
//  TFY_ButtonChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"
#import "UIButton+TFY_Tools.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TFY_ButtonImageTitleBlock)(UIImageView *imageView, UILabel *title);
@class TFY_ButtonChainModel;
@interface TFY_ButtonChainModel : TFY_BaseControlChainModel<TFY_ButtonChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ contentEdgeInsets)(UIEdgeInsets);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ titleEdgeInsets)(UIEdgeInsets);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ imageEdgeInsets)(UIEdgeInsets);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ adjustsImageWhenHighlighted) (BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ showsTouchWhenHighlighted) (BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ adjustsImageWhenDisabled) (BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ reversesTitleShadowWhenHighlighted) (BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ image) (UIImage *, UIControlState);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ text) (NSString *, UIControlState);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ textColor) (UIColor *, UIControlState);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel * (^ backgroundImage) (UIImage *, UIControlState);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ attributedTitle) (NSAttributedString *, UIControlState);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ titleShadow) (UIColor *, UIControlState);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ font) (UIFont *);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ textAlignment)(NSTextAlignment);
TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ numberOfLines)(NSInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ lineBreakMode)(NSLineBreakMode);
TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ adjustsFontSizeToFitWidth)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ baselineAdjustment)(UIBaselineAdjustment);
TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ contentHorizontalAlignment)(UIControlContentHorizontalAlignment);


TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel * (^ imageDirection) (ButtonImageDirection, CGFloat);

TFY_PROPERTY_CHAIN_READONLY TFY_ButtonChainModel *(^ imageAndTitle)(TFY_ButtonImageTitleBlock);
@end


CG_INLINE UIButton *UIButtonCreateWithType(UIButtonType buttonType){
    return [UIButton buttonWithType:buttonType];
}
TFY_CATEGORY_EXINTERFACE(UIButton, TFY_ButtonChainModel)

NS_ASSUME_NONNULL_END
