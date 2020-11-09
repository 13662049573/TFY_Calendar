//
//  TFYCommon.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#ifndef TFYCommon_h
#define TFYCommon_h

#import <objc/runtime.h>

// 导航栏间距，用于不同控制器之间的间距
static const CGFloat TFYNavigationBarItemSpace = -1;

typedef NS_ENUM(NSUInteger, TFYNavigationBarBackStyle) {
    TFYNavigationBarBackStyleNone,    // 无返回按钮，可自行设置
    TFYNavigationBarBackStyleBlack,   // 黑色返回按钮
    TFYNavigationBarBackStyleWhite    // 白色返回按钮
};

#import "TFYNavigationBarConfigure.h"
#import "TFYNavigationBar.h"
#import "UIImage+TFYCategory.h"


#define TFY_Configure                    [TFYNavigationBarConfigure sharedInstance]

// 判断是否是iPhoneX系列手机
#define TFY_IS_iPhoneX                   [TFY_Configure tfy_isNotchedScreen]

// 判断是否是iPad
#define TFY_IS_iPad                      UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

// 屏幕相关
#define TFY_SCREEN_WIDTH                 [UIScreen mainScreen].bounds.size.width
#define TFY_SCREEN_HEIGHT                [UIScreen mainScreen].bounds.size.height
#define TFY_SAFEAREA_TOP                 [TFY_Configure tfy_safeAreaInsets].top      // 顶部安全区域
#define TFY_SAFEAREA_BTM                 [TFY_Configure tfy_safeAreaInsets].bottom   // 底部安全区域
#define TFY_STATUSBAR_HEIGHT             [TFY_Configure tfy_statusBarFrame].size.height  // 状态栏高度
#define TFY_NAVBAR_HEIGHT                44.0f   // 导航栏高度
#define TFY_STATUSBAR_NAVBAR_HEIGHT      (TFY_STATUSBAR_HEIGHT + TFY_NAVBAR_HEIGHT) // 状态栏+导航栏高度
#define TFY_TABBAR_HEIGHT                (TFY_SAFEAREA_BTM + 49.0f)  //tabbar高度


// 使用static inline创建静态内联函数，方便调用
CG_INLINE void tfy_swizzled_method(NSString *prefix, Class oldClass ,NSString *oldSelector, Class newClass) {
    NSString *newSelector = [NSString stringWithFormat:@"%@_%@", prefix, oldSelector];
    
    SEL originalSelector = NSSelectorFromString(oldSelector);
    SEL swizzledSelector = NSSelectorFromString(newSelector);
    
    Method originalMethod = class_getInstanceMethod(oldClass, NSSelectorFromString(oldSelector));
    Method swizzledMethod = class_getInstanceMethod(newClass, NSSelectorFromString(newSelector));
    
    BOOL isAdd = class_addMethod(oldClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isAdd) {
        class_replaceMethod(newClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#endif /* TFYCommon_h */
