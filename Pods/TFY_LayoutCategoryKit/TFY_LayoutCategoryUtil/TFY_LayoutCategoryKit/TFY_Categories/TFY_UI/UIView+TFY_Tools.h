//
//  UIView+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TFY_Tools)
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;

- (void)tfy_removeAllSubViews;

- (UIViewController *)tfy_viewController;

- (CGFloat)tfy_visibleAlpha;

- (UIImage *)tfy_snapshotImage;

- (UIImage *)tfy_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

- (NSData *)tfy_snapshotPDF;

#pragma mark - convert -

- (CGPoint)tfy_convertPointTo:(CGPoint)point subView:(UIView *)view;

- (CGPoint)tfy_convertPointFrom:(CGPoint)point subView:(UIView *)view;

- (CGRect)tfy_convertRectTo:(CGRect)rect subView:(UIView *)view;

- (CGRect)tfy_convertRectFrom:(CGRect)rect subView:(UIView *)view;

#pragma mark - draw -
- (CAShapeLayer *)tfy_setCornerRadiusAngle:(UIRectCorner)corner cornerSize:(CGSize)size;

- (CALayer *)tfy_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

- (CALayer *)tfy_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor;


/**
 *  获取当前tabBarController
 */
- (UITabBarController *_Nonnull)tfy_tabBarController;

/**暗黑设置*/
- (void)tfy_setiOS13DarkModeColor:(UIColor *)color forProperty:(NSString *)property;

#pragma mark-------------------------------------手势点击添加方法---------------------------------

/**
 *  添加Tap手势事件  target 事件目标  vaction 事件  返回添加的手势
 */
- (UITapGestureRecognizer *)tfy_addGestureTapTarget:(id)target action:(SEL)action;

/**
 *  添加Pan手势事件  target 事件目标  action 事件  返回添加的手势
 */
- (UIPanGestureRecognizer *)tfy_addGesturePanTarget:(id)target action:(SEL)action;

/**
 *  添加Pinch手势事件   target 事件目标  action 事件  返回添加的手势
 */
- (UIPinchGestureRecognizer *)tfy_addGesturePinchTarget:(id)target action:(SEL)action;

/**
 *  添加LongPress手势事件  target 事件目标  action 事件  返回添加的手势
 */
- (UILongPressGestureRecognizer *)tfy_addGestureLongPressTarget:(id)target action:(SEL)action;

/**
 *  添加Swipe手势事件  target 事件目标  action 事件  返回添加的手势
 */
- (UISwipeGestureRecognizer *)tfy_addGestureSwipeTarget:(id)target action:(SEL)action;

/**
 *  添加Rotation手势事件  target 事件目标  action 事件  返回添加的手势
 */
- (UIRotationGestureRecognizer *)tfy_addGestureRotationTarget:(id)target action:(SEL)action;

/**
 *  添加ScreenEdgePan手势事件  target 事件目标  action 事件  返回添加的手势
 */
- (UIScreenEdgePanGestureRecognizer *)tfy_addGestureScreenEdgePanTarget:(id)target action:(SEL)action;

#pragma  mark---------------------手势回调------------------------------

/**
 *  添加Tap手势block事件  event block事件  返回添加的手势
 */
- (UITapGestureRecognizer *)tfy_addGestureTapEventHandle:(void (^)(id sender, UITapGestureRecognizer *gestureRecognizer))event;

/**
 *  添加Pan手势block事件  event block事件   返回添加的手势
 */
- (UIPanGestureRecognizer *)tfy_addGesturePanEventHandle:(void (^)(id sender, UIPanGestureRecognizer *gestureRecognizer))event;

/**
 *  添加Pinch手势block事件  event block事件  返回添加的手势
 */
- (UIPinchGestureRecognizer *)tfy_addGesturePinchEventHandle:(void (^)(id sender, UIPinchGestureRecognizer *gestureRecognizer))event;

/**
 *  添加LongPress手势block事件  event block事件  返回添加的手势
 */
- (UILongPressGestureRecognizer *)tfy_addGestureLongPressEventHandle:(void (^)(id sender, UILongPressGestureRecognizer *gestureRecognizer))event;

/**
 *  添加Swipe手势block事件  event block事件  返回添加的手势
 */
- (UISwipeGestureRecognizer *)tfy_addGestureSwipeEventHandle:(void (^)(id sender, UISwipeGestureRecognizer *gestureRecognizer))event;

/**
 *  添加Rotation手势block事件  event block事件  返回添加的手势
 */
- (UIRotationGestureRecognizer *)tfy_addGestureRotationEventHandle:(void (^)(id sender, UIRotationGestureRecognizer *gestureRecognizer))event;

/**
 *  添加ScreenEdgePan手势block事件  event block事件  返回添加的手势
 */
- (UIScreenEdgePanGestureRecognizer *)tfy_addGestureScreenEdgePanEventHandle:(void (^)(id sender, UIScreenEdgePanGestureRecognizer *gestureRecognizer))event;


@end

NS_ASSUME_NONNULL_END
