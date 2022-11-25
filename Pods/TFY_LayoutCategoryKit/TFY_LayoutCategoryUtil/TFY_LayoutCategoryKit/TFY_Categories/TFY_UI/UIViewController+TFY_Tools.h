//
//  UIViewController+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TFYPopDirection){
    TFYPopDirectionCenter = 0,
    TFYPopDirectionTop,
    TFYPopDirectionLeft,
    TFYPopDirectionRight,
    TFYPopDirectionBottom
};

typedef void(^PresentCompletion)(void);

@interface UIViewController (TFY_Tools)

+ (UIViewController *)currentViewController;

- (void)presentViewController:(UIViewController *)viewController inSize:(CGSize)size direction:(TFYPopDirection)direction completion:(PresentCompletion)completion;

- (void)dismissViewController;

@end

@interface UINavigationController (TFY_PlayerRotation)

@end

@interface UITabBarController (TFY_PlayerRotation)

@end

@interface UIAlertController (TFY_PlayerRotation)

@end

NS_ASSUME_NONNULL_END
