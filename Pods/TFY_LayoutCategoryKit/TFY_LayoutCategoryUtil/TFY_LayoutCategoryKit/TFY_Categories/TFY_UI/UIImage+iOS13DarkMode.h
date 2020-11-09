//
//  UIImage+iOS13DarkMode.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (iOS13DarkMode)

+ (UIImage *(^)(NSString *imageName))tfy_iOS13UnspecifiedImageName;
+ (UIImage *(^)(NSString *imageName))tfy_iOS13LightImageName;
+ (UIImage *(^)(NSString *imageName))tfy_iOS13DarkImageName;

- (UIImage *(^)(NSString *imageName))tfy_iOS13UnspecifiedImageName;
- (UIImage *(^)(NSString *imageName))tfy_iOS13LightImageName;
- (UIImage *(^)(NSString *imageName))tfy_iOS13DarkImageName;


+ (UIImage *(^)(UIImage *image))tfy_iOS13UnspecifiedImage;
+ (UIImage *(^)(UIImage *image))tfy_iOS13LightImage;
+ (UIImage *(^)(UIImage *image))tfy_iOS13DarkImage;

- (UIImage *(^)(UIImage *image))tfy_iOS13UnspecifiedImage;
- (UIImage *(^)(UIImage *image))tfy_iOS13LightImage;
- (UIImage *(^)(UIImage *image))tfy_iOS13DarkImage;

@end

NS_ASSUME_NONNULL_END
