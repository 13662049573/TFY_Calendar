//
//  UIScreen+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIScreen+TFY_Tools.h"
#import "UIDevice+TFY_Tools.h"

@implementation UIScreen (TFY_Tools)

+ (CGFloat)tfy_scale{
    static CGFloat screenScale = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([NSThread isMainThread]) {
            screenScale = [[UIScreen mainScreen] scale];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                screenScale = [[UIScreen mainScreen] scale];
            });
        }
    });
    return screenScale;
}

+ (CGRect)tfy_bounds{
    return [UIScreen mainScreen].bounds;
}

+ (CGSize)tfy_size{
    return [UIScreen tfy_bounds].size;
}

+ (CGFloat)tfy_width{
    return [UIScreen tfy_size].width;
}

+ (CGFloat)tfy_height{
    return [UIScreen tfy_size].height;
}

+ (CGFloat)tfy_screenWidth{
    static CGFloat width = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = [UIScreen tfy_size];
        width = size.height < size.width?size.height:size.width;
    });
    return width;
}

+ (CGFloat)tfy_screenHeight{
    static CGFloat height = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = [UIScreen tfy_size];
        height = size.height > size.width?size.height:size.width;
    });
    return height;
}

+ (CGFloat)tfy_screenScale{
    static CGFloat scale = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [[UIDevice currentDevice] tfy_isPad]?1:ceil([UIScreen tfy_screenWidth] / 375 * 100) /100.0;
    });
    return scale;
}

/**
 当前设备屏幕边界
 */
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (CGRect)tfy_currentBounds {
    return [self tfy_boundsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
#endif

- (CGRect)tfy_boundsForOrientation:(UIInterfaceOrientation)orientation{
    CGRect bounds = [self bounds];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat buffer = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = buffer;
    }
    return bounds;
}

@end
