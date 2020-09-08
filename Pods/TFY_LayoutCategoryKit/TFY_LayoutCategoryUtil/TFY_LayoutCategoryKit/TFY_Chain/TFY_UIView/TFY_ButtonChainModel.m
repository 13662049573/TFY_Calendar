//
//  TFY_ButtonChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ButtonChainModel.h"
#define TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ButtonChainModel *,UIButton)

#define TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION(TFY_Method,TFY_ParaType)\
- (TFY_ButtonChainModel * (^)(TFY_ParaType TFY_Method))TFY_Method    \
{   \
    return ^ (TFY_ParaType TFY_Method) {    \
        ((UIButton *)self.view).titleLabel.TFY_Method = TFY_Method;   \
        return self;    \
    };\
}
@implementation TFY_ButtonChainModel

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(contentEdgeInsets, UIEdgeInsets)

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(titleEdgeInsets, UIEdgeInsets)

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(imageEdgeInsets, UIEdgeInsets)

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(adjustsImageWhenHighlighted, BOOL)

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(showsTouchWhenHighlighted, BOOL)

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(adjustsImageWhenDisabled, BOOL)

TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION(reversesTitleShadowWhenHighlighted, BOOL)

TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION(textAlignment, NSTextAlignment)
TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION(numberOfLines, NSInteger)
TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION(lineBreakMode, NSLineBreakMode)
TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION(adjustsFontSizeToFitWidth, BOOL)
TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION(baselineAdjustment, UIBaselineAdjustment)


- (TFY_ButtonChainModel * _Nonnull (^)(UIControlContentHorizontalAlignment))contentHorizontalAlignment{
    return ^ (UIControlContentHorizontalAlignment alignment){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            obj.contentHorizontalAlignment = alignment;
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(UIImage * _Nonnull, UIControlState))image{
    return ^ (UIImage *image, UIControlState state){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            [obj setImage:image forState:state];
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(NSString * _Nonnull, UIControlState))text{
    return ^ (NSString *text, UIControlState state){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            [obj setTitle:text forState:state];
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(UIImage * _Nonnull, UIControlState))backgroundImage{
    return ^ (UIImage *image, UIControlState state){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            [obj setBackgroundImage:image forState:state];
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(NSAttributedString * _Nonnull, UIControlState))attributedTitle{
    return ^ (NSAttributedString *title, UIControlState state){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            [obj setAttributedTitle:title forState:state];
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(UIFont * _Nonnull))font{
    return ^ (UIFont *font){
        
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            obj.titleLabel.font = font;
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(UIColor * _Nonnull, UIControlState))textColor{
    return ^ (UIColor *color, UIControlState state){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            [obj setTitleColor:color forState:state];
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(UIColor * _Nonnull, UIControlState))titleShadow{
    return ^ (UIColor *color, UIControlState state){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
             [(UIButton *)obj setTitleShadowColor:color forState:state];
        }];
        return self;
    };
}

- (TFY_ButtonChainModel * _Nonnull (^)(ButtonImageDirection, CGFloat))imageDirection{
    return ^ (ButtonImageDirection direction, CGFloat space){
        [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
            [obj tfy_imageDirection:direction space:space];
        }];
        return self;
    };
}
- (TFY_ButtonChainModel * _Nonnull (^)(TFY_ButtonImageTitleBlock _Nonnull))imageAndTitle{
    return ^ (TFY_ButtonImageTitleBlock block){
        if (block) {
            [self enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj) {
                block(obj.imageView,obj.titleLabel);
            }];
            
        }
        return self;
    };
}
@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UIButton, TFY_ButtonChainModel)
#undef TFY_CATEGORY_CHAIN_BUTTON_IMPLEMENTATION
#undef TFY_CATEGORY_CHAIN_BUTTONLABEL_IMPLEMENTATION

