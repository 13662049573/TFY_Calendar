//
//  TFY_OpenShareHeader.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/6/1.
//  Copyright © 2023 田风有. All rights reserved.
//
/**
 [TFY_OpenShare connectQQWithAppId:@"1103194207"];
 [TFY_OpenShare connectWeiboWithAppKey:@"402180334"];
 [TFY_OpenShare connectWeixinWithAppId:@"wxd930ea5d5a258f4f" miniAppId:@"gh_d43f693ca31f"];
 [TFY_OpenShare connectAlipay];//支付宝参数都是服务器端生成的，这里不需要key.
 
 - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
     if ([OpenShare handleOpenURL:url]) {
         return YES;
     }
     return NO;
 }
 */

#ifndef TFY_OpenShareHeader_h
#define TFY_OpenShareHeader_h

#import "TFY_OpenShare+QQ.h"
#import "TFY_OpenShare+Weixin.h"
#import "TFY_OpenShare+Alipay.h"
#import "TFY_OpenShare+Weibo.h"

#endif /* TFY_OpenShareHeader_h */
