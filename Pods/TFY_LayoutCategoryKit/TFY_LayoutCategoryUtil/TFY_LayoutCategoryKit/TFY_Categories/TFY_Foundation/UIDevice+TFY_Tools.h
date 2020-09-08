//
//  UIDevice+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (TFY_Tools)
/**版本号*/
+ (double)tfy_systemVersion;

+ (NSString *)tfy_localVersion;

+ (NSString *)tfy_localBuild;
/**跳转下载地址*/
+ (NSString *)tfy_storeUrlWithAppId:(NSString *)appId;

@property (nonatomic, readonly) BOOL tfy_isJailbroken;

@property (nonatomic, readonly) BOOL tfy_isPad;

@property (nonatomic, readonly) BOOL tfy_isSimulator;

@property (nullable, nonatomic, readonly) NSString *tfy_machineModel;

@property (nullable, nonatomic, readonly) NSString *tfy_machineModelName;

/**
 系统启动时间
 */
@property (nonatomic, readonly) NSDate *tfy_systemUptime;

@property (nonatomic, readonly) BOOL tfy_canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");
/**
 wifi IP
 */
@property (nullable, nonatomic, readonly) NSString *tfy_ipAddressWIFI;

/**
 cell IP
 */
@property (nullable, nonatomic, readonly) NSString *tfy_ipAddressCell;

typedef NS_OPTIONS(NSUInteger, NetworkTrafficType) {
    NetworkTrafficTypeWWANSent     = 1 << 0,
    NetworkTrafficTypeWWANReceived = 1 << 1,
    NetworkTrafficTypeWIFISent     = 1 << 2,
    NetworkTrafficTypeWIFIReceived = 1 << 3,
    NetworkTrafficTypeAWDLSent     = 1 << 4,
    NetworkTrafficTypeAWDLReceived = 1 << 5,
    
    NetworkTrafficTypeWWAN = NetworkTrafficTypeWWANSent | NetworkTrafficTypeWWANReceived,
    NetworkTrafficTypeWIFI = NetworkTrafficTypeWIFISent | NetworkTrafficTypeWIFIReceived,
    NetworkTrafficTypeAWDL = NetworkTrafficTypeAWDLSent | NetworkTrafficTypeAWDLReceived,
    
    NetworkTrafficTypeALL = NetworkTrafficTypeWWAN |
    NetworkTrafficTypeWIFI |
    NetworkTrafficTypeAWDL,
};

- (uint64_t)tfy_getNetworkTrafficBytes:(NetworkTrafficType)types;


#pragma mark - Disk Space


@property (nonatomic, readonly) int64_t tfy_diskSpace;

@property (nonatomic, readonly) int64_t tfy_diskSpaceFree;

@property (nonatomic, readonly) int64_t tfy_diskSpaceUsed;

#pragma mark - Memory Information

@property (nonatomic, readonly) int64_t tfy_memoryTotal;

@property (nonatomic, readonly) int64_t tfy_memoryUsed;

@property (nonatomic, readonly) int64_t tfy_memoryFree;

@property (nonatomic, readonly) int64_t tfy_memoryActive;

@property (nonatomic, readonly) int64_t tfy_memoryInactive;

@property (nonatomic, readonly) int64_t tfy_memoryWired;

@property (nonatomic, readonly) int64_t tfy_memoryPurgable;

@property (nonatomic, readonly) NSUInteger tfy_cpuCount;

@property (nonatomic, readonly) float tfy_cpuUsage;

@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *tfy_cpuUsagePerProcessor;
@end

NS_ASSUME_NONNULL_END
