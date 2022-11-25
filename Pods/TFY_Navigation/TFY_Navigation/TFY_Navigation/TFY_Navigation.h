//
//  TFY_Navigation.h
//  TFY_Model
//
//  Created by 田风有 on 2019/4/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//  最新版本号: 2.9.4

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double TFY_NavigationVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_NavigationVersionString[];

#define TFY_NavigationRelease 0

#if TFY_NavigationRelease

#import <TFY_NavControoler/TFY_NavigationController.h>

#else

//导航栏容器头文件
#import "TFY_NavigationController.h"


#endif




