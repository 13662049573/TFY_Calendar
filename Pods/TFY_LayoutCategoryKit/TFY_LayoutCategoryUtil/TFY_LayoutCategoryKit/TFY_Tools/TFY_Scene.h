//
//  TFY_Scene.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/7.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TFY_ScenePackage [TFY_Scene defaultPackage]

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Scene : NSObject

+ (instancetype)defaultPackage;

/**
 * 是否基于UIWindowScene
 */
@property (nonatomic, assign, readonly) BOOL isSceneApp;

/**
 * 当前活跃window
 */
@property (nonatomic, copy, readonly) UIWindow *window;

/**
 * 当前活跃的windows
 */
@property (nonatomic, strong, readonly) NSArray <UIWindow *>* windows;

/**
 * 当前活跃windowscene
 */
@property (nonatomic, strong, readonly) id currentScene;

@property (nonatomic, copy, readonly) UIWindow *keyWindow;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign, readonly) CGRect statusBarFrame;

@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientation;

@property (nonatomic, assign) BOOL networkActivityIndicatorVisible;

/**
 * 在window第一次加载后进行事件处理，可以保证block执行时必定加载过window
 */
- (void)addBeforeWindowEvent:(void (^) (TFY_Scene *application))event;

- (UIWindow *)appKeyWindow;

@end

typedef NS_ENUM(NSUInteger, ControllerShowType) {
    ControllerShowTypeWindow = 0,//展示在新window中
    ControllerShowTypeRootVC,//根视图展示
    ControllerShowTypeCurrentVC,//当前显示控制器
    ControllerShowTypeNavigationVC,//当前导航控制器
};

@interface UIViewController (ScenePackage)

/**
 * 展示方式
 */
@property (nonatomic, copy, readonly) UIViewController * (^ showType)(ControllerShowType type);

/**
 * 是否以动画的形式展示
 */
@property (nonatomic, copy, readonly) UIViewController * (^ showAnimated) (BOOL animated);

/**
 * 多少秒后消失
 */
@property (nonatomic, copy, readonly) UIViewController * (^ dismissTime)(NSTimeInterval dismissTime);


/**
 * 是否以动画的形式消失
 */
@property (nonatomic, copy, readonly) UIViewController * (^ dismissAnimated) (BOOL animated);

/**
 * push出的navigationBar是否隐藏
 */
@property (nonatomic, copy, readonly) UIViewController * (^ navigationBarHidden)(BOOL isHidden);

//显示当前控制器
@property (nonatomic, copy, readonly) UIViewController *( ^ push) (void);

@property (nonatomic, copy, readonly) UIViewController *( ^ pushWithNavigation) (void (^ navigationConntroller)(UINavigationController *navigationController));

@property (nonatomic, copy, readonly) UIViewController *( ^ present) (void);

@end


@interface UIViewController (ScenePackageLifeEvents)

- (void)addViewWillAppearBlock:(void (^) (UIViewController * vc, BOOL animated))block;

- (void)addViewDidLoadBlock:(void (^) (UIViewController * vc))block;

- (void)addViewDidAppearBlock:(void (^) (UIViewController * vc, BOOL animated))block;

- (void)addViewWillDisappearBlock:(void (^) (UIViewController * vc, BOOL animated))block;

- (void)addViewDidDisappearBlock:(void (^) (UIViewController * vc, BOOL animated))block;

- (void)addLoadViewBlock:(void (^) (UIViewController * vc))block;

@property (nonatomic, copy, readonly) UIViewController *  ( ^ tfy_once)(BOOL once);

@end

typedef void(^tfy_deallocTask)(id _Nonnull object);

@interface NSObject (ScenePackageObject)

- (void)addDeallocTask:(tfy_deallocTask)task;

@end

NS_ASSUME_NONNULL_END
