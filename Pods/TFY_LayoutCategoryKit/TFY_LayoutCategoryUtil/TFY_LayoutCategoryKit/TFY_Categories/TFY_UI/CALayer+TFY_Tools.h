//
//  CALayer+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIColor.h>
#import "TFY_iOS13DarkModeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (TFY_Tools)

- (void(^)(UIColor *color))tfy_iOS13BorderColor;

- (void(^)(UIColor *color))tfy_iOS13ShadowColor;

- (void(^)(UIColor *color))tfy_iOS13BackgroundColor;


@end

NS_ASSUME_NONNULL_END
