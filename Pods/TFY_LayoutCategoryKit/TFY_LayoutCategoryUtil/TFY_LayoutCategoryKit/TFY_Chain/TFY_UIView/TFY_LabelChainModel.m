//
//  TFY_LabelChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_LabelChainModel.h"
#import "UILabel+TFY_Tools.h"
#define TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_LabelChainModel *,UILabel)
@implementation TFY_LabelChainModel

TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(text, NSString *);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(font, UIFont *);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(textColor, UIColor *);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(attributedText, NSAttributedString *);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(textAlignment, NSTextAlignment);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(numberOfLines, NSInteger);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(lineBreakMode, NSLineBreakMode);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(adjustsFontSizeToFitWidth, BOOL);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(baselineAdjustment, UIBaselineAdjustment);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(allowsDefaultTighteningForTruncation, BOOL);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(preferredMaxLayoutWidth, CGFloat);
TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION(minimumScaleFactor, CGFloat);

- (CGSize (^)(CGSize))sizeWithLimitSize{
    return ^ (CGSize size){
        return [(UILabel *)self.view tfy_sizeWithLimitSize:size];
    };
}

- (CGSize (^)(void))sizeWithOutLimitSize{
    return ^ (){
        return [(UILabel *)self.view tfy_sizeWithoutLimitSize];
    };
}

- (TFY_LabelChainModel * _Nonnull (^)(UIEdgeInsets))contentInsets{
    return ^(UIEdgeInsets contentInsets){
        [self enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj) {
            obj.tfy_contentInsets = contentInsets;
        }];
        return self;
    };
}
/**行间距 必须在文本输入之后赋值*/
- (TFY_LabelChainModel * _Nonnull (^)(CGFloat))lineSpace{
    return ^(CGFloat lineSpace){
        [self enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj) {
            obj.tfy_lineSpace = lineSpace;
        }];
        return self;
    };
}
/**字体间距 必须在文本输入之后赋值*/
- (TFY_LabelChainModel * _Nonnull (^)(CGFloat))textSpace{
    return ^(CGFloat textSpace){
        [self enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj) {
            obj.tfy_textSpace = textSpace;
        }];
        return self;
    };
}
/**首行缩进 必须在文本输入之后赋值*/
- (TFY_LabelChainModel * _Nonnull (^)(CGFloat))firstLineHeadIndent{
    return ^(CGFloat firstLineHeadIndent){
        [self enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj) {
            obj.tfy_firstLineHeadIndent = firstLineHeadIndent;
        }];
        return self;
    };
}

@end

TFY_CATEGORY_VIEW_IMPLEMENTATION(UILabel, TFY_LabelChainModel)
#undef TFY_CATEGORY_CHAIN_LABLE_IMPLEMENTATION
