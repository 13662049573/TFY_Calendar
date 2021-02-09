//
//  UIImage+TFYCategory.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TFYCategory)

/**获取NSBundle或Framework里面的图片*/
+ (UIImage *)tfy_imageNamed:(NSString *)name;

/**根据颜色生成size为(1, 1)的纯色图片*/
+ (UIImage *)tfy_imageWithColor:(UIColor *)color;

/**根据颜色生成指定size的纯色图片*/
+ (UIImage *)tfy_imageWithColor:(UIColor *)color size:(CGSize)size;

/**修改指定图片颜色生成新的图片*/
+ (UIImage *)tfy_changeImage:(UIImage *)image color:(UIColor *)color;

/**图片转颜色*/
+ (UIColor*)tfy_mostColorCategory_Color:(UIImage*)image;

@end


NS_ASSUME_NONNULL_END
