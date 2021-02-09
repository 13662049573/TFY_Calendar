//
//  UIBezierPath+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/12/13.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIBezierPath+TFY_Tools.h"

@implementation UIBezierPath (TFY_Tools)

+ (UIBezierPath *)makePath:(void(^)(TFY_BezierPathMaker *make))block {
    TFY_BezierPathMaker *maker = [[TFY_BezierPathMaker alloc] initWithBezierPath:[UIBezierPath bezierPath]];
    if (block) {
        block(maker);
    }
    return maker.bezierPath;
}

- (UIBezierPath *)makePath:(void(^)(TFY_BezierPathMaker *make))block {
    TFY_BezierPathMaker *maker = [[TFY_BezierPathMaker alloc] initWithBezierPath:[self copy]];
    if (block) {
        block(maker);
    }
    return maker.bezierPath;
}

@end

@implementation TFY_BezierPathMaker

- (instancetype)initWithBezierPath:(UIBezierPath *)bezierPath
{
    self = [self init];
    if (self) {
        _bezierPath = bezierPath;
    }
    return self;
}

#pragma mark - Moves

- (TFY_BezierPathMaker *(^)(CGPoint point))moveTo
{
    return ^TFY_BezierPathMaker *(CGPoint point) {
        [self.bezierPath moveToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance, CGFloat direction))move
{
    return ^TFY_BezierPathMaker *(CGFloat direction, CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x + distance * cos(direction), self.bezierPath.currentPoint.x + distance * sin(direction));
        [self.bezierPath moveToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))moveUp
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x, self.bezierPath.currentPoint.y - distance);
        [self.bezierPath moveToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))moveLeft
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x - distance, self.bezierPath.currentPoint.y);
        [self.bezierPath moveToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))moveDown
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x, self.bezierPath.currentPoint.y + distance);
        [self.bezierPath moveToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))moveRight
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x + distance, self.bezierPath.currentPoint.y);
        [self.bezierPath moveToPoint:point];
        return self;
    };
}

#pragma mark - Lines

- (TFY_BezierPathMaker *(^)(CGPoint point))lineTo
{
    return ^TFY_BezierPathMaker *(CGPoint point) {
        [self.bezierPath addLineToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance, CGFloat direction))line
{
    return ^TFY_BezierPathMaker *(CGFloat direction, CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x + distance * cos(direction), self.bezierPath.currentPoint.x + distance * sin(direction));
        [self.bezierPath addLineToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))lineUp
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x, self.bezierPath.currentPoint.y - distance);
        [self.bezierPath addLineToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))lineLeft
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x - distance, self.bezierPath.currentPoint.y);
        [self.bezierPath addLineToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))lineDown
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x, self.bezierPath.currentPoint.y + distance);
        [self.bezierPath addLineToPoint:point];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat distance))lineRight
{
    return ^TFY_BezierPathMaker *(CGFloat distance) {
        CGPoint point = CGPointMake(self.bezierPath.currentPoint.x + distance, self.bezierPath.currentPoint.y);
        [self.bezierPath addLineToPoint:point];
        return self;
    };
}

#pragma mark - Arcs

- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, BOOL clockwise))arcAt
{
    return ^TFY_BezierPathMaker *(CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, BOOL clockwise) {
        [self.bezierPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
        return self;
    };
}

#pragma mark - Curves

- (TFY_BezierPathMaker *(^)(CGPoint point, CGPoint controlPoint1, CGPoint controlPoint2))curveTo
{
    return ^TFY_BezierPathMaker *(CGPoint point, CGPoint controlPoint1, CGPoint controlPoint2) {
        [self.bezierPath addCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        return self;
    };
}

#pragma mark - Quad curves

- (TFY_BezierPathMaker *(^)(CGPoint point, CGPoint controlPoint))quadCurveTo
{
    return ^TFY_BezierPathMaker *(CGPoint point, CGPoint controlPoint) {
        [self.bezierPath addQuadCurveToPoint:point controlPoint:controlPoint];
        return self;
    };
}

#pragma mark - Transformations

- (TFY_BezierPathMaker *(^)(CGAffineTransform transform))transform
{
    return ^TFY_BezierPathMaker *(CGAffineTransform transform) {
        [self.bezierPath applyTransform:transform];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGPoint point))translate
{
    return ^TFY_BezierPathMaker *(CGPoint point) {
        [self.bezierPath applyTransform:CGAffineTransformMakeTranslation(point.x, point.y)];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGSize size))scale
{
    return ^TFY_BezierPathMaker *(CGSize size) {
        [self.bezierPath applyTransform:CGAffineTransformMakeScale(size.width, size.height)];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGFloat angle))rotate
{
    return ^TFY_BezierPathMaker *(CGFloat angle) {
        [self.bezierPath applyTransform:CGAffineTransformMakeRotation(angle)];
        return self;
    };
}

#pragma mark - Paths

- (TFY_BezierPathMaker *(^)(UIBezierPath *path))path
{
    return ^TFY_BezierPathMaker *(UIBezierPath *path) {
        [self.bezierPath appendPath:path];
        return self;
    };
}

#pragma mark - Rects

- (TFY_BezierPathMaker *(^)(CGRect rect))rect
{
    return ^TFY_BezierPathMaker *(CGRect rect) {
        [self.bezierPath appendPath:[UIBezierPath bezierPathWithRect:rect]];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius))rectAt
{
    return ^TFY_BezierPathMaker *(CGPoint center, CGFloat radius) {
        CGRect rect = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
        [self.bezierPath appendPath:[UIBezierPath bezierPathWithRect:rect]];
        return self;
    };
}

#pragma mark - Ovals

- (TFY_BezierPathMaker *(^)(CGRect rect))oval
{
    return ^TFY_BezierPathMaker *(CGRect rect) {
        [self.bezierPath appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius))ovalAt
{
    return ^TFY_BezierPathMaker *(CGPoint center, CGFloat radius) {
        CGRect rect = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
        [self.bezierPath appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
        return self;
    };
}

#pragma mark - Rounded rects

- (TFY_BezierPathMaker *(^)(CGRect rect, CGFloat cornerRadius))roundedRect
{
    return ^TFY_BezierPathMaker *(CGRect rect, CGFloat cornerRadius) {
        [self.bezierPath appendPath:[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius]];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius, CGFloat cornerRadius))roundedRectAt
{
    return ^TFY_BezierPathMaker *(CGPoint center, CGFloat radius, CGFloat cornerRadius) {
        CGRect rect = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
        [self.bezierPath appendPath:[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius]];
        return self;
    };
}

#pragma mark - Closure

- (TFY_BezierPathMaker *(^)(void))close
{
    return ^TFY_BezierPathMaker *(void){
        [self.bezierPath closePath];
        return self;
    };
}

- (TFY_BezierPathMaker *(^)(void))closed
{
    return [self close];
}


@end
