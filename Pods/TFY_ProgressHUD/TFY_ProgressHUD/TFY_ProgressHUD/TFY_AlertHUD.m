//
//  TFY_AlertHUD.m
//  TFY_ProgressHUD
//
//  Created by 田风有 on 2023/7/22.
//  Copyright © 2023 恋机科技. All rights reserved.
//

#import "TFY_AlertHUD.h"
#import <UIKit/UIKit.h>

@interface TFY_AlertHUD ()
{
    TFY_ProgressHUD *_hud;
}
@end

@implementation TFY_AlertHUD

+ (TFY_AlertHUD *)shareInstance{
    static TFY_AlertHUD * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[TFY_AlertHUD alloc]init];
    });
    return macro;
}

-(UIImage *)tfy_fileImage:(NSString *)fileImage {
    return [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] pathForResource:@"TFY_ProgressHUD" ofType:@"bundle"] stringByAppendingPathComponent:fileImage]];
}

#pragma mark - HUD
- (void)setHudTextAttibute{
    _hud.detailsLabelFont = [UIFont systemFontOfSize:15];
}
- (void)showIndeterminate{
    [self showIndeterminateWithStatus:nil];
}
- (void)showIndeterminateWithStatus:(NSString *)status{
    if (_hud) {
        [self hide];
    }
    _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
    if (status) {
        _hud.detailsLabelText = status;
    }else{
        _hud.detailsLabelText = @"请稍等...";
    }
    [self setHudTextAttibute];
}
- (void)showSuccessWithStatus:(NSString *)status{
    if (_hud) {
        [self hide];
    }
    _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = ProgressHUDModeCustomView;
    UIImage *image = [[self tfy_fileImage:@"lg_hud_success"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    _hud.customView = [[UIImageView alloc] initWithImage:image];
    _hud.detailsLabelText = status;
    [self setHudTextAttibute];
    [_hud hide:YES afterDelay:2.0f];
}
- (void)showErrorWithStatus:(NSString *)status{
    if (_hud) {
        [self hide];
    }
    _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = ProgressHUDModeCustomView;
    UIImage *image = [[self tfy_fileImage:@"lg_hud_error"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    _hud.customView = [[UIImageView alloc] initWithImage:image];
    _hud.detailsLabelText = status;
     [self setHudTextAttibute];
    [_hud hide:YES afterDelay:2.0f];
}
- (void)showErrorWithError:(NSError *)error{
    NSString *errorDesc = error.localizedDescription;
    if (!errorDesc || errorDesc.length == 0) {
        errorDesc = @"未知错误";
    }
    [self showErrorWithStatus:errorDesc];
}
- (void)showInfoWithStatus:(NSString *)status{
    if (_hud) {
        [self hide];
    }
    _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = ProgressHUDModeCustomView;
    UIImage *image = [[self tfy_fileImage:@"lg_hud_warning"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    _hud.customView = [[UIImageView alloc] initWithImage:image];
    _hud.detailsLabelText = status;
     [self setHudTextAttibute];
    [_hud hide:YES afterDelay:2.0f];
}
- (void)showStatus:(NSString *)status{
    if (_hud) {
        [self hide];
    }
    _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = ProgressHUDModeText;
    _hud.detailsLabelText = status;
     [self setHudTextAttibute];
    _hud.yOffset = ([UIScreen mainScreen].bounds.size.height -64)/2 - 100;
    [_hud hide:YES afterDelay:2.0f];
}
- (void)showRedStatus:(NSString *)status{
    if (_hud) {
        [self hide];
    }
    _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = ProgressHUDModeText;
    _hud.detailsLabelText = status;
    _hud.detailsLabelColor = [UIColor redColor];
     [self setHudTextAttibute];
    _hud.yOffset = ([UIScreen mainScreen].bounds.size.height -64)/2 - 100;
    [_hud hide:YES afterDelay:2.0f];
}

- (void)showBarDeterminateWithProgress:(CGFloat)progress{
    [self showBarDeterminateWithProgress:progress status:@"上传中..."];
}

- (void)showBarDeterminateWithProgress:(CGFloat)progress status:(NSString *)status {
    if (_hud && _hud.mode != ProgressHUDModeDeterminateHorizontalBar) {
        [self hide];
    }
    if (!_hud) {
        _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
        _hud.detailsLabelText = status;
        _hud.mode = ProgressHUDModeDeterminateHorizontalBar;
    }
    _hud.progress = progress;
    _hud.detailsLabelText = status;
    if (progress >= 1) {
        _hud.detailsLabelText = @"已完成";
        [self hide];
    }
}

- (void)showRoundDeterminateWithProgress:(CGFloat)progress {
    [self showRoundDeterminateWithProgress:progress status:@"上传中..."];
}

- (void)showRoundDeterminateWithProgress:(CGFloat)progress status:(nullable NSString *)status {
    if (_hud && _hud.mode != ProgressHUDModeDeterminate) {
        [self hide];
    }
    if (!_hud) {
        _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
        _hud.detailsLabelText = status;
        _hud.mode = ProgressHUDModeDeterminate;
    }
    _hud.progress = progress;
    _hud.detailsLabelText = status;
    if (progress >= 1) {
        _hud.detailsLabelText = @"已完成";
        [self hide];
    }
}

- (void)showWithProgress:(CGFloat)progress Mode:(ProgressHUDMode)mode status:(nullable NSString *)status {
    if (_hud && _hud.mode != mode) {
        [self hide];
    }
    if (!_hud) {
        _hud = [TFY_ProgressHUD showHUDAddedTo:[self appKeyWindow] animated:YES];
        _hud.detailsLabelText = status;
        _hud.mode = mode;
    }
    _hud.progress = progress;
    _hud.detailsLabelText = status;
    if (progress >= 1) {
        _hud.detailsLabelText = @"已完成";
        [self hide];
    }
}

- (void)hide{
    [_hud hide:YES];
    _hud = nil;
}

- (UIWindow *)appKeyWindow {
    UIWindow *keywindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                if (@available(iOS 15.0, *)) {
                    keywindow = scene.keyWindow;
                }
                if (keywindow == nil) {
                    for (UIWindow *window in scene.windows) {
                        if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO && CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                            keywindow = window;
                            break;
                        }
                    }
                }
            }
        }
    }
    return keywindow;
}

@end
