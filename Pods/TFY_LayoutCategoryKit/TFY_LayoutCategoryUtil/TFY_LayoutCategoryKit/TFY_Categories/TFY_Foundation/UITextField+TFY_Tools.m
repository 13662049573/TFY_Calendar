//
//  UITextField+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UITextField+TFY_Tools.h"
#import "UIControl+TFY_Tools.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>

// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat Field_UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat Field_UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

CG_INLINE void Field_ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@implementation UITextField (TFY_Tools)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (TARGET_IPHONE_SIMULATOR) {
            //模拟器不执行
        }else{
            Field_ReplaceMethod([self class], @selector(textRectForBounds:), @selector(tfy_textRectForBounds:));
            Field_ReplaceMethod([self class], @selector(sizeThatFits:), @selector(tfy_sizeThatFits:));
            Field_ReplaceMethod([self class], @selector(drawTextInRect:), @selector(tfy_drawTextInRect:));
            Field_ReplaceMethod([self class], @selector(editingRectForBounds:), @selector(tfy_editingRectForBounds:));
        }
    });
}
//重写来重置文字显示区域
- (void)tfy_textRectForBounds:(CGRect)rect {
    UIEdgeInsets insets = self.tfy_contentInsets;
    [self tfy_textRectForBounds:UIEdgeInsetsInsetRect(rect, insets)];
}
//重写来重置占位符区域
- (void)tfy_drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = self.tfy_contentInsets;
    [self tfy_drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
//重写来重置编辑区域（光标）
- (void)tfy_editingRectForBounds:(CGRect)rect {
    UIEdgeInsets insets = self.tfy_contentInsets;
    [self tfy_editingRectForBounds:UIEdgeInsetsInsetRect(rect, insets)];
}


- (CGSize)tfy_sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = self.tfy_contentInsets;
    size = [self tfy_sizeThatFits:CGSizeMake(size.width - Field_UIEdgeInsetsGetHorizontalValue(insets), size.height-Field_UIEdgeInsetsGetVerticalValue(insets))];
    size.width += Field_UIEdgeInsetsGetHorizontalValue(insets);
    size.height += Field_UIEdgeInsetsGetVerticalValue(insets);
    return size;
}

- (void)tfy_addLeftViewBlock:(UIView * (^) (UITextField *))leftBlock mode:(UITextFieldViewMode)mode{
    if (leftBlock) {
        self.leftView = leftBlock(self);
        self.leftViewMode = mode;
    }
}
- (void)tfy_addRightViewBlock:(UIView * (^) (UITextField *))rightBlock mode:(UITextFieldViewMode)mode{
    if (rightBlock) {
        self.rightView = rightBlock(self);
        self.rightViewMode = mode;
    }
}

- (NSRange)tfy_selectedRange
{
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)tfy_selectedText
{
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)tfy_setSelectedRange:(NSRange)range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}


- (void)setTfy_editedText:(void (^)(NSString * _Nonnull))tfy_editedText{
    objc_setAssociatedObject(self, @selector(tfy_editedText), tfy_editedText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addObserver];
}

- (void (^)(NSString * _Nonnull))tfy_editedText{
    return objc_getAssociatedObject(self, @selector(tfy_editedText));
}

- (NSUInteger)limitLength{
    return [objc_getAssociatedObject(self, @selector(limitLength)) integerValue];
}

- (void)setLimitLength:(NSUInteger)limitLength{
    objc_setAssociatedObject(self, @selector(limitLength), @(limitLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addObserver];
    
}

- (void)addObserver{
    if ([self tfy_containsEventBlockForKey:NSStringFromClass([self class])]) return;
    __weak typeof(self)weakSelf = self;
    [self tfy_addEventBlock:^(id  _Nonnull sender) {
        [weakSelf textFieldTextDidChange];
    } forEvents:UIControlEventEditingChanged ForKey:NSStringFromClass([self class])];
}

- (void)textFieldTextDidChange{
    NSString *toBeString = self.text;
    NSUInteger limit = self.limitLength;
    UITextRange *selectedRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    NSInteger loction = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.start];
    if (self.tfy_editedText) {
        if (!position) {
            self.tfy_editedText(toBeString);
        }else{
            self.tfy_editedText([toBeString substringToIndex:loction]);
        }
    }
    if (!position && (limit > 0 && toBeString.length > limit)) {
        NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:limit];
        if (rangeIndex.length == 1) {
            self.text = [toBeString substringToIndex:limit];
        }
        else {
            NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, limit)];
            NSInteger tmpLength;
            if (rangeRange.length > limit) {
                tmpLength = rangeRange.length - rangeIndex.length;
            }
            else{
                tmpLength = rangeRange.length;
            }
            self.text = [toBeString substringWithRange:NSMakeRange(0, tmpLength)];
        }
    }else{
        if (loction >= limit) {
            self.text = [toBeString substringWithRange:NSMakeRange(0, limit)];
        }
    }
}


const void *kField_contentInsets;
- (void)setTfy_contentInsets:(UIEdgeInsets)tfy_contentInsets {
    objc_setAssociatedObject(self, &kField_contentInsets, [NSValue valueWithUIEdgeInsets:tfy_contentInsets] , OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)tfy_contentInsets {
    return [objc_getAssociatedObject(self, &kField_contentInsets) UIEdgeInsetsValue];
}


- (CGFloat)tfy_lineSpace {
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_lineSpace));
    return number.floatValue;
}

- (void)setTfy_lineSpace:(CGFloat)tfy_lineSpace {
     NSNumber *number = [NSNumber numberWithDouble:tfy_lineSpace];
     objc_setAssociatedObject(self, @selector(tfy_lineSpace), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     [self editSettings];
}

- (CGFloat)tfy_textSpace {
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_textSpace));
    return number.floatValue;
}

- (void)setTfy_textSpace:(CGFloat)tfy_textSpace {
    NSNumber *number = [NSNumber numberWithDouble:tfy_textSpace];
    objc_setAssociatedObject(self, @selector(tfy_textSpace), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self editSettings];
}

- (CGFloat)tfy_firstLineHeadIndent {
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_firstLineHeadIndent));
    return number.floatValue;
}

- (void)setTfy_firstLineHeadIndent:(CGFloat)tfy_firstLineHeadIndent {
    NSNumber *number = [NSNumber numberWithDouble:tfy_firstLineHeadIndent];
    objc_setAssociatedObject(self, @selector(tfy_firstLineHeadIndent), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self editSettings];
}

- (void)editSettings {
    CGFloat textspace = self.tfy_textSpace>0?self.tfy_textSpace:0;
    CGFloat lineSpacing = self.tfy_lineSpace>0?self.tfy_lineSpace:0;
    CGFloat firstLineHeadIndent = self.tfy_firstLineHeadIndent>0?self.tfy_firstLineHeadIndent:0;
    
    NSString *text_str = self.text;
    
    NSMutableAttributedString *attributes = [[NSMutableAttributedString alloc] initWithString:text_str];
    //调整字间距(字符串)
    [attributes addAttribute:(__bridge NSString *)kCTKernAttributeName value:@(textspace) range:NSMakeRange(0, [attributes length])];
    
    [attributes addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, text_str.length)];//字体调整

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = lineSpacing;  // 行间距
    //首行文本缩进
    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent;//首行缩进
    
    [attributes addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text_str.length)];
     
    if (textspace>0 || lineSpacing>0 || firstLineHeadIndent>0) {
        self.attributedText = attributes;
    }
}
@end
