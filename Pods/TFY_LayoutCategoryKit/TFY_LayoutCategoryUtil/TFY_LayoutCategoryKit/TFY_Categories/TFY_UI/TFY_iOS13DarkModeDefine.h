//
//  TFY_iOS13DarkModeDefine.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const char * TFY_iOS13DarkMode_LightColor_Key;
extern const char * TFY_iOS13DarkMode_DarkColor_Key;

extern const char * TFY_iOS13DarkMode_LayerBorderColor_Key;
extern const char * TFY_iOS13DarkMode_LayerShadowColor_Key;
extern const char * TFY_iOS13DarkMode_LayerBackgroundColor_Key;

@interface TFY_iOS13DarkModeDefine : NSObject

+ (void)tfy_ExchangeClassMethodWithTargetCls:(Class)targetCls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

+ (void)tfy_ExchangeMethodWithOriginalClass:(Class)originalClass swizzledClass:(Class)swizzledClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end

NS_ASSUME_NONNULL_END
