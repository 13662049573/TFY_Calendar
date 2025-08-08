//
//  TFY_TextTag.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTag.h"
#import "TFY_TextTagStringContent.h"

static NSUInteger TFY_TextTagAutoIncreasedId = 0;

@implementation TFY_TextTag

- (instancetype)initWithContent:(TFY_TextTagContent *)content
                          style:(TFY_TextTagStyle *)style {
    self = [self init];
    if (self) {
        self.content = content;
        self.style = style;
    }
    return self;
}

- (instancetype)initWithContent:(TFY_TextTagContent *)content
                          style:(TFY_TextTagStyle *)style
                selectedContent:(TFY_TextTagContent *)selectedContent
                  selectedStyle:(TFY_TextTagStyle *)selectedStyle {
    self = [self init];
    if (self) {
        self.content = content;
        self.style = style;
        self.selectedContent = selectedContent;
        self.selectedStyle = selectedStyle;
    }
    return self;
}

+ (instancetype)tagWithContent:(TFY_TextTagContent *)content
                         style:(TFY_TextTagStyle *)style {
    return [[self alloc] initWithContent:content style:style];
}

+ (instancetype)tagWithContent:(TFY_TextTagContent *)content
                         style:(TFY_TextTagStyle *)style
               selectedContent:(TFY_TextTagContent *)selectedContent
                 selectedStyle:(TFY_TextTagStyle *)selectedStyle {
    return [[self alloc] initWithContent:content
                                   style:style
                         selectedContent:selectedContent
                           selectedStyle:selectedStyle];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tagId = TFY_TextTagAutoIncreasedId++;
        _attachment = nil;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    // Callback
    if (_onSelectStateChanged) {
        _onSelectStateChanged(selected);
    }
}

- (TFY_TextTagContent *)selectedContent {
    if (_selectedContent == nil) {
        _selectedContent = [_content copy];
    }
    return _selectedContent;
}

- (TFY_TextTagStyle *)selectedStyle {
    if (_selectedStyle == nil) {
        _selectedStyle = [_style copy];
    }
    return _selectedStyle;
}

- (TFY_TextTagContent *)getRightfulContent {
    return _selected ? self.selectedContent : self.content;
}

- (TFY_TextTagStyle *)getRightfulStyle {
    return _selected ? self.selectedStyle : self.style;
}

- (BOOL)isAccessibilityElement {
    return _enableAutoDetectAccessibility || _isAccessibilityElement;
}

- (NSString *)accessibilityLabel {
    if (_enableAutoDetectAccessibility) {
        return [self getRightfulContent].getContentAttributedString.string;
    }
    return _accessibilityLabel;
}

- (UIAccessibilityTraits)accessibilityTraits {
    if (_enableAutoDetectAccessibility) {
        return _selected ? UIAccessibilityTraitSelected : UIAccessibilityTraitButton;
    }
    return _accessibilityTraits;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToTag:other];
}

- (BOOL)isEqualToTag:(TFY_TextTag *)tag {
    if (self == tag)
        return YES;
    if (tag == nil)
        return NO;
    if (self.tagId != tag.tagId)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)self.tagId;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    TFY_TextTag *copy = (TFY_TextTag *)[[[self class] allocWithZone:zone] init];
    if (copy != nil) {
        copy->_tagId = TFY_TextTagAutoIncreasedId++;
        copy.attachment = self.attachment;
        copy.content = self.content;
        copy.style = self.style;
        copy.selected = self.selected;
        copy.selectedContent = self.selectedContent;
        copy.selectedStyle = self.selectedStyle;
        copy.isAccessibilityElement = self.isAccessibilityElement;
        copy.accessibilityLabel = self.accessibilityLabel;
        copy.accessibilityHint = self.accessibilityHint;
        copy.accessibilityValue = self.accessibilityValue;
        copy.accessibilityTraits = self.accessibilityTraits;
        copy.enableAutoDetectAccessibility = self.enableAutoDetectAccessibility;
    }
    return copy;
}

@end
