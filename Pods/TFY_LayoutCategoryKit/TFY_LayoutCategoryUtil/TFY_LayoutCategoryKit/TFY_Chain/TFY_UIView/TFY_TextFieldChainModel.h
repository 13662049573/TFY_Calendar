//
//  TFY_TextFieldChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_TextFieldChainModel;
@interface TFY_TextFieldChainModel : TFY_BaseControlChainModel<TFY_TextFieldChainModel*>

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ text)(NSString *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ attributedText)(NSAttributedString *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ font)(UIFont *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ textColor)(UIColor *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ textAlignment)(NSTextAlignment);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ borderStyle)(UITextBorderStyle);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ defaultTextAttributes)(NSDictionary *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ placeholder)(NSString *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ attributedPlaceholder)(NSAttributedString *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ clearsOnBeginEditing)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ adjustsFontSizeToFitWidth)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ minimumFontSize)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ delegate)(id<UITextFieldDelegate>);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ background)(UIImage *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ disabledBackground)(UIImage *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ allowsEditingTextAttributes)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ typingAttributes)(NSDictionary *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ clearButtonMode)(UITextFieldViewMode);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ leftView)(UIView *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ leftViewMode)(UITextFieldViewMode);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ rightView)(UIView *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ rightViewMode)(UITextFieldViewMode);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ limitLength) (NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ inputView)(UIView *);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ inputAccessoryView)(UIView *);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ placeholderColor)(UIColor *);

#pragma mark - UITextInputTraits -
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ autocapitalizationType)(UITextAutocapitalizationType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ autocorrectionType)(UITextAutocorrectionType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ spellCheckingType)(UITextSpellCheckingType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ keyboardType)(UIKeyboardType);

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ keyboardAppearance)(UIKeyboardAppearance);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ returnKeyType)(UIReturnKeyType);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ enablesReturnKeyAutomatically)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ secureTextEntry)(BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ textContentType)(UITextContentType) API_AVAILABLE(ios(10.0));

TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ contentInsets)(UIEdgeInsets);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ lineSpace)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ textSpace)(CGFloat);
TFY_PROPERTY_CHAIN_READONLY TFY_TextFieldChainModel *(^ firstLineHeadIndent)(CGFloat);
@end

TFY_CATEGORY_EXINTERFACE(UITextField, TFY_TextFieldChainModel)

NS_ASSUME_NONNULL_END
