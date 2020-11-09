//
//  UIWindow+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIApplication+TFY_Tools.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (TFY_Tools)
- (void)tfy_showOnCurrentScene;

- (void)tfy_showOnScene:(id)scene;
@end

NS_ASSUME_NONNULL_END
