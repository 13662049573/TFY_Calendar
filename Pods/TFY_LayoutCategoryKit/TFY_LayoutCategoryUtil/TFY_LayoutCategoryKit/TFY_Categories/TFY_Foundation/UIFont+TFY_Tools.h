//
//  UIFont+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define Font(type,fontSize) [UIFont tfy_fontType:type size:fontSize]

#define Font_Scale(type,fontSize) [UIFont tfy_fontScaleType:type size:fontSize]

typedef NS_ENUM(NSInteger, fontType) {
    SystemFont = 0,
    PingFangLight,
    PingFangReguler,
    PingFangMedium,
    PingFangSemibold,
    STHeitiSCLight,
    STHeitiSCMedium,
    DinaAlternateBold
};

@interface UIFont (TFY_Tools)

+ (UIFont *)tfy_fontScaleWithName:(NSString *)fontName fontSize:(CGFloat)fontSize;

+ (UIFont *)tfy_fontWithName:(NSString *)fontName fontSize:(CGFloat)fontSize;

+ (UIFont *)tfy_fontType:(fontType)type size:(CGFloat)size;

+ (UIFont *)tfy_fontScaleType:(fontType)type size:(CGFloat)size;

+ (UIFont *)tfy_PingFangSCLightAndSize:(CGFloat)size;

+ (UIFont *)tfy_PingFangSCRegularAndSize:(CGFloat)size;

+ (UIFont *)tfy_PingFangSCMediumAndSize:(CGFloat)size;

+ (UIFont *)tfy_PingFangSCScaleMediumAndSize:(CGFloat)size;

+ (UIFont *)tfy_PingFangSCSemiboldAndSize:(CGFloat)size;

+ (UIFont *)tfy_DINAlternateBoldAndSize:(CGFloat)size;

+ (UIFont *)tfy_STHeitiSCLightAndSize:(CGFloat)size;

+ (UIFont *)tfy_STHeitiSCMedium:(CGFloat)size;

+ (UIFont *)tfy_LatoBoldAndSize:(CGFloat)size;
@end

NS_ASSUME_NONNULL_END
