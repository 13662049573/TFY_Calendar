//
//  TFY_TextViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseScrollViewChainModel.h"

typedef void(^TFY_placeholderLabel)(__kindof UILabel * _Nonnull label);

NS_ASSUME_NONNULL_BEGIN
@class TFY_TextViewChainModel;
@interface TFY_TextViewChainModel : TFY_BaseScrollViewChainModel<TFY_TextViewChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ delegate)(id<UITextViewDelegate>);

TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ text)(NSString *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ font)(UIFont *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ textColor)(UIColor *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ textAlignment)(NSTextAlignment);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ selectedRange)(NSRange);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ editable)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ selectable)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ dataDetectorTypes)(UIDataDetectorTypes);


TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ allowsEditingTextAttributes)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ attributedText)(NSAttributedString *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ typingAttributes)(NSDictionary *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ clearsOnInsertion)(BOOL);

TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ textContainerInset)(UIEdgeInsets);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ linkTextAttributes)(NSDictionary *);
#pragma mark - UITextInputTraits -
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ autocapitalizationType)(UITextAutocapitalizationType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ autocorrectionType)(UITextAutocorrectionType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ spellCheckingType)(UITextSpellCheckingType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ keyboardType)(UIKeyboardType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ keyboardAppearance)(UIKeyboardAppearance);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ returnKeyType)(UIReturnKeyType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ enablesReturnKeyAutomatically)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ secureTextEntry)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ textContentType)(UITextContentType) API_AVAILABLE(ios(10));

TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ limitNum)(NSInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ placeholder)(NSString*);
TFY_PROPERTY_CHAIN_READONLY TFY_TextViewChainModel *(^ placeholderLabel)(TFY_placeholderLabel);

@end

TFY_CATEGORY_EXINTERFACE(UITextView, TFY_TextViewChainModel)

NS_ASSUME_NONNULL_END
