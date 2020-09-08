//
//  UILabel+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UILabel+TFY_Tools.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

@interface RichTextModel : NSObject
@property (nonatomic, copy) NSString *str;
@property (nonatomic) NSRange range;
@end

@implementation RichTextModel

@end

@implementation NSAttributedString (Chain)


+(NSAttributedString *)tfy_getAttributeId:(id)sender string:(NSString *)string orginFont:(CGFloat)orginFont orginColor:(UIColor *)orginColor attributeFont:(CGFloat)attributeFont attributeColor:(UIColor *)attributeColor
{
    __block  NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc] initWithString:string];
    [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:orginFont] range:NSMakeRange(0, string.length)];
    [totalStr addAttribute:NSForegroundColorAttributeName value:orginColor range:NSMakeRange(0, string.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.0f]; //设置行间距
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [totalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [totalStr length])];
    
    if ([sender isKindOfClass:[NSArray class]]) {
        
        __block NSString *oringinStr = string;
        __weak typeof(self) weakSelf = self;
        
        [sender enumerateObjectsUsingBlock:^(NSString *  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRange range = [oringinStr rangeOfString:str];
            [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
            [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
            oringinStr = [oringinStr stringByReplacingCharactersInRange:range withString:[weakSelf getStringWithRange:range]];
        }];
        
    }else if ([sender isKindOfClass:[NSString class]]) {
        
        NSRange range = [string rangeOfString:sender];
        
        [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
        [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
    }
    return totalStr;
}

+ (NSString *)getStringWithRange:(NSRange)range
{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < range.length ; i++) {
        [string appendString:@" "];
    }
    return string;
}


@end

// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

CG_INLINE void ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@implementation UILabel (TFY_Tools)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(drawTextInRect:), @selector(tfy_drawTextInRect:));
        ReplaceMethod([self class], @selector(sizeThatFits:), @selector(tfy_sizeThatFits:));
    });
}

- (void)tfy_drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = self.tfy_contentInsets;
    [self tfy_drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (CGSize)tfy_sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = self.tfy_contentInsets;
    size = [self tfy_sizeThatFits:CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(insets), size.height-UIEdgeInsetsGetVerticalValue(insets))];
    size.width += UIEdgeInsetsGetHorizontalValue(insets);
    size.height += UIEdgeInsetsGetVerticalValue(insets);
    return size;
}

const void *kAssociatedTfy_contentInsets;
- (void)setTfy_contentInsets:(UIEdgeInsets)tfy_contentInsets {
    objc_setAssociatedObject(self, &kAssociatedTfy_contentInsets, [NSValue valueWithUIEdgeInsets:tfy_contentInsets] , OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)tfy_contentInsets {
    return [objc_getAssociatedObject(self, &kAssociatedTfy_contentInsets) UIEdgeInsetsValue];
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

- (CGSize)tfy_sizeWithoutLimitSize {
    return [self tfy_sizeWithLimitSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}

- (CGSize)tfy_sizeWithLimitSize:(CGSize)size {
    CGRect strRect = [self.text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:self.font} context:nil];
    return strRect.size;
}

- (id<RichTextDelegate>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDelegate:(id<RichTextDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (NSMutableArray *)attributeStrings {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAttributeStrings:(NSMutableArray *)attributeStrings {
    objc_setAssociatedObject(self, @selector(attributeStrings), attributeStrings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)effectDic {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEffectDic:(NSMutableDictionary *)effectDic {
    objc_setAssociatedObject(self, @selector(effectDic), effectDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTapAction {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsTapAction:(BOOL)isTapAction {
    objc_setAssociatedObject(self, @selector(isTapAction), @(isTapAction), OBJC_ASSOCIATION_ASSIGN);
}

- (void (^)(UILabel *, NSString *, NSRange, NSInteger))tapBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTapBlock:(void (^)(UILabel *, NSString *, NSRange, NSInteger))tapBlock {
    objc_setAssociatedObject(self, @selector(tapBlock), tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tfy_enabledTapEffect {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTfy_enabledTapEffect:(BOOL)tfy_enabledTapEffect {
    objc_setAssociatedObject(self, @selector(tfy_enabledTapEffect), @(tfy_enabledTapEffect), OBJC_ASSOCIATION_ASSIGN);
    self.isTapEffect = tfy_enabledTapEffect;
}

- (BOOL)tfy_enlargeTapArea {
    NSNumber * number = objc_getAssociatedObject(self, _cmd);
    if (!number) {
        number = @(YES);
        objc_setAssociatedObject(self, _cmd, number, OBJC_ASSOCIATION_ASSIGN);
    }
    return [number boolValue];
}

- (void)setTfy_enlargeTapArea:(BOOL)tfy_enlargeTapArea {
    objc_setAssociatedObject(self, @selector(tfy_enlargeTapArea), @(tfy_enlargeTapArea), OBJC_ASSOCIATION_ASSIGN);
}

- (UIColor *)tfy_tapHighlightedColor {
    UIColor * color = objc_getAssociatedObject(self, _cmd);
    if (!color) {
        color = [UIColor lightGrayColor];
        objc_setAssociatedObject(self, _cmd, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return color;
}

- (void)setTfy_tapHighlightedColor:(UIColor *)tfy_tapHighlightedColor {
    objc_setAssociatedObject(self, @selector(tfy_tapHighlightedColor), tfy_tapHighlightedColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTapEffect {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsTapEffect:(BOOL)isTapEffect {
    objc_setAssociatedObject(self, @selector(isTapEffect), @(isTapEffect), OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - mainFunction
- (void)tfy_addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings tapClicked:(void (^) (UILabel * label, NSString *string, NSRange range, NSInteger index))tapClick
{
    [self tfy_removeAttributeTapActions];
    [self getRangesWithStrings:strings];
    self.userInteractionEnabled = YES;
    
    if (self.tapBlock != tapClick) {
        self.tapBlock = tapClick;
    }
}

- (void)tfy_addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings delegate:(id <RichTextDelegate> )delegate
{
    [self tfy_removeAttributeTapActions];
    [self getRangesWithStrings:strings];
    self.userInteractionEnabled = YES;
    
    if (self.delegate != delegate) {
        self.delegate = delegate;
    }
}

- (void)tfy_addAttributeTapActionWithRanges:(NSArray<NSString *> *)ranges tapClicked:(void (^)(UILabel *, NSString *, NSRange, NSInteger))tapClick
{
    [self tfy_removeAttributeTapActions];
    [self getRangesWithRanges:ranges];
    self.userInteractionEnabled = YES;
    
    if (self.tapBlock != tapClick) {
        self.tapBlock = tapClick;
    }
}

- (void)tfy_addAttributeTapActionWithRanges:(NSArray<NSString *> *)ranges delegate:(id<RichTextDelegate>)delegate
{
    [self tfy_removeAttributeTapActions];
    [self getRangesWithRanges:ranges];
    self.userInteractionEnabled = YES;
    
    if (self.delegate != delegate) {
        self.delegate = delegate;
    }
}

- (void)tfy_removeAttributeTapActions {
    self.tapBlock = nil;
    self.delegate = nil;
    self.effectDic = nil;
    self.isTapAction = NO;
    self.attributeStrings = [NSMutableArray array];
}

#pragma mark - touchAction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapAction) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    if (objc_getAssociatedObject(self, @selector(tfy_enabledTapEffect))) {
        self.isTapEffect = self.tfy_enabledTapEffect;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    __weak typeof(self) weakSelf = self;
    
    BOOL ret = [self getTapFrameWithTouchPoint:point result:^(NSString *string, NSRange range, NSInteger index) {
        
        if (weakSelf.isTapEffect) {
            
            [weakSelf saveEffectDicWithRange:range];
            
            [weakSelf tapEffectWithStatus:YES];
        }
        
    }];
    if (!ret) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.isTapAction) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    if (self.isTapEffect) {
        [self performSelectorOnMainThread:@selector(tapEffectWithStatus:) withObject:nil waitUntilDone:NO];
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    __weak typeof(self) weakSelf = self;
    
    BOOL ret = [self getTapFrameWithTouchPoint:point result:^(NSString *string, NSRange range, NSInteger index) {
        if (weakSelf.tapBlock) {
            weakSelf.tapBlock (weakSelf, string, range, index);
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(tfy_tapAttributeInLabel:string:range:index:)]) {
            [weakSelf.delegate tfy_tapAttributeInLabel:weakSelf string:string range:range index:index];
        }
    }];
    if (!ret) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapAction) {
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    if (self.isTapEffect) {
        [self performSelectorOnMainThread:@selector(tapEffectWithStatus:) withObject:nil waitUntilDone:NO];
    }
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    __weak typeof(self) weakSelf = self;
    
    BOOL ret = [self getTapFrameWithTouchPoint:point result:^(NSString *string, NSRange range, NSInteger index) {
        if (weakSelf.tapBlock) {
            weakSelf.tapBlock (weakSelf, string, range, index);
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(tfy_tapAttributeInLabel:string:range:index:)]) {
            [weakSelf.delegate tfy_tapAttributeInLabel:weakSelf string:string range:range index:index];
        }
    }];
    if (!ret) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - getTapFrame
- (BOOL)getTapFrameWithTouchPoint:(CGPoint)point result:(void (^) (NSString *string , NSRange range , NSInteger index))resultBlock
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    
    CGMutablePathRef Path = CGPathCreateMutable();
    
    CGPathAddRect(Path, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + 20));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    CGFloat total_height =  [self textSizeWithAttributedString:self.attributedText width:self.bounds.size.width numberOfLines:0].height;
    
    if (!lines) {
        CFRelease(frame);
        CFRelease(framesetter);
        CGPathRelease(Path);
        return NO;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    CGAffineTransform transform = [self transformForCoreText];
    
    for (CFIndex i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        CGFloat lineOutSpace = (self.bounds.size.height - total_height) / 2;
        
        rect.origin.y = lineOutSpace + [self getLineOrign:line];
        
        if (self.tfy_enlargeTapArea) {
            rect.origin.y -= 5;
            rect.size.height += 10;
        }
        
        if (CGRectContainsPoint(rect, point)) {
            
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));

            CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);
            
            CGFloat offset;
            
            CTLineGetOffsetForStringIndex(line, index, &offset);
            
            if (offset > relativePoint.x) {
                index = index - 1;
            }
            
            NSInteger link_count = self.attributeStrings.count;
            
            for (int j = 0; j < link_count; j++) {
                
                RichTextModel *model = self.attributeStrings[j];
                
                NSRange link_range = model.range;
                if (NSLocationInRange(index, link_range)) {
                    if (resultBlock) {
                        resultBlock (model.str , model.range , (NSInteger)j);
                    }
                    CFRelease(frame);
                    CFRelease(framesetter);
                    CGPathRelease(Path);
                    return YES;
                }
            }
        }
    }
    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(Path);
    return NO;
}

- (CGAffineTransform)transformForCoreText {
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = 0.0f;
    
    CFRange range = CTLineGetStringRange(line);
    NSAttributedString * attributedString = [self.attributedText attributedSubstringFromRange:NSMakeRange(range.location, range.length)];
    if ([attributedString.string hasSuffix:@"\n"] && attributedString.string.length > 1) {
        attributedString = [attributedString attributedSubstringFromRange:NSMakeRange(0, attributedString.length - 1)];
    }
    height = [self textSizeWithAttributedString:attributedString width:self.bounds.size.width numberOfLines:0].height;
    return CGRectMake(point.x, point.y , width, height);
}

- (CGFloat)getLineOrign:(CTLineRef)line {
    CFRange range = CTLineGetStringRange(line);
    if (range.location == 0) {
        return 0.;
    }else {
        NSAttributedString * attributedString = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, range.location)];
        if ([attributedString.string hasSuffix:@"\n"] && attributedString.string.length > 1) {
            attributedString = [attributedString attributedSubstringFromRange:NSMakeRange(0, attributedString.length - 1)];
        }
        return [self textSizeWithAttributedString:attributedString width:self.bounds.size.width numberOfLines:0].height;
    }
}

- (CGSize)textSizeWithAttributedString:(NSAttributedString *)attributedString width:(float)width numberOfLines:(NSInteger)numberOfLines
{
    @autoreleasepool {
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        sizeLabel.numberOfLines = numberOfLines;
        sizeLabel.attributedText = attributedString;
        CGSize fitSize = [sizeLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        return fitSize;
    }
}

#pragma mark - tapEffect
- (void)tapEffectWithStatus:(BOOL)status
{
    if (self.isTapEffect) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        NSMutableAttributedString *subAtt = [[NSMutableAttributedString alloc] initWithAttributedString:[[self.effectDic allValues] firstObject]];
        
        NSRange range = NSRangeFromString([[self.effectDic allKeys] firstObject]);
        
        if (status) {
            [subAtt addAttribute:NSBackgroundColorAttributeName value:self.tfy_tapHighlightedColor range:NSMakeRange(0, subAtt.string.length)];
            
            [attStr replaceCharactersInRange:range withAttributedString:subAtt];
        }else {
            
            [attStr replaceCharactersInRange:range withAttributedString:subAtt];
        }
        self.attributedText = attStr;
    }
}

- (void)saveEffectDicWithRange:(NSRange)range
{
    self.effectDic = [NSMutableDictionary dictionary];
    
    NSAttributedString *subAttribute = [self.attributedText attributedSubstringFromRange:range];
    
    [self.effectDic setObject:subAttribute forKey:NSStringFromRange(range)];
}

#pragma mark - getRange
- (void)getRangesWithStrings:(NSArray <NSString *>  *)strings
{
    if (self.attributedText == nil) {
        self.isTapAction = NO;
        return;
    }
    self.isTapAction = YES;
    self.isTapEffect = YES;
    __block  NSString *totalStr = self.attributedText.string;
    self.attributeStrings = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    [strings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range = [totalStr rangeOfString:obj];
        
        if (range.length != 0) {
            
            totalStr = [totalStr stringByReplacingCharactersInRange:range withString:[weakSelf getStringWithRange:range]];
            
            RichTextModel *model = [RichTextModel new];
            model.range = range;
            model.str = obj;
            [weakSelf.attributeStrings addObject:model];
            
        }
        
    }];
}

- (void)getRangesWithRanges:(NSArray <NSString *>  *)ranges
{
    if (self.attributedText == nil) {
        self.isTapAction = NO;
        return;
    }
    
    self.isTapAction = YES;
    self.isTapEffect = YES;
    __block  NSString *totalStr = self.attributedText.string;
    self.attributeStrings = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    [ranges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = NSRangeFromString(obj);
        NSAssert(totalStr.length >= range.location + range.length, @"NSRange(%lu,%lu) is out of bounds",(unsigned long)range.location,(unsigned long)range.length);
        NSString * string = [totalStr substringWithRange:range];
        
        RichTextModel *model = [RichTextModel new];
        model.range = range;
        model.str = string;
        [weakSelf.attributeStrings addObject:model];
    }];
}

- (NSString *)getStringWithRange:(NSRange)range
{
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i < range.length ; i++) {
        
        [string appendString:@" "];
    }
    return string;
}

#pragma mark - KVO
- (void)addObserver
{
    [self addObserver:self forKeyPath:@"attributedText" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)removeObserver
{
    id info = self.observationInfo;
    NSString * key = @"attributedText";
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id Properties = [objc valueForKeyPath:@"_property"];
        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
        if ([key isEqualToString:keyPath]) {
            [self removeObserver:self forKeyPath:@"attributedText" context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"attributedText"]) {
        if (self.isTapAction) {
            if (![change[NSKeyValueChangeNewKey] isEqual: change[NSKeyValueChangeOldKey]]) {
               
            }
        }
    }
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
