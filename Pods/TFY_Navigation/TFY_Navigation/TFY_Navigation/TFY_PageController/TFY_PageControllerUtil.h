//
//  TFY_PageControllerUtil.h
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_PageControllerConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PageControllerUtil : NSObject
//文字宽度
+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font size:(CGSize)size;

//颜色过渡
+ (UIColor *)colorTransformFrom:(UIColor*)fromColor to:(UIColor *)toColor progress:(CGFloat)progress;

//执行阴影动画
+ (void)showAnimationToShadow:(UIView *)shadow shadowWidth:(CGFloat)shadowWidth fromItemRect:(CGRect)fromItemRect toItemRect:(CGRect)toItemRect type:(TFY_PageShadowLineAnimationType)type progress:(CGFloat)progress;
@end

//------------------------------CUT------------------------------
/**
 兼容子view滚动，添加"让我先滚"属性
 */
@interface UIView (LetMeScroll)

/**
 让我先滚 默认 NO
 */
@property (nonatomic, assign) BOOL tfy_letMeScrollFirst;

@end

//------------------------------CUT------------------------------
/**
 子视图控制器的缓存，添加扩展标题
 */
@interface UIViewController (Title)

/**
 添加扩展标题
 */
@property (nonatomic, copy) NSString *tfy_title;

@end


//------------------------------CUT------------------------------

typedef BOOL(^TFY_OtherGestureRecognizerBlock)(UIGestureRecognizer *otherGestureRecognizer);

@interface UIScrollView (GestureRecognizer)<UIGestureRecognizerDelegate>

@property (nonatomic, copy) TFY_OtherGestureRecognizerBlock tfy_otherGestureRecognizerBlock;

@end

NS_ASSUME_NONNULL_END
