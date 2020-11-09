//
//  TFYNavigationBar.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFYNavigationBar : UINavigationBar

// 当前控制器
@property (nonatomic, assign) BOOL      tfy_statusBarHidden;

/** 导航栏背景色透明度，默认是1.0 */
@property (nonatomic, assign) CGFloat   tfy_navBarBackgroundAlpha;

@property (nonatomic, assign) BOOL      tfy_navLineHidden;

- (void)tfy_navLineHideOrShow;

@end

NS_ASSUME_NONNULL_END
