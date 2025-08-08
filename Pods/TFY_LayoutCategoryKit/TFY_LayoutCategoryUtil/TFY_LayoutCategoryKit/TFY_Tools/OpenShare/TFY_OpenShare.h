//
//  TFY_OpenShare.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/6/1.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 分享类型，除了news以外，还可能是video／audio／app等。
 */
typedef enum : NSUInteger {
    TFYOSMultimediaTypeNews,
    TFYOSMultimediaTypeAudio,
    TFYOSMultimediaTypeVideo,
    TFYOSMultimediaTypeApp,
    TFYOSMultimediaTypeFile,
    TFYOSMultimediaTypeMiniApp,
    TFYOSMultimediaTypeUndefined
} TFYOSMultimediaType;

typedef enum : NSUInteger {
    TFYOSMINIAppRelease,
    TFYOSMINIAppTest,
    TFYOSMINIAppPreview
} TFYOSMINIAppType;
/**
 *  TFY_OSMessage保存分享消息数据。
 */
@interface TFY_OSMessage : NSObject
@property NSString* title;
@property NSString* desc;
@property NSString* link;
@property UIImage *image;
@property UIImage *thumbnail;
@property TFYOSMultimediaType multimediaType;
//for 微信
@property NSString* extInfo;
@property NSString* mediaDataUrl;
@property NSString* fileExt;
@property (nonatomic, strong) NSData *file;   /// 微信分享gif/文件
//for 微信小程序
@property NSString* path;
@property BOOL withShareTicket;
@property TFYOSMINIAppType miniAppType;

/**
 *  判断emptyValueForKeys的value都是空的，notEmptyValueForKeys的value都不是空的。
 *
 *  emptyValueForKeys    空值的key
 *  notEmptyValueForKeys 非空值的key
 *   YES／NO
 */
-(BOOL)isEmpty:(NSArray*)emptyValueForKeys AndNotEmpty:(NSArray*)notEmptyValueForKeys;
@end


typedef void (^shareSuccess)(TFY_OSMessage * message);
typedef void (^shareFail)(TFY_OSMessage * message,NSError *error);
typedef void (^authSuccess)(NSDictionary * message);
typedef void (^authFail)(NSDictionary * __nullable message,NSError * __nullable error);
typedef void (^paySuccess)(NSDictionary * message);
typedef void (^payFail)(NSDictionary * message,NSError *error);
/**
 粘贴板数据编码方式，目前只有两种:
 1. [NSKeyedArchiver archivedDataWithRootObject:data];
 2. [NSPropertyListSerialization dataWithPropertyList:data format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
 */
typedef enum : NSUInteger {
    TFYOSPboardEncodingKeyedArchiver,
    TFYOSPboardEncodingPropertyListSerialization,
} TFYOSPboardEncoding;

@interface TFY_OpenShare : NSObject

+ (TFY_OpenShare *)shared;

@property (nonatomic, copy,nullable) authSuccess authSuccess;
@property (nonatomic, copy,nullable) authFail authFail;

- (void)addWebViewByURL:(NSURL *)URL;

/**
 *  设置平台的key
 *
 *   platform 平台名称
 *   key      NSDictionary格式的key
 */
+(void)set:(NSString*)platform Keys:(NSDictionary *)key;
/**
 *  获取平台的key
 *
 *   platform 平台名称，每个category自行决定。
 *
 *  @return 平台的key(NSDictionary或nil)
 */
+(NSDictionary *)keyFor:(NSString*)platform;

/**
 *  通过UIApplication打开url
 *
 *   url 需要打开的url
 */
+(void)openURL:(NSString*)url;
+(BOOL)canOpen:(NSString*)url;
/**
 *  处理被打开时的openurl
 *
 *   url openurl
 *
 *  @return 如果能处理，就返回YES。够则返回NO
 */
+(BOOL)handleOpenURL:(NSURL*)url;
+(shareSuccess)shareSuccessCallback;

+(shareFail)shareFailCallback;

+(void)setShareSuccessCallback:(shareSuccess)suc;

+(void)setShareFailCallback:(shareFail)fail;

+(NSURL*)returnedURL;

+(NSDictionary*)returnedData;

+(void)setReturnedData:(NSDictionary*)retData;

+(NSMutableDictionary *)parseUrl:(NSURL*)url;

+(void)setMessage:(TFY_OSMessage*)msg;

+(TFY_OSMessage*)message;

+(BOOL)beginShare:(NSString*)platform Message:(TFY_OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(BOOL)beginAuth:(NSString*)platform Success:(authSuccess)success Fail:(authFail)fail;

+(NSString*)base64Encode:(NSString *)input;
+(NSString*)base64Decode:(NSString *)input;
+(NSString*)CFBundleDisplayName;
+(NSString*)CFBundleIdentifier;

+(void)setGeneralPasteboard:(NSString*)key Value:(id)value encoding:(TFYOSPboardEncoding)encoding;
+(NSDictionary*)generalPasteboardData:(NSString*)key encoding:(TFYOSPboardEncoding)encoding;
+(NSString*)base64AndUrlEncode:(NSString *)string;
+(NSString*)urlDecode:(NSString*)input;
+ (UIImage *)screenshot;

+(authSuccess)authSuccessCallback;
+(authFail)authFailCallback;

+(void)setPaySuccessCallback:(paySuccess)suc;

+(void)setPayFailCallback:(payFail)fail;

+(paySuccess)paySuccessCallback;
+(payFail)payFailCallback;

+ (NSData *)dataWithImage:(UIImage *)image;
+ (NSData *)dataWithImage:(UIImage *)image scale:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
