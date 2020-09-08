//
//  TFY_Scene.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/7.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_Scene.h"
#import <objc/message.h>

typedef enum : NSUInteger {
    ScenePackageSceneHookStatusUndefine,
    ScenePackageSceneHookStatusUnstart,
    ScenePackageSceneHookStatusNeed,
    ScenePackageSceneHookStatusDone
} ScenePackageSceneHookStatus;


@interface TFY_Scene ()
@property (nonatomic, assign) BOOL isSceneApp;

@property (nonatomic, assign) BOOL isLoadFirstWindow;

@property (nonatomic, strong) NSMutableArray *alertWindows;

@property (nonatomic, strong) NSMutableArray * events;

@property (nonatomic, strong) NSMutableSet * hookDelegateClassNames;

@property (nonatomic, strong) NSMutableSet * hookApplicationClassNames;

@property (nonatomic, assign) ScenePackageSceneHookStatus hookSceneStatus;

@property (nonatomic, weak) UIWindow *currentClickWindow;
@end

@implementation TFY_Scene

+ (instancetype)defaultPackage{
    static TFY_Scene *package = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        package = [TFY_Scene new];
    });
    return package;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configure];
        _hookDelegateClassNames = [NSMutableSet set];
        _hookApplicationClassNames = [NSMutableSet set];
        _alertWindows = [NSMutableArray array];
    }
    return self;
}

- (void)configure{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
        NSDictionary *sceneManifest = infoDict[@"UIApplicationSceneManifest"];
        if (sceneManifest) {
            id supportsMiltipleScenes = sceneManifest[@"UIApplicationSupportsMultipleScenes"];
            if (supportsMiltipleScenes) {
                if ([supportsMiltipleScenes integerValue] == 1) {
                    _isSceneApp = YES;
                }else{
                    NSDictionary *configurationDic = sceneManifest[@"UISceneConfigurations"];
                    if (configurationDic.count > 0) {
                        BOOL(^isValue)(NSString *) = ^(NSString *name) {
                            NSArray *role = configurationDic[name];
                            if ([role isKindOfClass:[NSArray class]] && [role count] > 0) {
                                return YES;
                            }
                            return NO;
                        };
                        NSArray *keys = @[@"UIWindowSceneSessionRoleApplication", @"UIWindowSceneSessionRoleExternalDisplay", @"CPTemplateApplicationSceneSessionRoleApplication"];
                        for (NSString *key in keys) {
                            if (isValue(key)) {
                                _isSceneApp = YES;
                                break;
                            }
                        }
                    }
                }
            }
        }
        if (_isSceneApp) {
            _hookSceneStatus = ScenePackageSceneHookStatusNeed;
        }else{
            _hookSceneStatus = ScenePackageSceneHookStatusUnstart;
        }
        
    }else{
        _hookSceneStatus = ScenePackageSceneHookStatusUndefine;
        _isLoadFirstWindow = YES;
    }
}
- (UIWindow *)window{
    if (!_isSceneApp) return self.currentClickWindow?:[UIApplication sharedApplication].delegate.window;
    NSArray *set = ((NSSet* (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication,sel_registerName("connectedScenes")).allObjects;
    id delegate;
    if (set.count == 1){
        delegate = ((id (*)(id, SEL))objc_msgSend)(set[0],sel_registerName("delegate"));
    }else{
        NSInteger lastIndex = -1;
        NSInteger count = 0;
        for (int i = 0; i < set.count; i++) {
            id windowScene = set[i];
            
            NSInteger status = ((NSInteger (*)(id, SEL))objc_msgSend)(windowScene,sel_registerName("activationState"));
            if (status == 0) {
                lastIndex = i;
                count++;
                if (count > 1) break;
            }
        }
        if (lastIndex!=-1 && count==1) {
            delegate = ((id (*)(id, SEL))objc_msgSend)(set[lastIndex],sel_registerName("delegate"));
        }else if(self.currentClickWindow == nil){
            delegate = ((id (*)(id, SEL))objc_msgSend)([set firstObject],sel_registerName("delegate"));
        }
    }
    
    if (delegate) {
        return ((UIWindow* (*)(id, SEL))objc_msgSend)(delegate,sel_registerName("window"));
    }
    return self.currentClickWindow;
}

- (NSArray<UIWindow *> *)windows{
    if (_isSceneApp) {
        id windowScene = ((id (*)(id, SEL))objc_msgSend)(self.window,sel_registerName("windowScene"));
        NSArray *windows = ((NSArray <UIWindow *>* (*)(id, SEL))objc_msgSend)(windowScene,sel_registerName("windows"));
        return windows;
    }else{
        return [UIApplication sharedApplication].windows;
    }
}

- (id)currentScene{
    if (self.window && _isSceneApp) {
        return ((id (*)(id, SEL))objc_msgSend)(self.window,sel_registerName("windowScene"));
    }
    return nil;
}

- (UIWindow *)keyWindow{
    for (UIWindow *win in self.windows) {
        if (win.isKeyWindow) {
            return win;
        }
    }
    return nil;
}



- (void)showWindow:(UIWindow *)window{
    if (self.currentScene) {
        SEL sel = sel_registerName("setWindowScene:");
        IMP imp = method_getImplementation(class_getInstanceMethod(objc_getClass("UIWindow"), sel));
        ((void (*) (id , SEL, id))imp)(window, sel, self.currentScene);
    }
}

- (void)clickUpdateWindow:(UIWindow *)window{
    if ([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) return;
    if (window == nil) return;
    if (_isSceneApp) {
        if (((id (*)(id, SEL))objc_msgSend)(self.currentClickWindow,sel_registerName("windowScene"))==((id (*)(id, SEL))objc_msgSend)(window,sel_registerName("windowScene"))) return;
    }else{
        if (self.currentClickWindow == window) return;
    }
    self.currentClickWindow = window;
}


#pragma mark - statusBar -

- (CGRect)statusBarFrame{
    if (_isSceneApp) {
        id windowScene = ((id (*)(id, SEL))objc_msgSend)(self.window,sel_registerName("windowScene"));
        id statusBarManager = ((id (*)(id, SEL))objc_msgSend)(windowScene,sel_registerName("statusBarManager"));
        id value = [statusBarManager valueForKeyPath:@"statusBarFrame"];
        CGRect rect;
        [value getValue:&rect];
        return rect;
    }else{
        return [UIApplication sharedApplication].statusBarFrame;
    }
}


- (BOOL)statusBarHidden{
    if (_isSceneApp) {
        id windowScene = ((id (*)(id, SEL))objc_msgSend)(self.window,sel_registerName("windowScene"));
        id statusBarManager = ((id (*)(id, SEL))objc_msgSend)(windowScene,sel_registerName("statusBarManager"));
        return ((BOOL (*)(id, SEL))objc_msgSend)(statusBarManager,_cmd);
    }else{
        return [UIApplication sharedApplication].statusBarHidden;
    }
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden{
    [UIApplication sharedApplication].statusBarHidden = statusBarHidden;
}

- (UIStatusBarStyle)statusBarStyle{
    if (_isSceneApp) {
        id windowScene = ((id (*)(id, SEL))objc_msgSend)(self.window,sel_registerName("windowScene"));
        id statusBarManager = ((id (*)(id, SEL))objc_msgSend)(windowScene,sel_registerName("statusBarManager"));
        return ((UIStatusBarStyle (*)(id, SEL))objc_msgSend)(statusBarManager,_cmd);
    }else{
        return [UIApplication sharedApplication].statusBarStyle;
    }
}
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    [UIApplication sharedApplication].statusBarStyle = statusBarStyle;
}

- (UIInterfaceOrientation)statusBarOrientation{
    if (_isSceneApp) {
        id windowScene = ((id (*)(id, SEL))objc_msgSend)(self.window,sel_registerName("windowScene"));
        return ((UIInterfaceOrientation (*)(id, SEL))objc_msgSend)(windowScene,sel_registerName("interfaceOrientation"));
    }else{
        return [UIApplication sharedApplication].statusBarOrientation;
    }
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)statusBarOrientation{
    [UIApplication sharedApplication].statusBarOrientation = statusBarOrientation;
}

- (BOOL)networkActivityIndicatorVisible{
    return [UIApplication sharedApplication].networkActivityIndicatorVisible;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = networkActivityIndicatorVisible;
}


#pragma mark - 异步 -

- (NSMutableArray *)events{
    if (!_events) {
        _events = [NSMutableArray array];
    }
    return _events;
}

- (void)setIsLoadFirstWindow:(BOOL)isLoadFirstWindow{
    if (_events.count == 0) {
        _isLoadFirstWindow = isLoadFirstWindow;
    }else{
        if (!_isLoadFirstWindow && isLoadFirstWindow) {
            @synchronized (self.events) {
                for (void (^ block)(TFY_Scene * _Nonnull) in self.events) {
                    block(self);
                }
                [self.events removeAllObjects];
            }
        }
        _isLoadFirstWindow = isLoadFirstWindow;
    }
}

- (void)addBeforeWindowEvent:(void (^)(TFY_Scene * _Nonnull))event{
    if (_isLoadFirstWindow) {
        event(self);
    }else{
        @synchronized (self.events) {
            [self.events addObject:event];
        }
    }
}

- (void)_scene_windowHit{
    Class swizzleClass = objc_getClass("UIWindow");
    if (!swizzleClass) return;
    SEL swizzleSelector = NSSelectorFromString(@"hitTest:withEvent:");
    if (!swizzleSelector) return;
    __block id (* oldImp) (__unsafe_unretained id, SEL,CGPoint, id) = NULL;
    id newImpBlock = ^ (__unsafe_unretained id object,CGPoint obj1,id obj2){
        UIView * obj;
        if ((IMP)oldImp != _objc_msgForward) {
            [[TFY_Scene defaultPackage] clickUpdateWindow:object];
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = object,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                obj = ((id (*) (struct objc_super *, SEL, CGPoint, id))objc_msgSendSuper)(&supperInfo, swizzleSelector,obj1,obj2);
            }else{
                obj = oldImp(object,swizzleSelector,obj1,obj2);
            }
        }
        return obj;
    };
    oldImp = (__typeof__ (oldImp))[self methodImpSet:newImpBlock class:swizzleClass selector:swizzleSelector];
}

- (void)_scene_init{
    Class swizzleClass = objc_getClass("UIWindowScene");
    if (!swizzleClass) return;
    SEL swizzleSelector = NSSelectorFromString(@"initWithSession:connectionOptions:");
    if (!swizzleSelector) return;
    __block id (* oldImp) (__unsafe_unretained id, SEL, id,id) = NULL;
    id newImpBlock = ^ (__unsafe_unretained id object, id obj1,id obj2){
        id obj;
        if ((IMP)oldImp != _objc_msgForward) {
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = object,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                obj = ((id (*) (struct objc_super *, SEL,id,id))objc_msgSendSuper)(&supperInfo, swizzleSelector,obj1,obj2);
                
            }else{
                obj = oldImp(object,swizzleSelector,obj1,obj2);
            }
            [[TFY_Scene defaultPackage] setScene:obj];
        }
        return obj;
        
    };
    
    oldImp = (__typeof__ (oldImp))(__typeof__ (oldImp))[self methodImpSet:newImpBlock class:swizzleClass selector:swizzleSelector];
}

- (void)methodSwizzledScene{
    @synchronized (self) {
        if (_isSceneApp && _hookSceneStatus == ScenePackageSceneHookStatusNeed) {
            [self _scene_init];
            [self _scene_setDelegate];
            [self _scene_windowHit];
            _hookSceneStatus = ScenePackageSceneHookStatusDone;
        }
    }
}

- (void)_scene_setDelegate{
    Class swizzleClass = objc_getClass("UIWindowScene");
    if (!swizzleClass) return;
    SEL swizzleSelector = NSSelectorFromString(@"setDelegate:");
    if (!swizzleSelector) return;
    __block void (* oldImp) (__unsafe_unretained id, SEL,id) = NULL;
    id newImpBlock = ^ (__unsafe_unretained id object, id obj1){
        if ((IMP)oldImp != _objc_msgForward) {
            [[TFY_Scene defaultPackage] setSceneDelegate:obj1];
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = object,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL, id))objc_msgSendSuper)(&supperInfo, swizzleSelector,obj1);
            }else{
                oldImp(object,swizzleSelector,obj1);
            }
        }
    };
    
    oldImp = (__typeof__ (oldImp))[self methodImpSet:newImpBlock class:swizzleClass selector:swizzleSelector];
}

- (void)setScene:(id)scene{
    if (!scene) return;
    if ([scene respondsToSelector:sel_registerName("delegate")]) {
        id delegate = ((id (*)(id, SEL))objc_msgSend)(scene,sel_registerName("delegate"));
        [self setSceneDelegate:delegate];
    }
}
- (void)setSceneDelegate:(id)delegate{
    if (!delegate) return;
    @synchronized (self.hookDelegateClassNames) {
        NSString *clasName = NSStringFromClass([delegate class]);
        if ([self.hookDelegateClassNames containsObject:clasName]) return;
        [self hookSceneDelegate:delegate];
        [self.hookDelegateClassNames addObject:clasName];
    }
}
- (void)hookSceneDelegate:(id)delegate{
    [self _scene_willConnectToSession:delegate];
}
- (void)_scene_willConnectToSession:(id)delegate{
    Class swizzleClass = [delegate class];
    if (!swizzleClass) return;
    SEL swizzleSelector = NSSelectorFromString(@"scene:willConnectToSession:options:");
    if (!swizzleSelector) return;
    __block void (* oldImp) (__unsafe_unretained id, SEL,id,id,id) = NULL;
    id newImpBlock = ^ (__unsafe_unretained id object,id obj1,id obj2,id obj3){
        if ((IMP)oldImp != _objc_msgForward) {
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = object,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL,id,id,id))objc_msgSendSuper)(&supperInfo, swizzleSelector,obj1,obj2,obj3);
            }else{
                oldImp(object,swizzleSelector,obj1,obj2,obj3);
            }
        }
        [[TFY_Scene defaultPackage] setIsLoadFirstWindow:YES];
    };
    
    oldImp = (__typeof__ (oldImp))[self methodImpSet:newImpBlock class:swizzleClass selector:swizzleSelector];
}

- (IMP)methodImpSet:(dispatch_block_t)newImpBlock class:(Class)class selector:(SEL)selector{
    
    IMP newImp = imp_implementationWithBlock(newImpBlock);
    Method method = class_getInstanceMethod(class, selector);
    IMP imp = method== NULL?_objc_msgForward:NULL;
    if (!class_addMethod(class, selector, newImp, method_getTypeEncoding(method))) {
        imp = method_setImplementation(method, newImp);
    }
    return imp;
}

- (void)_checkApplicationIsSceneApp:(id)delegate{
    @synchronized (self) {
        if (_hookSceneStatus == ScenePackageSceneHookStatusUnstart) {
            if ([delegate respondsToSelector:sel_registerName("application:configurationForConnectingSceneSession:options:")]) {
                _isSceneApp = YES;
                _hookSceneStatus = ScenePackageSceneHookStatusNeed;
                [self methodSwizzledScene];
                
            }else{
                self.isLoadFirstWindow = YES;
            }
        }
    }
}
- (void)_application_setDelegate{
    Class swizzleClass = objc_getClass("UIApplication");
    if (!swizzleClass) return;
    SEL swizzleSelector = NSSelectorFromString(@"setDelegate:");
    if (!swizzleSelector) return;
    __block void (* oldImp) (__unsafe_unretained id, SEL,id) = NULL;
    id newImpBlock = ^ (__unsafe_unretained id object, id obj1){
        [[TFY_Scene defaultPackage] _checkApplicationIsSceneApp:obj1];
        if ((IMP)oldImp != _objc_msgForward) {
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = object,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL, id))objc_msgSendSuper)(&supperInfo, swizzleSelector,obj1);
            }else{
                oldImp(object,swizzleSelector,obj1);
            }
        }
    };
    
    oldImp = (__typeof__ (oldImp))[self methodImpSet:newImpBlock class:swizzleClass selector:swizzleSelector];
}


- (void)methodSwizzledApplication{
    [self _application_setDelegate];
    
}
@end

__attribute__((constructor)) static void ScenePackageExcImp(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[TFY_Scene defaultPackage] methodSwizzledScene];
        [[TFY_Scene defaultPackage] methodSwizzledApplication];
    });
}


@interface ScenePackageRootViewController : UIViewController

@end

@implementation ScenePackageRootViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

@end

typedef NS_ENUM(NSUInteger, ControllerShowStyle) {
    ControllerShowStylePresent = 0,//模态推出
    ControllerShowStylePush//push
};
static void * kScenePackageShowTypeKey = &kScenePackageShowTypeKey;
static void * kScenePackageShowStyleKey = &kScenePackageShowStyleKey;
static void * kScenePackageShowDismissTimeKey = &kScenePackageShowDismissTimeKey;
static void * kScenePackageShowAnimatedKey = &kScenePackageShowAnimatedKey;
static void * kScenePackageShowDismissKey = &kScenePackageShowDismissKey;
static void * kScenePackageShowNavigationBarKey = &kScenePackageShowNavigationBarKey;
static void * kScenePackageReturnNavigationControllerKey = &kScenePackageReturnNavigationControllerKey;

@implementation UIViewController (ScenePackage)

- (void)___showViewController{
    dispatch_async(dispatch_get_main_queue(), ^{
        id showType = objc_getAssociatedObject(self, kScenePackageShowTypeKey);
        if (showType && [showType integerValue] != ControllerShowTypeWindow) {
            [self ___showInRootController];
        }else{
            [self ___showInNewWindow];
        }
    });
}


- (void)___showInNewWindow{
    
    NSInteger showStyle = [objc_getAssociatedObject(self, kScenePackageShowStyleKey) integerValue];
    BOOL showAnimated = [self __AssociatedViewControllerboolValue:kScenePackageShowAnimatedKey default:showStyle == ControllerShowStylePush];
    BOOL dismissAnimated = [self __AssociatedViewControllerboolValue:kScenePackageShowDismissKey default:showStyle == ControllerShowStylePush];
    NSTimeInterval time = [objc_getAssociatedObject(self, kScenePackageShowDismissTimeKey) doubleValue];
    UIWindow *currentWindow = ({
        NSArray *windows = [TFY_Scene defaultPackage].windows;
        UIWindow *highWindow = windows.firstObject;
        for (UIWindow * window  in windows) {
            if (window.windowLevel > highWindow.windowLevel) {
                highWindow = window;
            }
        }
        highWindow;
    });
    [currentWindow endEditing:YES];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[TFY_Scene defaultPackage].window.frame];
    window.windowLevel = currentWindow.windowLevel+1;
    [[TFY_Scene defaultPackage] showWindow:window];
    ScenePackageRootViewController *root = [[ScenePackageRootViewController alloc] init];
    [root.tfy_once(YES) addViewDidLoadBlock:^(UIViewController * _Nonnull vc) {
        if (vc.navigationController) {
            [self __dealNaviagtionReturnBlock:vc.navigationController];
        }
        objc_setAssociatedObject(self, kScenePackageReturnNavigationControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
    if (showStyle == ControllerShowStylePush) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
        window.rootViewController = nav;
        nav.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)nav;
        nav.navigationBarHidden = YES;
    }else{
        window.rootViewController = root;
    }
    window.hidden = NO;
    [window makeKeyWindow];
    window.backgroundColor = [UIColor clearColor];
    
    [[TFY_Scene defaultPackage].alertWindows addObject:window];
    if (showStyle == ControllerShowStylePush) {
        id isBarHidden = objc_getAssociatedObject(self, kScenePackageShowNavigationBarKey);
        BOOL defaultNavigationBarHidden = YES;
        BOOL barHidden = YES;
        if (!isBarHidden) {
            UIViewController *topViewController = [self __getTopViewController:currentWindow.rootViewController];
            UINavigationController *currentTopNavi = [self ___getNavigationControllerWithVC:topViewController];
            YES;
            if (currentTopNavi) {
                defaultNavigationBarHidden = currentTopNavi.navigationBar.isHidden;
            }
            barHidden = defaultNavigationBarHidden;
            root.title = topViewController.title?:topViewController.navigationItem.title;
        }else{
            barHidden = [isBarHidden boolValue];
        }
        [self addViewWillDisappearBlock:^(UIViewController * _Nonnull vc, BOOL animated) {
            vc.navigationController.navigationBarHidden = defaultNavigationBarHidden;
        }];
        [self addViewWillAppearBlock:^(UIViewController * _Nonnull vc, BOOL animated) {
            vc.navigationController.navigationBarHidden = barHidden;
        }];
        
        [root.tfy_once(YES) addViewDidAppearBlock:^(UIViewController * _Nonnull vc, BOOL animated) {
            [vc.navigationController pushViewController:self animated:showAnimated];
            
        }];
        if (time > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:dismissAnimated];
            });
        }
    }else{
        [root.tfy_once(YES) addViewDidAppearBlock:^(UIViewController * _Nonnull vc, BOOL animated) {
            [vc presentViewController:self animated:showAnimated completion:nil];
        }];
        if (time > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:dismissAnimated completion:nil];
            });
        }
    }
    
    __weak typeof(window)weakWindow = window;
    [self addDeallocTask:^(id  _Nonnull object) {
        __strong typeof(weakWindow) strongWindow = weakWindow;
        if (!strongWindow) return;
        [strongWindow resignKeyWindow];
        [[TFY_Scene defaultPackage].alertWindows removeObject:strongWindow];
        [strongWindow removeFromSuperview];
        strongWindow.hidden = YES;
    }];
}

- (void)___showInRootController{
    
    UIViewController *viewController = ([TFY_Scene defaultPackage].keyWindow?:[TFY_Scene defaultPackage].window).rootViewController;
    UIViewController *vc = [self __getTopViewController:viewController];
    if (vc) {
        NSInteger showStyle = [objc_getAssociatedObject(self, kScenePackageShowStyleKey) integerValue];
        BOOL showAnimated = [self __AssociatedViewControllerboolValue:kScenePackageShowAnimatedKey default:showStyle == ControllerShowStylePush];
        BOOL dismissAnimated = [self __AssociatedViewControllerboolValue:kScenePackageShowDismissKey default:showStyle == ControllerShowStylePush];
        NSTimeInterval time = [objc_getAssociatedObject(self, kScenePackageShowDismissTimeKey) doubleValue];
        if (showStyle == ControllerShowStylePush) {
            UINavigationController *nav = [self ___getNavigationControllerWithVC:vc];
            [nav pushViewController:self animated:showAnimated];
            if (time > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:dismissAnimated];
                });
            }
        }else{
            ControllerShowType showType = [objc_getAssociatedObject(self, kScenePackageShowTypeKey) integerValue];
            if (showType == ControllerShowTypeRootVC) {
                [viewController presentViewController:self animated:showAnimated completion:nil];
            }else if (showType == ControllerShowTypeNavigationVC){
                UINavigationController *nav = [self ___getNavigationControllerWithVC:vc];
                [nav presentViewController:self animated:showAnimated completion:nil];
            }else{
                [vc presentViewController:self animated:showAnimated completion:nil];
            }
            if (time > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:dismissAnimated completion:nil];
                });
            }
        }
    }
    
}

- (BOOL)__AssociatedViewControllerboolValue:(void *)key default:(BOOL)booValue{
    id value = objc_getAssociatedObject(self, key);
    if (value) {
        return [value boolValue];
    }else{
        return booValue;
    }
    
}

- (void)__dealNaviagtionReturnBlock:(UINavigationController *)nav{
    void (^block) (UINavigationController *nav) = objc_getAssociatedObject(self, kScenePackageReturnNavigationControllerKey);
    if (block) {
        block(nav);
    }
}

- (UIViewController *)__getTopViewController:(UIViewController *)viewController{
    UIViewController *vc = viewController;
    Class naVi = [UINavigationController class];
    Class tabbarClass = [UITabBarController class];
    BOOL isNavClass = [vc isKindOfClass:naVi];
    BOOL isTabbarClass = NO;
    if (!isNavClass) {
        isTabbarClass = [vc isKindOfClass:tabbarClass];
    }
    while (isNavClass || isTabbarClass) {
        UIViewController * top;
        if (isNavClass) {
            top = [(UINavigationController *)vc topViewController];
        }else{
            top = [(UITabBarController *)vc selectedViewController];
        }
        if (top) {
            vc = top;
        }else{
            break;
        }
        isNavClass = [vc isKindOfClass:naVi];
        if (!isNavClass) {
            isTabbarClass = [vc isKindOfClass:tabbarClass];
        }
    }
    return vc;
}

- (UINavigationController *)___getNavigationControllerWithVC:(UIViewController *)vc{
    UIResponder * responder = vc.view.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UINavigationController class]]) {
            break;
        }
        responder = responder.nextResponder;
    }
    return (UINavigationController *)responder;
}

- (UIViewController * _Nonnull (^)(ControllerShowType))showType{
    return ^(ControllerShowType type){
        objc_setAssociatedObject(self, kScenePackageShowTypeKey, @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}


- (UIViewController * _Nonnull (^)(BOOL))showAnimated{
    return ^(BOOL isAnimated){
        objc_setAssociatedObject(self, kScenePackageShowAnimatedKey, @(isAnimated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}

- (UIViewController * _Nonnull (^)(NSTimeInterval))dismissTime{
    return ^(NSTimeInterval time){
        objc_setAssociatedObject(self, kScenePackageShowDismissTimeKey, @(time), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}

- (UIViewController * _Nonnull (^)(BOOL))dismissAnimated{
    return ^ (BOOL isAnimated){
        objc_setAssociatedObject(self, kScenePackageShowDismissKey, @(isAnimated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}

- (UIViewController * _Nonnull (^)(void))present{
    return ^{
        if ([self __isShowing]) return self;
        objc_setAssociatedObject(self, kScenePackageShowStyleKey, @(ControllerShowStylePresent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self ___showViewController];
        return self;
    };
}

- (UIViewController * _Nonnull (^)(void))push{
    return ^{
        if ([self __isShowing]) return self;
        objc_setAssociatedObject(self, kScenePackageShowStyleKey, @(ControllerShowStylePush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self ___showViewController];
        return self;
    };
}

- (BOOL)__isShowing{
    if( objc_getAssociatedObject(self, @selector(___showViewController)))return YES;
    objc_setAssociatedObject(self, @selector(___showViewController), @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.tfy_once(YES) addViewDidAppearBlock:^(UIViewController * _Nonnull vc, BOOL animated) {
        objc_setAssociatedObject(vc, @selector(___showViewController), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
    return NO;
}

- (UIViewController * _Nonnull (^)(BOOL))navigationBarHidden{
    return ^(BOOL navigationbarHidden){
        objc_setAssociatedObject(self, kScenePackageShowNavigationBarKey, @(navigationbarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}

- (UIViewController * _Nonnull (^)(void (^ _Nonnull)(UINavigationController * _Nonnull)))pushWithNavigation{
    return ^ (void (^navigationContoller) (UINavigationController *nav)){
        objc_setAssociatedObject(self, kScenePackageReturnNavigationControllerKey, navigationContoller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self.push();
    };
}

@end



static void *kScenePackageViewLifeEventTasksKey = &kScenePackageViewLifeEventTasksKey;
static void *kScenePackageViewLifeEventFlagTag = &kScenePackageViewLifeEventFlagTag;
static void *kScenePackageViewLifeEventOnceKey = &kScenePackageViewLifeEventOnceKey;
CG_INLINE void ScenePackageViewLifeEventSwizzledMethodExp(Class swizzleClass, NSString *sel){
    @synchronized (swizzleClass) {
        NSMutableArray *sels = objc_getAssociatedObject(swizzleClass, kScenePackageViewLifeEventFlagTag);
        if (!sels) {
            sels = [NSMutableArray array];
            objc_setAssociatedObject(swizzleClass, kScenePackageViewLifeEventFlagTag, sels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        if ([sels containsObject:sel]) return;
        [sels addObject: sel];
        SEL selector = NSSelectorFromString(sel);
        __block void (* oldImp) (__unsafe_unretained id, SEL,BOOL) = NULL;
        id newImpBlock = ^ (__unsafe_unretained id self,BOOL animated){
            NSMutableDictionary *taskMap = objc_getAssociatedObject(self, kScenePackageViewLifeEventTasksKey);
            NSMutableArray *tasks = [taskMap objectForKey:sel];
            NSArray * untableTasks = tasks.copy;
            @synchronized (untableTasks) {
                if (untableTasks.count > 0) {
                    for (id obj in untableTasks) {
                        if ([objc_getAssociatedObject(obj, kScenePackageViewLifeEventOnceKey) boolValue]) {
                            [tasks removeObject:obj];
                        }

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (obj) {
                                ((void (^) (id,BOOL))obj)([sel isEqualToString:@"viewDidDisappear:"]?nil:self,animated);
                            }
                        });
                    }
                }
            }
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL,BOOL))objc_msgSendSuper)(&supperInfo, selector, animated);
            }else{
                oldImp(self,selector,animated);
            }
        };
        IMP newImp = imp_implementationWithBlock(newImpBlock);
        Method method = class_getInstanceMethod(swizzleClass, selector);
        if (!class_addMethod(swizzleClass, selector, newImp, method_getTypeEncoding(method))) {
            oldImp = (__typeof__ (oldImp))method_getImplementation(method);
            oldImp = (__typeof__ (oldImp))method_setImplementation(method, newImp);
        }
    }
}

CG_INLINE void ScenePackageViewLifeEventSwizzledNoParametersMethodExp(Class swizzleClass, NSString *sel){
    @synchronized (swizzleClass) {
        NSMutableArray *sels = objc_getAssociatedObject(swizzleClass, kScenePackageViewLifeEventFlagTag);
        if (!sels) {
            sels = [NSMutableArray array];
            objc_setAssociatedObject(swizzleClass, kScenePackageViewLifeEventFlagTag, sels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        if ([sels containsObject:sel]) return;
        [sels addObject: sel];
        SEL selector = NSSelectorFromString(sel);
        __block void (* oldImp) ( id, SEL) = NULL;
        id newImpBlock = ^ ( id self){
            NSMutableDictionary *taskMap = objc_getAssociatedObject(self, kScenePackageViewLifeEventTasksKey);
            NSMutableArray *tasks = [taskMap objectForKey:sel];
            NSArray * untableTasks = tasks.copy;
            @synchronized (untableTasks) {
                if (untableTasks.count > 0) {
                    for (id obj in untableTasks) {
                        if ([objc_getAssociatedObject(obj, kScenePackageViewLifeEventOnceKey) boolValue]) {
                            [tasks removeObject:obj];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (obj) {
                                ((void (^) (id))obj)(self);
                            }
                        });
                    }
                }
            }
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL))objc_msgSendSuper)(&supperInfo, selector);
            }else{
                oldImp(self,selector);
            }
        };
        IMP newImp = imp_implementationWithBlock(newImpBlock);
        Method method = class_getInstanceMethod(swizzleClass, selector);
        if (!class_addMethod(swizzleClass, selector, newImp, method_getTypeEncoding(method))) {
            oldImp = (__typeof__ (oldImp))method_getImplementation(method);
            oldImp = (__typeof__ (oldImp))method_setImplementation(method, newImp);
        }
    }
}

@implementation UIViewController (ScenePackageLifeEvents)

- (void)__viewLifeEventTasks:(NSString *)key block:(id)block{
    NSMutableDictionary * tasksMap = objc_getAssociatedObject(self, kScenePackageViewLifeEventTasksKey);
    NSMutableArray *tasks;
    if (tasksMap) {
        tasks = tasksMap[key];
    }else{
        tasksMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, kScenePackageViewLifeEventTasksKey, tasksMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    @synchronized (tasksMap) {
        if (!tasks) {
            tasks = [NSMutableArray array];
            tasksMap[key] = tasks;
        }
        if (![key hasSuffix:@":"]) {
            ScenePackageViewLifeEventSwizzledNoParametersMethodExp(object_getClass(self),key);
        }else{
            ScenePackageViewLifeEventSwizzledMethodExp(object_getClass(self),key);
        }
        
        [tasks addObject:[block copy]];
        objc_setAssociatedObject(tasks.lastObject, kScenePackageViewLifeEventOnceKey, objc_getAssociatedObject(self, kScenePackageViewLifeEventOnceKey), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kScenePackageViewLifeEventOnceKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)addViewWillAppearBlock:(void (^) (UIViewController * vc, BOOL animated))block{
    [self __viewLifeEventTasks:@"viewWillAppear:" block:block];
}

- (void)addViewDidLoadBlock:(void (^)(UIViewController * _Nonnull))block{
    [self __viewLifeEventTasks:@"viewDidLoad" block:block];
}

- (void)addViewDidAppearBlock:(void (^) (UIViewController * vc, BOOL animated))block{
    [self __viewLifeEventTasks:@"viewDidAppear:" block:block];
}

- (void)addViewWillDisappearBlock:(void (^) (UIViewController * vc, BOOL animated))block{
    [self __viewLifeEventTasks:@"viewWillDisappear:" block:block];
}

- (void)addViewDidDisappearBlock:(void (^) (UIViewController * vc, BOOL animated))block{
    [self __viewLifeEventTasks:@"viewDidDisappear:" block:block];
}

- (void)addLoadViewBlock:(void (^)(UIViewController * _Nonnull))block{
    [self __viewLifeEventTasks:@"loadView" block:block];
}

- (UIViewController * _Nonnull (^)(BOOL))tfy_once{
    return ^ (BOOL once){
        objc_setAssociatedObject(self, kScenePackageViewLifeEventOnceKey, @(once), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}
@end

static const void *RuntimeDeallocTasks = &RuntimeDeallocTasks;
static const void *RuntimeDeallocClassTag = &RuntimeDeallocClassTag;

CG_INLINE void tfy_swizzleDeallocIfNeed(Class swizzleClass){
    @synchronized (swizzleClass) {
        if (objc_getAssociatedObject(swizzleClass, RuntimeDeallocClassTag)) return;
        objc_setAssociatedObject(swizzleClass, RuntimeDeallocClassTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (* oldImp) (__unsafe_unretained id, SEL) = NULL;
        
        id newImpBlock = ^ (__unsafe_unretained id self){
            
            NSMutableArray *deallocTask = objc_getAssociatedObject(self, RuntimeDeallocTasks);
            @synchronized (deallocTask) {
                if (deallocTask.count > 0) {
                    [deallocTask enumerateObjectsUsingBlock:^(tfy_deallocTask obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj) {
                            obj(self);
                        }
                    }];
                    [deallocTask removeAllObjects];
                }
            }
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL))objc_msgSendSuper)(&supperInfo, deallocSelector);
            }else{
                oldImp(self,deallocSelector);
            }
        };
        IMP newImp = imp_implementationWithBlock(newImpBlock);
        if (!class_addMethod(swizzleClass, deallocSelector, newImp, "v@:")) {
            Method deallocMethod = class_getInstanceMethod(swizzleClass, deallocSelector);
            oldImp = (__typeof__ (oldImp))method_getImplementation(deallocMethod);
            oldImp = (__typeof__ (oldImp))method_setImplementation(deallocMethod, newImp);
        }
    }
}

@implementation NSObject (ScenePackageObject)

- (NSMutableArray<tfy_deallocTask> *)tfy_deallocTasks{
    NSMutableArray *tasks = objc_getAssociatedObject(self, RuntimeDeallocTasks);
    if (tasks) return tasks;
    tasks = [NSMutableArray array];
    tfy_swizzleDeallocIfNeed(object_getClass(self));
    objc_setAssociatedObject(self, RuntimeDeallocTasks, tasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return tasks;
}

- (void)addDeallocTask:(void (^)(id _Nonnull))task{
    @synchronized ([self tfy_deallocTasks]) {
        [[self tfy_deallocTasks] addObject:task];
    }
}

@end
