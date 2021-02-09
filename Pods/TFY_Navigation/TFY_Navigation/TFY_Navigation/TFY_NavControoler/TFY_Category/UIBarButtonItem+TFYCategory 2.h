//
//  UIBarButtonItem+TFYCategory.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NAV_ButtonImageDirection) {
    NAV_ButtonImageDirectionTop,
    NAV_ButtonImageDirectionLeft,
    NAV_ButtonImageDirectionRight,
    NAV_ButtonImageDirectionBottom,
};

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (TFYCategory)
/**
 *  按钮初始化 也是隐藏返回按钮
 */
UIBarButtonItem *tfy_barbtnItem(void);

/**
 *  添加图片 image_str 图片字符串 object self  action 点击方法 tfy_barbtnItem().tfy_imageItem(@"me_data_icom",self,@selector(imageClick));
 */
@property(nonatomic,copy,readonly)UIBarButtonItem *(^tfy_imageItem)(id,id,SEL);
/**
 *  添加 title_str 字体文本  fontOfSize字体大小  color 字体颜色 object self  action 点击方法 tfy_barbtnItem().tfy_titleItem(@"开始计时",20,[UIColor redColor],self,@selector(timeimageClick));
 */
@property(nonatomic,copy,readonly)UIBarButtonItem *(^tfy_titleItem)(NSString *,CGFloat,UIColor *,id, SEL);
/**
 *  文字--文字状态-文字颜色-文字大小  图片--图片UIImage--图片状态 direction 图片和字体距离，space 文字和图片间距  点击方法--方法状态
 *  tfy_barbtnItem().tfy_titleItembtn(CGSizeMake(100, 64), @"开始计时", [UIColor redColor], [UIFont boldSystemFontOfSize:14], [UIImage imageNamed:@"me_data_icom"], ButtonImageDirectionLeft, 2, self, @selector(imageClick), UIControlEventTouchUpInside);
 */
@property(nonatomic,copy,readonly)UIBarButtonItem *(^tfy_titleItembtn)(CGSize,NSString *,id,UIFont *,id,NAV_ButtonImageDirection,CGFloat,id, SEL,UIControlEvents);

@end

@interface UIButton (TFYCategory)
- (void)imageDirection:(NAV_ButtonImageDirection)direction space:(CGFloat)space;
@end

NS_ASSUME_NONNULL_END
