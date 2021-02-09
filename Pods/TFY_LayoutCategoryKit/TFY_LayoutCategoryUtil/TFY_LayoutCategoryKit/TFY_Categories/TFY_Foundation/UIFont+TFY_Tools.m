//
//  UIFont+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIFont+TFY_Tools.h"
#import "UIDevice+TFY_Tools.h"

#define FontScale ([[UIDevice currentDevice] tfy_isPad]? 1 : [UIFont screenWidth] / 375.0)

@implementation UIFont (TFY_Tools)

+ (CGFloat)screenWidth{
    static CGFloat width = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        width = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    });
    return width;
}

+ (UIFont *)tfy_fontScaleWithName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    return [self tfy_fontWithName:fontName fontSize:fontSize * FontScale];
}

+ (UIFont *)tfy_fontWithName:(NSString *)fontName fontSize:(CGFloat)fontSize{
    BOOL isLoadSystem = fontName.length == 0;
    UIFont *font = nil;
    if (!isLoadSystem) {
        font = [UIFont fontWithName:fontName size:fontSize];
        isLoadSystem = font == nil;
    }
    if (isLoadSystem) {
        return [self systemFontOfSize:fontSize];
    }else{
        return font;
    }
}

+ (UIFont*)tfy_fontType:(fontType)type size:(CGFloat)size{
    static NSDictionary *fontNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:@"" forKey:@(SystemFont)];
        [dic setObject:@"PingFangSC-Light" forKey:@(PingFangLight)];
        [dic setObject:@"PingFangSC-Regular" forKey:@(PingFangReguler)];
        [dic setObject:@"PingFangSC-Medium" forKey:@(PingFangMedium)];
        [dic setObject:@"PingFangSC-Semibold" forKey:@(PingFangSemibold)];
        [dic setObject:@"STHeitiSC-Light" forKey:@(STHeitiSCLight)];
        [dic setObject:@"STHeitiSC-Medium" forKey:@(STHeitiSCMedium)];
        [dic setObject:@"DINAlternate-Bold" forKey:@(DinaAlternateBold)];
        fontNames = dic.copy;
    });
    if (type >= fontNames.count || type < 0) {
        type = 0;
    }
    return [self tfy_fontWithName:fontNames[@(type)] fontSize:size];
}

+ (UIFont*)tfy_fontScaleType:(fontType)type size:(CGFloat)size{
    return [self tfy_fontType:type size:size * FontScale];
}

+ (UIFont*)tfy_PingFangSCRegularAndSize:(CGFloat)size{
    return [self tfy_fontType:PingFangReguler size:size];
}

+ (UIFont*)tfy_PingFangSCLightAndSize:(CGFloat)size{
    return [self tfy_fontType:PingFangLight size:size];
}

+ (UIFont*)tfy_PingFangSCMediumAndSize:(CGFloat)size{
    return [self tfy_fontType:PingFangMedium size:size];
}

+ (UIFont *)tfy_PingFangSCScaleMediumAndSize:(CGFloat)size{
    return [self tfy_fontScaleType:PingFangMedium size:size];
}


+ (UIFont *)tfy_PingFangSCSemiboldAndSize:(CGFloat)size{
    return [self tfy_fontType:PingFangSemibold size:size];
}

+ (UIFont *)tfy_DINAlternateBoldAndSize:(CGFloat)size{
    return [self tfy_fontType:DinaAlternateBold size:size];
}

+ (UIFont *)tfy_STHeitiSCLightAndSize:(CGFloat)size{
    return [self tfy_fontType:STHeitiSCLight size:size];
}

+ (UIFont *)tfy_STHeitiSCMedium:(CGFloat)size{
    return [self tfy_fontType:STHeitiSCMedium size:size];
}

+ (UIFont *)tfy_LatoBoldAndSize:(CGFloat)size{
    return [self tfy_fontType:SystemFont size:size];
}
@end
