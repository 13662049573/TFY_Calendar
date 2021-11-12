//
//  UIViewController+RootNavigation.m
//  RootNavigation
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import "UIViewController+RootNavigation.h"
#import "TFY_NavigationController.h"
#import <objc/runtime.h>

@implementation UIViewController (RootNavigation)
@dynamic tfy_disableInteractivePop;

- (void)setTfy_disableInteractivePop:(BOOL)tfy_disableInteractivePop
{
    objc_setAssociatedObject(self, @selector(tfy_disableInteractivePop), @(tfy_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.tfy_navigationController.tfy_topViewController == self) {
        self.tfy_navigationController.interactivePopGestureRecognizer.enabled = !tfy_disableInteractivePop;
    }
}

- (BOOL)tfy_disableInteractivePop
{
    return [objc_getAssociatedObject(self, @selector(tfy_disableInteractivePop)) boolValue];
}

- (Class)tfy_navigationBarClass
{
    return nil;
}

- (TFY_NavigationController *)tfy_navigationController
{
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[TFY_NavigationController class]]) {
        vc = vc.navigationController;
    }
    return (TFY_NavigationController *)vc;
}

- (id<UIViewControllerAnimatedTransitioning>)tfy_animatedTransitioning
{
    return nil;
}

-(UIImage *)tfy_imageWithColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
