//
//  TFY_PopController.h
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_PopControllerAnimationProtocol.h"

typedef NS_ENUM(NSInteger, PopPosition) {
    PopPositionCenter,
    PopPositionTop,
    PopPositionBottom,
};

typedef NS_ENUM(NSInteger, PopState) {
    PopStatePop,      // present
    PopStateDismiss,  // dismiss
};

typedef NS_ENUM(NSInteger, PopType) {
    PopTypeNone,
    PopTypeFadeIn,
    PopTypeGrowIn,
    PopTypeShrinkIn,
    PopTypeSlideInFromTop,
    PopTypeSlideInFromBottom,
    PopTypeSlideInFromLeft,
    PopTypeSlideInFromRight,
    PopTypeBounceIn,
    PopTypeBounceInFromTop,
    PopTypeBounceInFromBottom,
    PopTypeBounceInFromLeft,
    PopTypeBounceInFromRight,
};

typedef NS_ENUM(NSInteger, DismissType) {
    DismissTypeNone,
    DismissTypeFadeOut,
    DismissTypeGrowOut,
    DismissTypeShrinkOut,
    DismissTypeSlideOutToTop,
    DismissTypeSlideOutToBottom,
    DismissTypeSlideOutToLeft,
    DismissTypeSlideOutToRight,
    DismissTypeBounceOut,
    DismissTypeBounceOutToTop,
    DismissTypeBounceOutToBottom,
    DismissTypeBounceOutToLeft,
    DismissTypeBounceOutToRight,
};


NS_ASSUME_NONNULL_BEGIN

@interface TFY_PopController : NSObject
/**
 *  流行动画风格
 */
@property (nonatomic, assign)PopType popType;
/**
 *  取消动画风格
 */
@property (nonatomic, assign)DismissType dismissType;
/**
 *  动画时长
 */
@property (nonatomic, assign)NSTimeInterval animationDuration;
/**
 *   弹出视图的最终位置。
 */
@property (nonatomic, assign)PopPosition popPosition;
/**
 * 弹出视图的偏移量。
 */
@property (nonatomic, assign) CGPoint positionOffset;
/**
 *  您可以自定义自己的动画以弹出和关闭。一旦设置了此属性，并且不为nil，popType`和`dismissType`将被忽略。
 */
@property (nonatomic, weak) id<TFY_PopControllerAnimationProtocol> animationProtocol;
@property (nonatomic, assign) UIEdgeInsets safeAreaInsets;
/**
 *  弹出时的背景。您可以将其设置为“ UIImageView”，“ UIVisualEffectView”等。
 */
@property (nullable, nonatomic, strong) UIView *backgroundView;
/**
 *  流行背景alpha。
 */
@property (nonatomic, assign) CGFloat backgroundAlpha;
/**
 *  确定要关闭的触摸背景
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;
/**
 *  握住弹出视图容器。默认backgroundColor为白色。默认拐角半径为8.0f。如果要自定义角落，请更改containerView图层。
 */
@property (nonatomic, strong, readonly) UIView *containerView;
/**
 *  哪个视图添加了弹出的ViewController视图。
 */
@property (nonatomic, strong, readonly) UIView *contentView;
/**
 *  topViewController是显示的viewController。
 */
@property (nonatomic, strong, readonly) UIViewController *topViewController;
@property (nonatomic, assign, readonly) BOOL presented;
/**
 *  初始化PopController
 */
- (instancetype)initWithViewController:(UIViewController *)presentedViewController;
/**
 *  弹出控制器
 */
- (void)presentInViewController:(UIViewController *)presentingViewController;

- (void)presentInViewController:(UIViewController *)presentingViewController completion:(nullable void (^)(void))completion;

- (void)dismiss;

- (void)dismissWithCompletion:(nullable void (^)(void))completion;

- (void)layoutContainerView;


@end

NS_ASSUME_NONNULL_END
