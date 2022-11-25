//
//  TFYExtensionRotation.h
//  ScreenRotation
//
//  Created by 田风有 on 2022/10/8.
//  Copyright © 2022 Twisted Fate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TFYRotatingWizzle.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFYRotateDefault : NSObject

@property (nonatomic, assign) BOOL defaultShouldAutorotate; // default YES
@property (nonatomic, assign) UIInterfaceOrientationMask defaultSupportedInterfaceOrientations; // default UIInterfaceOrientationMaskPortrait
@property (nonatomic, assign) UIInterfaceOrientation defaultPreferredInterfaceOrientationForPresentation; // default UIInterfaceOrientationPortrait
@property (nonatomic, assign) UIStatusBarStyle defaultPreferredStatusBarStyle; // default UIStatusBarStyleDefault
@property (nonatomic, assign) BOOL defaultPrefersStatusBarHidden; // default NO
+ (instancetype)shared;

@end

__attribute__((objc_subclassing_restricted))
@interface TFYRotationModel : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *cls;
- (instancetype)initWithClass:(NSString *)cls containsSubClass:(BOOL)containsSubClass; // 默认不改变这个类
- (instancetype)configContainsSubClass:(BOOL)containsSubClass;
- (instancetype)configShouldAutorotate:(BOOL)shouldAutorotate;
- (instancetype)configSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (instancetype)configPrefersStatusBarHidden:(UIInterfaceOrientation)prefersStatusBarHidden;
- (instancetype)configPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle;
- (instancetype)configPreferredInterfaceOrientationForPresentation:(BOOL)preferredInterfaceOrientationForPresentation;
/*
 可以通过打印来查看具体内容
 */
- (NSString *)description;
- (NSString *)debugDescription;

@end

static inline NSArray <TFYRotationModel *> * __UIViewControllerDefaultRotationClasses() {
    NSArray <NSString *>*classNames = @[
    @"AVPlayerViewController",
    @"AVFullScreenViewController",
    @"AVFullScreenPlaybackControlsViewController",
    @"WebFullScreenVideoRootViewController",
    @"UISnapshotModalViewController",
    @"TFY_NavigationController"
    ];
    NSMutableArray <TFYRotationModel *> * result = [NSMutableArray arrayWithCapacity:classNames.count];
    [classNames enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:[[[[TFYRotationModel alloc]
                             initWithClass:className
                             containsSubClass:YES]
                            configShouldAutorotate:true]
                           configSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll]];
    }];
    return result;
}

@interface UIViewController (Rotation)

/**
 注册内部不能实例化的类, 使其强制应用某些旋转特性
 models 要注册的类转换成的Model, 支持多个
 */
+ (void)registerClasses:(NSArray<TFYRotationModel *> *)models;

/**
 查看已经注册的内部类
 已经注册的类转换成的Model
 */
+ (NSArray <TFYRotationModel *> *)registedClasses;

/**
 若想要删除某些不需要的类, 则调用此方法
 classes 类名字符串列表
 */
+ (void)removeClasses:(NSArray<NSString *> *)classes;

@end

NS_ASSUME_NONNULL_END
