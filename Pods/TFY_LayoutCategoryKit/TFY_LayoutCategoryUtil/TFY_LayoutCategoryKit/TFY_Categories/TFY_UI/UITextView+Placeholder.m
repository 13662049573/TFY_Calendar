//
//  UITextView+Placeholder.m
//  shore
//
//  Created by 田风有 on 2023/4/27.
//

#import "UITextView+Placeholder.h"
#import <objc/runtime.h>

@interface UITextView ()

// 存储添加的图片
@property (nonatomic, strong) NSMutableArray *tfy_imageArray;
// 存储最后一次改变高度后的值
@property (nonatomic, assign) CGFloat lastHeight;

@end

@implementation UITextView (Placeholder)

+ (void)load {
    // is this the best solution?
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc")),
                                   class_getInstanceMethod(self.class, @selector(swizzledDealloc)));
}

- (void)swizzledDealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UITextView *textView = objc_getAssociatedObject(self, @selector(tfy_placeholderTextView));
    if (textView) {
        for (NSString *key in self.class.observingKeys) {
            @try {
                [self removeObserver:self forKeyPath:key];
            }
            @catch (NSException *exception) {
                // Do nothing
            }
        }
    }
    [self swizzledDealloc];
}


#pragma mark - Class Methods
#pragma mark `defaultPlaceholderColor`

+ (UIColor *)tfy_defaultPlaceholderColor {
    if (@available(iOS 13, *)) {
      SEL selector = NSSelectorFromString(@"placeholderTextColor");
      if ([UIColor respondsToSelector:selector]) {
        return [UIColor performSelector:selector];
      }
    }
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @" ";
        NSDictionary *attributes = [textField.attributedPlaceholder attributesAtIndex:0 effectiveRange:nil];
        color = attributes[NSForegroundColorAttributeName];
        if (!color) {
          color = [UIColor colorWithRed:0 green:0 blue:0.0980392 alpha:0.22];
        }
    });
    return color;
}

#pragma mark - `observingKeys`

+ (NSArray *)observingKeys {
    return @[@"attributedText",
             @"bounds",
             @"font",
             @"text",
             @"frame",
             @"text",
             @"textAlignment",
             @"textContainerInset",
             @"textContainer.lineFragmentPadding",
             @"textContainer.exclusionPaths"];
}


#pragma mark - Properties
#pragma mark `placeholderTextView`

- (UITextView *)tfy_placeholderTextView {
    UITextView *textView = objc_getAssociatedObject(self, @selector(tfy_placeholderTextView));
    if (!textView) {
        NSAttributedString *originalText = self.attributedText;
        self.text = @" "; // lazily set font of `UITextView`.
        self.attributedText = originalText;

        self.tfy_imageArray = [NSMutableArray array];
        
        textView = [[UITextView alloc] init];
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [self.class tfy_defaultPlaceholderColor];
        textView.userInteractionEnabled = NO;
        textView.isAccessibilityElement = NO;
        objc_setAssociatedObject(self, @selector(tfy_placeholderTextView), textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        self.needsUpdateFont = YES;
        [self updatePlaceholderTextView];
        self.needsUpdateFont = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePlaceholderTextView)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewTextChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        
        for (NSString *key in self.class.observingKeys) {
            [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    return textView;
}


#pragma mark `placeholder`

- (NSString *)tfy_placeholder {
    return self.tfy_placeholderTextView.text;
}

- (void)setTfy_placeholder:(NSString *)tfy_placeholder {
    self.tfy_placeholderTextView.text = tfy_placeholder;
    [self updatePlaceholderTextView];
}

- (NSAttributedString *)tfy_attributedPlaceholder {
    return self.tfy_placeholderTextView.attributedText;
}

- (void)setTfy_attributedPlaceholder:(NSAttributedString *)tfy_attributedPlaceholder {
    self.tfy_placeholderTextView.attributedText = tfy_attributedPlaceholder;
    [self updatePlaceholderTextView];
}

#pragma mark `placeholderColor`

- (UIColor *)tfy_placeholderColor {
    return self.tfy_placeholderTextView.textColor;
}

- (void)setTfy_placeholderColor:(UIColor *)tfy_placeholderColor {
    self.tfy_placeholderTextView.textColor = tfy_placeholderColor;
}

- (void)setTfy_maxHeight:(CGFloat)tfy_maxHeight
{
    CGFloat max = tfy_maxHeight;
    // 如果传入的最大高度小于textView本身的高度，则让最大高度等于本身高度
    if (tfy_maxHeight < self.frame.size.height) {
        max = self.frame.size.height;
    }
    objc_setAssociatedObject(self, @selector(tfy_maxHeight), [NSString stringWithFormat:@"%lf", max], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)tfy_maxHeight
{
    return [objc_getAssociatedObject(self, @selector(tfy_maxHeight)) doubleValue];
}

#pragma mark `needsUpdateFont`

- (BOOL)needsUpdateFont {
    return [objc_getAssociatedObject(self, @selector(needsUpdateFont)) boolValue];
}

- (void)setNeedsUpdateFont:(BOOL)needsUpdate {
    objc_setAssociatedObject(self, @selector(needsUpdateFont), @(needsUpdate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTfy_minHeight:(CGFloat)tfy_minHeight
{
    objc_setAssociatedObject(self, @selector(tfy_minHeight), [NSString stringWithFormat:@"%lf", tfy_minHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)tfy_minHeight
{
    return [objc_getAssociatedObject(self, @selector(tfy_minHeight)) doubleValue];
}

- (void)setTfy_textViewHeightDidChanged:(textViewHeightDidChangedBlock)tfy_textViewHeightDidChanged
{
    objc_setAssociatedObject(self, @selector(tfy_textViewHeightDidChanged), tfy_textViewHeightDidChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (textViewHeightDidChangedBlock)tfy_textViewHeightDidChanged
{
    void(^textViewHeightDidChanged)(CGFloat currentHeight) = objc_getAssociatedObject(self, @selector(tfy_textViewHeightDidChanged));
    return textViewHeightDidChanged;
}

- (NSArray *)tfy_getImages
{
    return self.tfy_imageArray;
}

- (void)setLastHeight:(CGFloat)lastHeight {
    objc_setAssociatedObject(self, @selector(lastHeight), [NSString stringWithFormat:@"%lf", lastHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)lastHeight {
    return [objc_getAssociatedObject(self, @selector(lastHeight)) doubleValue];
}

- (void)setTfy_imageArray:(NSMutableArray *)tfy_imageArray {
    objc_setAssociatedObject(self, @selector(tfy_imageArray), tfy_imageArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)tfy_imageArray {
    return objc_getAssociatedObject(self, @selector(tfy_imageArray));
}

- (void)tfy_autoHeightWithMaxHeight:(CGFloat)maxHeight
{
    [self tfy_autoHeightWithMaxHeight:maxHeight textViewHeightDidChanged:nil];
}
// 是否启用自动高度，默认为NO
static bool autoHeight = NO;
- (void)tfy_autoHeightWithMaxHeight:(CGFloat)maxHeight textViewHeightDidChanged:(textViewHeightDidChangedBlock)textViewHeightDidChanged
{
    autoHeight = YES;
    [self tfy_placeholderTextView];
    self.tfy_maxHeight = maxHeight;
    if (textViewHeightDidChanged) self.tfy_textViewHeightDidChanged = textViewHeightDidChanged;
}

#pragma mark - addImage
/* 添加一张图片 */
- (void)tfy_addImage:(UIImage *)image
{
    [self tfy_addImage:image size:CGSizeZero];
}

/* 添加一张图片 image:要添加的图片 size:图片大小 */
- (void)tfy_addImage:(UIImage *)image size:(CGSize)size
{
    [self tfy_insertImage:image size:size index:self.attributedText.length > 0 ? self.attributedText.length : 0];
}

/* 插入一张图片 image:要添加的图片 size:图片大小 index:插入的位置 */
- (void)tfy_insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index
{
    [self tfy_addImage:image size:size index:index multiple:-1];
}

/* 添加一张图片 image:要添加的图片 multiple:放大／缩小的倍数 */
- (void)tfy_addImage:(UIImage *)image multiple:(CGFloat)multiple
{
    [self tfy_addImage:image size:CGSizeZero index:self.attributedText.length > 0 ? self.attributedText.length : 0 multiple:multiple];
}

/* 插入一张图片 image:要添加的图片 multiple:放大／缩小的倍数 index:插入的位置 */
- (void)tfy_insertImage:(UIImage *)image multiple:(CGFloat)multiple index:(NSInteger)index
{
    [self tfy_addImage:image size:CGSizeZero index:index multiple:multiple];
}

/* 插入一张图片 image:要添加的图片 size:图片大小 index:插入的位置 multiple:放大／缩小的倍数 */
- (void)tfy_addImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index multiple:(CGFloat)multiple {
    if (image) [self.tfy_imageArray addObject:image];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = image;
    CGRect bounds = textAttachment.bounds;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        bounds.size = size;
        textAttachment.bounds = bounds;
    } else if (multiple <= 0) {
        CGFloat oldWidth = textAttachment.image.size.width;
        CGFloat scaleFactor = oldWidth / (self.frame.size.width - 10);
        textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
    } else {
        bounds.size = image.size;
        textAttachment.bounds = bounds;
    }
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(index, 0) withAttributedString:attrStringWithImage];
    self.attributedText = attributedString;
    [self textViewTextChange];
    [self updatePlaceholderTextView];
}

// 处理文字改变
- (void)textViewTextChange {
    UITextView *placeholderView = objc_getAssociatedObject(self, @selector(tfy_placeholderTextView));
    
    // 如果有值才去调用，这步很重要
    if (placeholderView) {
        self.tfy_placeholderTextView.hidden = (self.text.length > 0 && self.text);
    }
    // 如果没有启用自动高度，不执行以下方法
    if (!autoHeight) return;
    if (self.tfy_maxHeight >= self.bounds.size.height) {
        // 计算高度
        NSInteger currentHeight = ceil([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
        // 如果高度有变化，调用block
        if (currentHeight != self.lastHeight) {
            // 是否可以滚动
            self.scrollEnabled = currentHeight >= self.tfy_maxHeight;
            CGFloat currentTextViewHeight = currentHeight >= self.tfy_maxHeight ? self.tfy_maxHeight : currentHeight;
            // 改变textView的高度
            if (currentTextViewHeight >= self.tfy_minHeight) {
                CGRect frame = self.frame;
                frame.size.height = currentTextViewHeight;
                self.frame = frame;
                // 调用block
                if (self.tfy_textViewHeightDidChanged) self.tfy_textViewHeightDidChanged(currentTextViewHeight);
                // 记录当前高度
                self.lastHeight = currentTextViewHeight;
            }
        }
    }
    if (!self.isFirstResponder) [self becomeFirstResponder];
}

// 判断是否有placeholder值，这步很重要
- (BOOL)placeholderExist {
    // 获取对应属性的值
    UITextView *placeholderView = objc_getAssociatedObject(self, @selector(tfy_placeholderTextView));
    // 如果有placeholder值
    if (placeholderView) return YES;
    
    return NO;
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"font"]) {
        self.needsUpdateFont = (change[NSKeyValueChangeNewKey] != nil);
    }
    if ([keyPath isEqualToString:@"text"]) [self textViewTextChange];
    [self updatePlaceholderTextView];
}

#pragma mark - Update

- (void)updatePlaceholderTextView {
    if (self.text.length) {
        [self.tfy_placeholderTextView removeFromSuperview];
        self.accessibilityValue = self.text;
    } else {
        [self insertSubview:self.tfy_placeholderTextView atIndex:0];
        self.accessibilityValue = self.tfy_placeholder;
    }

    if (self.needsUpdateFont) {
        self.tfy_placeholderTextView.font = self.font;
        self.needsUpdateFont = NO;
    }
    if (self.tfy_placeholderTextView.attributedText.length == 0) {
      self.tfy_placeholderTextView.textAlignment = self.textAlignment;
    }
    self.tfy_placeholderTextView.textContainer.exclusionPaths = self.textContainer.exclusionPaths;
    self.tfy_placeholderTextView.textContainerInset = self.textContainerInset;
    self.tfy_placeholderTextView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    self.tfy_placeholderTextView.frame = self.bounds;
}


@end
