//
//  TFY_WebViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseScrollViewChainModel.h"
#if __has_include(<WebKit/WebKit.h>)
#import <WebKit/WebKit.h>
#else
@import WebKit;
#endif
NS_ASSUME_NONNULL_BEGIN
@class TFY_WebViewChainModel;
@interface TFY_WebViewChainModel : TFY_BaseScrollViewChainModel<TFY_WebViewChainModel *>

@end
TFY_CATEGORY_EXINTERFACE(WKWebView, TFY_WebViewChainModel)
NS_ASSUME_NONNULL_END
