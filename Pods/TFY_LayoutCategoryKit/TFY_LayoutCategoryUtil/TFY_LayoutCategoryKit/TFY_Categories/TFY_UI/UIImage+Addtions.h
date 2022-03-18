//
//  UIImage+Addtions.h
//  TFY_ChatIMInterface
//
//  Created by 田风有 on 2022/2/11.
//

#import <UIKit/UIKit.h>

@interface UIImage (Addtions)

#pragma mark --- 微信群组头像拼接 默认 100 * 100 的大小
///  支持urrl 地址传值
+ (UIImage *)tfy_groupIconWith:(NSArray *)array bgColor:(UIColor *)bgColor;
/// 支持本地url 和 image
+ (UIImage *)tfy_groupIconWithURLArray:(NSArray *)URLArray bgColor:(UIColor *)bgColor;

@end
