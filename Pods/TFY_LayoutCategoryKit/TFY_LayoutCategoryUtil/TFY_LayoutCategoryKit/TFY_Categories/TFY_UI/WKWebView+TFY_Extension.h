//
//  WKWebView+TFY_Extension.h
//  TFY_CHESHI
//
//  Created by 田风有 on 2019/3/29.
//  Copyright © 2019 田风有. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (TFY_Extension)
//显示加载网页的进度条
- (void)tfy_showProgressWithColor:(UIColor *)color;

- (void )tfy_screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;

@end


NS_ASSUME_NONNULL_END
