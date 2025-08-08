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

@implementation UIView (TFY_Tools)

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
- (CGPoint)tfy_convertPointTo:(CGPoint)point subView:(UIView *)view {
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

- (CGPoint)tfy_convertPointFrom:(CGPoint)point subView:(UIView *)view{
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
- (CGRect)tfy_convertRectTo:(CGRect)rect subView:(UIView *)view {
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

- (CGRect)tfy_convertRectFrom:(CGRect)rect subView:(UIView *)view {
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

- (NSMutableDictionary *)gestureBlocks{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        obj = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(gestureBlocks), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
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

