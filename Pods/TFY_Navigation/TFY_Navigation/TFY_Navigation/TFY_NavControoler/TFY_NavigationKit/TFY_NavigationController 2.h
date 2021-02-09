//
//  TFY_NavigationController.h
//
//  Created by 田风有 on 2019/03/27.
//  Copyright © 2019 恋机科技. All rights reserved.

#import <UIKit/UIKit.h>
#import "TFYCommon.h"

//仅限于内部使用
@interface TFYContainerNavigationController : UINavigationController
@end

@interface TFY_NavigationController : TFYContainerNavigationController
@end

@interface UIViewController (TFYNavigationContainer)
/**
 返回控制器的导航栏,默认`TFYContainerNavigationController.class`
 你可以通过定义`kTFYNavigationControllerClassName`这个宏来返回默认的导航栏,
 子类也可以通过重写这个方法返回单独的导航栏,
 如果你自定义了导航栏之后,记得自己处理状态栏和屏幕旋转等问题
 导航栏控制器类,必须是`UINavigationController`或其子类
 */
- (Class _Nonnull )tfy_navigationControllerClass;

- (TFY_NavigationController *_Nonnull)tfy_rootNavigationController;

@end

