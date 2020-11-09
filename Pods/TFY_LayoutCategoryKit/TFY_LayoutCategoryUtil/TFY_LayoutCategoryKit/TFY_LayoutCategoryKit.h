//
//  TFY_LayoutCategoryKit.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 田风有. All rights reserved.
//  最新版本号：1.6.8

/**
  使用说明：
  只要是类别的方法，所有方法前面，都会加 tfy_   如：[self.window tfy_showOnScene:scene];
  如果是单列，或者一些工具方法，前面没有加任何修饰。  如：[TFY_Utils judgeIsEmptyWithString:@""];
*/

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double TFY_LayoutCategoryKitVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_LayoutCategoryKitVersionString[];

#define TFY_LayoutCategoryKitRelease 0

#if TFY_LayoutCategoryKitRelease

#import <TFY_Categories/TFY_CategoriesHeader.h>
#import <TFY_Chain/TFY_ChainHeader.h>
#import <TFY_Tools/TFY_ToolsHeader.h>

#else

/**类别*/
#import "TFY_CategoriesHeader.h"
/**连式编程*/
#import "TFY_ChainHeader.h"
/**额外工具*/
#import "TFY_ToolsHeader.h"

#endif
