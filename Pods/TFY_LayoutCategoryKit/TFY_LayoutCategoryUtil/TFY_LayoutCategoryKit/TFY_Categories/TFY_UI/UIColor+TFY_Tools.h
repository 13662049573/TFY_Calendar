//
//  UIColor+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 渐变方式
 
 - GradientChangeDirectionLevel:              水平渐变
 - GradientChangeDirectionVertical:           竖直渐变
 - GradientChangeDirectionUpwardDiagonalLine: 向下对角线渐变
 - GradientChangeDirectionDownDiagonalLine:   向上对角线渐变
 */
typedef NS_ENUM(NSInteger, GradientChangeDirection) {
    GradientChangeDirectionLevel,
    GradientChangeDirectionVertical,
    GradientChangeDirectionUpwardDiagonalLine,
    GradientChangeDirectionDownDiagonalLine,
};



@interface UIColor (PrivateColorWithHexAndAlpha)

+ (instancetype)tfy_colorWith3DigitHex:(NSString *)hex andAlpha:(CGFloat)alpha;
+ (instancetype)tfy_colorWith6DigitHex:(NSString *)hex andAlpha:(CGFloat)alpha;

@end


@interface UIColor (TFY_Tools)
/**
 *  默认alpha为1
 */
+ (UIColor *)tfy_colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
/**
 *  从十六进制字符串获取颜色，alpha需要自己传递 color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 */
+ (UIColor *)tfy_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
/**
 *  根据图片获取图片的主色调 position--范围
 */
+ (UIColor *)tfy_colorAtPosition:(CGPoint)position inImage:(UIImage *)image;
/**
 *  颜色转换：iOS中 十六进制的颜色转换为UIColor(RGB)
 */
+ (UIColor *)tfy_colorWithHex:(NSString *)hexString;
/**
 *  颜色转换：将颜色换字符串
 */
+ (NSString *)tfy_hexFromColor:(UIColor *)color;
/**
 *  将颜色值带有#号的字符去掉
 */
+ (NSString *)tfy_stripHashtagFromHex:(NSString *)hexString;
/**
 *   将颜色值带有#号的字符添加
 */
+ (NSString *)tfy_addHashtagToHex:(NSString *)hexString;
/**
 *   颜色值的暗调
 */
- (UIColor *)tfy_darkenedColorByPercent:(float)percentage;
/**
 *  颜色值的点亮
 */
- (UIColor *)tfy_lightenedColorByPercent:(float)percentage;
/**
 *  百分之十打火机
 */
- (UIColor *)tfy_tenPercentLighterColor;
/**
 *
 */
- (UIColor *)tfy_twentyPercentLighterColor;
/**
 *
 */
- (UIColor *)tfy_tenPercentDarkerColor;
/**
 *
 */
- (UIColor *)tfy_twentyPercentDarkerColor;
/**
 *  颜色渐变
 */
+(UIColor *)tfy_colorBetweenColor:(UIColor *)color1 andColor:(UIColor *)color2 percentage:(float)percentage;

/**
 *  创建渐变颜色 size  渐变的size direction 渐变方式 startcolor 开始颜色  endColor 结束颜色
 */
+(UIColor *)tfy_colorGradientChangeWithSize:(CGSize)size direction:(GradientChangeDirection)direction startColor:(UIColor *)startcolor endColor:(UIColor *)endColor;

/**
 * 需要的 NSNumbers 数组中并配置从它的颜色。
 * 位置 0 是红色，1 绿，2 蓝色，3 阿尔法。
 */
+(UIColor *)tfy_colorWithConfig:(NSArray *)config;
/**
 *  颜色转换：iOS中 十六进制的颜色转换为UIColor(RGB)
 */
+ (UIColor *)tfy_colorFromHexRGB:(NSString *)inColorString;
/**
 *   获取图片的平均颜色
 */
+(UIColor*)tfy_mostColor_Color:(UIImage*)image;
/**
 *  随机颜色
 */
+(UIColor *)tfy_randomColor;
/**
 *   ios 13 添加颜色的判断 提供了的新方法，可以在 block 中判断 traitCollection.userInterfaceStyle，根据系统模式设置返回的颜色。
 */
+(UIColor *)tfy_generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;
/**将颜色对象转换为canvas用字符串格式*/
-(NSString *)tfy_canvasColorString;
/***将颜色对象转换为Web用字符串格式*/
-(NSString *)tfy_webColorString;
/***将颜色对象变亮*/
-(UIColor *)tfy_lighten;
/***将颜色对象变暗*/
-(UIColor *)tfy_darken;
/**将两个颜色对象混合*/
-(UIColor *)tfy_mix:(UIColor *)c;
/**适合各种颜色值*/
+(UIColor *)tfy_colorWithHexString:(NSString *)hexString;
/***颜色转字符串*/
+(NSString*)tfy_stringWithColor:(UIColor *)color;

+ (UIColor *)tfy_percentR:(NSInteger)r g:(NSInteger)g b:(NSInteger)b alpha:(CGFloat)alpha;

+ (UIColor *)tfy_r:(NSInteger)r g:(NSInteger)g b:(NSInteger)b alpha:(CGFloat)alpha;

- (NSString *)tfy_hexString;

- (NSString *)tfy_hexStringWithAplha;

- (UIColor *)tfy_addColor:(UIColor *)acolor blendMode:(CGBlendMode)blendModel;

@property (nonatomic, assign, readonly) CGFloat  tfy_red;

@property (nonatomic, assign, readonly) CGFloat  tfy_green;

@property (nonatomic, assign, readonly) CGFloat  tfy_blue;

@property (nonatomic, assign, readonly) CGFloat  tfy_alpha;

@property (nonatomic, assign, readonly) CGFloat  tfy_hue;

@property (nonatomic, assign, readonly) CGFloat  tfy_saturation;

@property (nonatomic, assign, readonly) CGFloat  tfy_brightness;

@property (nonatomic, readonly) CGColorSpaceModel tfy_colorSpaceModel;

@property (nonatomic, readonly) NSString *tfy_colorSpaceString;

/**
 反色调
 */
- (UIColor *)tfy_antiColor;

/**
 *  设置正常模式和深色模式 Color
 *
 *   light 正常模式 Color
 *   dark 深色模式 Color
 *   适配深色模式的 Color
 */
+ (UIColor *)tfy_colorWithColorLight:(UIColor *)light dark:(UIColor *)dark;

/**
 *  系统灰色
 *
 *   适配深色模式的灰色
 */
+ (UIColor *)tfy_systemGrayColor;

/**
 *  系统红色
 *
 *   适配深色模式的红色
 */
+ (UIColor *)tfy_systemRedColor;

/**
 *  系统蓝色
 *
 *   适配深色模式的蓝色
 */
+ (UIColor *)tfy_systemBlueColor;


@end
/**十六进制字符串获取颜色*/
CG_INLINE UIColor *TFY_ColorHexString(NSString *hexString){
    return [UIColor tfy_colorWithHexString:hexString];
}
/**十六进制字符串获取颜色，alpha需要自己传递*/
CG_INLINE UIColor *TFY_ColorHexAlpha(NSString *hexString, CGFloat alpha){
    return [UIColor tfy_colorWithHexString:hexString alpha:alpha];
}
/** RGBA颜色，传整数 */
CG_INLINE UIColor *TFY_ColorRGBAlpha(CGFloat r, CGFloat g, CGFloat b, CGFloat alpha){
    return [UIColor tfy_percentR:r g:g b:b alpha:alpha];
}

/** RGB颜色，传整数  */
CG_INLINE UIColor *TFY_ColorRGB(CGFloat r, CGFloat g, CGFloat b){
    return TFY_ColorRGBAlpha(r,g,b,1);
}
/** RGBA颜色传分数 */
CG_INLINE UIColor *TFY_ColorRGBAlphaPercent(CGFloat r, CGFloat g, CGFloat b, CGFloat alpha){
    return [UIColor tfy_r:r g:g b:b alpha:alpha];
}

/** RGB颜色传分数 */
CG_INLINE UIColor *TFY_ColorRGBPercent(CGFloat r, CGFloat g, CGFloat b){
    return TFY_ColorRGBAlphaPercent(r,g,b,1);
}
/**渐变色*/
CG_INLINE UIColor *TFY_ColorGradient(CGSize size,GradientChangeDirection direction,UIColor *starcolor,UIColor *endcolor){
    return [UIColor tfy_colorGradientChangeWithSize:size direction:direction startColor:starcolor endColor:endcolor];
}

#define RGBAlphaPercent(r,g,b,a) UIColorRGBAlphaPercent(r,g,b,a)

#define RGBPercent(r,g,b) UIColorRGBPercent(r,g,b)

#define RGBAlpha(r,g,b,a) UIColorRGBAlpha(r,g,b,a)

#define RGB(r,g,b) UIColorRGB(r,g,b)

NS_ASSUME_NONNULL_END

