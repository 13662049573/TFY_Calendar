//
//  UITextView+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/3.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UITextView+TFY_Tools.h"
#import <objc/runtime.h>

CG_INLINE void TextView_ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@interface UITextView ()
/**限制文本*/
@property (nonatomic , strong)UILabel *tfy_textNumLabel;

@end

@implementation UITextView (TFY_Tools)

+ (void)load {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       TextView_ReplaceMethod([self class], @selector(layoutSubviews), @selector(tfytext_layoutSubviews));
   });
}

- (void)tfytext_layoutSubviews {
    [self updateLabel];
}

- (void)setTfy_limitNum:(NSInteger)tfy_limitNum {
    NSNumber *number = [NSNumber numberWithInteger:tfy_limitNum];
    objc_setAssociatedObject(self, &@selector(tfy_limitNum), number, OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger )tfy_limitNum {
    NSNumber *number = objc_getAssociatedObject(self, &@selector(tfy_limitNum));
    return number.integerValue;
}

- (void)setTfy_placeholder:(NSString *)tfy_placeholder {
    objc_setAssociatedObject(self, &@selector(tfy_placeholder), tfy_placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.tfy_placeholderLabel.text = tfy_placeholder;
}

- (NSString *)tfy_placeholder {
    return objc_getAssociatedObject(self, &@selector(tfy_placeholder));
}

- (void)setTfy_placeholderLabel:(UILabel *)tfy_placeholderLabel {
    objc_setAssociatedObject(self, &@selector(tfy_placeholderLabel), tfy_placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 是否需要调整字体
- (BOOL)needAdjustFont {
    return [objc_getAssociatedObject(self, &@selector(needAdjustFont)) boolValue];
}

- (void)setNeedAdjustFont:(BOOL)needAdjustFont {
    objc_setAssociatedObject(self, &@selector(needAdjustFont), @(needAdjustFont), OBJC_ASSOCIATION_ASSIGN);
}

- (UILabel *)tfy_placeholderLabel {
    UILabel *label = objc_getAssociatedObject(self, &@selector(tfy_placeholderLabel));
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        label.textColor = self.textColor;
        objc_setAssociatedObject(self,  &@selector(tfy_placeholderLabel), label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tfy_textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
        //监听font的变化
        [self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
    }
    return label;
}

- (UILabel *)tfy_textNumLabel {
    UILabel *label = objc_getAssociatedObject(self, &@selector(tfy_textNumLabel));
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        objc_setAssociatedObject(self,  &@selector(tfy_textNumLabel), label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return label;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"font"]){
        self.needAdjustFont = YES;
        [self tfy_textViewDidChange];
    }
}

- (void)tfy_textViewDidChange {
    self.tfy_placeholderLabel.hidden = self.hasText;
    
    if (self.tfy_limitNum > 0) {
        self.tfy_textNumLabel.hidden = !self.hasText;
        UITextRange *selectedRange = [self markedTextRange];
        // 获取高亮部分 中文联想
        UITextPosition *posi = [self positionFromPosition:selectedRange.start offset:0];
        // 如果在变化中是高亮部分在变，就不要计算字符
        if (selectedRange && posi) {
            return;
        }
        // 是否需要更新字体（NO 采用默认字体大小）
        if (self.needAdjustFont) {
            self.tfy_placeholderLabel.font = self.font;
            self.needAdjustFont = NO;
        }
        // 实际总长度
        NSInteger realLength = self.text.length;
        NSRange selection = self.selectedRange;
//        NSString *headText = [self.text substringToIndex:selection.location];   // 光标前的文本
        NSString *tailText = [self.text substringFromIndex:selection.location]; // 光标后的文本
        NSInteger restLength = self.tfy_limitNum - tailText.length;             // 光标前允许输入的最大数量

        if (realLength > self.tfy_limitNum) {
            // 解决半个emoji 定位到index位置时，返回在此位置的完整字符的range
            NSRange range = [self.text rangeOfComposedCharacterSequenceAtIndex:restLength];
            NSString *subHeadText = [self.text substringToIndex:range.location];
            
            // NSString *subHeadText = [headText substringToIndex:restLength];
            self.text = [subHeadText stringByAppendingString:tailText];
            [self setSelectedRange:NSMakeRange(restLength, 0)];
            // 解决粘贴过多之后，撤销粘贴 崩溃问题 —— 不会出现弹框
            [self.undoManager removeAllActions];
        }
        self.tfy_textNumLabel.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)self.text.length, (long)self.tfy_limitNum];
    } else {
        self.tfy_textNumLabel.hidden = self.hasText;
    }
}

- (void)updateLabel{
    if (self.text.length>0) {
        [self.tfy_placeholderLabel removeFromSuperview];
    }
    if (self.tfy_limitNum==0) {
        [self.tfy_textNumLabel removeFromSuperview];
    }
    //显示label
    [self insertSubview:self.tfy_placeholderLabel atIndex:0];
    
    NSArray *subsArr = self.subviews;
    for (UIView *view in subsArr) {
        if ([view isKindOfClass:NSClassFromString(@"_UIScrollViewScrollIndicator")]) {
            [self insertSubview:self.tfy_textNumLabel aboveSubview:view];
        }
    }
    CGFloat lineFragmentPadding =  self.textContainer.lineFragmentPadding;  //边距
    UIEdgeInsets contentInset = self.textContainerInset;
    //设置label frame
    CGFloat labelX = lineFragmentPadding + contentInset.left;
    CGFloat labelY = contentInset.top;
    CGFloat labelW = CGRectGetWidth(self.bounds) - contentInset.right - labelX;
    CGFloat labelH = [self.tfy_placeholderLabel sizeThatFits:CGSizeMake(labelW, MAXFLOAT)].height;
    self.tfy_placeholderLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    
    CGFloat textH = [self sizeThatFits:CGSizeMake(labelW, MAXFLOAT)].height;
    CGFloat labelnumberH = CGRectGetHeight(self.bounds) - contentInset.bottom-10;
    if (textH >= labelnumberH && self.tfy_limitNum > 0) {
        self.scrollEnabled = NO;
    }
    self.tfy_textNumLabel.frame = CGRectMake(labelX, labelnumberH, labelW-labelX, 15);
}

@end
