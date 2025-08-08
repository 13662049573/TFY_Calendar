//
//  TFY_AppVersion.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/6.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_AppVersion.h"
#import "TFY_Scene.h"
#import "TFY_Utils.h"
#import "UIApplication+TFY_Tools.h"

#import <StoreKit/StoreKit.h>

#define APP_InfoDict                [[NSBundle mainBundle] infoDictionary]
//应用版本
#define APP_Version                 [APP_InfoDict objectForKey:@"CFBundleShortVersionString"]
//应用BundleId
#define APP_BundleId                [APP_InfoDict objectForKey:@"CFBundleIdentifier"]
//区域编码
#define APP_CountryCode             [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]

#define APPStore_BundleId_URL       @"https://itunes.apple.com/lookup?bundleId=%@&country=%@"
#define APPStore_ItunesId_URL       @"https://itunes.apple.com/lookup?id=%@&country=%@"

#define AppStore_ResultCount        @"resultCount"
#define AppStore_Results            @"results"


@implementation TFY_AppVersionModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"description"]) {
        self.descrip = value;
    }
}

@end

@interface TFY_AppVersion ()<SKStoreProductViewControllerDelegate>
@property (nonatomic, strong) TFY_AppVersionModel *appModel;
@end

@implementation TFY_AppVersion

/**
 *  自动检测app版本更新
 *  自动读取BundleId去App Store获取信息
 */
+ (void)autoCheckVersion {
    [self autoCheckVersionHandleView:nil];
}
+ (void)autoCheckVersionHandleView:(BlockAppStoreInfo)appInfo {
    __weak typeof(self) weakSelf = self;
    [self getNewAppStoreInfo:^(TFY_AppVersionModel *appModel) {
        if ([weakSelf shouldUpdateApp:appModel]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (appInfo){
                    appInfo(appModel);
                }else{
                    [TFY_Utils makeToast:@"请自定义View,block回调"];
                }
            });
        }
    }];
}
/**
 *  根据应用itunesId版本更新
 */
+ (void)checkVersionItunesId:(NSString *)itunesId {
    [self checkVersionItunesId:itunesId handleView:nil];
}
+ (void)checkVersionItunesId:(NSString *)itunesId handleView:(BlockAppStoreInfo)appInfo {
    __weak typeof(self) weakSelf = self;
    [self getNewAppStoreInfoItunesId:itunesId appInfo:^(TFY_AppVersionModel *appModel) {
        if ([weakSelf shouldUpdateApp:appModel]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (appInfo){
                    appInfo(appModel);
                }else{
                    [TFY_Utils makeToast:@"请自定义View,block回调"];
                }
            });
        }
    }];
}

/**
 *  获取App Store应用信息
 */
+ (void)getAppInfoByUrl:(NSString *)url appStore:(BlockAppStoreInfo)appInfo {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error = %@",error);
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        if ([dict[AppStore_ResultCount] integerValue] == 0) {
            NSLog(@"please check you App!");
            return;
        }
        TFY_AppVersionModel *model = [[TFY_AppVersionModel alloc] init];
        NSDictionary *results = [dict[AppStore_Results] firstObject];
        [model setValuesForKeysWithDictionary:results];
        appInfo(model);
    }];
    [dataTask resume];
}

/**
 *  获取前期应用在App Store的信息详情
 *  1、自动读取当前APP的App Store信息
 *  2、itunesId:自定义传入APP应用的iTunesId
 */
+ (void)getNewAppStoreInfo:(BlockAppStoreInfo)appInfo {
    NSString *url = [self autoTransformURLByItunesId:nil];
    [self getAppInfoByUrl:url appStore:^(TFY_AppVersionModel *appModel) {
        appInfo(appModel);
    }];
}
+ (void)getNewAppStoreInfoItunesId:(NSString *)itunesId appInfo:(BlockAppStoreInfo)appInfo {
    NSString *url = [self autoTransformURLByItunesId:itunesId];
    [self getAppInfoByUrl:url appStore:^(TFY_AppVersionModel *appModel) {
        appInfo(appModel);
    }];
}
/**
 *  自动装换出正确请求App Store的URL
 */
+ (NSString *)autoTransformURLByItunesId:(NSString *)itunesId {
    NSString *urlStr = @"";
    if (itunesId) {
        urlStr = [NSString stringWithFormat:APPStore_ItunesId_URL,itunesId,APP_CountryCode];
    }else {
        urlStr = [NSString stringWithFormat:APPStore_BundleId_URL,APP_BundleId,APP_CountryCode];
    }
    return urlStr;
}
/**
 *  判断是否需要更新
 */
+ (BOOL)shouldUpdateApp:(TFY_AppVersionModel *)model {
    NSMutableArray *currentVersions = [NSMutableArray array];
    NSMutableArray *appStoreVersions = [NSMutableArray array];
    [currentVersions addObjectsFromArray:[APP_Version componentsSeparatedByString:@"."]];
    [appStoreVersions addObjectsFromArray:[model.version componentsSeparatedByString:@"."]];
    NSInteger difference = currentVersions.count - appStoreVersions.count;
    if (difference < 0) {
        for (NSInteger i = 0; i < labs(difference); i++) {
            [currentVersions addObject:@"0"];
        }
    }else if (difference > 0){
        for (NSInteger i = 0; i < labs(difference); i++) {
            [appStoreVersions addObject:@"0"];
        }
    }
    for (NSInteger i = 0; i < appStoreVersions.count; i++) {
        NSInteger currNum = [currentVersions[i] integerValue];
        NSInteger appStoreNum = [appStoreVersions[i] integerValue];
        if (appStoreNum > currNum) {
            return YES;
        }else if (appStoreNum < currNum) {
            return NO;
        }
    }
    return NO;
}

/// 获取对应项目下载界面
- (void)sKStoreProductAppId:(NSString *)appid {
    [TFY_Utils makeToastActivity];
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    NSDictionary *dic = [NSDictionary dictionaryWithObject:appid forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dic completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (!error) {
            [self.currentViewController presentViewController:storeProductVC animated:YES completion:nil];
        }
        [TFY_Utils hideToastActivity];
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self.currentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIWindow *)LastWindow {
    NSEnumerator  *frontToBackWindows = [[TFY_Scene defaultPackage].windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha>0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        if (windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {return window;}
    }
    return [UIApplication tfy_keyWindow];
}

- (UIViewController *)currentViewController {
    UIViewController* currentViewController = self.LastWindow.rootViewController;
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    return currentViewController;
}


@end
