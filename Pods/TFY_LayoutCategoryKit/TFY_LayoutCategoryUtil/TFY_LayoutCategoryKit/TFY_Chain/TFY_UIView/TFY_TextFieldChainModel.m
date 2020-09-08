//
//  TFY_TextFieldChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TextFieldChainModel.h"
#import "UITextField+TFY_Tools.h"
#define TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TextFieldChainModel *,UITextField)
@implementation TFY_TextFieldChainModel

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(text, NSString *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(attributedText, NSAttributedString *);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(font, UIFont *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(textColor, UIColor *);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(textAlignment, NSTextAlignment);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(borderStyle, UITextBorderStyle);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(defaultTextAttributes, NSDictionary *);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(placeholder, NSString *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(attributedPlaceholder, NSAttributedString *);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(keyboardType, UIKeyboardType);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(clearsOnBeginEditing, BOOL);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(adjustsFontSizeToFitWidth, BOOL);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(minimumFontSize, CGFloat);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(delegate, id<UITextFieldDelegate>);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(background, UIImage *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(disabledBackground, UIImage *);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(allowsEditingTextAttributes, BOOL);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(typingAttributes, NSDictionary *);

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(clearButtonMode, UITextFieldViewMode);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(leftView, UIView *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(leftViewMode, UITextFieldViewMode);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(rightView, UIView *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(rightViewMode, UITextFieldViewMode);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(limitLength, NSUInteger);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(inputView, UIView *);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(inputAccessoryView, UIView *);

#pragma mark - UITextInputTraits -
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(autocapitalizationType, UITextAutocapitalizationType);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(autocorrectionType, UITextAutocorrectionType)
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(spellCheckingType, UITextSpellCheckingType)

TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(keyboardAppearance, UIKeyboardAppearance);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(returnKeyType, UIReturnKeyType);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(enablesReturnKeyAutomatically, BOOL);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(secureTextEntry, BOOL);
TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION(textContentType, UITextContentType);


- (TFY_TextFieldChainModel * _Nonnull (^)(UIColor * _Nonnull))placeholderColor{
    return ^(UIColor *color){
        [self enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj) {
            obj.attributedPlaceholder = [[NSAttributedString alloc] initWithString:obj.placeholder attributes:@{NSForegroundColorAttributeName: color ,NSFontAttributeName:obj.font}];
        }];
        return self;
    };
}

- (TFY_TextFieldChainModel * _Nonnull (^)(UIEdgeInsets))contentInsets{
    return ^(UIEdgeInsets contentInsets){
        [self enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj) {
            obj.tfy_contentInsets = contentInsets;
        }];
        return self;
    };
}
/**行间距 必须在文本输入之后赋值*/
- (TFY_TextFieldChainModel * _Nonnull (^)(CGFloat))lineSpace{
    return ^(CGFloat lineSpace){
        [self enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj) {
            obj.tfy_lineSpace = lineSpace;
        }];
        return self;
    };
}
/**字体间距 必须在文本输入之后赋值*/
- (TFY_TextFieldChainModel * _Nonnull (^)(CGFloat))textSpace{
    return ^(CGFloat textSpace){
        [self enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj) {
            obj.tfy_textSpace = textSpace;
        }];
        return self;
    };
}
/**首行缩进 必须在文本输入之后赋值*/
- (TFY_TextFieldChainModel * _Nonnull (^)(CGFloat))firstLineHeadIndent{
    return ^(CGFloat firstLineHeadIndent){
        [self enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj) {
            obj.tfy_firstLineHeadIndent = firstLineHeadIndent;
        }];
        return self;
    };
}
@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UITextField, TFY_TextFieldChainModel)
#undef TFY_CATEGORY_CHAIN_TEXTFIELD_IMPLEMENTATION

