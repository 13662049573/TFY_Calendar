//
//  CLLocationManager+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/8/9.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
/**
 用于表示以米为单位的位置精度级别的类型。以米为单位的值越低，
  实际位置更精确。精度值为负值表示位置无效。
 */
typedef double CLUpdateAccuracyFilter;

/**
 用于表示位置年龄(以秒为单位)的类型。
 */
typedef NSTimeInterval CLLocationAgeFilter;

/**
 这个常数表示生成更新之前所需的最小精度。
*/
extern const CLUpdateAccuracyFilter kCLUpdateAccuracyFilterNone;

/**
 此常量指示生成更新前所需的最大年龄(以秒为单位)。
 */
extern const CLLocationAgeFilter kCLLocationAgeFilterNone;

@class CLVisit;

/**
 用于指定授权描述信息的Enum
 */
typedef NS_ENUM(NSUInteger, CLLocationUpdateAuthorizationDescription) {
    CLLocationUpdateAuthorizationDescriptionAlways,
    CLLocationUpdateAuthorizationDescriptionWhenInUse,
};

/**
 Block，用于通知位置管理器的更新。

 一旦成功，将提供更新的地点。如果我们有一个错误，位置将是nil。

 发送更新的位置管理器
  location更新后的位置
 错误使用如果更新期间有错误
  stopUpdating设置为YES以便停止位置更新
 */
typedef void (^LocationManagerUpdateBlock)(CLLocationManager * __nullable manager, CLLocation *__nullable location, NSError *__nullable error, BOOL *stopUpdating);

/**
 Block，用于通知标题的更新

 成功后将提供更新的标题。如果我们有一个错误，位置将是nil。

 manager发送更新的位置管理器
 更新后的标题
 error在更新过程中发生错误时使用
 stopUpdating设置为YES以停止标题更新
 */
typedef void(^HeadingUpdateBlock)(CLLocationManager *__nullable manager, CLHeading *__nullable heading, NSError *__nullable error, BOOL *stopUpdating);

/**
 Block，用于通知对授权状态的更改

 manager发送状态的位置管理器
 状态的状态
 */
typedef void (^DidChangeAuthorizationStatusBlock)(CLLocationManager *manager, CLAuthorizationStatus status);

/**
 Block，用于通知用户进入某个区域
 */
typedef void (^DidEnterRegionBlock)(CLLocationManager *manager, CLRegion *region);

/**
 Block，用于通知用户退出某个区域
 */
typedef void (^DidExitRegionBlock)(CLLocationManager *manager, CLRegion *region);

/**
 Block，用于通知对指定区域的监视失败
 */
typedef void (^MonitoringDidFailForRegionWithBlock)(CLLocationManager *manager, CLRegion *region, NSError *error);

/**
 ，用于通知对指定区域的监视已启动
 */
typedef void (^DidStartMonitoringForRegionWithBlock)(CLLocationManager *manager, CLRegion *region);

/**
 Block 用于通知位置更新
 */
typedef void (^DidUpdateLocationsBlock)(CLLocationManager *manager, NSArray *locations);

/**
 Block 用于通知标题更新
 */
typedef void(^DidUpdateHeadingBlock)(CLLocationManager *manager, CLHeading *heading);

/**
 Block 用于通知位置错误
 */
typedef void (^DidFailWithErrorBlock)(CLLocationManager *manager, NSError *error);

/**
 Block 用于确认校准是否应显示
 */
typedef BOOL(^ShouldDisplayHeadingCalibrationBlock)(CLLocationManager *manager);

/**
 Block 用于通知监控区域的状态转换
 */
typedef void(^DidDetermineStateBlock)(CLLocationManager *manager, CLRegionState state, CLRegion *region);

/**
 Block 用于在区域更新中通知信标
 */
typedef void(^DidRangeBeaconsBlock)(CLLocationManager *manager, NSArray *beacons, CLBeaconRegion *region);

/**
 Block 用于通知信标在区域更新失败
 */
typedef void(^RangingBeaconsDidFailForRegionBlock)(CLLocationManager *manager, CLBeaconRegion *region, NSError *error);

/**
 Block 用于通知位置更新暂停
 */
typedef void(^LocationManagerDidPauseLocationUpdatesBlock)(CLLocationManager *manager);

/**
 Block 用于通知位置更新恢复
 */
typedef void(^LocationManagerDidResumeLocationUpdatesBlock)(CLLocationManager *manager);

/**
 Block 用于通知位置更新的文件将不再交付
 */
typedef void(^DidFinishDeferredUpdatesWithErrorBlock)(CLLocationManager *manager, NSError *error);

/**
 Block 用于通知与访问相关的新事件
 */
typedef void(^DidVisitBLock)(CLLocationManager *manager, CLVisit *visit) NS_AVAILABLE_IOS(8_0);

/**
 这是一个帮助类，以便将块添加到CLLocationManager作为一个类别。
 它是CLLocationManager委托，并确保调用正确的块。
 */
@interface CLLocationManagerBlocks : NSObject <CLLocationManagerDelegate>
@end

@interface CLLocationManager (TFY_Tools)
/**
 用于在内部允许将位置管理器块添加为类别
 */
@property (nonatomic, retain, readonly) id blocksDelegate;

/**
 指定使用块时的最小更新精度。客户不会被通知少的移动
 除非精度提高了，否则不会超过所规定的值。传递kCLUpdateAccuracyFilterNone
 通知所有行动。缺省情况下，使用kCLUpdateAccuracyFilterNone。
 */
@property(assign, nonatomic) CLUpdateAccuracyFilter updateAccuracyFilter;

/**
 指定使用块时的最大更新位置年龄。客户端将不会被通知位置
 年龄:比规定值大的年龄传递kCLLocationAgeFilterNone来通知所有的移动。
 缺省情况下，使用kCLLocationAgeFilterNone。
 */
@property(assign, nonatomic) CLLocationAgeFilter updateLocationAgeFilter;

/**
 更新位置管理器的默认初始化
 CLLocationManager实例
 */
+ (instancetype)updateManager;

/**
 在一个调用中用过滤器初始化位置管理器。

 @note默认使用描述为NSLocationAlwaysUsageDescription。
 这必须在Info中设置。Plist作为一个键。
 该值可能是给用户的消息。

 updateAccuracyFilter更新精度过滤器
 updateLocationAgeFilter位置年龄过滤器

 CLLocationManager实例
 */
+ (instancetype)updateManagerWithAccuracy:(CLUpdateAccuracyFilter)updateAccuracyFilter locationAge:(CLLocationAgeFilter)updateLocationAgeFilter;


/**
 在一个调用中用过滤器初始化位置管理器。

 @note NSLocationAlwaysUsageDescription或NSLocationWhenInUseUsageDescription
 必须在Info中设置。Plist作为一个键。
 该值可能是给用户的消息。

 updateAccuracyFilter更新精度过滤器
 updateLocationAgeFilter位置年龄过滤器
 authorizationDescription授权描述信息

 CLLocationManager实例
 */
+ (instancetype)updateManagerWithAccuracy:(CLUpdateAccuracyFilter)updateAccuracyFilter locationAge:(CLLocationAgeFilter)updateLocationAgeFilter authorizationDesciption:(CLLocationUpdateAuthorizationDescription)authorizationDescription NS_AVAILABLE_IOS(8_0);

/**
 在一个调用中用过滤器初始化位置管理器。

 新方法与一个块给你所有你需要接收更新在一个单一的块。
 请注意，在调用此方法时将自动开始位置更新。
 要停止位置更新，只需将*stopUpdating参数设置为YES。

 updateBlock用于位置更新的块。
 */
- (void)startUpdatingLocationWithUpdateBlock:(LocationManagerUpdateBlock)updateBlock;

/**
 这个方法的行为就像startUpdatingLocationWithUpdateBlock:方法，
 但它会通知标题更新而不是位置。
 要停止更新，只需将*stopUpdating参数设置为YES。

 updateBlock用于标题更新的块。
 */
- (void)startUpdatingHeadingWithUpdateBlock:(HeadingUpdateBlock)updateBlock;

/**
 用于检查用户是否启用了位置更新。

 指示位置和可用性的布尔值
 */
+ (BOOL)isLocationUpdatesAvailable;


/**
 替换didupdatelocation: delegate方法

 替换委托方法的块
 */
- (void)didUpdateLocationsWithBlock:(DidUpdateLocationsBlock)block;

/**
 代替didUpdateHeading: delegate方法

 替换委托方法的块
 */
- (void)didUpdateHeadingWithBock:(DidUpdateHeadingBlock)block;

/**
 替换了shouldDisplayCalibration: delegate方法

 替换委托方法的块
 */
- (void)shouldDisplayHeadingCalibrationWithBlock:(ShouldDisplayHeadingCalibrationBlock)block;

/**
 替换didDetermineState: delegate方法

 替换委托方法的块
 */
- (void)didDetermineStateWithBlock:(DidDetermineStateBlock)block;

/**
 代替didRangeBeacons: delegate方法

 替换委托方法的块
 */
- (void)didRangeBeaconsWithBlock:(DidRangeBeaconsBlock)block;

/**
 替换rangingBeaconsDidFailForRegion: delegate方法

 替换委托方法的块
 */
- (void)rangingBeaconsDidFailForRegionWithBlock:(RangingBeaconsDidFailForRegionBlock)block;

/**
 替换didEnterRegion: delegate方法

 替换委托方法的块
 */
- (void)didEnterRegionWithBlock:(DidEnterRegionBlock)block;

/**
 替换didExitRegion: delegate方法

 替换委托方法的块
 */
- (void)didExitRegionWithBlock:(DidExitRegionBlock)block;

/**
 替换didFailWithError: delegate方法

 替换委托方法的块
 */
- (void)didFailWithErrorWithBlock:(DidFailWithErrorBlock)block;

/**
 替换monitingdidfailforregion: delegate方法

 替换委托方法的块
 */
- (void)monitoringDidFailForRegionWithBlock:(MonitoringDidFailForRegionWithBlock)block;

/**
 替换didChangeAuthorizationStatus: delegate方法

 替换委托方法的块
 */
- (void)didChangeAuthorizationStatusWithBlock:(DidChangeAuthorizationStatusBlock)block;

/**
 替换didStartMonitoringForRegion: delegate方法

 替换委托方法的块
 */
- (void)didStartMonitoringForRegionWithBlock:(DidStartMonitoringForRegionWithBlock)block;

/**
 替换locationManagerDidPauseLocationUpdates: delegate方法

 替换委托方法的块
 */
- (void)locationManagerDidPauseLocationUpdatesWithBlock:(LocationManagerDidPauseLocationUpdatesBlock)block;

/**
 替换locationManagerDidResumeLocationUpdates: delegate方法

 替换委托方法的块
 */
- (void)locationManagerDidResumeLocationUpdatesWithBlock:(LocationManagerDidResumeLocationUpdatesBlock)block;

/**
 替换didFinishDeferredUpdatesWithErrorWithBlock: delegate方法

 替换委托方法的块
 */
- (void)didFinishDeferredUpdatesWithErrorWithBlock:(DidFinishDeferredUpdatesWithErrorBlock)block;

/**
 替换didVisit: delegate方法

 替换委托方法的块
 */
- (void)didVisitWithBlock:(DidVisitBLock)block NS_AVAILABLE_IOS(8_0);

@end

NS_ASSUME_NONNULL_END
