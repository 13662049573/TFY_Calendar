//
//  UIBarButtonItem+TFY_Chain.m
//  TFY_Navigation
//
//  Created by 田风有 on 2019/6/6.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UIBarButtonItem+TFY_Chain.h"
#import <objc/runtime.h>

static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    str = [[str stringByTrimmingCharactersInSet:set] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    NSUInteger length = [str length];
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

NSString const *UIBarButtonItem_badgeKey = @"UIBarButtonItem_badgeKey";
NSString const *UIBarButtonItem_badgeBGColorKey = @"UIBarButtonItem_badgeBGColorKey";
NSString const *UIBarButtonItem_badgeTextColorKey = @"UIBarButtonItem_badgeTextColorKey";
NSString const *UIBarButtonItem_badgeFontKey = @"UIBarButtonItem_badgeFontKey";
NSString const *UIBarButtonItem_badgePaddingKey = @"UIBarButtonItem_badgePaddingKey";
NSString const *UIBarButtonItem_badgeMinSizeKey = @"UIBarButtonItem_badgeMinSizeKey";
NSString const *UIBarButtonItem_badgeOriginXKey = @"UIBarButtonItem_badgeOriginXKey";
NSString const *UIBarButtonItem_badgeOriginYKey = @"UIBarButtonItem_badgeOriginYKey";
NSString const *UIBarButtonItem_shouldHideBadgeAtZeroKey = @"UIBarButtonItem_shouldHideBadgeAtZeroKey";
NSString const *UIBarButtonItem_shouldAnimateBadgeKey = @"UIBarButtonItem_shouldAnimateBadgeKey";
NSString const *UIBarButtonItem_badgeValueKey = @"UIBarButtonItem_badgeValueKey";
#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation UIBarButtonItem (TFY_Chain)
/**
 *  按钮初始化
 */
UIBarButtonItem *tfy_barbtnItem(void){
    return [UIBarButtonItem new];
}
-(UILabel *)tfy_bgdge{
    UILabel* lbl = objc_getAssociatedObject(self, &UIBarButtonItem_badgeKey);
    if(lbl==nil) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.tfy_badgeOriginX, self.tfy_badgeOriginY, 20, 20)];
        [self setTfy_bgdge:lbl];
        [self badgeInit];
        [self.customView addSubview:lbl];
        lbl.textAlignment = NSTextAlignmentCenter;
    }
    return lbl;
}

-(void)setTfy_bgdge:(UILabel * _Nonnull)tfy_bgdge{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeKey, tfy_bgdge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)tfy_badgeValue{
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeValueKey);
}

-(void)setTfy_badgeValue:(NSString * _Nonnull)tfy_badgeValue{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeValueKey, tfy_badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBadgeValueAnimated:YES];
    [self refreshBadge];
}

-(UIColor *)tfy_badgeBGColor{
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey);
}

-(void)setTfy_badgeBGColor:(UIColor * _Nonnull)tfy_badgeBGColor{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey, tfy_badgeBGColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(UIColor *)tfy_badgeTextColor{
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeTextColorKey);
}

-(void)setTfy_badgeTextColor:(UIColor * _Nonnull)tfy_badgeTextColor{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeTextColorKey, tfy_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(UIFont *)tfy_badgeFont{
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeFontKey);
}

-(void)setTfy_badgeFont:(UIFont * _Nonnull)tfy_badgeFont{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeFontKey, tfy_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(CGFloat)tfy_badgePadding{
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgePaddingKey);
    return number.floatValue;
}

-(void)setTfy_badgePadding:(CGFloat)tfy_badgePadding{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgePadding];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgePaddingKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat)tfy_badgeMinSize{
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeMinSizeKey);
    return number.floatValue;
}

-(void)setTfy_badgeMinSize:(CGFloat)tfy_badgeMinSize{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgeMinSize];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeMinSizeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat)tfy_badgeOriginX{
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey);
    return number.floatValue;
}

-(void)setTfy_badgeOriginX:(CGFloat)tfy_badgeOriginX{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgeOriginX];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat)tfy_badgeOriginY{
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginYKey);
    return number.floatValue;
}

-(void)setTfy_badgeOriginY:(CGFloat)tfy_badgeOriginY{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgeOriginY];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginYKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(BOOL)tfy_shouldHideBadgeAtZero{
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_shouldHideBadgeAtZeroKey);
    return number.boolValue;
}

-(void)setTfy_shouldHideBadgeAtZero:(BOOL)tfy_shouldHideBadgeAtZero{
    NSNumber *number = [NSNumber numberWithBool:tfy_shouldHideBadgeAtZero];
    objc_setAssociatedObject(self, &UIBarButtonItem_shouldHideBadgeAtZeroKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(BOOL)tfy_shouldAnimateBadge{
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_shouldAnimateBadgeKey);
    return number.boolValue;
}

-(void)setTfy_shouldAnimateBadge:(BOOL)tfy_shouldAnimateBadge{
    NSNumber *number = [NSNumber numberWithBool:tfy_shouldAnimateBadge];
    objc_setAssociatedObject(self, &UIBarButtonItem_shouldAnimateBadgeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.tfy_bgdge) {
        [self refreshBadge];
    }
}
- (void)removeBadge{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tfy_bgdge.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.tfy_bgdge removeFromSuperview];
    }];
}

-(void)badgeInit{
    UIView *superview = nil;
    CGFloat defaultOriginX = 0;
    if (self.customView) {
        superview = self.customView;
        defaultOriginX = superview.frame.size.width - self.tfy_bgdge.frame.size.width/2;
        superview.clipsToBounds = NO;
        
    } else if ([self respondsToSelector:@selector(view)] && [(id)self view]) {
        superview = [(id)self view];
        defaultOriginX = superview.frame.size.width - self.tfy_bgdge.frame.size.width;
    }
    [superview addSubview:self.tfy_bgdge];
    
    self.tfy_badgeBGColor = [UIColor redColor];
    self.tfy_badgeTextColor = [UIColor whiteColor];
    self.tfy_badgeFont = [UIFont systemFontOfSize:12];
    self.tfy_badgePadding = 6;
    self.tfy_badgeMinSize = 8;
    self.tfy_badgeOriginX = defaultOriginX;
    self.tfy_badgeOriginY = -4;
    self.tfy_shouldHideBadgeAtZero = YES;
    self.tfy_shouldAnimateBadge = YES;
}

-(void)updateBadgeValueAnimated:(BOOL)animated{
    if (animated && self.tfy_shouldAnimateBadge && ![self.tfy_bgdge.text isEqualToString:self.tfy_badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4f :1.3f :1.f :1.f]];
        [self.tfy_bgdge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    self.tfy_bgdge.text = self.tfy_badgeValue;
    
    if (animated && self.tfy_shouldAnimateBadge) {
        [UIView animateWithDuration:0.2 animations:^{
            [self updateBadgeFrame];
        }];
    } else {
        [self updateBadgeFrame];
    }
}

-(void)updateBadgeFrame{
    
    CGSize expectedLabelSize = [self badgeExpectedSize];
    CGFloat minHeight = expectedLabelSize.height;
    minHeight = (minHeight < self.tfy_badgeMinSize) ? self.tfy_badgeMinSize : expectedLabelSize.height;
    CGFloat minWidth = expectedLabelSize.width;
    CGFloat padding = self.tfy_badgePadding;
    minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
    self.tfy_bgdge.frame = CGRectMake(self.tfy_badgeOriginX, self.tfy_badgeOriginY, minWidth + padding, minHeight + padding);
    self.tfy_bgdge.layer.cornerRadius = (minHeight + padding) / 2;
    self.tfy_bgdge.layer.masksToBounds = YES;
}

-(CGSize)badgeExpectedSize
{
    UILabel *frameLabel = [self duplicateLabel:self.tfy_bgdge];
    [frameLabel sizeToFit];
    
    CGSize expectedLabelSize = frameLabel.frame.size;
    return expectedLabelSize;
}

-(UILabel *)duplicateLabel:(UILabel *)labelToCopy{
    
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    return duplicateLabel;
}

-(void)refreshBadge{
    self.tfy_bgdge.textColor = self.tfy_badgeTextColor;
    self.tfy_bgdge.backgroundColor = self.tfy_badgeBGColor;
    self.tfy_bgdge.font = self.tfy_badgeFont;
    
    if (!self.tfy_badgeValue || [self.tfy_badgeValue isEqualToString:@""] || ([self.tfy_badgeValue isEqualToString:@"0"] && self.tfy_shouldHideBadgeAtZero)) {
        self.tfy_bgdge.hidden = YES;
    } else {
        self.tfy_bgdge.hidden = NO;
        [self updateBadgeValueAnimated:YES];
    }
}


/**
 *  添加图片和点击事件
 */
-(UIBarButtonItem *(^)(NSString *image_str,id object, SEL action))tfy_imageItem{
    return ^(NSString *image_str,id object, SEL action){
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:image_str] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:object action:action];
        return item;
    };
}
/**
 *  添加 title_str 字体文本  fontOfSize字体大小  color 字体颜色
 */
-(UIBarButtonItem *(^)(NSString *title_str,CGFloat fontOfSize,UIColor *color,id object, SEL action))tfy_titleItem{
    return ^(NSString *title_str,CGFloat fontOfSize,UIColor *color,id object, SEL action){
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title_str style:UIBarButtonItemStylePlain target:object action:action];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontOfSize],NSFontAttributeName, color,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        return item;
    };
}
// 文字--文字状态-文字颜色-文字大小  图片--图片UIImage--图片状态   点击方法
-(UIBarButtonItem *(^)(CGSize size,NSString *title_str,id color,UIFont *font,NSString *image,NAV_ButtonImageDirection direction,CGFloat space,id object, SEL action,UIControlEvents evrnts))tfy_titleItembtn{
    return ^(CGSize size,NSString *title_str,id color,UIFont *font,NSString *image,NAV_ButtonImageDirection direction,CGFloat space,id object, SEL action,UIControlEvents evrnts){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (size.width>65 && size.height>44) {
            btn.frame = CGRectMake(0, 0, size.width, size.height);
        }
        btn.frame = CGRectMake(0, 0, 65, 44);
        
        [btn setTitle:title_str forState:UIControlStateNormal];
        
        if ([color isKindOfClass:[UIColor class]]) {
            [btn setTitleColor:color forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        }
        if ([color isKindOfClass:[NSString class]]) {
            [btn setTitleColor:[self colorWithHexString:color] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        }
        btn.titleLabel.font = font;
        if (image!=nil) {
            [btn setImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        
        [btn imageDirection:direction space:space];
        
        [btn addTarget:object action:action forControlEvents:evrnts];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        return item;
    };
}

- (UIColor *)colorWithHexString:(NSString *)hexStr{
    return [self colorWithHexString:hexStr alpha:-1];
}

- (UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha{
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        if (@available(iOS 10.0, *)) {
            return [UIColor colorWithDisplayP3Red:r green:g blue:b alpha:alpha < 0?a : alpha];
        }else{
            return [UIColor colorWithRed:r green:g blue:b alpha:alpha < 0?a : alpha];
        }
    }
    return [UIColor whiteColor];
}
@end
