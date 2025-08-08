//
//  UIView+ShadowPath.m
//  ShadowPath
//
//  Created by 田风有 on 2021/9/12.
//

#import "UIView+ShadowPath.h"
#import "UIColor+TFY_Tools.h"
#import <objc/runtime.h>

#define kConrnerCorner  "UIView.privateConrnerCorner"
#define kConrnerBounds  "UIView.privateConrnerBounds"
#define kConrnerRadius  "UIView.privateConrnerRadius"

#define kBorderColor    "UIView.privateBorderColor"
#define kBorderWidth    "UIView.privateBorderWidth"

#define kShadowOpacity  "UIView.privateShadowOpacity"
#define kShadowRadius   "UIView.privateShadowRadius"
#define kShadowOffset   "UIView.privateShadowOffset"
#define kShadowColor    "UIView.privateShadowColor"

#define kBezierPath     "UIView.privateBezierPath"
#define kViewBounds     "UIView.privateViewBounds"

#define kBackgroundView "UIView.BackgroundView"

@implementation UIView (ShadowPath)
@dynamic conrnerCorner,
         conrnerRadius,
         borderColor,
         borderWidth,
         shadowColor,
         shadowOffset,
         shadowRadius,
         shadowOpacity,
         showVisual,
         clerVisual,
         bezierPath,
         viewBounds;

#pragma mark - 添加私有属性
// mark - 圆角 矩形 默认 AllCorners
- (void)setPrivateConrnerCorner:(TFYCornerClipType)corner {
    objc_setAssociatedObject(self, kConrnerCorner, [NSNumber numberWithInteger:corner], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TFYCornerClipType)privateConrnerCorner {
    id corner = objc_getAssociatedObject(self, kConrnerCorner);
    return corner ? [corner integerValue] : TFYCornerClipTypeAll;
}

// mark - 圆角 半径 默认 0.0
- (void)setPrivateConrnerRadius:(CGFloat)radius {
    objc_setAssociatedObject(self, kConrnerRadius, [NSNumber numberWithFloat:radius], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)privateConrnerRadius {
    id radius = objc_getAssociatedObject(self, kConrnerRadius);
    return radius ? [radius floatValue] : 0.0;
}

// mark - 边框 宽度 默认 0.0
- (void)setPrivateBorderWidth:(CGFloat)width {
    objc_setAssociatedObject(self, kBorderWidth, [NSNumber numberWithFloat:width], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)privateBorderWidth {
    id width = objc_getAssociatedObject(self, kBorderWidth);
    return width ? [width floatValue] : 0.0;
}

// mark - 边框 颜色 默认 黑色
- (void)setPrivateBorderColor:(UIColor *)color {
    objc_setAssociatedObject(self, kBorderColor, color, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)privateBorderColor {
    id color = objc_getAssociatedObject(self, kBorderColor);
    return color ? color : [UIColor blackColor];
}

// mark - 阴影 半径 默认 0.0
- (void)setPrivateShadowRadius:(CGFloat)opacity {
    objc_setAssociatedObject(self, kShadowOpacity, [NSNumber numberWithFloat:opacity], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)privateShadowRadius {
    id radius = objc_getAssociatedObject(self, kShadowOpacity);
    return radius ? [radius floatValue] : 0.0;
}

// mark - 阴影 模糊度 默认 0.0
- (void)setPrivateShadowOpacity:(CGFloat)radius {
    objc_setAssociatedObject(self, kShadowRadius, [NSNumber numberWithFloat:radius], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)privateShadowOpacity {
    id opacity = objc_getAssociatedObject(self, kShadowRadius);
    return opacity ? [opacity floatValue] : 0.0;
}

// mark - 阴影 偏移方向和距离 默认 {0.0，0.0}
- (void)setPrivateShadowOffset:(CGSize)offset {
    objc_setAssociatedObject(self, kShadowOffset, NSStringFromCGSize(offset), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGSize)privateShadowOffset {
    id offset = objc_getAssociatedObject(self, kShadowOffset);
    return offset ? CGSizeFromString(offset) : CGSizeZero;
}

// mark - 阴影 颜色 默认 black
- (void)setPrivateShadowColor:(UIColor *)color {
    objc_setAssociatedObject(self, kShadowColor, color, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)privateShadowColor {
    id color = objc_getAssociatedObject(self, kShadowColor);
    return color ? color : [UIColor blackColor];
}

// mark - 路径 默认 nil
- (void)setPrivateBezierPath:(UIBezierPath *)path {
    objc_setAssociatedObject(self, kBezierPath, path, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIBezierPath *)privateBezierPath {
    id path = objc_getAssociatedObject(self, kBezierPath);
    return path ? path : nil;
}

// mark - 视图 大小 默认 nil
- (void)setPrivateViewBounds:(CGRect)rect {
    objc_setAssociatedObject(self, kViewBounds, NSStringFromCGRect(rect), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)privateViewBounds {
    id path = objc_getAssociatedObject(self, kViewBounds);
    return path ? CGRectFromString(path) : CGRectZero;
}

// 阴影空视图，只在有圆角的时候使用
- (UIView *)shadowBackgroundView {
    return objc_getAssociatedObject(self, kBackgroundView);
}

- (void)setShadowBackgroundView:(UIView *)backgroundView {
    objc_setAssociatedObject(self, kBackgroundView, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 链式属性实现
- (ConrnerCorner)conrnerCorner {
    return ^(TFYCornerClipType corner) {
        self.privateConrnerCorner = corner;
        return self;
    };
}

- (ConrnerRadius)conrnerRadius {
    return ^(CGFloat radius) {
        self.privateConrnerRadius = radius;
        return self;
    };
}

- (BorderColor)borderColor {
    return ^(UIColor *color) {
        self.privateBorderColor = color;
        return self;
    };
}

- (BorderWidth)borderWidth {
    return ^(CGFloat width) {
        self.privateBorderWidth = width;
        return self;
    };
}

- (ShadowOpacity)shadowOpacity {
    return ^(CGFloat opacity) {
        self.privateShadowOpacity = opacity;
        return self;
    };
}

- (ShadowRadius)shadowRadius {
    return ^(CGFloat radius) {
        self.privateShadowRadius = radius;
        return self;
    };
}

- (ShadowOffset)shadowOffset {
    return ^(CGSize size) {
        self.privateShadowOffset = size;
        return self;
    };
}

- (ShadowColor)shadowColor {
    return ^(UIColor *color) {
        self.privateShadowColor = color;
        return self;
    };
}

- (BezierPath)bezierPath {
    return ^(UIBezierPath *path) {
        self.privateBezierPath = path;
        return self;
    };
}

- (ViewBounds)viewBounds {
    return ^(CGRect rect) {
        self.privateViewBounds = rect;
        return self;
    };
}

#pragma mark - 方法实现
- (ClerVisual)clerVisual {
    return ^{
        // 阴影
        if (self.shadowBackgroundView) {
            [self.shadowBackgroundView removeFromSuperview];
            self.shadowBackgroundView = nil;
        }
        
        // 圆角、边框
        for (CALayer *layer in self.layer.sublayers) {
            if ([layer.name isEqualToString:@"CCViewEffects"]) {
                [layer removeFromSuperlayer];
            }
        }
        
        // 恢复默认设置
        self.privateConrnerCorner = TFYCornerClipTypeAll;
        self.privateConrnerRadius = 0.0;
        self.privateBorderColor   = [UIColor blackColor];
        self.privateBorderWidth   = 0.0;
        self.privateShadowOpacity = 0.0;
        self.privateShadowRadius  = 0.0;
        self.privateShadowOffset  = CGSizeZero;
        self.privateViewBounds    = CGRectZero;
        self.privateShadowColor   = [UIColor blackColor];
        self.shadowBackgroundView = nil;
        
        self.layer.masksToBounds  = NO;
        self.layer.cornerRadius   = 0.0;
        self.layer.borderWidth    = 0.0;
        self.layer.borderColor    = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity  = 0.0;
        self.layer.shadowPath     = nil;
        self.layer.shadowRadius   = 0.0;
        self.layer.shadowColor    = [UIColor blackColor].CGColor;
        self.layer.shadowOffset   = CGSizeZero;
        self.layer.mask           = nil;
        return self;
    };
}

- (ShowVisual)showVisual {
    return ^{
        // 阴影
        [self addShadow];
        // 边框、圆角
        [self addBorderAndRadius];
        return self;
    };
}

#pragma mark - Private methods
-(CGRect)drawBounds {
    // 1.如果传入了大小，则直接返回
    if (!CGRectEqualToRect(self.privateViewBounds, CGRectZero)) {
        return self.privateViewBounds;
    }
    // 2.获取在自动布局时的视图大小
    if (self.superview != nil) {
        [self.superview layoutIfNeeded];
    }
    CGRect rect = self.bounds;
    return rect;
}

-(UIBezierPath *)drawBezierPath {
    if (self.privateBezierPath != nil) {
        return self.privateBezierPath;
    }
    return [UIBezierPath bezierPathWithRoundedRect:[self drawBounds]
                                 byRoundingCorners:(UIRectCorner)self.privateConrnerCorner
                                       cornerRadii:CGSizeMake(self.privateConrnerRadius, self.privateConrnerRadius)];
}

// 添加阴影
-(void)addShadow {
    UIView *shadowView = self;
    // 同时存在阴影和圆角
    if ((self.privateShadowOpacity > 0 && self.privateConrnerRadius > 0) || self.privateBezierPath) {
        if (self.shadowBackgroundView) {
            [self.shadowBackgroundView removeFromSuperview];
            self.shadowBackgroundView = nil;
        }
        NSAssert(self.superview, @"添加阴影和圆角时，请先将view加到父视图上");
        shadowView = [[UIView alloc] initWithFrame:self.frame];
        shadowView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superview insertSubview:shadowView belowSubview:self];
        [self.superview addConstraints:@[[NSLayoutConstraint constraintWithItem:shadowView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0],
                                         [NSLayoutConstraint constraintWithItem:shadowView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0],
                                         [NSLayoutConstraint constraintWithItem:shadowView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0],
                                         [NSLayoutConstraint constraintWithItem:shadowView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0]]];
        self.shadowBackgroundView = shadowView;
    }
    // 圆角
    if (self.privateConrnerRadius > 0 || self.privateBezierPath) {
        UIBezierPath *shadowPath = [self drawBezierPath];
        shadowView.layer.shadowPath = shadowPath.CGPath;
    }
    // 阴影
    shadowView.layer.masksToBounds = NO;
    shadowView.layer.shadowOpacity = self.privateShadowOpacity;
    shadowView.layer.shadowRadius  = self.privateShadowRadius;
    shadowView.layer.shadowOffset  = self.privateShadowOffset;
    shadowView.layer.shadowColor   = self.privateShadowColor.CGColor;
}

// 添加圆角和边框
-(void)addBorderAndRadius {
    // 圆角或阴影或自定义曲线
    if (self.privateConrnerRadius > 0 || self.privateShadowOpacity > 0 || self.privateBezierPath) {
        // 圆角
        if (self.privateConrnerRadius > 0 || self.privateBezierPath) {
            UIBezierPath *path = [self drawBezierPath];
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.frame = self.bounds;
            maskLayer.path  = path.CGPath;
            self.layer.mask = maskLayer;
        }
        // 边框
        if (self.privateBorderWidth > 0 || self.privateBezierPath) {
            for (CALayer *layer in self.layer.sublayers) {
                if ([layer.name isEqualToString:@"CCViewEffects"]) {
                    [layer removeFromSuperlayer];
                }
            }
            UIBezierPath *path = [self drawBezierPath];
            CAShapeLayer *layer = [[CAShapeLayer alloc]init];
            layer.name  = @"CCViewEffects";
            layer.frame = self.bounds;
            layer.path  = path.CGPath;
            layer.lineWidth   = self.privateBorderWidth;
            layer.strokeColor = self.privateBorderColor.CGColor;
            layer.fillColor   = [UIColor clearColor].CGColor;
            [self.layer addSublayer:layer];
        }
    } else {
        // 只有边框
        self.layer.masksToBounds = true;
        self.layer.borderWidth   = self.privateBorderWidth;
        self.layer.borderColor   = self.privateBorderColor.CGColor;
    }
}

-(void)addShdowColor:(UIColor *)shadowColor shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius shadowSide:(TFYShadowSide)shadowSide{
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowOpacity = shadowOpacity;
    
    // 默认值 0 -3
    // 使用默认值即可，这个各个边都要设置阴影的，自己调反而效果不是很好。
    //    self.layer.shadowOffset = CGSizeMake(0, -3);
    
    CGRect bounds = self.layer.bounds;
    CGFloat maxX = CGRectGetMaxX(bounds);
    CGFloat maxY = CGRectGetMaxY(bounds);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (shadowSide & TFYShadowSideTop) {
        // 上边
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(0, -shadowRadius)];
        [path addLineToPoint:CGPointMake(maxX, -shadowRadius)];
        [path addLineToPoint:CGPointMake(maxX, 0)];
    }
    
    if (shadowSide & TFYShadowSideRight) {
        // 右边
        [path moveToPoint:CGPointMake(maxX, 0)];
        [path addLineToPoint:CGPointMake(maxX,maxY)];
        [path addLineToPoint:CGPointMake(maxX + shadowRadius, maxY)];
        [path addLineToPoint:CGPointMake(maxX + shadowRadius, 0)];
    }
    
    if (shadowSide & TFYShadowSideBottom) {
        // 下边
        [path moveToPoint:CGPointMake(0, maxY)];
        [path addLineToPoint:CGPointMake(maxX,maxY)];
        [path addLineToPoint:CGPointMake(maxX, maxY + shadowRadius)];
        [path addLineToPoint:CGPointMake(0, maxY + shadowRadius)];
    }
    
    if (shadowSide & TFYShadowSideLeft) {
        // 左边
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(-shadowRadius,0)];
        [path addLineToPoint:CGPointMake(-shadowRadius, maxY)];
        [path addLineToPoint:CGPointMake(0, maxY)];
    }
    
    self.layer.shadowPath = path.CGPath;
}

/// 切上面两个圆角
- (void)setCornersTopLeftRight:(CGFloat)cornersTopLeftRight {
    objc_setAssociatedObject(self, @selector(cornersTopLeftRight), [NSNumber numberWithFloat:cornersTopLeftRight], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeBothTop).conrnerRadius(cornersTopLeftRight).showVisual();
}

- (CGFloat)cornersTopLeftRight {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersTopLeftRight));
    return number.floatValue;
}
/// 切下面两个圆角
- (void)setCornersBottomLeftRight:(CGFloat)cornersBottomLeftRight {
    objc_setAssociatedObject(self, @selector(cornersBottomLeftRight), [NSNumber numberWithFloat:cornersBottomLeftRight], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeBothBottom).conrnerRadius(cornersBottomLeftRight).showVisual();
}

- (CGFloat)cornersBottomLeftRight {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersBottomLeftRight));
    return number.floatValue;
}
/// 切全部圆角
- (void)setCornersAll:(CGFloat)cornersAll {
    objc_setAssociatedObject(self, @selector(cornersAll), [NSNumber numberWithFloat:cornersAll], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeAll).conrnerRadius(cornersAll).showVisual();
}

- (CGFloat)cornersAll {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersAll));
    return number.floatValue;
}
/// 切左边两个圆角
- (void)setCornersLeftTopBottom:(CGFloat)cornersLeftTopBottom {
    objc_setAssociatedObject(self, @selector(cornersLeftTopBottom), [NSNumber numberWithFloat:cornersLeftTopBottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeBothLeft).conrnerRadius(cornersLeftTopBottom).showVisual();
}

- (CGFloat)cornersLeftTopBottom {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersLeftTopBottom));
    return number.floatValue;
}
/// 切右边两个圆角
- (void)setCornersRightTopBottom:(CGFloat)cornersRightTopBottom {
    objc_setAssociatedObject(self, @selector(cornersRightTopBottom), [NSNumber numberWithFloat:cornersRightTopBottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeBothRight).conrnerRadius(cornersRightTopBottom).showVisual();
}

- (CGFloat)cornersRightTopBottom {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersRightTopBottom));
    return number.floatValue;
}

/// 切上左边圆角
- (void)setCornersTopLeft:(CGFloat)cornersTopLeft {
    objc_setAssociatedObject(self, @selector(cornersTopLeft), [NSNumber numberWithFloat:cornersTopLeft], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeTopLeft).conrnerRadius(cornersTopLeft).showVisual();
}

- (CGFloat)cornersTopLeft {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersTopLeft));
    return number.floatValue;
}

/// 切上右边圆角
- (void)setCornersTopRight:(CGFloat)cornersTopRight {
    objc_setAssociatedObject(self, @selector(cornersTopRight), [NSNumber numberWithFloat:cornersTopRight], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeTopRight).conrnerRadius(cornersTopRight).showVisual();
}

- (CGFloat)cornersTopRight {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersTopRight));
    return number.floatValue;
}

/// 切下左圆角
- (void)setCornersBottomLeft:(CGFloat)cornersBottomLeft {
    objc_setAssociatedObject(self, @selector(cornersBottomLeft), [NSNumber numberWithFloat:cornersBottomLeft], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeBottomLeft).conrnerRadius(cornersBottomLeft).showVisual();
}

- (CGFloat)cornersBottomLeft {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersBottomLeft));
    return number.floatValue;
}

- (void)setCornerRadiusAll:(CGFloat)cornerRadiusAll {
    objc_setAssociatedObject(self, @selector(cornerRadiusAll), [NSNumber numberWithFloat:cornerRadiusAll], OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 边框
    self.layer.borderWidth = 0.2;
    self.layer.borderColor = TFY_ColorHexString(@"#E5E5E5").CGColor;
    self.layer.cornerRadius = cornerRadiusAll;
    self.layer.masksToBounds = YES;
   // 阴影
    self.layer.shadowColor = TFY_ColorRGBAlpha(0, 0, 0, 0.15).CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 2;
    self.clipsToBounds = NO;
}

- (CGFloat)cornerRadiusAll {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornerRadiusAll));
    return number.floatValue;
}

/// 切下右圆角
- (void)setCornersBottomRight:(CGFloat)cornersBottomRight {
    objc_setAssociatedObject(self, @selector(cornersBottomRight), [NSNumber numberWithFloat:cornersBottomRight], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.conrnerCorner(TFYCornerClipTypeBottomRight).conrnerRadius(cornersBottomRight).showVisual();
}

- (CGFloat)cornersBottomRight {
    NSNumber *number = objc_getAssociatedObject(self, @selector(cornersBottomRight));
    return number.floatValue;
}

/// 阴影
- (void)setConrnersShowColor:(UIColor *)conrnersShowColor {
    objc_setAssociatedObject(self, @selector(conrnersShowColor),conrnersShowColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.shadowOpacity(1).shadowColor(conrnersShowColor).shadowRadius(7)
        .shadowOffset(CGSizeMake(5, 5)).conrnerRadius(8)
        .conrnerCorner(TFYCornerClipTypeAll)
        .showVisual();
}

- (UIColor *)conrnersShowColor {
    UIColor *color = objc_getAssociatedObject(self, @selector(conrnersShowColor));
    return color;
}

@end

