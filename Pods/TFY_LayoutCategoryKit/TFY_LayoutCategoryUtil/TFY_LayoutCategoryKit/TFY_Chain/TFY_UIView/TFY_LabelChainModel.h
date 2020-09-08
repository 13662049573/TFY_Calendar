//
//  TFY_LabelChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseViewChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_LabelChainModel;
@interface TFY_LabelChainModel : TFY_BaseViewChainModel<TFY_LabelChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ text)(NSString *);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ font)(UIFont *);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ textColor)(UIColor *);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ attributedText)(NSAttributedString *);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ textAlignment)(NSTextAlignment);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ numberOfLines)(NSInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ lineBreakMode)(NSLineBreakMode);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ adjustsFontSizeToFitWidth)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ baselineAdjustment)(UIBaselineAdjustment);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ allowsDefaultTighteningForTruncation)(BOOL) API_AVAILABLE(ios(9.0));
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ minimumScaleFactor)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ preferredMaxLayoutWidth)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ contentInsets)(UIEdgeInsets);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ lineSpace)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ textSpace)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_LabelChainModel *(^ firstLineHeadIndent)(CGFloat);


TFY_PROPERTY_CHAIN_READONLY CGSize (^ sizeWithLimitSize) (CGSize);

TFY_PROPERTY_CHAIN_READONLY CGSize (^ sizeWithOutLimitSize) (void);

@end

TFY_CATEGORY_EXINTERFACE(UILabel, TFY_LabelChainModel)

NS_ASSUME_NONNULL_END
