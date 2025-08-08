//
//  UIWindow+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIWindow+TFY_Tools.h"
#import <objc/message.h>

@implementation UIWindow (TFY_Tools)

- (void)tfy_showOnCurrentScene{
    [self tfy_showOnScene:[UIApplication tfy_currentScene]];
}

- (void)tfy_showOnScene:(id)scene{
    if (UIApplication.tfy_isSceneApp) {
        if (scene && [scene isKindOfClass:NSClassFromString(@"UIWindowScene")]) {
            ((void (*)(id, SEL,id))objc_msgSend)(self,sel_registerName("setWindowScene:"),scene);
        }
    }
}
@end
