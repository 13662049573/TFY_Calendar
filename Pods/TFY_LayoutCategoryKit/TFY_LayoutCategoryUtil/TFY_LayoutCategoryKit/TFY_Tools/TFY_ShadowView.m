//
//  TFY_ShadowView.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/1/29.
//  Copyright © 2021 田风有. All rights reserved.
//

#import "TFY_ShadowView.h"

@interface TFY_ShadowView ()
@property(nonatomic, strong) UIColor        *shadowColor;
@property(nonatomic, assign) CGSize         shadowOffset;
@property(nonatomic, assign) CGFloat        shadowRadius;
@property(nonatomic, assign) NSInteger      shadowSide;

@property(nonatomic, assign) CGFloat        cornerRadius;
@property(nonatomic, assign) UIRectCorner   rectCorner;

@property(nonatomic, strong)UIView          *backContentView;

@property(nonatomic, strong)CALayer         *topShadowLayer;
@property(nonatomic, strong)CALayer         *botShadowLayer;
@property(nonatomic, strong)CALayer         *leftShadowLayer;
@property(nonatomic, strong)CALayer         *rightShadowLayer;
@property(nonatomic, strong)CAShapeLayer    *maskLayer;
@end

@implementation TFY_ShadowView

#pragma mark - init 初始化自身
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Life Cycle 生命周期的方法

#pragma mark - override 重载父类的方法
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.backContentView.backgroundColor = backgroundColor;
}

- (void)addSubview:(UIView *)view {
    if (view == _backContentView) {
        [super addSubview:view];
    } else {
        [self.backContentView addSubview:view];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backContentView.frame = self.bounds;
    [self _setShadowWithShadowRadius:self.shadowRadius shadowColor:self.shadowColor shadowOffset:self.shadowOffset byShadowSide:self.shadowSide];
    [self _setCornerRadius:self.cornerRadius byRoundingCorners:self.rectCorner];
}

#pragma mark - setupXxx Methods 初始化的方法
- (void)setup {
    [self addSubview:self.backContentView];
}

#pragma mark - public method 共有方法
- (void)shaodw {
    [self shaodwRadius:5 shadowColor:[UIColor colorWithWhite:0 alpha:0.3] shadowOffset:CGSizeMake(0, 0) byShadowSide:ShadowSideAllSides];
}
- (void)verticalShaodwRadius:(CGFloat)shadowRadius shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset {
    [self shaodwRadius:shadowRadius shadowColor:shadowColor shadowOffset:shadowOffset byShadowSide:ShadowSideTop|ShadowSideBottom];
}
- (void)horizontalShaodwRadius:(CGFloat)shadowRadius shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset {
    [self shaodwRadius:shadowRadius shadowColor:shadowColor shadowOffset:shadowOffset byShadowSide:ShadowSideLeft|ShadowSideRight];
}
- (void)shaodwRadius:(CGFloat)shadowRadius shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset byShadowSide:(ShadowTypeSide)shadowSide {
    _shadowRadius = shadowRadius;
    _shadowColor  = shadowColor;
    _shadowOffset = shadowOffset;
    _shadowSide   = shadowSide;
}
- (void)cornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    _rectCorner   = UIRectCornerAllCorners;
}
- (void)cornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners {
    _cornerRadius = cornerRadius;
    _rectCorner   = corners;
}

#pragma mark - Setter/Getter Methods set/get方法
- (UIView *)backContentView {
    if (!_backContentView) {
        _backContentView = [[UIView alloc] init];
        _backContentView.backgroundColor = [UIColor whiteColor];
        _backContentView.layer.masksToBounds = YES;
        _backContentView.clipsToBounds = YES;
        [self insertSubview:_backContentView atIndex:0];
    }
    return _backContentView;
}

- (CALayer *)topShadowLayer {
    if (!_topShadowLayer) {
        _topShadowLayer = [[CALayer alloc] init];
    }
    return _topShadowLayer;
}
- (CALayer *)botShadowLayer {
    if (!_botShadowLayer) {
        _botShadowLayer = [[CALayer alloc] init];
    }
    return _botShadowLayer;
}
- (CALayer *)leftShadowLayer {
    if (!_leftShadowLayer) {
        _leftShadowLayer = [[CALayer alloc] init];
    }
    return _leftShadowLayer;
}
- (CALayer *)rightShadowLayer {
    if (!_rightShadowLayer) {
        _rightShadowLayer = [[CALayer alloc] init];
    }
    return _rightShadowLayer;
}
- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [[CAShapeLayer alloc] init];
    }
    return _maskLayer;
}

#pragma mark - private method 私有方法
// 绘制圆角
- (void)_setCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners {
    
    if (cornerRadius <= 0) {
        return;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    self.maskLayer.frame = self.bounds;
    self.maskLayer.path = maskPath.CGPath;
    self.backContentView.layer.mask = self.maskLayer;
}

// 绘制阴影
- (void)_setShadowWithShadowRadius:(CGFloat)shadowRadius shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset byShadowSide:(ShadowTypeSide)shadowSide {

    if (shadowRadius <= 0) {
        return;
    }
    
    if (shadowSide & ShadowSideTop) {
        [self _setSingleSideShadowWithShadowRadius:shadowRadius shadowColor:shadowColor shadowOffset:shadowOffset byShadowSide:ShadowSideTop];
    }
    
    if (shadowSide & ShadowSideBottom) {
        [self _setSingleSideShadowWithShadowRadius:shadowRadius shadowColor:shadowColor shadowOffset:shadowOffset byShadowSide:ShadowSideBottom];
    }
    
    if (shadowSide & ShadowSideLeft) {
        [self _setSingleSideShadowWithShadowRadius:shadowRadius shadowColor:shadowColor shadowOffset:shadowOffset byShadowSide:ShadowSideLeft];
    }
    
    if (shadowSide & ShadowSideRight) {
        [self _setSingleSideShadowWithShadowRadius:shadowRadius shadowColor:shadowColor shadowOffset:shadowOffset byShadowSide:ShadowSideRight];
    }
}

// 绘制单边阴影
- (void)_setSingleSideShadowWithShadowRadius:(CGFloat)shadowRadius shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset byShadowSide:(ShadowTypeSide)shadowSide {
    
    CALayer *shadowLayer = nil;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (shadowSide & ShadowSideTop) {
        shadowLayer = self.topShadowLayer;
        shadowLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*0.5);
        [path moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.5, CGRectGetHeight(self.frame)*0.5)];
        [path addLineToPoint:(CGPointMake(0, 0))];
        [path addLineToPoint:(CGPointMake(CGRectGetWidth(self.frame), 0))];
    } else if (shadowSide & ShadowSideLeft) {
        shadowLayer = self.leftShadowLayer;
        shadowLayer.frame = CGRectMake(0, 0, CGRectGetHeight(self.frame)*0.5, CGRectGetHeight(self.frame));
        [path moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.5, CGRectGetHeight(self.frame)*0.5)];
        [path addLineToPoint:(CGPointMake(0, 0))];
        [path addLineToPoint:(CGPointMake(0, CGRectGetHeight(self.frame)))];
    } else if (shadowSide & ShadowSideRight) {
        shadowLayer = self.rightShadowLayer;
        shadowLayer.frame = CGRectMake(CGRectGetWidth(self.frame)*0.5, 0, CGRectGetWidth(self.frame)*0.5, self.frame.size.height);
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame)*0.5)];
        [path addLineToPoint:(CGPointMake(CGRectGetWidth(self.frame)*0.5, 0))];
        [path addLineToPoint:(CGPointMake(CGRectGetWidth(self.frame)*0.5, CGRectGetHeight(self.frame)))];
    } else if (shadowSide & ShadowSideBottom) {
        shadowLayer = self.botShadowLayer;
        shadowLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame)*0.5, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*0.5);
        [path moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.5, 0)];
        [path addLineToPoint:(CGPointMake(0, CGRectGetHeight(self.frame)*0.5))];
        [path addLineToPoint:(CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*0.5))];
    }
    
    [self.layer insertSublayer:shadowLayer atIndex:0];
    
    shadowLayer.masksToBounds = NO;
    
    CGFloat components[4];
    [self _getRGBAComponents:components forColor:_shadowColor];
    
    shadowLayer.shadowColor   = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0].CGColor;
    shadowLayer.shadowOpacity = components[3];
    shadowLayer.shadowRadius  = _shadowRadius;
    shadowLayer.shadowOffset  = CGSizeMake(0, 0);
    shadowLayer.shadowPath    = path.CGPath;
}

- (void)_getRGBAComponents:(CGFloat [4])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4] = {0};
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    CGFloat a = resultingPixel[3] / 255.0;
    CGFloat unpremultiply = (a != 0.0) ? 1.0 / a / 255.0 : 0.0;
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] * unpremultiply;
    }
    components[3] = a;
}

@end
