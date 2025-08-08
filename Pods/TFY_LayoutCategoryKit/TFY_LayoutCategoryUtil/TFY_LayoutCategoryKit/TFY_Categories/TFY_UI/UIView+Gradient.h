//
//  UIView+Gradient.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/7/14.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Gradient)

@property CGPoint tfy_startPoint;
@property CGPoint tfy_endPoint;

@property(nullable, copy) NSArray *tfy_colors;
@property(nullable, copy) NSArray<NSNumber *> *tfy_locations;

+ (UIView *_Nullable)tfy_gradientViewWithColors:(NSArray<UIColor *> *_Nullable)colors locations:(NSArray<NSNumber *> *_Nullable)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)tfy_setGradientBackgroundWithColors:(NSArray<UIColor *> *_Nullable)colors locations:(NSArray<NSNumber *> *_Nullable)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end

NS_ASSUME_NONNULL_END
