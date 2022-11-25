//
//  TFY_WKWebView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@class TFY_WKWebView;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYWebViewDelegate <NSObject>

@optional
// 网页加载进度
- (void)webView:(TFY_WKWebView *)webView estimatedProgress:(CGFloat)progress;
// 网页标题更新
- (void)webView:(TFY_WKWebView *)webView didUpdateTitle:(NSString *)title;
// 网页开始加载
- (BOOL)webView:(TFY_WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType;
// 网页开始加载
- (void)webViewDidStartLoad:(TFY_WKWebView *)webView;
// 网页完成加载
- (void)webViewDidFinishLoad:(TFY_WKWebView *)webView;
// 网页加载出错
- (void)webView:(TFY_WKWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface TFY_WKWebView : WKWebView<WKNavigationDelegate>

// 代理
@property (nonatomic,assign) id<TFYWebViewDelegate> delegate;
// 是否显示进度条[默认 NO]
@property (nonatomic,assign) BOOL displayProgressBar;
// displayProgressBar为YES是可用
@property(nonatomic, strong) UIColor *progressTintColor;
// displayProgressBar为YES是可用
@property(nonatomic, strong) UIColor *trackTintColor;

/*
 缓存类型，这里清除所有缓存
 
 WKWebsiteDataTypeDiskCache,
 WKWebsiteDataTypeOfflineWebApplicationCache,
 WKWebsiteDataTypeMemoryCache,
 WKWebsiteDataTypeLocalStorage,
 WKWebsiteDataTypeCookies,
 WKWebsiteDataTypeSessionStorage,
 WKWebsiteDataTypeIndexedDBDatabases,
 WKWebsiteDataTypeWebSQLDatabases
 */

// 清缓存
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
