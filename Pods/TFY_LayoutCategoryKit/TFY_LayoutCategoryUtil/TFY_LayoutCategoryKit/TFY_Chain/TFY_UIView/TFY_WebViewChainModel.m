//
//  TFY_WebViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_WebViewChainModel.h"
#define TFY_CATEGORY_CHAIN_WEBVIEW_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_WebViewChainModel *,WKWebView)
@implementation TFY_WebViewChainModel

@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(WKWebView, TFY_WebViewChainModel)
#undef TFY_CATEGORY_CHAIN_WEBVIEW_IMPLEMENTATION
