//
//  UIView+Gradient.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/7/14.
//  Copyright © 2021 田风有. All rights reserved.
//

#import "UIView+Gradient.h"
#import <objc/runtime.h>


@implementation UIView (Gradient)

+ (Class)layerClass {
    return [CAGradientLayer class];
}

+ (UIView *)tfy_gradientViewWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UIView *view = [[self alloc] init];
    [view tfy_setGradientBackgroundWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    return view;
}

- (void)tfy_setGradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *color in colors) {
        [colorsM addObject:(__bridge id)color.CGColor];
    }
    self.tfy_colors = [colorsM copy];
    self.tfy_locations = locations;
    self.tfy_startPoint = startPoint;
    self.tfy_endPoint = endPoint;
}

#pragma mark- Getter&Setter

- (NSArray *)tfy_colors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTfy_colors:(NSArray *)colors {
    objc_setAssociatedObject(self, @selector(tfy_colors), colors, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setColors:self.tfy_colors];
    }
}

- (NSArray<NSNumber *> *)tfy_locations {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTfy_locations:(NSArray<NSNumber *> *)locations {
    objc_setAssociatedObject(self, @selector(tfy_locations), locations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setLocations:self.tfy_locations];
    }
}

- (CGPoint)tfy_startPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setTfy_startPoint:(CGPoint)startPoint {
    objc_setAssociatedObject(self, @selector(tfy_startPoint), [NSValue valueWithCGPoint:startPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setStartPoint:self.tfy_startPoint];
    }
}

- (CGPoint)tfy_endPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setTfy_endPoint:(CGPoint)endPoint {
    objc_setAssociatedObject(self, @selector(tfy_endPoint), [NSValue valueWithCGPoint:endPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setEndPoint:self.tfy_endPoint];
    }
}

@end

@implementation UILabel (Gradient)

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end

