//
//  UIBezierPath+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/12/13.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_BezierPathMaker;

static CGFloat DirectionNorth = 1.5 * M_PI;
static CGFloat DirectionNorthEast = 1.75 * M_PI;
static CGFloat DirectionEast = 0.0 * M_PI;
static CGFloat DirectionSouthEast = 0.25 * M_PI;
static CGFloat DirectionSouth = 0.5 * M_PI;
static CGFloat DirectionSouthWest = 0.75 * M_PI;
static CGFloat DirectionWest = 1.0 * M_PI;
static CGFloat DirectionNorthWest = 1.25 * M_PI;

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (TFY_Tools)

+ (UIBezierPath *)makePath:(void(^)(TFY_BezierPathMaker *make))block;

- (UIBezierPath *)makePath:(void(^)(TFY_BezierPathMaker *make))block;

@end


@interface TFY_BezierPathMaker : NSObject

@property (readonly) UIBezierPath *bezierPath;

- (instancetype)initWithBezierPath:(UIBezierPath *)bezierPath;

/* Moves */

- (TFY_BezierPathMaker *(^)(CGPoint point))moveTo;
- (TFY_BezierPathMaker *(^)(CGFloat distance, CGFloat direction))move;
- (TFY_BezierPathMaker *(^)(CGFloat distance))moveUp;
- (TFY_BezierPathMaker *(^)(CGFloat distance))moveLeft;
- (TFY_BezierPathMaker *(^)(CGFloat distance))moveDown;
- (TFY_BezierPathMaker *(^)(CGFloat distance))moveRight;

/* Lines */

- (TFY_BezierPathMaker *(^)(CGPoint point))lineTo;
- (TFY_BezierPathMaker *(^)(CGFloat distance, CGFloat direction))line;
- (TFY_BezierPathMaker *(^)(CGFloat distance))lineUp;
- (TFY_BezierPathMaker *(^)(CGFloat distance))lineLeft;
- (TFY_BezierPathMaker *(^)(CGFloat distance))lineDown;
- (TFY_BezierPathMaker *(^)(CGFloat distance))lineRight;

/* Arcs */

- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, BOOL clockwise))arcAt;

/* Curves */

- (TFY_BezierPathMaker *(^)(CGPoint point, CGPoint controlPoint1, CGPoint controlPoint2))curveTo;

/* Quad curves */

- (TFY_BezierPathMaker *(^)(CGPoint point, CGPoint controlPoint))quadCurveTo;

/* Translations */

- (TFY_BezierPathMaker *(^)(CGAffineTransform transform))transform;
- (TFY_BezierPathMaker *(^)(CGPoint point))translate;
- (TFY_BezierPathMaker *(^)(CGSize size))scale;
- (TFY_BezierPathMaker *(^)(CGFloat angle))rotate;

/* Paths */

- (TFY_BezierPathMaker *(^)(UIBezierPath *path))path;

/* Rects */

- (TFY_BezierPathMaker *(^)(CGRect rect))rect;
- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius))rectAt;

/* Ovals */

- (TFY_BezierPathMaker *(^)(CGRect rect))oval;
- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius))ovalAt;

/* Rounded rects */

- (TFY_BezierPathMaker *(^)(CGRect rect, CGFloat cornerRadius))roundedRect;
- (TFY_BezierPathMaker *(^)(CGPoint center, CGFloat radius, CGFloat cornerRadius))roundedRectAt;

/* Closure */

- (TFY_BezierPathMaker *(^)(void))close;
- (TFY_BezierPathMaker *(^)(void))closed;


@end

NS_ASSUME_NONNULL_END
