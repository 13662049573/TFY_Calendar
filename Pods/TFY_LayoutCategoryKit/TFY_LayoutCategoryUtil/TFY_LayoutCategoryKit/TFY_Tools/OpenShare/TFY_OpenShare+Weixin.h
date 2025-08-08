//
//  TFY_OpenShare+Weixin.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/6/1.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_OpenShare.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_OpenShare (Weixin)
+(void)connectWeixinWithAppId:(NSString *)appId miniAppId:(NSString *)miniAppId;
+(BOOL)isWeixinInstalled;

+(void)shareToWeixinSession:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)shareToWeixinTimeline:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)shareToWeixinFavorite:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)WeixinAuth:(NSString*)scope Success:(authSuccess)success Fail:(authFail)fail;
+(void)WeixinPay:(NSString*)link Success:(paySuccess)success Fail:(payFail)fail;
@end

NS_ASSUME_NONNULL_END
