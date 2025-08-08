//
//  TFY_OpenShare+QQ.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/6/1.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_OpenShare.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_OpenShare (QQ)
/**
 *  连接QQ平台。可以分享到：qq好友／qq空间。只需要appId：http://op.open.qq.com/index.php?mod=appinfo&act=main&appid=1103194207#mobile|center
 *  需要添加CFBundleURLSchemes：
 *  <array>
 *  <string>tencent1103194207</string>
 *  <string>tencent1103194207.content</string>
 *  <string>QQ41C1685F</string> 16进制表示的appid，可以通过new Number(1103194207).toString(16).toUpperCase()获取。
 *   appId 所申请的应用的APP ID
 */
+(void)connectQQWithAppId:(NSString *)appId;
+(BOOL)isQQInstalled;

+(void)shareToQQFriends:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)shareToQQZone:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)shareToQQFavorites:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)shareToQQDataline:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)QQAuth:(NSString*)scope Success:(authSuccess)success Fail:(authFail)fail;
/**
 *  打开WPA临时会话
 *   qqNumber 要聊天的QQ号
 */
+(void)chatWithQQNumber:(NSString*)qqNumber;
/**
 *  打开某个群聊天。QQ客户端登录的QQ号，必须是groupNumber的成员才能聊天。
 *   groupNumber 群号码
 */
+(void)chatInQQGroup:(NSString*)groupNumber;
/**
 *  是否能处理这个openUrl，如果能就返回YES，并且按照callback处理，否则返回NO，交给下一个处理。
 *
 *   url     openURL
 *   success success callback
 *   fail    fail callback
 *   是否能处理给定的url
 */
+(BOOL)QQ_handleOpenURL;

@end

NS_ASSUME_NONNULL_END
