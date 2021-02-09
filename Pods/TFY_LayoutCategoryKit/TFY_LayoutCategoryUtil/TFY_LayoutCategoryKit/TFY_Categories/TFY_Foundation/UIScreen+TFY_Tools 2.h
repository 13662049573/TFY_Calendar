//
//  UIScreen+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (TFY_Tools)

+ (CGFloat)tfy_scale;

+ (CGRect)tfy_bounds;

+ (CGSize)tfy_size;

+ (CGFloat)tfy_width;

+ (CGFloat)tfy_height;
/**
 宽度，恒定
 */
+ (CGFloat)tfy_screenWidth;
/**
 高度，恒定
 */
+ (CGFloat)tfy_screenHeight;

/**
 适配比例
 */
+ (CGFloat)tfy_screenScale;
/**
 当前设备屏幕边界
 */
- (CGRect)tfy_currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");

- (CGRect)tfy_boundsForOrientation:(UIInterfaceOrientation)orientation;

@end

/** 主窗口 */
CG_INLINE UIWindow* TFY_KeyWindow() {
    return [UIApplication sharedApplication].delegate.window;
}
/**主窗口*/
CG_INLINE void TFY_MakeKeyWindow() {
    return [[UIApplication sharedApplication].delegate.window makeKeyWindow];
}

/** 是否是竖屏*/
CG_INLINE BOOL TFY_isPortrait() {
    return  ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ||  [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown ) ?YES:NO;
}

/**屏幕高*/
CG_INLINE CGFloat TFY_Height_H() {
    return [UIScreen tfy_screenHeight];
}
/**屏幕宽*/
CG_INLINE CGFloat TFY_Width_W() {
    return [UIScreen tfy_screenWidth];
}
/**是配比*/
CG_INLINE CGFloat TFY_SCALE() {
    return [UIScreen tfy_screenScale];
}

/**等比宽*/
CG_INLINE CGFloat TFY_DEBI_width(CGFloat width) {
    return width *(TFY_isPortrait() ?(375/TFY_Width_W()):(TFY_Height_H()/375));
}
/**等比高*/
CG_INLINE CGFloat TFY_DEBI_height(CGFloat height) {
    return height *(TFY_isPortrait() ?(667/TFY_Height_H()):(TFY_Width_W()/667));
}

/**是否是苹果iPhoneX以上机型*/
CG_INLINE BOOL TFY_iPhoneX() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO);
}
/**导航栏高度*/
CG_INLINE CGFloat TFY_kNavBarHeight() {
    return (TFY_iPhoneX() ? 88.0 : 64.0);
}
/**底部工具高度*/
CG_INLINE CGFloat TFY_kBottomBarHeight() {
    return (TFY_iPhoneX() ? 83.0 : 49.0);
}
/**导航栏状态栏高度*/
CG_INLINE CGFloat TFY_kNavTimebarHeight() {
    return (TFY_iPhoneX() ? 44.0 : 20.0);
}
/**去除导航栏和底部工具栏剩余高度*/
CG_INLINE CGFloat TFY_kContentHeight() {
    return (TFY_Height_H() - TFY_kNavBarHeight() - TFY_kBottomBarHeight());
}

/**弧度 --> 角度（ π --> 180° ）*/
CG_INLINE CGFloat TFY_RadianAngle(CGFloat radian) {
    return (radian * 180.0) / M_PI;
}

/**角度 --> 弧度（ 180° -->  π  ）*/
CG_INLINE CGFloat TFY_AngleRadian(CGFloat angle) {
    return (angle / 180.0) * M_PI;
}


NS_ASSUME_NONNULL_END
