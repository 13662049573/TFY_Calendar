//
//  Utils.m
//  LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/4.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_Utils.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UIView+Toast.h"
#import "TFY_Scene.h"
#pragma 获取网络系统库头文件
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreText/CoreText.h>
#pragma 手机授权需求系统库头文件
#import <Photos/Photos.h>
#pragma 各种方法需要的系统头文件
#import <CommonCrypto/CommonDigest.h>
#import <sys/stat.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <sys/socket.h>
#include <sys/socket.h>

#import <dlfcn.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

#import <netinet/in.h>
#import <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
#define IOS_10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)


#pragma mark*******************************************判断获取网络数据****************************************

NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)                ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [TFY_Utils class]], @"info was wrong class in ReachabilityCallback");
    
    TFY_Utils* noteObject = (__bridge TFY_Utils *)info;
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
}

@interface TFY_Utils ()
#pragma 获取网络需求
@property(nonatomic , assign)SCNetworkReachabilityRef reachabilityRef;
@property (strong, nonatomic) dispatch_source_t timer;
@property (assign, nonatomic) NSTimeInterval retryInterval;
@property (assign, nonatomic) NSTimeInterval currentRetryInterval;
@property (assign, nonatomic) NSTimeInterval maxRetryInterval;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (copy, nonatomic) void (^reconnectBlock)(void);
@end


@implementation TFY_Utils
static TFY_Utils *_instance; //单例数据需求
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

#pragma mark------------------------------------------手机获取网络监听方法---------------------------------------

+ (instancetype)reachabilityWithHostName:(NSString *)hostName{
    TFY_Utils* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL)
    {
        returnValue= [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    TFY_Utils* returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityForInternetConnection{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

- (BOOL)startNotifier{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)){
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)){
            returnValue = YES;
        }
    }
    return returnValue;
}

- (void)stopNotifier{
    if (_reachabilityRef != NULL){
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}
#pragma mark - Network Flag Handling

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags{
    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0){return NotReachable;}
    NetworkStatus returnValue = NotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {returnValue = ReachableViaWiFi;}
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            returnValue = ReachableViaWiFi;
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        returnValue = ReachableViaWWAN;
    }
    return returnValue;
}


- (BOOL)connectionRequired{
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)){
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

- (NetworkStatus)currentReachabilityStatus{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)){
        returnValue = [self networkStatusForFlags:flags];
    }
    return returnValue;
}

/**
 获取网络状态 2G/3G/4G/wifi
 */
+(NSString *)getNetconnType{
    NSString *netcomType = @"";
    TFY_Utils *reach = [TFY_Utils reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:{
            netcomType = @"network";
        }
        break;
        case ReachableViaWiFi:{
            netcomType = @"Wifi";
        }
        break;
        case ReachableViaWWAN:{
            netcomType = [self getNetType];
        }
        break;
    }
    return netcomType;
}

//针对蜂窝网络判断是3G或者4G
+(NSString *)getNetType{
    __block NSString *netconnType = nil;
    NSArray *typeStrings2G = @[
            CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyCDMA1x];
      
     NSArray *typeStrings3G = @[
            CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyeHRPD];
      
    NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
    NSArray *typeStrings5G;
    if (@available(iOS 14.1, *)) {
        typeStrings5G = @[CTRadioAccessTechnologyNRNSA,
                          CTRadioAccessTechnologyNR];
    }
    CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        NSDictionary<NSString *, NSString *> *currentStatus = teleInfo.serviceCurrentRadioAccessTechnology;
        if (currentStatus.allKeys.count==0) {netconnType = @"未知";}
        [currentStatus enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([typeStrings4G containsObject:obj]) {
                netconnType = @"4G";
            } else if ([typeStrings3G containsObject:obj]) {
                netconnType = @"3G";
            } else if ([typeStrings2G containsObject:obj]) {
                netconnType = @"2G";
            } else if ([typeStrings5G containsObject:obj]) {
                netconnType = @"5G";
            } else {
                netconnType = @"未知";
            }
        }];
    }
    return netconnType;
}
/**是否开插sim卡*/
+ (BOOL)simCardInseerted {
    CTTelephonyNetworkInfo *netIInfo = [[CTTelephonyNetworkInfo alloc] init];
    __block BOOL result = NO;
    if (@available(iOS 12.0, *)) {
        NSDictionary<NSString *, CTCarrier *>*currentStatus = netIInfo.serviceSubscriberCellularProviders;
        [currentStatus enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CTCarrier * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.isoCountryCode.length) {
                *stop = YES;
                result = YES;
            }
        }];
    }
    return result;
}

// 获取运营商类型
+ (SSOperatorsType)getOperatorsType{
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        NSDictionary *dic = telephonyInfo.serviceSubscriberCellularProviders;
        if (dic.count == 2) {
            //双卡
            UIApplication *app = [UIApplication sharedApplication];
            id statusBar = [app valueForKeyPath:@"statusBar"];
            
            if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
                id curData = [statusBar valueForKeyPath:@"statusBar.currentData.cellularEntry.string"];
                if ([curData isEqualToString:@"中国电信"]) {
                    return SSOperatorsTypeTelecom;
                }else if ([curData isEqualToString:@"中国联通"]){
                    return SSOperatorsTypeChinaUnicom;
                }else if ([curData isEqualToString:@"中国移动"]){
                    return SSOperatorsTypeChinaMobile;
                }
            }else{
                return SSOperatorsTypeUnknown;
            }
        }
    }
    return SSOperatorsTypeUnknown;
}


+(NSString *)getDeviceIDFV{
    NSString* idfvStr      = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    return idfvStr;
}
//Git上的erica的UIDevice扩展文件，以前可用但由于IOKit framework没有公开，所以也无法使用。就算手动导入，依旧无法使用，看来获取IMEI要失败了,同时失败的还有IMSI。不过还存在另外一种可能，Stack Overflow上有人提供采用com.apple.coretelephony.Identity.get entitlement方法，but device must be jailbroken；在此附上链接，供大家参考：http://stackoverflow.com/questions/16667988/how-to-get-imei-on-iphone-5/16677043#16677043
+(NSString *)getDeviceIMEI{
    NSString* imeiStr = @"回头吧，翻遍国内外了，failed，快看代码注释";
    return imeiStr;
}

+(NSString*)getDeviceMAC{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macStr = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return macStr;
}
+(NSString*)getDeviceUUID{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    return (__bridge NSString *)(uuidStr);
}

#pragma mark---------------------------------------手机权限授权方法开始---------------------------------------
/*
 * 单例
 */
+(instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
    return _instance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    return [TFY_Utils shareInstance] ;
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return [TFY_Utils shareInstance] ;
}

/*
 *跳转设置
 */
- (void)pushSetting:(NSString*)urlStr{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@%@",urlStr,@"尚未开启,是否前往设置"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (IOS_10_OR_LATER) {
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication]openURL:url options:@{}completionHandler:^(BOOL        success) {
                }];
            }
        }
    }];
    [alert addAction:okAction];
    [[TFY_Utils getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

//获取当前VC
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

/**
 *  截取控制器所生产图片
 */
+ (void )screenSnapshot:(UIView *)snapshotView finishBlock:(void(^)(UIImage *snapShotImage))finishBlock{
    UIView *snapshotFinalView = snapshotView;
    
    if([snapshotView isKindOfClass:[WKWebView class]]){
        //WKWebView
        snapshotFinalView = (WKWebView *)snapshotView;
        
    }else if([snapshotView isKindOfClass:[WKWebView class]]){
        
        //WKWebView
        WKWebView *webView = (WKWebView *)snapshotView;
        snapshotFinalView = webView.scrollView;
    }else if([snapshotView isKindOfClass:[UIScrollView class]] ||
             [snapshotView isKindOfClass:[UITableView class]] ||
             [snapshotView isKindOfClass:[UICollectionView class]]
             ){
        //ScrollView
        snapshotFinalView = (UIScrollView *)snapshotView;
    }else{
        NSLog(@"不支持的类型");
    }
    
    [snapshotFinalView screenSnapshot:^(UIImage *snapShotImage) {
        if (snapShotImage != nil && finishBlock) {
            finishBlock(snapShotImage);
        }
    }];
}


/**
 * 温度单位转换方法
 */
+(CGFloat)temperatureUnitExchangeValue:(CGFloat)value changeTo:(Temperature)unit{
    if (unit == Fahrenheit) {
        return 32 + 1.8 * value; //华氏度
    }else {
        return (value - 32) / 1.8; //摄氏度
    }
}

#pragma mark------------------------------------------各种方法使用------------------------------------------

- (void)initLanguage{
    NSString *language=[self currentLanguage];
    if (language.length>0) {
        NSLog(@"自设置语言:%@",language);
    }else{
        [self systemLanguage];
    }
}

- (NSString *)currentLanguage{
    NSString *language=[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage];
    return language;
}

- (void)setLanguage:(NSString *)language{
    [NSBundle setLanguage:language];
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:AppLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)systemLanguage{
    NSString *languageCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
    NSLog(@"系统语言:%@",languageCode);
    if([languageCode hasPrefix:@"zh-Hans"]){
        languageCode = @"zh-Hans";//简体中文
    }else if([languageCode hasPrefix:@"en"]){
        languageCode = @"en";//英语
    }
    [self setLanguage:languageCode];
}

#pragma mark------------------------------------------国际化设置---------------------------------------
/**
 *  获取长度为stringLength的随机字符串, 随机数字字符混合类型字符串函数
 */
+(NSString *)getRandomString:(NSInteger)stringLength{
    NSMutableString *randomString_ = [NSMutableString string];
    NSString *baseString_ = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (int i=0; i<stringLength; i++)
    {
        NSInteger count_ = arc4random()%(baseString_.length);
        NSString *subStr_ = [baseString_ substringWithRange:NSMakeRange(count_, 1)];
        [randomString_ appendString:subStr_];
    }
    return randomString_;
}
/**
 *  随机数字类型字符串函数
 */
+(NSString *)getRandomNumberString:(NSInteger)stringLength{
    NSMutableString *randomString_ = [NSMutableString string];
    NSString *baseString_ = @"0123456789";
    for (int i=0; i<stringLength; i++)
    {
        NSInteger count_ = arc4random()%(baseString_.length);
        NSString *subStr_ = [baseString_ substringWithRange:NSMakeRange(count_, 1)];
        [randomString_ appendString:subStr_];
    }
    
    return randomString_;
}
/**
 *  随机字符类型字符串函数
 */
+(NSString *)getRandomCharacterString:(NSInteger)stringLength{
    NSMutableString *randomString_ = [NSMutableString string];
    NSString *baseString_ = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (int i=0; i<stringLength; i++)
    {
        NSInteger count_ = arc4random()%(baseString_.length);
        NSString *subStr_ = [baseString_ substringWithRange:NSMakeRange(count_, 1)];
        [randomString_ appendString:subStr_];
    }
    
    return randomString_;
}
/**
 *  获取wifi信号 method
 */
+(NSString*)currentWifiSSID{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge  id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs)
    {
        NSDictionary *info = (__bridge  id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        ssid = [info objectForKey:@"SSID"];
        if (ssid)
            break;
    }
    return ssid;
}
/**
 *  获取设备的UUID
 */
+(NSString *)gen_uuid{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}
/**
 *  替换掉Json字符串中的换行符
 */
+(NSString *)ReplacingNewLineAndWhitespaceCharactersFromJson:(NSString *)jsonStr{
    NSScanner *scanner = [[NSScanner alloc] initWithString:jsonStr];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    NSString *temp;
    NSCharacterSet*newLineAndWhitespaceCharacters = [NSCharacterSet newlineCharacterSet];
    // 扫描
    while (![scanner isAtEnd])
    {
        temp = nil;
        [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
        if (temp) [result appendString:temp];
        
        // 替换换行符
        if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
            if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                [result appendString:@"|"];
        }
    }
    return result;
}

+(NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] <= 1) {
            return nil;
        }
        NSString *key = [[elements objectAtIndex:0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *val = [[elements objectAtIndex:1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [dict setObject:val forKey:key];
    }
    return dict;
}

/*MD5加密*/
+(NSString *)md5HexDigest:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString * mdfiveString = [hash lowercaseString];
    
    return mdfiveString;
}
/**
 *  把多个json字符串转为一个json字符串
 */
+(NSString *)objArrayToJSON:(NSArray *)array{
    NSString *jsonStr = @"[";
    for (NSInteger i = 0; i < array.count; ++i) {
        if (i != 0) {
            jsonStr = [jsonStr stringByAppendingString:@","];
        }
        jsonStr = [jsonStr stringByAppendingString:array[i]];
    }
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    return jsonStr;
}

/**
 *  去掉手机号码上的+号和+86
 */
+ (NSString *)formatPhoneNum:(NSString *)phone{
    if ([phone hasPrefix:@"86"]) {
        NSString *formatStr = [phone substringWithRange:NSMakeRange(2, [phone length]-2)];
        return formatStr;
    }
    else if ([phone hasPrefix:@"+86"])
    {
        if ([phone hasPrefix:@"+86·"]) {
            NSString *formatStr = [phone substringWithRange:NSMakeRange(4, [phone length]-4)];
            return formatStr;
        }
        else
        {
            NSString *formatStr = [phone substringWithRange:NSMakeRange(3, [phone length]-3)];
            return formatStr;
        }
    }
    return phone;
}
/**
 *  手机系统版本
 */
+(NSString *)phoneVersions{
    return [[UIDevice currentDevice] systemVersion];
}
/**
 *  设备名称
 */
+(NSString *)deviceName{
    return [[UIDevice currentDevice] systemName];
}
/**
 *  获取当前版本号
 */
+(NSString *)cfbundleVersion{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}
/**
 *  获取当前应用名称
 */
+(NSString *)cfbundleDisplayName{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
}
/**
 *  当前应用软件版本
 */
+(NSString *)cfbundleShortVersionString{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}
/**
 *  国际化区域名称
 */
+(NSString *)localizedModel{
    return [[UIDevice currentDevice] localizedModel];
}

/**
 *  当前使用的语言
 */
+(NSString *)defaultsTH{
    //取得用户默认信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 取得 iPhone 支持的所有语言设置
    NSArray *languages = [defaults objectForKey :@"AppleLanguages" ];
    // 获得当前iPhone使用的语言
    NSString* currentLanguage =[languages objectAtIndex:0];
    return currentLanguage;
}
/**
 *  程序主目录，可见子目录(3个):Documents、Library、tmp
 */
+ (NSString *)homePath{
    return NSHomeDirectory();
}
/**
 *   程序目录，不能存任何东西
 */
+(NSString *)appPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
/**
 *  文档目录，需要ITUNES同步备份的数据存这里，可存放用户数据
 */
+(NSString *)docPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
/**
 *  配置目录，配置文件存这里
 */
+(NSString *)libPrefPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
}
/**
 *  缓存目录，系统永远不会删除这里的文件，ITUNES会删除
 */
+(NSString *)libCachePath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}
/**
 *  临时缓存目录，APP退出后，系统可能会删除这里的内容
 */
+(NSString *)tmpPath{
    return [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
}
/**
 *  获取本机IP
 */
+(NSString *)getIPAddress{
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSData *data = [NSData dataWithContentsOfURL:ipURL];
    if (data==nil) {
        return  @"0.0.0.0";
    }
    NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *ipStr = nil;
    if (ipDic && [ipDic[@"code"] integerValue] == 0) { //获取成功
        ipStr = ipDic[@"data"][@"ip"];
        NSLog(@">>>%@",ipStr);
    }
    return (ipStr ? ipStr : @"0.0.0.0");
}
/**
 *  获取WIFI的MAC地址
 */
+(NSString *)getWifiBSSID{
    return (NSString *)[self fetchSSIDInfo][@"BSSID"];
}
/**
 *   获取WIFI名字
 */
+(NSString *)getWifiSSID{
     return (NSString *)[self fetchSSIDInfo][@"SSID"];
}
+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            break;
        }
    }
    return info;
}
/**
 *  截取字符串后几位
 */
+(NSString *)substring:(NSString *)substring length:(NSInteger )lengths{
    return [substring substringFromIndex:substring.length-lengths];
}
/**
 *  不需要加密的参数请求
 */
+(NSString *)requestparmereaddWithDict:(NSDictionary *)dict{
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];//排序
    
    for (NSString *key in sortedKeys)
    {
        [parametersArray addObject :[NSString stringWithFormat:@"%@=%@",key,[dict objectForKey:key]]];
    }
    NSString *parme=[NSString stringWithFormat:@"%@",[parametersArray componentsJoinedByString : @"&"]];
    
    return  parme;
}

/**
 *  视频显示时间
 */
+(NSString *)convertSecond2Time:(int)second
{
    NSString* timeStr = @"" ;
    int oneHour = 3600;// 一小时 3600s
    NSTimeInterval time= second - 8*oneHour;//因为时差问题要减8小时(28800s)
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    dateFormatter.dateFormat = second < oneHour ? @"mm:ss" : @"HH:mm:ss";
    timeStr = [dateFormatter stringFromDate: detaildate];
    return timeStr;
}
/**
 *   获取图片格式
 */
+(NSString *)typeForImageData:(NSData *)data{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    
    return nil;
}
/**
 *  指定字符串末尾倒数第5个 是 . 替换成自己需要的字符
 */
+(NSString *)stringByReplacing_String:(NSString *)str withString:(NSString *)String{
    return [str stringByReplacingOccurrencesOfString:@"." withString:String options:NSBackwardsSearch range:NSMakeRange(str.length-5, 5)];
}
/**
 *  字典转化成字符串
 */
+(NSString*)dictionaryToJsonString:(NSDictionary *)dic{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
/**
 *  图片转f字符串
 */
+(NSString *)imageToString:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    return [data base64EncodedStringWithOptions:0];
}
/**
 *   出生日期计算星座
 */
+(NSString *)getAstroWithMonth:(int)m day:(int)d{
    NSString *astroString = @"摩羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手摩羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}
/**
 *   计算生肖
 */
+(NSString *)getZodiacWithYear:(NSString *)year{
    NSInteger constellation = ([year integerValue] - 4)%12;
    NSString * result;
    switch (constellation) {
        case 0:result = @"鼠";break;
        case 1:result = @"牛";break;
        case 2:result = @"虎";break;
        case 3:result = @"兔";break;
        case 4:result = @"龙";break;
        case 5:result = @"蛇";break;
        case 6:result = @"马";break;
        case 7:result = @"羊";break;
        case 8:result = @"猴";break;
        case 9:result = @"鸡";break;
        case 10:result = @"狗";break;
        case 11:result = @"猪";break;
        default:
            break;
    }
    return result;
}
/**
 *  将中文字符串转为拼音
 */
+(NSString *)chineseStringToPinyin:(NSString *)string{
    // 将中文字符串转成可变字符串
    NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:string];
    // 先转换为带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO);// 输出 pinyin: zhōng guó sì chuān
    // 再转换为不带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO);// 输出 pinyin: zhong guo si chuan
    // 转换为首字母大写拼音
    NSString *newString = [NSString stringWithFormat:@"%@",pinyinText];
    NSString *newStr = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return newStr.lowercaseString;
}
/**
 *  iOS 隐藏手机号码中间的四位数字
 */
+(NSString *)numberSuitScanf:(NSString*)number{
    BOOL isOk = [TFY_Utils mobilePhoneNumber:number];;
    if (isOk) {//如果是手机号码的话
        NSString *numberString = [number stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        return numberString;
    }
    return number;
}
/**
 *  设置银行卡号的格式方法
 */
+(NSString *)getNewBankNumWitOldBankNum:(NSString *)bankNum{
    NSMutableString *mutableStr;
    if (bankNum.length) {
        mutableStr = [NSMutableString stringWithString:bankNum];
        for (int i = 0 ; i < mutableStr.length; i ++) {
            
            if(i>=0&&i<mutableStr.length - 4) {
                [mutableStr replaceCharactersInRange:NSMakeRange(i, 1) withString:@"*"];
            }
        }
        NSString *text = mutableStr;
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 4)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 4) {
                newString = [newString stringByAppendingString:@" "];
            }
            text = [text substringFromIndex:MIN(text.length, 4)];
        }
        return newString;
        
    }
    return bankNum;
}

+(NSString *)hiddenEmailNum:(NSString *)EmailStr
{
    NSString *symbolStr = @"******************";
    NSString * lastStr =  @"@";//截取符
    NSRange rangeLenth = [EmailStr rangeOfString:lastStr];
    //开始
    NSRange rangeBegin = NSMakeRange(0, 2);
    NSString *beginStr = [EmailStr substringWithRange:rangeBegin];
    
    //隐藏部分
    NSRange rangeHidden = NSMakeRange(2, rangeLenth.location - 4);
    NSString * hiddenStr = [EmailStr substringWithRange:rangeHidden];
    
    //替换隐藏部分
    NSRange rangSymbol = NSMakeRange(0, hiddenStr.length);
    NSString *newHiddenStr = [symbolStr substringWithRange:rangSymbol];
    
    //结尾
    NSRange rangeEnd = NSMakeRange(rangeLenth.location - 2, EmailStr.length - rangeLenth.location + 2);
    NSString *endStr = [EmailStr substringWithRange:rangeEnd];
    
    NSString * newStr = [NSString stringWithFormat:@"%@%@%@",beginStr,newHiddenStr,endStr];
    
    return newStr;
}


//去掉小数点后无效的0
+ (NSString *)deleteFailureZero:(NSString *)string
{
    if ([string rangeOfString:@"."].length == 0) {
        return string;
    }
    
    for (int i = 0; i < string.length; i++) {
        if (![string hasSuffix:@"0"]) {
            break;
        }else {
            string = [string substringToIndex:[string length] - 1];
        }
    }
    
    //避免像2.0000这样的被解析成2.
    if ([string hasSuffix:@"."]) {
        return [string substringToIndex:[string length] - 1];
    }else {
        return string;
    }
}
/**
 *  根据字节大小返回文件大小字符KB、MB
 */
+ (NSString *)stringFromByteCount:(long long)byteCount{
    return [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleFile];
}
/**
 *  根据字节大小返回文件大小字符KB、MB GB
 */
+(NSString *)convertFileSize:(long long)size{
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    if (size >= gb) {
        return [NSString stringWithFormat:@"%.1f GB", (float) size / gb];
    } else if (size >= mb) {
        float f = (float) size / mb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0f MB", f];
        }else{
            return [NSString stringWithFormat:@"%.1f MB", f];
        }
    } else if (size >= kb) {
        float f = (float) size / kb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0f KB", f];
        }else{
            return [NSString stringWithFormat:@"%.1f KB", f];
        }
    } else
        return [NSString stringWithFormat:@"%lld B", size];
}
/**
 *  获取缓存数据单位 M
 */
+(float)readCacheSize{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject];
    return [ self folderSizeAtPath :cachePath];
}

/**
 *  遍历文件夹获得文件夹大小，返回多少 M
 */
+(float)folderSizeAtPath:(NSString *)folderPath{
    
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath :folderPath]) return 0 ;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator];
    NSString * fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject]) != nil ){
        //获取文件全路径
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize/( 1024.0 * 1024.0);
    
}
/**
 *  计算 单个文件的大小
 */
+(long long)fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath :filePath error : nil] fileSize];
    }
    return 0;
}
/**
 *  清楚缓存数据
 */
+(void)clearFile
{
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES ) firstObject];
    NSArray * files = [[NSFileManager defaultManager ] subpathsAtPath :cachePath];
    for ( NSString * p in files) {
        
        NSError * error = nil ;
        //获取文件全路径
        NSString * fileAbsolutePath = [cachePath stringByAppendingPathComponent :p];
        
        if ([[NSFileManager defaultManager ] fileExistsAtPath :fileAbsolutePath]) {
            [[NSFileManager defaultManager ] removeItemAtPath :fileAbsolutePath error :&error];
        }
    }
}

/**
 *  判断字符串是否是纯数字
 */
+(BOOL)isPureNumber:(NSString *)string{
    NSString *numberRegex = @"([1-9][0-9]*||[0-9][0-9]+)";
    NSPredicate *idCardNumberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    BOOL isPureNum_ = [idCardNumberTest evaluateWithObject:string];
    return isPureNum_;
}
/**
 *  判断数组是否为空
 */
+(BOOL)isBlankArray:(NSArray *)array{
    if (array == nil || [array isKindOfClass:[NSNull class]] || ![array isKindOfClass:[NSArray class]] || array.count == 0) {
        return YES;
    }
    return NO;
}
/**
 *  拿去存储的当前状态
 */
+(BOOL)addWithisLink:(NSString *)isLink{
    NSUserDefaults *defaultison = [NSUserDefaults standardUserDefaults];
    return [defaultison boolForKey:isLink];
}
/**
 *  判断目录是否存在，不存在则创建
 */
+(BOOL)hasLive:(NSString *)path{
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:path] ){
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return NO;
}
/**
 *   判断字符串是否为空  @return YES or NO
 */
+(BOOL)judgeIsEmptyWithString:(NSString *)string{
    if (string.length == 0 || [string isEqualToString:@""] || string == nil || string == NULL || [string isEqual:[NSNull null]] || [string isEqualToString:@" "] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    return NO;
}
/**
 * 检测用户输入密码是否以字母开头，6-18位数字和字母组合
 */
+(BOOL)detectionIsPasswordQualified:(NSString *)patternStr{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:patternStr];
    return isMatch;
}
/**
 * 检测字符串中是否包含表情符号
 */
+(BOOL)stringContainsEmoji:(NSString *)string{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}
/**
 * 判断字符串是否是整形数字
 */
+(BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
/**
 * 判断是否为空NSNumber对象，nil,NSNull都为空，不是NSNumber对象也判为空
 */
+(BOOL)emptyNSNumber:(NSNumber *)number{
    if (number == nil || [number isKindOfClass:[NSNull class]] || ![number isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    return NO;
}
/**
 *  判断是否为空NSDictionary对象，nil,NSNull,@{}都为空,零个键值对也是空，不是NSDictionary对象也判为空
 */
+(BOOL)emptyNSDictionary:(NSDictionary *)dictionary{
    if (dictionary == nil || [dictionary isKindOfClass:[NSNull class]] || ![dictionary isKindOfClass:[NSDictionary class]] || dictionary.allKeys == 0) {
        return YES;
    }
    return NO;
}
/**
 *  判断是否为空NSSet对象，nil,NSNull,@{}都为空，零个键值对也是空不是NSSet对象也判为空
 */
+(BOOL)emptyNSSet:(NSSet *)set{
    if (set == nil || [set isKindOfClass:[NSNull class]] || ![set isKindOfClass:[NSSet class]] || set.count == 0) {
        return YES;
    }
    return NO;
}
/**
 *  判断email格式是否正确，正则表达式不够好，慎用
 */
+(BOOL)email:(NSString *)email{
    NSString *patternEmail = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    
    if ([self judgeIsEmptyWithString:email]) {
        return NO;
    } else {
        return [self regular:patternEmail withString:email];
    }
}
+(BOOL)regular:(NSString *)regular withString:(NSString *)string {
    NSError *error = NULL;
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regular options:0 error:&error];
    
    NSTextCheckingResult *result = [regularExpression firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (result > 0) {
        return YES;
    }
    return NO;
}

/**
 *  验证手机号
 */
+(BOOL)mobilePhoneNumber:(NSString *)mobile{
    BOOL  mobilebool =[self isPureNumber:mobile];
    if (mobilebool==YES) {
        if ([self judgeIsEmptyWithString:mobile]) {
            return NO;
        } else {
            return [self valiMobile:mobile];
        }
    } else {
        return NO;
    }
}

+ (BOOL)valiMobile:(NSString *)mobile {
    if (mobile.length != 11) {
            return NO;
        } else {
            BOOL isMatch2 = [self isMobilePperators:mobile];// 移动号段正则表达式
            
            BOOL isMatch3 = [self isUnicomPperators:mobile];// 联通号段正则表达式
            
            BOOL isMatch4 = [self isTelecomPperators:mobile];// 电信号段正则表达式
            
        if (isMatch2 || isMatch3 || isMatch4) {
            return YES;
        } else {
            return NO;
        }
    }
}
/**
 *  判断是否全数字 符合则为YES，不符合则为NO
 */
+ (BOOL)OnlyDigitalNumber:(NSString *)number{
    NSString *patternFloatNumber = @"^[0-9]+$";
    if ([self judgeIsEmptyWithString:number]) {
        return NO;
    } else {
        return [self regular:patternFloatNumber withString:number];
    }
}

/**
 * 判断是不是小数，如1.2这样  符合则为YES，不符合则为NO
 */
+(BOOL)floatNumber:(NSString *)number{
    if ([self judgeIsEmptyWithString:number]) {
        return NO;
    } else {
        
        NSString *signNumber = [number substringToIndex:1];
        NSString *finalString = number;
        if ([signNumber isEqualToString:@"-"] || [signNumber isEqualToString:@"+"]) {
            finalString = [number substringFromIndex:1];
        }
        
        NSRange dotRange = [finalString rangeOfString:@"."];
        if (dotRange.location == NSNotFound) {
            return [self OnlyDigitalNumber:finalString];
        } else {
            if (dotRange.length ==1) {
                NSString *leftSting = [finalString substringToIndex:dotRange.location];
                NSString *rightString = [finalString substringFromIndex:dotRange.location+1];
                
                return [self OnlyDigitalNumber:leftSting] && [self OnlyDigitalNumber:rightString];
                
            } else {
                return NO;
            }
            
        }
    }
}
/**
 *   判断版本号是否发生变化，有为 yes
 */
+(BOOL)version_CFBundleShortVersionString{
    // 1.当前应用软件版本
    NSString *currentVersion = [self cfbundleShortVersionString];
    // 2.获取上一次的版本号
    NSString *lastVersion = [self getStrValueInUDWithKey:@"VersionKey"];
    
    if ([currentVersion isEqualToString:lastVersion]) {
        return NO;
    }else{
        [self saveStrValueInUD:currentVersion forKey:@"VersionKey"];
        return YES;
    }
}
/*
 *  判断手机是否越狱
 */
+(BOOL)isJailBreak{
    BOOL isYUEYU = [self mgjpf_isJailbroken];
    if (isYUEYU) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"检测到此设备为越狱设备，此应用暂不支持该设备使用" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            exit(0);
        }];
        [alert addAction:okAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return isYUEYU;
    }
    return isYUEYU;
}
+(BOOL)mgjpf_isJailbroken
{
    //以下检测的过程是越往下，越狱越高级
    
    //    /Applications/Cydia.app, /privte/var/stash
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    
    if ([self isJailBreak1]) {
        jailbroken = YES;
    }
    
    if ([self isJailBreak2]) {
        jailbroken = YES;
    }
    
    if ([self isJailBreak3]) {
        jailbroken = YES;
    }
    //可能存在hook了NSFileManager方法，此处用底层C stat去检测
    struct stat stat_info;
    if (0 == stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info)) {
        jailbroken = YES;
    }
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        jailbroken = YES;
    }
    if (0 == stat("/var/lib/cydia/", &stat_info)) {
        jailbroken = YES;
    }
    if (0 == stat("/var/cache/apt", &stat_info)) {
        jailbroken = YES;
    }
    //    /Library/MobileSubstrate/MobileSubstrate.dylib 最重要的越狱文件，几乎所有的越狱机都会安装MobileSubstrate
    //    /Applications/Cydia.app/ /var/lib/cydia/绝大多数越狱机都会安装
    //    /var/cache/apt /var/lib/apt /etc/apt
    //    /bin/bash /bin/sh
    //    /usr/sbin/sshd /usr/libexec/ssh-keysign /etc/ssh/sshd_config
    
    //可能存在stat也被hook了，可以看stat是不是出自系统库，有没有被攻击者换掉
    //这种情况出现的可能性很小
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *,struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSLog(@"lib:%s",dylib_info.dli_fname);      //如果不是系统库，肯定被攻击了
        if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {   //不相等，肯定被攻击了，相等为0
            jailbroken = YES;
        }
    }
    
    //还可以检测链接动态库，看下是否被链接了异常动态库，但是此方法存在appStore审核不通过的情况，这里不作罗列
    //通常，越狱机的输出结果会包含字符串： Library/MobileSubstrate/MobileSubstrate.dylib——之所以用检测链接动态库的方法，是可能存在前面的方法被hook的情况。这个字符串，前面的stat已经做了
    
    //如果攻击者给MobileSubstrate改名，但是原理都是通过DYLD_INSERT_LIBRARIES注入动态库
    //那么可以，检测当前程序运行的环境变量
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s",env);
    if (env != NULL) {
        jailbroken = YES;
    }
    return jailbroken;
}
+(BOOL)isJailBreak3
{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    NSLog(@"The device is NOT jail broken!");
    
    return NO;
}
+(BOOL)isJailBreak1
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}



#define USER_APP_PATH   @"/User/Applications/"

+(BOOL)isJailBreak2
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}
/**
 *  判断是否需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。
 */
+(BOOL)isIncludeSpecialCharact:(NSString *)str{
    //***需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€"]];
    if (urgentRange.location == NSNotFound)
    {
        return NO;
    }
    return YES;
}
/**
 *  验证身份证号码
 */
+ (BOOL)isIdentityCardNumber:(NSString *)number{
    NSString *cardNum = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|[X|x])";
    
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cardNum];
    
    if ([identityCardPredicate evaluateWithObject:number] == YES) {
        return YES;
    }else {
        return NO;
    }
}
/**
 *  验证香港身份证号码
 */
+ (BOOL)isIdentityHKCardNumber:(NSString *)number{
    NSString *cardNum = @"^[A-Z]{1,2}[0-9]{6}\\(?[0-9A]\\)?$";
    
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cardNum];
    
    if ([identityCardPredicate evaluateWithObject:number] == YES) {
        return YES;
    }else {
        return NO;
    }
}
/**
 *  验证密码格式（包含大写、小写、数字）
 */
+ (BOOL)isConformSXPassword:(NSString *)password{
    NSString *conText = @"(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])[a-zA-Z0-9]{6,20}";
    
    NSPredicate *regextestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", conText];
    
    if ([regextestMobile evaluateWithObject:password] == YES) {
        return YES;
    }else {
        return NO;
    }
}
/**
 *  验证护照
 */
+ (BOOL)isPassportNumber:(NSString *)number{
    NSString *portNum = @"^1[45][0-9]{7}|([P|p|S|s]\\d{7})|([S|s|G|g]\\d{8})|([Gg|Tt|Ss|Ll|Qq|Dd|Aa|Ff]\\d{8})|([H|h|M|m]\\d{8，10})$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", portNum];
    if ([identityCardPredicate evaluateWithObject:number] == YES) {
        return YES;
    }else {
        return NO;
    }
}

/**
 *  判断是否为纯汉字
 */
+ (BOOL)isChineseCharacters:(NSString *)string{
    //中文编码范围是0x4e00~0x9fa5
       NSString *regex = @"[\u4e00-\u9fa5]+";
       
       return [self isValidateByRegex:regex Object:string];
}

/**
 * 判断是否包含字母
 */
+ (BOOL)isContainLetters:(NSString *)string{
    if (!string) {return NO;}
    
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [numberRegular numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    
    //count是str中包含[A-Za-z]数字的个数，只要count>0，说明str中包含数字
    if (count > 0) {return YES;}
    
    return NO;
}

/**
 *  判断4-8位汉字：位数可更改
 */
+ (BOOL)combinationChineseCharacters:(NSString *)string{
    NSString *regex = @"^[\u4e00-\u9fa5]{4,8}$";
    
    return [self isValidateByRegex:regex Object:string];
}
/**
 *  判断6-18位字母或数字组合：位数可更改
 */
+ (BOOL)combinationOfLettersOrNumbers:(NSString *)string{
    NSString *regex = @"^[A-Za-z0-9]{6,18}+$";
    
    return [self isValidateByRegex:regex Object:string];
}
/**
 *  判断仅中文、字母或数字
 */
+ (BOOL)isChineseOrLettersOrNumbers:(NSString *)string{
    NSString *regex = @"^[A-Za-z0-9\\u4e00-\u9fa5]+?$";
    
    return [self isValidateByRegex:regex Object:string];
}
/**
 * 判断6~18位字母开头，只能包含“字母”，“数字”，“下划线”：位数可更改
 */
+ (BOOL)isValidPassword:(NSString *)string{
    NSString *regex = @"^([a-zA-Z]|[a-zA-Z0-9_]|[0-9]){6,18}$";
    return [self isValidateByRegex:regex Object:string];
}
/**
 * 判断是否为大写字母
 */
+ (BOOL)isCapitalLetters:(NSString *)string{
    NSString *regex =@"[A-Z]*";
       
       return [self isValidateByRegex:regex Object:string];
}

/**
 *  判断是否为小写字母
 */
+ (BOOL)isLowercaseLetters:(NSString *)string{
    NSString *regex =@"[a-z]*";
       
       return [self isValidateByRegex:regex Object:string];
}
/**
 * 判断是否以字母开头
 */
+ (BOOL)isLettersBegin:(NSString *)string{
    if(string.length <= 0) {
        
        return NO;
        
    }else {
        
        NSString *firstStr = [string substringToIndex:1];
        
        NSString *regex = @"[a-zA-Z]*";
        
        return [self isValidateByRegex:regex Object:firstStr];
    }
}

/**
 * 判断是否以汉字开头
 */
+ (BOOL)isChineseBegin:(NSString *)string{
    if(string.length <= 0) {
        
        return NO;
        
    }else {
        
        NSString *firstStr = [string substringToIndex:1];
        
        NSString *regex = @"[\u4e00-\u9fa5]+";
        
        return [self isValidateByRegex:regex Object:firstStr];
    }
}

/**
 *  验证运营商:移动
 */
+ (BOOL)isMobilePperators:(NSString *)string{
    if(string.length != 11) {
           return NO;
       }else {
           NSString *CM_NUM = @"(^134[0-8]\\d{7}$)|(^1(3[5-9]|4[7]|5[0-27-9]|6[5]|7[28]|8[2-478]|9[8])\\d{8}$)|(^170[356]\\d{7})";
           return [self isValidateByRegex:CM_NUM Object:string];
       }
}

/** 验证运营商:联通 */
+ (BOOL)isUnicomPperators:(NSString *)string {
    if(string.length != 11) {
        return NO;
    }else {
        NSString *CU_NUM = @"(^1(3[0-2]|4[5]|5[56]|6[67]|7[156]|8[56])\\d{8}$)|(^170[47-9]\\d{7}$)";
        return [self isValidateByRegex:CU_NUM Object:string];
    }
}

/** 验证运营商:电信 */
+ (BOOL)isTelecomPperators:(NSString *)string {
    if(string.length != 11) {
        return NO;
    }else {
        NSString *CT_NUM = @"(^1(3[3]|4[9]|5[3]|6[2]|7[37]|8[019]|9[1-9])\\d{8}$)|(^170[0-2]\\d{7}$)";
        return [self isValidateByRegex:CT_NUM Object:string];
    }
}

//判断运营商

+ (NSString *)getPhoneNumType:(NSString *)phoneNum {
    return [self isMobilePperators:phoneNum]? @"中国移动": ([self isUnicomPperators:phoneNum]? @"中国联通":([self isTelecomPperators:phoneNum]? @"中国电信": @"未知"));

}

//验证正则表达式
+ (BOOL)isValidateByRegex:(NSString *)regex Object:(NSString *)object {
    if(object.length <= 0) {
        return NO;
    }else {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        return [pre evaluateWithObject:object];
    }
}

+(BOOL)hasSerialSubstrWithString:(NSString *)string{
    NSUInteger markLength = 3;
    if(markLength > string.length){
        return  NO;
    }
    
    NSUInteger length = string.length;
    NSUInteger substrLength = 0;
    NSUInteger index = 0;
    BOOL isDesc = 1;
    // 65-90 A-Z  97-122 a-z
    while (index < length) {
        int asciiCode = [string characterAtIndex:index];
        NSLog(@"%d,%lu",asciiCode,(unsigned long)substrLength);
        if(!(asciiCode >= 65 && asciiCode <= 90) && !(asciiCode >= 97 && asciiCode <= 122) ){
            if(index >= length - 1){
                return  NO;
            }else {
                index++;
                substrLength = 0;
                isDesc = NO;
                NSLog(@"d1");
                continue;
            }
            
        }
        if(index + 1 >= length){
            return NO;
        }
        int nextAscii = [string characterAtIndex:index + 1];
        if(!(nextAscii >= 65 && nextAscii <= 90)  && !(nextAscii >= 97 && nextAscii <= 122) ){
            substrLength = 0;
            index += 2;
            continue;
        }
        
        if(nextAscii - asciiCode == 1 ){
            if(substrLength == 0){
                substrLength++;
                index++;
                isDesc = NO;
                continue;
            }else{
                if(isDesc){
                    
                    substrLength = 0;
                    index += 1;
                    continue;
                }else{
                    substrLength++;
                    index++;
                    if(substrLength >= markLength){
                        return YES;
                    }
                    continue;
                }
            }
            
        }else if(nextAscii -asciiCode == -1){
            
            if(substrLength == 0){
                substrLength++;
                index++;
                isDesc = YES;
                continue;
            }else{
                if(isDesc){
                    substrLength++;
                    index++;
                    if(substrLength >= markLength){
                        return YES;
                    }
                    continue;
                    
                }else{
                    substrLength = 0;
                    index += 1;
                    continue;
                }
            }
        }else {
            substrLength = 0;
            index ++;
            continue;
        }
    }
    return NO;
}
/**
 * pincode是相同的或连续的
 */
+(BOOL)checkPincode:(NSString*)pincode{
    
    BOOL isTure = NO;//不符合规则，pincode是相同的或连续的
    NSString *pincodeRegex = @"^(?=.*\\d+)(?!.*?([\\d])\\1{4})[\\d]{5}$";
    NSPredicate *pincodePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pincodeRegex];
   
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    if ([pincodePredicate evaluateWithObject:pincode]) {
       
        // 遍历字符串，按字符来遍历。每个字符将通过block参数中的substring传出
        [pincode enumerateSubstringsInRange:NSMakeRange(0, pincode.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            //将遍历出来的字符串添加到数组中
            [arr addObject:substring];
           
        }];
       
        BOOL isInscend = [self judgeInscend:arr];
        BOOL isDescend = [self judgeDescend:arr];
        if ( !isInscend && !isDescend) {
            isTure = YES;
        }
    }
    return isTure;
}

+ (BOOL)judgeInscend:(NSArray *)arr{
    //递增12345
    int j = 0;
    for (int i = 0; i<arr.count; i++) {
        if (i>0) {
            int num = [arr[i] intValue];
            int num_ = [arr[i-1] intValue] +1;
            if (num == num_) {
                j++;
            }
        }
    }
    if (j == arr.count - 1) {
        return YES;
    }
    return NO;
}
+ (BOOL)judgeDescend:(NSArray *)arr{
    //递减54321
    int j=0;//计数归零,用于递减判断
    for (int i = 0; i<arr.count; i++) {
        if (i>0) {
            int num = [arr[i] intValue];
            int num_ = [arr[i-1] intValue]-1;
            if (num == num_) {
                j++;
            }
        }
    }
    if (j == arr.count - 1) {
        return YES;
    }
    return NO;
}
 
//判断是否相等
+ (BOOL)judgeEqual:(NSArray *)arr{
    int j=0;
    int firstNum = [arr[0] intValue];
    for (int i = 0; i<arr.count; i++) {
        if (firstNum == [arr[i] intValue]) {
            j++;
        }
    }
    if (j == arr.count - 1) {
        return YES;
    }
    return NO;
}
/**
 * 检测WIFI功能是否打开
 */
+(BOOL)isWiFiOpened
{
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) )
    {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next)
        {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP )
            {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}
/**判断当前时间和结束时间是否是将来  YES */
+(BOOL)compareDate:(NSDate*)stary withDate:(NSDate*)end{
    NSComparisonResult result = [stary compare: end];
      if (result==NSOrderedSame){
        //相等
        return NO;
    }else if (result==NSOrderedAscending){
       //结束时间大于开始时间
        return YES;
    }else if (result==NSOrderedDescending){
        //结束时间小于开始时间
        return NO;
    }
    return NO;
}
/**
 * 识别整体字符串里面是否包含指定字符串  YES
 */
+(BOOL)judgmentstring:(NSString *)string OfString:(NSString *)ofString{
    BOOL str_bool= NO;
    if([string rangeOfString:ofString].location !=NSNotFound){
        str_bool = YES;
    }else{
       str_bool = NO;
    }
    return str_bool;
}
/**
 * 获取当前IP地址
 */
+(nullable NSString*)getCurrentWifiIP
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

/**
 *  存储当前BOOL
 */
+(void)saveBoolValueInUD:(BOOL)value forKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:value forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSString
 */
+(void)saveStrValueInUD:(NSString *)str forKey:(NSString *)key{
    if(!str){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:str forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSData
 */
+(void)saveDataValueInUD:(NSData *)data forKey:(NSString *)key{
    if(!data){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:data forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSDictionary
 */
+(void)saveDicValueInUD:(NSDictionary *)dic forKey:(NSString *)key{
    if(!dic){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:dic forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSArray
 */
+(void)saveArrValueInUD:(NSArray *)arr forKey:(NSString *)key{
    if(!arr){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:arr forKey:key];
    [ud synchronize];

}
/**
 *  存储当前NSDate
 */
+(void)saveDateValueInUD:(NSDate *)date forKey:(NSString *)key{
    if(!date){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:date forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSInteger
 */
+(void)saveIntValueInUD:(NSInteger)value forKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:value forKey:key];
    [ud synchronize];
}

/**
 *  存储当前CGFloat
 */
+(void)saveFloatValueInUD:(CGFloat)value forKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setFloat:value forKey:key];
    [ud synchronize];
}

/**
 *  存储当前double
 */
+(void)saveDoubleValueInUD:(double)value forKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setDouble:value forKey:key];
    [ud synchronize];
}

/**
 *  存储当前Double
 */
+(void)saveUrlValueInUD:(NSURL*)value forKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setURL:value forKey:key];
    [ud synchronize];
}

/**
 *   保存模型id
 */
+(void)saveValueInUD:(id)value forKey:(NSString *)key{
    if(!value){return;}
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:value forKey:key];
    [ud synchronize];
}
/**
 *  获取保存的id
 */
+(id)getValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud valueForKey:key];
}
/**
 *  获取保存的NSDate
 */
+(NSDate *)getDateValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud valueForKey:key];
}
/**
 *  获取保存的NSString
 */
+(NSString *)getStrValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud stringForKey:key];
}
/**
 *  获取保存的NSInteger
 */
+(NSInteger )getIntValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud integerForKey:key];
}

/**
 *  获取保存的CGFloat
 */
+ (CGFloat)getFloatValueInUDWithKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud floatForKey:key];
}

/**
 *  获取保存的double
 */
+ (double)getdoubleValueInUDWithKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud doubleForKey:key];
}

/**
 *  获取保存的NSURL
 */
+ (NSURL*)getURLValueInUDWithKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud URLForKey:key];
}

/**
 *  获取保存的NSDictionary
 */
+(NSDictionary *)getDicValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud dictionaryForKey:key];
}
/**
 *  获取保存的NSArray
 */
+(NSArray *)getArrValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud arrayForKey:key];
}
/**
 *  获取保存的NSData
 */
+(NSData *)getdataValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud dataForKey:key];
}
/**
 *  获取保存的BOOL
 */
+(BOOL)getBoolValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:key];
}
/**
 *  删除对应的KEY
 */
+(void)removeValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:key];
    [ud synchronize];
}
/**
 *   归档
 */
+ (void)keyedArchiverObject:(id)object ToFile:(NSString *)path{
    NSError * error;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:&error];
    [data writeToFile:path atomically:YES];
}
static CGRect oldframe;
/**
 *  图片点击放大缩小
 */
+(void)showImage:(UIImageView*)avatarImageView{
    UIImage *image = avatarImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image = image;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = oldframe;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}
/**
 *  反归档
 */
+(id)keyedUnArchiverForKey:(id)object FromFile:(NSString *)path{
    NSError *error=nil;
    NSData * unData = [NSData dataWithContentsOfFile:path];
    id unarch;
    if (@available(iOS 14.0, *)) {
        unarch = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:object fromData:unData error:&error];
    } else {
        unarch = [NSKeyedUnarchiver unarchivedObjectOfClass:object fromData:unData error:&error];
    }
    return unarch;
}

/**
*  将数组拆分成固定长度的子数组
*/
+(NSArray *)splitArray:(NSArray *)array withSubSize:(int)subSize{
    //  数组将被拆分成指定长度数组的个数
    unsigned long count = array.count % subSize == 0 ? (array.count / subSize) : (array.count / subSize + 1);
    //  用来保存指定长度数组的可变数组对象
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    //利用总个数进行循环，将指定长度的元素加入数组
    for (int i = 0; i < count; i ++) {
        //数组下标
        int index = i * subSize;
        //保存拆分的固定长度的数组元素的可变数组
        NSMutableArray *arr1 = [[NSMutableArray alloc] init];
        //移除子数组的所有元素
        [arr1 removeAllObjects];
        
        int j = index;
        //将数组下标乘以1、2、3，得到拆分时数组的最大下标值，但最大不能超过数组的总大小
        while (j < subSize*(i + 1) && j < array.count) {
            [arr1 addObject:[array objectAtIndex:j]];
            j += 1;
        }
        //将子数组添加到保存子数组的数组中
        [arr addObject:[arr1 copy]];
    }
    return [arr copy];
}

+ (NSArray *)getLinesArrayOfStringInrowsOfString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)width {
    
    CTFontRef myFont = CTFontCreateWithName((CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,MAXFLOAT));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef)line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}

/**
 *  直接跳转到手机浏览器
 */
+(void)openURLAtSafari:(NSString *)urlString{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {}];
}
/**
 *  设置语音提示
 */
+(void)SpeechSynthesizer:(NSString *)SpeechUtterancestring{
    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:SpeechUtterancestring];
    utterance.rate=0.1;//设置语速快慢
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置语言类别（不能被识别，返回值为nil）
    utterance.voice = voiceType;
    [av speakUtterance:utterance];//语音合成器会生成音频
}
/**
 *  心跳动画
 */
+(void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat{
    if (view && (fDurationPerBeat > 0.1f))
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.8, 0.8, 1);
        
        CATransform3D scale2 = CATransform3DMakeScale(fMaxSize, fMaxSize, 1);
        
        CATransform3D scale3 = CATransform3DMakeScale(fMaxSize - 0.3f, fMaxSize - 0.3f, 1);
        
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                
                                [NSValue valueWithCATransform3D:scale1],
                                
                                [NSValue valueWithCATransform3D:scale2],
                                
                                [NSValue valueWithCATransform3D:scale3],
                                
                                [NSValue valueWithCATransform3D:scale4],
                                
                                nil];
        
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               
                               [NSNumber numberWithFloat:0.05],
                               
                               [NSNumber numberWithFloat:0.2],
                               
                               [NSNumber numberWithFloat:0.6],
                               
                               [NSNumber numberWithFloat:1.0],
                               
                               nil];
        
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        
        animation.duration = fDurationPerBeat;
        
        animation.repeatCount = fDuration/fDurationPerBeat;
        
        [view.layer addAnimation:animation forKey:@"heartbeatView"];
        
    }else{}
    
}
/**
 *  保存数组数据以  data.plist
 */
+(void)save:(NSArray *)Array data_plist:(NSString *)plistname{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *namepist=[NSString stringWithFormat:@"%@.plist",plistname];
    
    path = [path stringByAppendingPathComponent:namepist];
    
    [Array writeToFile:path atomically:YES];
}
/**
 *  拨打电话号码
 */
+(void)makePhoneCallWithNumber:(NSString *)number{
    NSInteger length = number.length;
    NSString *realNumber = [NSString string];
    
    for (NSInteger i = 0 ; i <length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [number substringWithRange:range];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber *subnum = [numberFormatter numberFromString:subString];
        if ( subnum || [subString isEqualToString:@"-"])
        {
            realNumber = [realNumber stringByAppendingString:subString];
        }
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"telprompt://", realNumber]]])
    {
        [self openURLAtSafari:[NSString stringWithFormat:@"%@%@", @"telprompt://", realNumber]];
    }
}
/**
 *   调转到系统邮箱
 */
+(void)makeEmil:(NSString *)mailbox{
    [self openURLAtSafari:[NSString stringWithFormat:@"%@%@",@"mailto://",mailbox]];
}
/**
 *  保存相应viwe的图片到相册
 */
+(void)savePhoto:(UIView *)views{
    UIImage * image = [self captureImageFromView:views];
    //方法1：同步存到系统相册
    __block NSString *createdAssetID =nil;//唯一标识，可以用于图片资源获取
    NSError *error =nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
}

+(void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler {
    // 1. 获取当前App的相册授权状态
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    
    // 2. 判断授权状态
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        
        // 2.1 如果已经授权, 保存图片(调用步骤2的方法)
        [self saveImage:image toCollectionWithName:collectionName completionHandler:completionHandler];
        
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) { // 如果没决定, 弹出指示框, 让用户选择
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            // 如果用户选择授权, 则保存图片
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImage:image toCollectionWithName:collectionName completionHandler:completionHandler];
            }
        }];
        
    }
}

/// 隐藏对应的字符串
+ (NSString *)hidePartWithStr:(NSString *)Str holderSingleStr:(NSString *)holderSingleStr location:(NSInteger)location length:(NSInteger)length
{
    NSString *hideNumStr = Str;
    NSString *placeHolderStr=[NSString string];
    if (![self judgeIsEmptyWithString:Str] && ![self judgeIsEmptyWithString:holderSingleStr])//判断非空
    {
        for (int i=0; i<length; i++)
        {
            placeHolderStr = [placeHolderStr stringByAppendingString:holderSingleStr];
        }
        hideNumStr =[Str stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:placeHolderStr];
    }
    return hideNumStr;
}

// 保存图片
+ (void)saveImage:(UIImage *)image toCollectionWithName:(NSString *)collectionName completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler {
    
    // 1. 获取相片库对象
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    // 2. 调用changeBlock
    [library performChanges:^{
        
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest;
        
        // 2.2 取出指定名称的相册
        PHAssetCollection *assetCollection = [self getCurrentPhotoCollectionWithTitle:collectionName];
        
        // 2.3 判断相册是否存在
        if (assetCollection) { // 如果存在就使用当前的相册创建相册请求
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else { // 如果不存在, 就创建一个新的相册请求
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName];
        }
        
        // 2.4 根据传入的相片, 创建相片变动请求
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // 2.4 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        
        // 2.5 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
        
    } completionHandler:completionHandler];
}
/**
 *  改变导航栏工具条字体颜色 0 为白色 1 为黑色
 */
+(void)BackstatusBarStyle:(NSInteger)index{
  [UIApplication sharedApplication].statusBarStyle = index==0?(UIStatusBarStyleLightContent):(UIStatusBarStyleDefault);
}

/**
 *  按钮旋转动画
 */
+(void)RotatinganimationView:(UIButton *)btn animateWithDuration:(NSTimeInterval)duration{
    if (btn.selected) {
        [UIView animateWithDuration:duration animations:^{
            btn.imageView.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {}];
    } else {
        [UIView animateWithDuration:duration animations:^{
            btn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {}];
    }
}

//步骤三用于获取当前系统中是否有指定的相册
+ (PHAssetCollection *)getCurrentPhotoCollectionWithTitle:(NSString *)collectionName {
    
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. 遍历搜索集合并取出对应的相册
    for (PHAssetCollection *assetCollection in result) {
        
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    
    return nil;
}

//截图功能
+(UIImage *)captureImageFromView:(UIView *)view{
    
    CGRect screenRect = [view bounds];
    
    UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, 0.0);//原图
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:ctx];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}
/**
 *  修改状态栏的颜色
 */
+ (void)statusBarBackgroundColor:(UIColor *)statusBarColor{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        
        statusBar.backgroundColor = statusBarColor;
    }
}

/**
 *  得到中英文混合字符串长度
 */
+ (int)lengthForText:(NSString *)text{
    int strlength = 0;
    char *p = (char*)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }else {
            p++;
        }
    }
    
    return strlength;
}

/**
 *  过滤数组中相等的数据
 */
+(NSArray *)filterSameObject:(NSArray *)array{
    NSMutableArray * mArray = [NSMutableArray new];
    for (id object in array) {
        
        if (![array containsObject:object]) {
            [mArray addObject:object];
            
        }
    }
    NSArray * filterArray =  [NSArray arrayWithArray:mArray];
    return filterArray;
}
/**
 *  获取保存好的数组数据以  data.plist
 */
+(NSArray *)readsenderArraydata_plist:(NSString *)plistname{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *namepist=[NSString stringWithFormat:@"%@.plist",plistname];
    
    path = [path stringByAppendingPathComponent:namepist];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    return array;
}

/**
 *  获取某个view在屏幕上的frame
 */
+(CGRect)rectFromSunView:(UIView *)view{
    //查找frame
    UIView *vcView = [self rootViewFromSubView:view];
    UIView *superView = view.superview;
    CGRect viewRect = view.frame;
    CGRect viewRectFromWindow = [superView convertRect:viewRect toView:vcView];
    return viewRectFromWindow;
}

+(UIView *)rootViewFromSubView:(UIView *)view
{
    UIViewController *vc = nil;
    UIResponder *next = view.nextResponder;
    do {
        if ([next isKindOfClass:[UINavigationController class]]) {
            vc = (UIViewController *)next;
            break ;
        }
        next = next.nextResponder;
    } while (next != nil);
    if (vc == nil) {
        next = view.nextResponder;
        do {
            if ([next isKindOfClass:[UIViewController class]] || [next isKindOfClass:[UITableViewController class]]) {
                vc = (UIViewController *)next;
                break ;
            }
            next = next.nextResponder;
        } while (next != nil);
    }
    
    return vc.view;
}
/**
 *  横屏截图长度 --- 获取主图片数据所返回的总图片长度 vertical 横屏 1 竖屏 0
 */
+ (void)WKWebViewScroll:(WKWebView *)webView vertical:(NSInteger)vertical CaptureCompletionHandler:(void(^)(UIImage *capturedImage))completionHandler{
    // 制作了一个UIView的副本
    UIView *snapShotView = [webView snapshotViewAfterScreenUpdates:YES];
    
    snapShotView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, snapShotView.frame.size.width, snapShotView.frame.size.height);
    
    [webView.superview addSubview:snapShotView];
    
    // 获取当前UIView可滚动的内容长度
    CGPoint scrollOffset = webView.scrollView.contentOffset;
    
    // 向上取整数 － 可滚动长度与UIView本身屏幕边界坐标相差倍数 这里是横屏所以修改了获取方法，如果是竖屏可以改成高度
    float maxIndex = ceilf(webView.scrollView.contentSize.height/webView.bounds.size.height);
    if (vertical==1) {
        maxIndex = ceilf(webView.scrollView.contentSize.width/webView.bounds.size.width);
    }
    // 保持清晰度
    UIGraphicsBeginImageContextWithOptions(webView.scrollView.contentSize, YES, [UIScreen mainScreen].scale);
    
    // 滚动截图
    [self ZTContentScroll:webView PageDraw:0 maxIndex:(int)maxIndex vertical:vertical drawCallback:^{
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 恢复原UIView
        [webView.scrollView setContentOffset:scrollOffset animated:NO];
        [snapShotView removeFromSuperview];
                
        completionHandler(capturedImage);
        
    }];
}

// 滚动截图
+(void)ZTContentScroll:(WKWebView *)webView PageDraw:(int)index maxIndex:(int)maxIndex vertical:(NSInteger)vertical drawCallback:(void(^)(void))drawCallback{
    CGRect splitFrame;
    if (vertical==1) {
        // 这里是横屏所以修改了获取方法，如果是竖屏可以改成高度 改变偏移量
        [webView.scrollView setContentOffset:CGPointMake((float)index * webView.frame.size.width, 0)];
        //这里是横屏所以修改了获取方法，如果是竖屏可以改成高度 改变偏移量
        splitFrame = CGRectMake((float)index * webView.frame.size.width,0 , webView.bounds.size.width, webView.bounds.size.height);
    }
    else{
        [webView.scrollView setContentOffset:CGPointMake(0, (float)index * webView.frame.size.height)];
        
        splitFrame = CGRectMake(0, (float)index * webView.frame.size.height, webView.bounds.size.width, webView.bounds.size.height);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [webView drawViewHierarchyInRect:splitFrame afterScreenUpdates:YES];
        if(index < maxIndex){
            [self ZTContentScroll:webView PageDraw: index + 1 maxIndex:maxIndex vertical:vertical drawCallback:drawCallback];
        }else{
            drawCallback();
        }
    });
}

#pragma mark****************************************提示框****************************************

+ (void)makeToast:(NSString *)str
{
    [TFY_ScenePackage.keyWindow tfy_makeToast:str];
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration {
    [TFY_ScenePackage.keyWindow tfy_makeToast:str duration:duration];
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position
{
    [TFY_ScenePackage.keyWindow tfy_makeToast:str duration:duration position:[NSValue valueWithCGPoint:position]];
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position
{
    [TFY_ScenePackage.keyWindow tfy_makeToast:str duration:duration position:position];
}

+ (void)hideToast {
    [TFY_ScenePackage.keyWindow tfy_hideToast];
}

+ (void)makeToastActivity
{
    [TFY_ScenePackage.keyWindow tfy_makeToastActivity:TFYToastPositionCenter];
}

+ (void)hideToastActivity
{
    [TFY_ScenePackage.keyWindow tfy_hideToastActivity];
}



@end

@implementation UIView (Utils_Chain)

/**
 *  截取图片会带哦
 */
- (void )screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock{
    if (!finishBlock)return;
    
    UIImage *snapshotImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,[UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];

    snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    finishBlock(snapshotImage);
}


@end

static const char _bundle = 0;

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation NSBundle (Utils_Chain)

+ (void)setLanguage:(NSString *)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [BundleEx class]);
    });
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
