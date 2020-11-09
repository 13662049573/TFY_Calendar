//
//  UIView+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIView+TFY_Tools.h"
#import <objc/runtime.h>
#import "TFY_iOS13DarkMode_MonitorView.h"
#import "UIView+TFY_iOS13DarkMode_MonitorView.h"

NSString const *BlockTapKey = @"BlockTapKey";
NSString const *BlockKey = @"BlockKey";

@interface BorderLayer: CALayer

/// 默认为0.0
@property (nonatomic, assign)CGFloat tfy_border_Width;
/// 默认为UIEdgeInsetsZero
@property (nonatomic, assign)UIEdgeInsets tfy_border_Inset;

@end

@implementation BorderLayer

- (instancetype)init{
    if (self = [super init]) {
        self.anchorPoint = CGPointZero;
        self.tfy_border_Width = 0.0;
        self.tfy_border_Inset = UIEdgeInsetsZero;
    }
    return self;
}

@end

@protocol BorderDirection <NSObject>

@property (nonatomic, strong) BorderLayer *leftLayer;
@property (nonatomic, strong) BorderLayer *topLayer;
@property (nonatomic, strong) BorderLayer *rightLayer;
@property (nonatomic, strong) BorderLayer *bottomLayer;

@end

@interface UIView (BorderDirection)<BorderDirection>
@end



@implementation UIView (TFY_Tools)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 变化方法实现
        [self tfy_swizzleMethod:[self class] orgSel:@selector(layoutSubviews) swizzSel:@selector(tfy_layoutSubviews)];
    });
}
+ (void)tfy_swizzleMethod:(Class)class orgSel:(SEL)originalSelector swizzSel:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    IMP swizzledImp = method_getImplementation(swizzledMethod);
    char *swizzledTypes = (char *)method_getTypeEncoding(swizzledMethod);
    
    IMP originalImp = method_getImplementation(originalMethod);
    char *originalTypes = (char *)method_getTypeEncoding(originalMethod);
    
    BOOL success = class_addMethod(class, originalSelector, swizzledImp, swizzledTypes);
    if (success) {
        class_replaceMethod(class, swizzledSelector, originalImp, originalTypes);
    }else {
        // 添加失败，表明已经有这个方法，直接交换
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - self.frame.size.height;
    self.frame = frame;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - self.frame.size.width;
    self.frame = frame;
}

- (void)tfy_removeAllSubViews{
    while (self.subviews.count > 0) {
        [[self.subviews firstObject] removeFromSuperview];
    }
}

- (UIViewController *)tfy_viewController{
    id nextResponder = [self nextResponder];
    UIView *view = self;
    while (![nextResponder isKindOfClass:[UIViewController class]]) {
        view = view.superview;
        nextResponder = [view nextResponder];
    }
    return nextResponder;
}

- (CGFloat)tfy_visibleAlpha{
    if ([self isKindOfClass:[UIWindow class]]) {
        if (self.hidden) return 0;
        return self.alpha;
    }
    if (!self.window) return 0;
    CGFloat alpha = 1;
    UIView *v = self;
    while (v) {
        if (v.hidden) {
            alpha = 0;
            break;
        }
        alpha *= v.alpha;
        v = v.superview;
    }
    return alpha;
}

- (UIImage *)tfy_snapshotImage{
    UIGraphicsBeginImageContextWithOptions(self.size, self.opaque > 0, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)tfy_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates{
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self tfy_snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque > 0, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}


- (NSData *)tfy_snapshotPDF{
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

#pragma mark - convert -
- (CGPoint)tfy_convertPointTo:(CGPoint)point :(UIView *)view{
    UIView *myView = self;
    CGPoint endPoint;
    if (!view) {
        if ([myView isKindOfClass:[UIWindow class]]) {
            endPoint = [((UIWindow *)myView) convertPoint:point toWindow:nil];
        } else {
            endPoint = [myView convertPoint:point toView:nil];
        }
    }
    
    UIWindow *from = [myView isKindOfClass:[UIWindow class]] ? (id)myView : myView.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [myView convertPoint:point toView:view];
    point = [myView convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    endPoint = [view convertPoint:point fromView:to];
    return endPoint;
}
- (CGPoint)tfy_convertPointFrom:(CGPoint)point :(UIView *)view{
    CGPoint endPoint;
    UIView *myView = self;
    if (!view) {
        if ([myView isKindOfClass:[UIWindow class]]) {
            endPoint = [(UIWindow *)myView convertPoint:point fromWindow:nil];
        }else{
            endPoint = [myView convertPoint:point fromView:nil];
        }
    }else{
        UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
        UIWindow *to = [myView isKindOfClass:[UIWindow class]] ? (id)myView : myView.window;
        if ((!from || !to) || (from == to)) return [myView convertPoint:point fromView:view];
        point = [from convertPoint:point fromView:view];
        point = [to convertPoint:point fromWindow:from];
        endPoint = [myView convertPoint:point fromView:to];
    }
    return endPoint;
}
- (CGRect)tfy_convertRectTo:(CGRect)rect :(UIView *)view{
    UIView *myView = self;
    CGRect toRect;
    if (!view) {
        if ([myView isKindOfClass:[UIWindow class]]) {
            toRect = [((UIWindow *)myView) convertRect:rect toWindow:nil];
        } else {
            toRect = [myView convertRect:rect toView:nil];
        }
    }
    
    UIWindow *from = [myView isKindOfClass:[UIWindow class]] ? (id)myView : myView.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [myView convertRect:rect toView:view];
    if (from == to) return [myView convertRect:rect toView:view];
    rect = [myView convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    toRect = [view convertRect:rect fromView:to];
    return toRect;
}
- (CGRect)tfy_convertRectFrom:(CGRect)rect :(UIView *)view{
    CGRect fromRect;
    UIView *myView = self;
    if (!view) {
        if ([myView isKindOfClass:[UIWindow class]]) {
            fromRect = [((UIWindow *)myView) convertRect:rect fromWindow:nil];
        } else {
            fromRect = [myView convertRect:rect fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [myView isKindOfClass:[UIWindow class]] ? (id)myView : myView.window;
    if ((!from || !to) || (from == to)) return [myView convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    fromRect = [myView convertRect:rect fromView:to];
    return fromRect;
}

#pragma mark - draw -
- (CAShapeLayer *)tfy_setCornerRadiusAngle:(UIRectCorner)corner cornerSize:(CGSize)size{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:size];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bezierPath.CGPath;
    return layer;
}

- (CALayer *)tfy_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return self.layer;
}

- (CALayer *)tfy_setLayerShadow:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor{
    [self tfy_setLayerShadow:color offset:offset radius:radius];
    if (cornerRadius > 0) {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = cornerRadius;
    }
    if (backgroundColor) {
        self.layer.backgroundColor = backgroundColor.CGColor;
    }
    return self.layer;
}

- (UITabBarController *_Nonnull)tfy_tabBarController
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UITabBarController class]]) {
            return (UITabBarController *)next;
        }
        next = next.nextResponder;
    } while (next);
    return nil;
}

-(void)tfy_setShadow:(CGSize)size shadowOpacity:(CGFloat)opacity shadowRadius:(CGFloat)radius shadowColor:(UIColor *)color{
    self.layer.shadowOffset = size;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowColor = color.CGColor;
}

/**
 *  添加点击事件
 */
- (void)tfy_addActionWithblock:(TouchCallBackBlock)block
{
    self.touchCallBackBlock = block;

    self.userInteractionEnabled = YES;
    
    /**
     *  添加相同事件方法，，先将原来的事件移除，避免重复调用
     */
    NSMutableArray *taps = [self allUIViewBlockTaps];
    [taps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)obj;
        [self removeGestureRecognizer:tap];
    }];
    [taps removeAllObjects];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(invoke:)];
    [self addGestureRecognizer:tap];
    [taps addObject:tap];
}

- (void)invoke:(id)sender
{
    if(self.touchCallBackBlock) {
        self.touchCallBackBlock();
    }
}

- (void)setTouchCallBackBlock:(TouchCallBackBlock)touchCallBackBlock
{
    objc_setAssociatedObject(self, &BlockKey, touchCallBackBlock, OBJC_ASSOCIATION_COPY);
}

- (TouchCallBackBlock)touchCallBackBlock
{
    return objc_getAssociatedObject(self, &BlockKey);
}

- (void)tfy_addTarget:(id)target action:(SEL)action
{
    self.userInteractionEnabled = YES;
    
    /**
     *  添加相同事件方法，，先将原来的事件移除，避免重复调用
     */
    NSMutableArray *taps = [self allUIViewBlockTaps];
    [taps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)obj;
        [self removeGestureRecognizer:tap];
    }];
    [taps removeAllObjects];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    [taps addObject:tap];
}

- (NSMutableArray *)allUIViewBlockTaps
{
    NSMutableArray *taps = objc_getAssociatedObject(self, &BlockTapKey);
    if (!taps) {
        taps = [NSMutableArray array];
        objc_setAssociatedObject(self, &BlockTapKey, taps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return taps;
}


#pragma mark -
- (void)tfy_layoutSubviews
{
    // 调用本身的实现
    [self tfy_layoutSubviews];
    BOOL isFrameChange = NO;;
    if(!CGRectEqualToRect(self.oldBounds, self.bounds)){
        isFrameChange = YES;
        self.oldBounds = self.bounds;
    }
    UIBezierPath *maskPath = [UIBezierPath  bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCorner)self.tfy_clipType cornerRadii:CGSizeMake(self.tfy_clipRadius, self.tfy_clipRadius)];
    if(self.needUpdateRadius || isFrameChange){
        self.needUpdateRadius = NO;
        if (self.tfy_clipType == CornerClipTypeNone || self.tfy_clipRadius <= 0) {
            // 以前使用了maskLayer，去掉
            if(self.layer.mask == self.maskLayer){
                self.layer.mask = nil;
            }
            self.maskLayer = nil;
        } else {
            if (self.layer.mask == nil) {
                self.maskLayer = [[CAShapeLayer alloc] init];
            }
            
            self.maskLayer.frame = self.bounds;
            self.maskLayer.path = maskPath.CGPath;
            self.layer.mask = self.maskLayer;
            
        }
    }
    
    if(self.tfy_borderWidth <= 0 || self.tfy_borderColor == nil){
        if(self.borderLayer){
            [self.borderLayer removeFromSuperlayer];
        }
        self.borderLayer = nil;
    }else{
        if(self.borderLayer == nil){
            self.borderLayer = [CAShapeLayer layer];
            self.borderLayer.lineWidth = self.tfy_borderWidth;
            self.borderLayer.fillColor = [UIColor clearColor].CGColor;
            self.borderLayer.strokeColor = self.tfy_borderColor.CGColor;
            self.borderLayer.frame = self.bounds;
            self.borderLayer.path = maskPath.CGPath;
            
            [self.layer addSublayer:self.borderLayer];
        }
        
    }
    //加边框用
    CGRect generalBound = self.leftLayer.bounds;
    CGPoint generalPoint = CGPointZero;
    UIEdgeInsets generalInset = self.leftLayer.tfy_border_Inset;
    
    //left
    generalBound.size.height = self.layer.bounds.size.height - generalInset.top - generalInset.bottom;//高度
    generalBound.size.width = self.leftLayer.tfy_border_Width;//宽度为border
    self.leftLayer.bounds = generalBound;
    
    generalPoint.x = generalInset.left;
    generalPoint.y = generalInset.top;
    self.leftLayer.position = generalPoint;
    
    generalBound = self.topLayer.bounds;
    generalPoint = self.topLayer.position;
    generalInset = self.topLayer.tfy_border_Inset;
    
    //top
    generalBound.size.height = self.topLayer.tfy_border_Width;
    generalBound.size.width = self.layer.bounds.size.width - generalInset.left - generalInset.right;
    self.topLayer.bounds = generalBound;
    
    generalPoint.x = generalInset.left;
    generalPoint.y = generalInset.top;
    self.topLayer.position = generalPoint;
    
    generalBound = self.rightLayer.bounds;
    generalPoint = self.rightLayer.position;
    generalInset = self.rightLayer.tfy_border_Inset;
    
    //right
    generalBound.size.height = self.layer.bounds.size.height - generalInset.top - generalInset.bottom;
    generalBound.size.width = self.rightLayer.tfy_border_Width;
    self.rightLayer.bounds = generalBound;
    
    generalPoint.x = self.layer.bounds.size.width - generalInset.right - generalBound.size.width;
    generalPoint.y = generalInset.top;
    self.rightLayer.position = generalPoint;
    
    generalBound = self.bottomLayer.bounds;
    generalPoint = self.bottomLayer.position;
    generalInset = self.bottomLayer.tfy_border_Inset;
    
    //bottom
    generalBound.size.height = self.bottomLayer.tfy_border_Width;
    generalBound.size.width = self.layer.bounds.size.width - generalInset.right - generalInset.left;
    self.bottomLayer.bounds = generalBound;
    
    generalPoint.x = generalInset.left;
    generalPoint.y = self.layer.bounds.size.height - generalInset.bottom - generalBound.size.height;
    self.bottomLayer.position = generalPoint;
    
    
}
/**
 * 便捷添加圆角  clipType 圆角类型  radius 圆角角度
 */
- (void)tfy_clipWithType:(CornerClipType)clipType radius:(CGFloat)radius
{
    self.tfy_clipType = clipType;
    self.tfy_clipRadius = radius;
}
/**
 * 便捷给添加border color 边框的颜色 borderWidth 边框的宽度
 */
- (void)tfy_addBorderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth
{
    self.tfy_borderColor = color;
    self.tfy_borderWidth = borderWidth;
}
#pragma mark - getter && setter
#pragma mark - radisu
- (void)setTfy_clipType:(CornerClipType)tfy_clipType
{
    if(self.tfy_clipType == tfy_clipType){
        // 数值相同不需要修改
        return;
    }
    // 以get方法名为key
    objc_setAssociatedObject(self, @selector(tfy_clipType), @(tfy_clipType), OBJC_ASSOCIATION_RETAIN);
    self.needUpdateRadius = YES;
}
- (CornerClipType)tfy_clipType
{
    // 以get方面为key
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}
- (void)setTfy_clipRadius:(CGFloat)tfy_clipRadius
{
    if(self.tfy_clipRadius == tfy_clipRadius){
        // 数值相同，不需要修改内如
        return;
    }
    // 以get方法名为key
    objc_setAssociatedObject(self, @selector(tfy_clipRadius), @(tfy_clipRadius), OBJC_ASSOCIATION_RETAIN);
    self.needUpdateRadius = YES;
}
- (CGFloat)tfy_clipRadius
{
    // 以get方面为key
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}
#pragma mark - border
- (void)setTfy_borderColor:(UIColor *)tfy_borderColor
{
    if(self.tfy_borderColor == tfy_borderColor){
        // 数值相同不需要修改
        return;
    }
    objc_setAssociatedObject(self, @selector(tfy_borderColor), tfy_borderColor, OBJC_ASSOCIATION_RETAIN);
    //self.needUpdateRadius = YES;
}
- (UIColor *)tfy_borderColor
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setTfy_borderWidth:(CGFloat)tfy_borderWidth
{
    if(self.tfy_borderWidth == tfy_borderWidth){
        // 数值相同不需要修改
        return;
    }
    // 以get方法名为key
    objc_setAssociatedObject(self, @selector(tfy_borderWidth), @(tfy_borderWidth), OBJC_ASSOCIATION_RETAIN);
    //self.needUpdateRadius = YES;
}
- (CGFloat)tfy_borderWidth{
    // 以get方面为key
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}
- (void)setBorderLayer:(CAShapeLayer *)borderLayer
{
    objc_setAssociatedObject(self, @selector(borderLayer), borderLayer, OBJC_ASSOCIATION_RETAIN);
}
- (CAShapeLayer *)borderLayer
{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark -
- (BOOL)needUpdateRadius
{
    // 以get方面为key
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setNeedUpdateRadius:(BOOL)needUpdateRadius
{
    // 以get方法名为key
    objc_setAssociatedObject(self, @selector(needUpdateRadius), @(needUpdateRadius), OBJC_ASSOCIATION_RETAIN);
}
- (void)setOldBounds:(CGRect)oldBounds
{
    // 以get方法名为key
    objc_setAssociatedObject(self, @selector(oldBounds), [NSValue valueWithCGRect:oldBounds], OBJC_ASSOCIATION_RETAIN);
}
- (CGRect)oldBounds
{
    // 以get方面为key
    return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}
- (void)setMaskLayer:(CAShapeLayer *)maskLayer
{
    objc_setAssociatedObject(self, @selector(maskLayer), maskLayer, OBJC_ASSOCIATION_RETAIN);
}
- (CAShapeLayer *)maskLayer
{
    return objc_getAssociatedObject(self, _cmd);
}

- (NSMutableDictionary *)gestureBlocks{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        obj = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(gestureBlocks), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}
#pragma mark-------------------------------------加边框方法---------------------------------

- (void)tfy_addBorderWithInset:(UIEdgeInsets)inset Color:(UIColor *)borderColor direction:(BorderDirection)directions{
    [self tfy_addBorderWithInset:inset Color:borderColor BorderWidth:self.layer.borderWidth direction:directions];
}


- (void)tfy_addBorderWithInset:(UIEdgeInsets)inset BorderWidth:(CGFloat)borderWidth direction:(BorderDirection)directions{
    [self tfy_addBorderWithInset:inset Color:[UIColor colorWithCGColor:self.layer.borderColor] BorderWidth:borderWidth direction:directions];
}

- (void)tfy_addBorderWithColor:(UIColor *)borderColor BodrerWidth:(CGFloat)borderWidth direction:(BorderDirection)directions{
    [self tfy_addBorderWithInset:UIEdgeInsetsZero Color:borderColor BorderWidth:borderWidth direction:directions];
}

- (void)tfy_addBorderWithInset:(UIEdgeInsets)inset Color:(UIColor *)borderColor BorderWidth:(CGFloat)borderWidth direction:(BorderDirection)directions
{
    if (directions & BorderDirectionLeft) {
        
        self.leftLayer.backgroundColor = borderColor.CGColor;
        self.leftLayer.tfy_border_Width = borderWidth;
        self.leftLayer.tfy_border_Inset = inset;
        if (self.leftLayer.superlayer) { [self.leftLayer removeFromSuperlayer]; }
        [self.layer addSublayer:self.leftLayer];
    }
    
    if (directions & BorderDirectionTop) {
        
        self.topLayer.backgroundColor = borderColor.CGColor;
        self.topLayer.tfy_border_Width = borderWidth;
        self.topLayer.tfy_border_Inset = inset;
        if (self.topLayer.superlayer) { [self.topLayer removeFromSuperlayer]; }
        [self.layer addSublayer:self.topLayer];
    }
    
    if (directions & BorderDirectionRight) {
        
        self.rightLayer.backgroundColor = borderColor.CGColor;
        self.rightLayer.tfy_border_Width = borderWidth;
        self.rightLayer.tfy_border_Inset = inset;
        if (self.rightLayer.superlayer) { [self.rightLayer removeFromSuperlayer]; }
        [self.layer addSublayer:self.rightLayer];
    }
    
    if (directions & BorderDirectionBottom) {
        
        self.bottomLayer.backgroundColor = borderColor.CGColor;
        self.bottomLayer.tfy_border_Width = borderWidth;
        self.bottomLayer.tfy_border_Inset = inset;
        if (self.bottomLayer.superlayer) { [self.bottomLayer removeFromSuperlayer]; }
        [self.layer addSublayer:self.bottomLayer];
    }
    
    [self setNeedsLayout];
}

- (void)tfy_removeBorders:(BorderDirection)directions{
    if (directions & BorderDirectionLeft) {
        [self removeBorderLayer:self.leftLayer];
    }
    if (directions & BorderDirectionTop) {
        [self removeBorderLayer:self.topLayer];
    }
    if (directions & BorderDirectionRight) {
        [self removeBorderLayer:self.rightLayer];
    }
    if (directions & BorderDirectionBottom) {
        [self removeBorderLayer:self.bottomLayer];
    }
}

- (void)tfy_removeAllBorders{
    [self removeBorderLayer:self.leftLayer];
    [self removeBorderLayer:self.topLayer];
    [self removeBorderLayer:self.rightLayer];
    [self removeBorderLayer:self.bottomLayer];
}

- (void)removeBorderLayer:(CALayer *)layer{
    if (layer) {
        [layer removeFromSuperlayer];
    }
}

- (void)setLeftLayer:(BorderLayer *)leftLayer
{
    objc_setAssociatedObject(self, @selector(leftLayer), leftLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTopLayer:(BorderLayer *)topLayer
{
    objc_setAssociatedObject(self, @selector(topLayer), topLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRightLayer:(BorderLayer *)rightLayer
{
    objc_setAssociatedObject(self, @selector(rightLayer), rightLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBottomLayer:(BorderLayer *)bottomLayer
{
    objc_setAssociatedObject(self, @selector(bottomLayer), bottomLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BorderLayer *)leftLayer{
    id layer = objc_getAssociatedObject(self, _cmd);
    if (layer == nil) {
        self.leftLayer = BorderLayer.new;
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (BorderLayer *)topLayer{
    id layer = objc_getAssociatedObject(self, _cmd);
    if (layer == nil) {
        self.topLayer = BorderLayer.new;
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (BorderLayer *)rightLayer
{
    id layer = objc_getAssociatedObject(self, _cmd);
    if (layer == nil) {
        self.rightLayer = BorderLayer.new;
    }
    return objc_getAssociatedObject(self, _cmd);
}


- (BorderLayer *)bottomLayer{
    id layer = objc_getAssociatedObject(self, _cmd);
    if (layer == nil) {
        self.bottomLayer = BorderLayer.new;
    }
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark-------------------------------------手势点击添加方法---------------------------------

- (id)tfy_addGestureTarget:(id)target action:(SEL)action gestureClass:(Class)class {
    UIGestureRecognizer *gesture = [[class alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:gesture];
    return gesture;
}

- (UITapGestureRecognizer *)tfy_addGestureTapTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UITapGestureRecognizer class]];
}

- (UIPanGestureRecognizer *)tfy_addGesturePanTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UIPanGestureRecognizer class]];
}

- (UIPinchGestureRecognizer *)tfy_addGesturePinchTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UIPinchGestureRecognizer class]];
}

- (UILongPressGestureRecognizer *)tfy_addGestureLongPressTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UILongPressGestureRecognizer class]];
}

- (UISwipeGestureRecognizer *)tfy_addGestureSwipeTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UISwipeGestureRecognizer class]];
}

- (UIRotationGestureRecognizer *)tfy_addGestureRotationTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UIRotationGestureRecognizer class]];
}

- (UIScreenEdgePanGestureRecognizer *)tfy_addGestureScreenEdgePanTarget:(id)target action:(SEL)action {
    return [self tfy_addGestureTarget:target action:action gestureClass:[UIScreenEdgePanGestureRecognizer class]];
}

#pragma mark - Category Block Events

- (id)tfy_addGestureEventHandle:(void (^)(id, id))event gestureClass:(Class)class {
    UIGestureRecognizer *gesture = [[class alloc] initWithTarget:self action:@selector(handleGestureRecognizer:)];
    [self addGestureRecognizer:gesture];
    if (event) {
        [[self gestureBlocks] setObject:event forKey:NSStringFromClass(class)];
    }
    return gesture;
}

- (UITapGestureRecognizer *)tfy_addGestureTapEventHandle:(void (^)(id sender, UITapGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UITapGestureRecognizer class]];
}

- (UIPanGestureRecognizer *)tfy_addGesturePanEventHandle:(void (^)(id sender, UIPanGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UIPanGestureRecognizer class]];
}

- (UIPinchGestureRecognizer *)tfy_addGesturePinchEventHandle:(void (^)(id sender, UIPinchGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UIPinchGestureRecognizer class]];
}

- (UILongPressGestureRecognizer *)tfy_addGestureLongPressEventHandle:(void (^)(id sender, UILongPressGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UILongPressGestureRecognizer class]];
}

- (UISwipeGestureRecognizer *)tfy_addGestureSwipeEventHandle:(void (^)(id sender, UISwipeGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UISwipeGestureRecognizer class]];
}

- (UIRotationGestureRecognizer *)tfy_addGestureRotationEventHandle:(void (^)(id sender, UIRotationGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UIRotationGestureRecognizer class]];
}

- (UIScreenEdgePanGestureRecognizer *)tfy_addGestureScreenEdgePanEventHandle:(void (^)(id sender, UIScreenEdgePanGestureRecognizer *recognizer))event {
    return [self tfy_addGestureEventHandle:event gestureClass:[UIScreenEdgePanGestureRecognizer class]];
}

#pragma mark -

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gesture
{
    NSString *key = NSStringFromClass(gesture.class);
    void (^block)(id sender, UIGestureRecognizer *tap) = [self gestureBlocks][key];
    block ? block(self, gesture) : nil;
}

/**暗黑设置*/
- (void)tfy_setiOS13DarkModeColor:(UIColor *)color forProperty:(NSString *)property {
    if (property.length == 0) {
        return;
    }
    
    NSString *proSetStr = [NSString stringWithFormat:@"set%@:",[property stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[property substringToIndex:1] capitalizedString]]];
    SEL proSetSel = NSSelectorFromString(proSetStr);
    
    __weak typeof(self) weakView = self;
    if ([self.layer respondsToSelector:proSetSel]) {
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            
            if (color) {
                [self.tfy_iOS13DrakMove_MonitorView tfy_setTraitCollectionChange:^(UIView * _Nonnull view) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [weakView.layer performSelector:proSetSel withObject:(id)[color resolvedColorWithTraitCollection:weakView.traitCollection].CGColor];
#pragma clang diagnostic pop
                } forKey:property forObject:self];
            } else {
                [self.tfy_iOS13DrakMove_MonitorView tfy_setTraitCollectionChange:nil forKey:property forObject:self];
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.layer performSelector:proSetSel withObject:(id)[color resolvedColorWithTraitCollection:self.traitCollection].CGColor];
#pragma clang diagnostic pop
        } else {
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.layer performSelector:proSetSel withObject:(id)color.CGColor];
#pragma clang diagnostic pop
#if __IPHONE_13_0
        }
#endif
    }
}

@end

