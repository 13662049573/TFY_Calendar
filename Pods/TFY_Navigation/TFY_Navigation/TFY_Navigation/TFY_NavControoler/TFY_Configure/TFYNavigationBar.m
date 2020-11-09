//
//  TFYNavigationBar.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFYNavigationBar.h"
#import "TFYCommon.h"

@implementation TFYNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置默认透明度
        self.tfy_navBarBackgroundAlpha = 1.0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 这里为了适配iOS11，需要遍历所有的子控件，并向下移动状态栏的高度
    if (@available(iOS 11.0, *)) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                CGRect frame = obj.frame;
                frame.size.height = self.frame.size.height;
                obj.frame = frame;
            }else {
                CGFloat width  = [UIScreen mainScreen].bounds.size.width;
                CGFloat height = [UIScreen mainScreen].bounds.size.height;
                
                CGFloat y = 0;
                
                if (width > height) {   // 横屏
                    if (TFY_IS_iPhoneX) {
                        y = 0;
                    }else {
                        y = self.tfy_statusBarHidden ? 0 : TFY_STATUSBAR_HEIGHT;
                    }
                }else {
                    y = self.tfy_statusBarHidden ? TFY_SAFEAREA_TOP : TFY_STATUSBAR_HEIGHT;
                }
        
                CGRect frame   = obj.frame;
                frame.origin.y = y;
                obj.frame      = frame;
            }
        }];
    }
    
    // 重新设置透明度，解决iOS11的bug
    self.tfy_navBarBackgroundAlpha = self.tfy_navBarBackgroundAlpha;
    
    // 显隐分割线
    [self tfy_navLineHideOrShow];
}

- (void)tfy_navLineHideOrShow {
    UIView *backgroundView = self.subviews.firstObject;
    
    for (UIView *view in backgroundView.subviews) {
        if (view.frame.size.height <= 1.0 && view.frame.size.height > 0) {
            view.hidden = self.tfy_navLineHidden;
        }
    }
}

- (void)setTfy_navBarBackgroundAlpha:(CGFloat)tfy_navBarBackgroundAlpha {
    _tfy_navBarBackgroundAlpha = tfy_navBarBackgroundAlpha;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (@available(iOS 10.0, *)) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (obj.alpha != tfy_navBarBackgroundAlpha) {
                        obj.alpha = tfy_navBarBackgroundAlpha;
                    }
                });
            }
        }else if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (obj.alpha != tfy_navBarBackgroundAlpha) {
                    obj.alpha = tfy_navBarBackgroundAlpha;
                }
            });
        }
    }];
    
    BOOL isClipsToBounds = (tfy_navBarBackgroundAlpha == 0.0f);
    if (self.clipsToBounds != isClipsToBounds) {
        self.clipsToBounds = isClipsToBounds;
    }
}

@end
