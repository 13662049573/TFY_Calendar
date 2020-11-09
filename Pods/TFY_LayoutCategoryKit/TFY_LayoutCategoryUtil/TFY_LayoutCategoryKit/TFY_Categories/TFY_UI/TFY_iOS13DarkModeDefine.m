//
//  TFY_iOS13DarkModeDefine.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_iOS13DarkModeDefine.h"
#import <objc/runtime.h>

const char * TFY_iOS13DarkMode_LightColor_Key = "TFY_iOS13DarkMode_LightColor_Key";
const char * TFY_iOS13DarkMode_DarkColor_Key = "TFY_iOS13DarkMode_DarkColor_Key";

const char * TFY_iOS13DarkMode_LayerBorderColor_Key = "TFY_iOS13DarkMode_LayerBorderColor_Key";
const char * TFY_iOS13DarkMode_LayerShadowColor_Key = "TFY_iOS13DarkMode_LayerShadowColor_Key";
const char * TFY_iOS13DarkMode_LayerBackgroundColor_Key = "TFY_iOS13DarkMode_LayerBackgroundColor_Key";

@implementation TFY_iOS13DarkModeDefine

+ (void)tfy_ExchangeClassMethodWithTargetCls:(Class)targetCls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    [self tfy_ExchangeMethodWithOriginalClass:targetCls swizzledClass:targetCls originalSelector:originalSelector swizzledSelector:swizzledSelector];
}

+ (void)tfy_ExchangeMethodWithOriginalClass:(Class)originalClass swizzledClass:(Class)swizzledClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    
    if (!originalMethod || !swizzledMethod) {return;}
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    const char *originalType = method_getTypeEncoding(originalMethod);
    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
    
    class_replaceMethod(originalClass,swizzledSelector,originalIMP,originalType);
    class_replaceMethod(originalClass,originalSelector,swizzledIMP,swizzledType);
}

@end
