//
//  UIView+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

/**切圆角*/
typedef NS_OPTIONS (NSUInteger, CornerClipType) {
    CornerClipTypeNone = 0,  // 不切
    CornerClipTypeTopLeft     = UIRectCornerTopLeft, // 左上角
    CornerClipTypeTopRight    = UIRectCornerTopRight, // 右上角
    CornerClipTypeBottomLeft  = UIRectCornerBottomLeft, // 左下角
    CornerClipTypeBottomRight = UIRectCornerBottomRight, // 右下角
    CornerClipTypeAll  = UIRectCornerAllCorners,// 全部四个角
    // 上面2个角
    CornerClipTypeBothTop  = CornerClipTypeTopLeft | CornerClipTypeTopRight,
    // 下面2个角
    CornerClipTypeBothBottom  = CornerClipTypeBottomLeft | CornerClipTypeBottomRight,
    // 左侧2个角
    CornerClipTypeBothLeft  = CornerClipTypeTopLeft | CornerClipTypeBottomLeft,
    // 右面2个角
    CornerClipTypeBothRight  = CornerClipTypeTopRight | CornerClipTypeBottomRight
};
/**加边框*/
typedef NS_OPTIONS(NSInteger, BorderDirection){
    BorderDirectionLeft = 1 << 1,
    BorderDirectionTop = 1 << 2,
    BorderDirectionRight = 1 << 3,
    BorderDirectionBottom = 1 << 4,
};

typedef void(^TouchCallBackBlock)(void);

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

- (CGPoint)tfy_convertPointTo:(CGPoint)point :(UIView *)view;

- (CGPoint)tfy_convertPointFrom:(CGPoint)point :(UIView *)view;

- (CGRect)tfy_convertRectTo:(CGRect)rect :(UIView *)view;

- (CGRect)tfy_convertRectFrom:(CGRect)rect :(UIView *)view;

#pragma mark - draw -
- (CAShapeLayer *)tfy_setCornerRadiusAngle:(UIRectCorner)corner cornerSize:(CGSize)size;

- (CALayer *)tfy_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

- (CALayer *)tfy_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor;

/**
 *  获取当前tabBarController
 */
- (UITabBarController *_Nonnull)tfy_tabBarController;
/**
 *  添加四边阴影 shadowColor 颜色  shadowRadius 半径 shadowOpacity 透明度  setShadow 大小
 */
-(void)tfy_setShadow:(CGSize)size shadowOpacity:(CGFloat)opacity shadowRadius:(CGFloat)radius shadowColor:(UIColor *)color;

#pragma mark-------------------------------------点击事件方法---------------------------------

/**
 *  添加点击事件
 */
@property (nonatomic, copy) TouchCallBackBlock touchCallBackBlock;

- (void)tfy_addActionWithblock:(TouchCallBackBlock)block;

- (void)tfy_addTarget:(id)target action:(SEL)action;

#pragma mark-------------------------------------添加圆角方法---------------------------------

/**圆角*/
@property(nonatomic, assign) CGFloat tfy_clipRadius;
@property(nonatomic, assign) CornerClipType tfy_clipType;

/**border*/
@property(nonatomic, assign) CGFloat tfy_borderWidth;
@property(nonatomic, strong) UIColor *tfy_borderColor;

/**
 * 便捷添加圆角 clipType 圆角类型  radius 圆角角度
 */
- (void)tfy_clipWithType:(CornerClipType)clipType radius:(CGFloat)radius;

/**
 * 便捷给添加border  color 边框的颜色  borderWidth 边框的宽度
 */
- (void)tfy_addBorderWithColor:(UIColor *_Nonnull)color borderWidth:(CGFloat)borderWidth;

#pragma mark-------------------------------------加边框方法---------------------------------

/** 使用layer的borderWidth统一设置*/
- (void)tfy_addBorderWithInset:(UIEdgeInsets)inset Color:(UIColor *_Nonnull)borderColor direction:(BorderDirection)directions;

/**使用layer的borderColor统一设置*/
- (void)tfy_addBorderWithInset:(UIEdgeInsets)inset BorderWidth:(CGFloat)borderWidth direction:(BorderDirection)directions;


/**各项的间距为UIEdgeInsetsZero*/
- (void)tfy_addBorderWithColor:(UIColor *_Nonnull)borderColor BodrerWidth:(CGFloat)borderWidth direction:(BorderDirection)directions;

/**自定义的layer设置*/
- (void)tfy_addBorderWithInset:(UIEdgeInsets)inset Color:(UIColor *_Nonnull)borderColor BorderWidth:(CGFloat)borderWidth direction:(BorderDirection)directions;

/** 移除当前边框*/
- (void)tfy_removeBorders:(BorderDirection)directions;

/**移除所有追加的边框*/
- (void)tfy_removeAllBorders;

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
