//
//  TFY_TextViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TextViewChainModel.h"
#import "UITextView+TFY_Tools.h"

#define TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_TextViewChainModel *,UITextView)

@implementation TFY_TextViewChainModel

TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(delegate, id<UITextViewDelegate>);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(text, NSString *);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(font, UIFont *);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(textColor, UIColor *);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(textAlignment, NSTextAlignment);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(selectedRange, NSRange);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(editable, BOOL);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(selectable, BOOL);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(dataDetectorTypes, UIDataDetectorTypes);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(keyboardType, UIKeyboardType);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(allowsEditingTextAttributes, BOOL);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(attributedText, NSAttributedString *);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(typingAttributes, NSDictionary *);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(clearsOnInsertion, BOOL);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(textContainerInset, UIEdgeInsets);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(linkTextAttributes, NSDictionary *);
#pragma mark - UITextInputTraits -
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(autocapitalizationType, UITextAutocapitalizationType);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(autocorrectionType, UITextAutocorrectionType)
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(spellCheckingType, UITextSpellCheckingType)

TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(keyboardAppearance, UIKeyboardAppearance);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(returnKeyType, UIReturnKeyType);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(enablesReturnKeyAutomatically, BOOL);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(secureTextEntry, BOOL);
TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION(textContentType, UITextContentType);


- (TFY_TextViewChainModel * _Nonnull (^)(NSInteger))limitNum {
    return ^(NSInteger num){
        [self enumerateObjectsUsingBlock:^(UITextView *textView) {
            textView.tfy_limitNum = num;
        }];
        return self;
    };
}

- (TFY_TextViewChainModel * _Nonnull (^)(NSString * _Nonnull))placeholder {
    return ^(NSString *string){
        [self enumerateObjectsUsingBlock:^(UITextView *textView) {
            textView.tfy_placeholder = string;
        }];
        return self;
    };
}

- (TFY_TextViewChainModel * _Nonnull (^)(TFY_placeholderLabel _Nonnull))placeholderLabel{
    return ^ (TFY_placeholderLabel block){
        if (block) {
            [self enumerateObjectsUsingBlock:^(UITextView * _Nonnull obj) {
                block(obj.tfy_placeholderLabel);
            }];
        }
        return self;
    };
}

@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UITextView, TFY_TextViewChainModel)

#undef TFY_CATEGORY_CHAIN_TEXT_IMPLEMENTATION
