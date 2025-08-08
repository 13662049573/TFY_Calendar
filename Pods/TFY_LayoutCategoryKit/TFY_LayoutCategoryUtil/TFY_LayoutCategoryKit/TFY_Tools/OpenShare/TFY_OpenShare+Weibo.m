//
//  TFY_OpenShare+Weibo.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/6/1.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_OpenShare+Weibo.h"

@implementation TFY_OpenShare (Weibo)
static NSString *schema=@"Weibo";

+(void)connectWeiboWithAppKey:(NSString *)appKey {
    [self set:schema Keys:@{@"appKey":appKey}];
}

+(void)connectWeiboWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI {
    [self set:schema Keys:@{@"appKey":appKey,
                            @"appSecret":appSecret,
                            @"redirectURI":redirectURI}];
}

+(BOOL)isWeiboInstalled{
    return [self canOpen:@"weibosdk://request"];
}

+(void)shareToWeibo:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail{
    if (![self beginShare:schema Message:msg Success:success Fail:fail]) {
        return;
    }
    NSDictionary *message;
    if ([msg isEmpty:@[@"link" ,@"image"] AndNotEmpty:@[@"title"] ]) {
        //text类型分享
        message= @{
            @"__class" : @"WBMessageObject",
            @"text" :msg.title
        };
    }else if ([msg isEmpty:@[@"link" ] AndNotEmpty:@[@"title",@"image"] ]) {
        //图片类型分享
        message=@{
            @"__class" : @"WBMessageObject",
            @"imageObject":@{
                @"imageData":[self dataWithImage:msg.image]
            },
            @"text" : msg.title
        };
        
    }else if ([msg isEmpty:@[] AndNotEmpty:@[@"title",@"link" ,@"image"] ]) {
        //链接类型分享
        message=@{
            @"__class" : @"WBMessageObject",
            @"mediaObject":@{
                @"__class" : @"WBWebpageObject",
                @"description": msg.desc?:msg.title,
                @"objectID" : @"identifier1",
                @"thumbnailData":msg.thumbnail ? [self dataWithImage:msg.thumbnail] : [self dataWithImage:msg.image  scale:CGSizeMake(100, 100)],
                @"title": msg.title,
                @"webpageUrl":msg.link
            }
            
        };
    }
    NSString *uuid=[[NSUUID UUID] UUIDString];
    NSError *transferObjecterr;
    NSData *transferObjectdata = [NSKeyedArchiver archivedDataWithRootObject:@{
        @"__class" :@"WBSendMessageToWeiboRequest",
        @"message":message,
        @"requestID" :uuid,
    } requiringSecureCoding:YES error:&transferObjecterr];
    
    NSError *userInfoerr;
    NSData *userInfodata = [NSKeyedArchiver archivedDataWithRootObject:@{} requiringSecureCoding:YES error:&userInfoerr];
    
    NSError *apperr;
    NSData *appdata = [NSKeyedArchiver archivedDataWithRootObject:@{@"appKey" : [self keyFor:schema][@"appKey"],@"bundleID" : [self CFBundleIdentifier]} requiringSecureCoding:YES error:&apperr];
    
    NSArray *messageData=@[
                           @{@"transferObject":transferObjectdata},
                           @{@"userInfo":userInfodata},
                           @{@"app":appdata}
                           ];
    [UIPasteboard generalPasteboard].items=messageData;
    [self openURL:[NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=003013000",uuid]];
}

+(void)WeiboAuth:(NSString*)scope redirectURI:(NSString*)redirectURI Success:(authSuccess)success Fail:(authFail)fail{
    if (![self beginAuth:schema Success:success Fail:fail]) {
        return;
    }
    
    if (![self isWeiboInstalled]) {
        NSString *oauthURL = [NSString stringWithFormat:@"https://open.weibo.cn/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@&scope=all", [TFY_OpenShare keyFor:@"Weibo"][@"appKey"], [TFY_OpenShare keyFor:@"Weibo"][@"redirectURI"]];
        [TFY_OpenShare shared].authSuccess = success;
        [TFY_OpenShare shared].authFail = fail;
        [[TFY_OpenShare shared] addWebViewByURL:[NSURL URLWithString:oauthURL]];
        return;
    }
    
    NSString *uuid=[[NSUUID UUID] UUIDString];
    
    NSError *transferObjecterr;
    NSData *transferObjectdata = [NSKeyedArchiver archivedDataWithRootObject:@{
        @"__class" :@"WBAuthorizeRequest",
        @"redirectURI":redirectURI,
        @"requestID" :uuid,
        @"scope": scope?:@"all"
        } requiringSecureCoding:YES error:&transferObjecterr];
    
    NSError *userInfoerr;
    NSData *userInfodata = [NSKeyedArchiver archivedDataWithRootObject:@{
        @"mykey":@"as you like",
       @"SSO_From" : @"SendMessageToWeiboViewController"
       } requiringSecureCoding:YES error:&userInfoerr];
    
    NSError *apperr;
    NSData *appdata = [NSKeyedArchiver archivedDataWithRootObject:@{
        @"appKey" :[self keyFor:schema][@"appKey"],
        @"bundleID" : [self CFBundleIdentifier],
        @"name" :[self CFBundleDisplayName]
        } requiringSecureCoding:YES error:&apperr];
    
    NSArray *authData=@[
                        @{@"transferObject":transferObjectdata},
                        @{@"userInfo":userInfodata},
                        @{@"app":appdata}];
    [UIPasteboard generalPasteboard].items=authData;
    [self openURL:[NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=003013000",uuid]];
}

+(BOOL)Weibo_handleOpenURL{
    NSURL* url=[self returnedURL];
    if ([url.scheme hasPrefix:@"wb"]) {
        NSArray *items=[UIPasteboard generalPasteboard].items;
        NSMutableDictionary *ret=[NSMutableDictionary dictionaryWithCapacity:items.count];
        for (NSDictionary *item in items) {
            for (NSString *k in item) {
                NSError *err;
                if (@available(iOS 14.0, *)) {
                    ret = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:self fromData:item[k] error:&err].firstObject;
                } else {
                    ret = [NSKeyedUnarchiver unarchivedObjectOfClass:self fromData:item[k] error:&err];
                }
                ret[k]=[k isEqualToString:@"transferObject"]?ret:item[k];
            }
        }
        NSDictionary *transferObject=ret[@"transferObject"];
        if ([transferObject[@"__class"] isEqualToString:@"WBAuthorizeResponse"]) {
            //auth
            if ([transferObject[@"statusCode"] intValue]==0) {
                if ([self authSuccessCallback]) {
                    [self authSuccessCallback](transferObject);
                }
            }else{
                if ([self authFailCallback]) {
                    NSError *err=[NSError errorWithDomain:@"weibo_auth_response" code:[transferObject[@"statusCode"] intValue] userInfo:transferObject];
                    [self authFailCallback](transferObject,err);
                }
            }
        }else if ([transferObject[@"__class"] isEqualToString:@"WBSendMessageToWeiboResponse"]) {
            //分享回调
            if ([transferObject[@"statusCode"] intValue]==0) {
                if ([self shareSuccessCallback]) {
                    [self shareSuccessCallback]([self message]);
                }
            }else{
                if ([self shareFailCallback]) {
                    NSError *err=[NSError errorWithDomain:@"weibo_share_response" code:[transferObject[@"statusCode"] intValue] userInfo:transferObject];
                    [self shareFailCallback]([self message],err);
                }
            }
        }
        return YES;
    } else{
        return NO;
    }
}

@end
