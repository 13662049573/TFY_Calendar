//
//  UIColor+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIColor+TFY_Tools.h"

CG_INLINE NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    str = [[str stringByTrimmingCharactersInSet:set] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, V是不确定的
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;     // 黄色和红色之间
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // 青色和黄色之间
    else
        *h = 4 + ( r - g ) / delta; // 品红和青之间
    *h *= 60;               // 度
    if( *h < 0 )
        *h += 360;
}

@implementation UIColor (TFY_Tools)

+ (UIColor *)tfy_colorWithHexString:(NSString *)hexStr{
    return [self tfy_colorWithHexString:hexStr alpha:-1];
}

+ (UIColor *)tfy_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha{
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        if (@available(iOS 10.0, *)) {
            return [UIColor colorWithDisplayP3Red:r green:g blue:b alpha:alpha < 0?a : alpha];
        }else{
            return [UIColor colorWithRed:r green:g blue:b alpha:alpha < 0?a : alpha];
        }
    }
    return [UIColor whiteColor];
}

- (NSString *)tfy_hexString{
    return [self tfy_hexStringWithAplha:NO];
}

- (NSString *)tfy_hexStringWithAplha{
    return [self tfy_hexStringWithAplha:YES];
}

- (NSString *)tfy_hexStringWithAplha:(BOOL)isWithAlpha{
    CGColorRef colorRef = self.CGColor;
    size_t count = CGColorGetNumberOfComponents(colorRef);
    const CGFloat *compents = CGColorGetComponents(colorRef);
    static NSString *stringFormat = @"%02x%02x%02x";
    NSString *hex = nil;
    if (count == 2) {
        NSUInteger white = (NSUInteger)(compents[0] * 255.0f);
        hex = [NSString stringWithFormat:stringFormat,white,white,white];
    }else if (count == 4){
        hex = [NSString stringWithFormat:stringFormat,
               (NSUInteger)(compents[1] * 255.0f),
               (NSUInteger)(compents[2] * 255.0f),
               (NSUInteger)(compents[3] * 255.0f)
               ];
    }
    if (hex && isWithAlpha) {
        hex = [hex stringByAppendingFormat:@"%02lx",(unsigned long)(self.tfy_alpha * 255.0 + 0.5)];
    }
    return hex;
}

+ (UIColor *)tfy_randomColor{
    return [UIColor tfy_percentR:arc4random() g:arc4random() b:arc4random() alpha:1];
}

+ (UIColor *)tfy_percentR:(NSInteger)r g:(NSInteger)g b:(NSInteger)b alpha:(CGFloat)alpha{
    if (@available(iOS 10.0, *)) {
        return [UIColor colorWithDisplayP3Red:r % 256 * 1.0 / 255 green:g % 256 * 1.0 / 255 blue:b % 256  * 1.0/  255 alpha:alpha];
    }else{
        return [UIColor colorWithRed:r % 256 * 1.0 / 255 green:g % 256 * 1.0 / 255 blue:b % 256  * 1.0/  255 alpha:alpha];
    }
}

+ (UIColor *)tfy_r:(NSInteger)r g:(NSInteger)g b:(NSInteger)b alpha:(CGFloat)alpha{
    if (@available(iOS 10.0, *)) {
        return [UIColor colorWithDisplayP3Red:r green:g blue:b alpha:alpha];
    }else{
        return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    }
}

- (UIColor *)tfy_addColor:(UIColor *)acolor blendMode:(CGBlendMode)blendModel{
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    uint8_t pixel[4] = {0};
    CGContextRef context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorspace, bitmapInfo);
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextSetBlendMode(context, blendModel);
    CGContextSetFillColorWithColor(context, acolor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    return [UIColor tfy_percentR:pixel[0] g:pixel[1] b:pixel[2] alpha:pixel[3]];
}

- (CGFloat)tfy_red {
    CGFloat r = 0, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return r;
}

- (CGFloat)tfy_green {
    CGFloat r, g = 0, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return g;
}

- (CGFloat)tfy_blue {
    CGFloat r, g, b = 0, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return b;
}

- (CGFloat)tfy_alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (CGFloat)tfy_hue {
    CGFloat h = 0, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return h;
}

- (CGFloat)tfy_saturation {
    CGFloat h, s = 0, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return s;
}

- (CGFloat)tfy_brightness {
    CGFloat h, s, b = 0, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return b;
}


- (CGColorSpaceModel)tfy_colorSpaceModel{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *)tfy_colorSpaceString {
    CGColorSpaceModel model =  CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    switch (model) {
        case kCGColorSpaceModelUnknown:
            return @"kCGColorSpaceModelUnknown";
            
        case kCGColorSpaceModelMonochrome:
            return @"kCGColorSpaceModelMonochrome";
            
        case kCGColorSpaceModelRGB:
            return @"kCGColorSpaceModelRGB";
            
        case kCGColorSpaceModelCMYK:
            return @"kCGColorSpaceModelCMYK";
            
        case kCGColorSpaceModelLab:
            return @"kCGColorSpaceModelLab";
            
        case kCGColorSpaceModelDeviceN:
            return @"kCGColorSpaceModelDeviceN";
            
        case kCGColorSpaceModelIndexed:
            return @"kCGColorSpaceModelIndexed";
            
        case kCGColorSpaceModelPattern:
            return @"kCGColorSpaceModelPattern";
            
        default:
            return @"ColorSpaceInvalid";
    }
}

- (UIColor *)tfy_antiColor{
    CGFloat r, g, b = 0, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    if (@available(iOS 10.0, *)) {
        return [UIColor colorWithDisplayP3Red:1-r green:1-g blue:1-b alpha:a];
    }else{
        return [UIColor colorWithRed:1-r green:1-g blue:1-b alpha:a];
    }
}

+ (UIColor *)tfy_colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue{
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

/**
 *  根据图片获取图片的主色调
 */
+ (UIColor *)tfy_colorAtPosition:(CGPoint)position inImage:(UIImage *)image
{
    CGRect sourceRect = CGRectMake(position.x, position.y, 1.0f, 1.0f);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, sourceRect);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *buffer = malloc(4);
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(buffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.0f, 1.0f), imageRef);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGFloat r = buffer[0] / 255.0f;
    CGFloat g = buffer[1] / 255.0f;
    CGFloat b = buffer[2] / 255.0f;
    CGFloat a = buffer[3] / 255.0f;
    free(buffer);
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)tfy_colorWithHex:(NSString *)hexString
{
    NSString *trimmedString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    //Only take the last 6 characters ever, so someone can prefix it with #, 0x, or whatever they want
    if (trimmedString.length != 6)
    {
        trimmedString = [trimmedString substringWithRange:NSMakeRange(trimmedString.length-6, 6)];
    }
    
    NSRange range = NSMakeRange(0, 2);
    NSString *red = [trimmedString substringWithRange:range];
    
    range.location = 2;
    NSString *green = [trimmedString substringWithRange:range];
    
    range.location = 4;
    NSString *blue = [trimmedString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (NSString *)tfy_hexFromColor:(UIColor *)color
{
    if (color == nil || color == [UIColor whiteColor])
    {
        //[UIColor whiteColor] isn't in the RGB spectrum
        return @"#ffffff";
    }
    
    CGFloat red, blue, green, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSUInteger redInt = (NSUInteger)(red*255);
    NSUInteger greenInt = (NSUInteger)(green*255);
    NSUInteger blueInt = (NSUInteger)(blue*255);
    
    NSString *returnString = [NSString stringWithFormat:@"#%02x%02x%02x", (unsigned int)redInt, (unsigned int)greenInt, (unsigned int)blueInt];
    
    return returnString;
}

+ (NSString *)tfy_stripHashtagFromHex:(NSString *)hexString
{
    return ([hexString hasPrefix:@"#"]) ? [hexString substringFromIndex:1] : hexString;
}

+ (NSString *)tfy_addHashtagToHex:(NSString *)hexString
{
    return ([hexString hasPrefix:@"#"]) ? hexString : [@"#" stringByAppendingString:hexString];
}

- (UIColor *)tfy_darkenedColorByPercent:(float)percentage
{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    double multiplier = 1.0-percentage;
    
    return [UIColor colorWithRed:red*multiplier green:green*multiplier blue:blue*multiplier alpha:alpha];
}

- (UIColor *)tfy_lightenedColorByPercent:(float)percentage
{
    return [self tfy_darkenedColorByPercent:-percentage];
}

- (UIColor *)tfy_tenPercentLighterColor
{
    return [self tfy_lightenedColorByPercent:0.1];
}

- (UIColor *)tfy_twentyPercentLighterColor
{
    return [self tfy_lightenedColorByPercent:0.2];
}

- (UIColor *)tfy_tenPercentDarkerColor
{
    return [self tfy_darkenedColorByPercent:0.1];
}

- (UIColor *)tfy_twentyPercentDarkerColor
{
    return [self tfy_darkenedColorByPercent:0.2];
}

+(UIColor *)tfy_colorBetweenColor:(UIColor *)c1 andColor:(UIColor *)c2 percentage:(float)p
{
    float p1 = 1.0 - p;
    float p2 = p;
    
    const CGFloat *components = CGColorGetComponents([c1 CGColor]);
    CGFloat r1 = components[0];
    CGFloat g1 = components[1];
    CGFloat b1 = components[2];
    CGFloat a1 = components[3];
    
    components = CGColorGetComponents([c2 CGColor]);
    CGFloat r2 = components[0];
    CGFloat g2 = components[1];
    CGFloat b2 = components[2];
    CGFloat a2 = components[3];
    
    return [UIColor colorWithRed:r1*p1 + r2*p2
                           green:g1*p1 + g2*p2
                            blue:b1*p1 + b2*p2
                           alpha:a1*p1 + a2*p2];
}

/**
 *  创建渐变颜色 size  渐变的size direction 渐变方式 startcolor 开始颜色  endColor 结束颜色
 */
+(UIColor *)tfy_colorGradientChangeWithSize:(CGSize)size direction:(GradientChangeDirection)direction startColor:(UIColor *)startcolor endColor:(UIColor *)endColor{
    if (CGSizeEqualToSize(size, CGSizeZero) || !startcolor || !endColor) {
        return nil;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGPoint startPoint = CGPointZero;
    if (direction == GradientChangeDirectionDownDiagonalLine) {
        startPoint = CGPointMake(0.0, 1.0);
    }
    gradientLayer.startPoint = startPoint;
    
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case GradientChangeDirectionLevel:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        case GradientChangeDirectionVertical:
            endPoint = CGPointMake(0.0, 1.0);
            break;
        case GradientChangeDirectionUpwardDiagonalLine:
            endPoint = CGPointMake(1.0, 1.0);
            break;
        case GradientChangeDirectionDownDiagonalLine:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        default:
            break;
    }
    gradientLayer.endPoint = endPoint;
    
    gradientLayer.colors = @[(__bridge id)startcolor.CGColor, (__bridge id)endColor.CGColor];
    UIGraphicsBeginImageContext(size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:image];
}
/**
 * Takes in an array of NSNumbers and configures a color from it.
 * Position 0 is red, 1 green, 2 blue, 3 alpha.
 */
+(UIColor *)tfy_colorWithConfig:(NSArray *)config{
    return [UIColor colorWithRed:((NSNumber *)[config objectAtIndex:0]).floatValue
                           green:((NSNumber *)[config objectAtIndex:1]).floatValue
                            blue:((NSNumber *)[config objectAtIndex:2]).floatValue
                           alpha:((NSNumber *)[config objectAtIndex:3]).floatValue];
}

+ (UIColor *)tfy_colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

+(UIColor*)tfy_mostColor_Color:(UIImage*)image{
    
    
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    
    CGSize thumbSize=CGSizeMake((int)(image.size.width/2), (int)(image.size.height/2));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    
    if (data == NULL) return nil;
    NSArray *MaxColor=nil;
    // NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    float maxScore=0;
    for (int x=0; x<thumbSize.width*thumbSize.height; x++) {
        
        int offset = 4*x;
        
        int red = data[offset];
        int green = data[offset+1];
        int blue = data[offset+2];
        int alpha =  data[offset+3];
        
        if (alpha<25)continue;
        
        float h,s,v;
        RGBtoHSV(red, green, blue, &h, &s, &v);
        
        float y = MIN(abs(red*2104+green*4130+blue*802+4096+131072)>>13, 235);
        y= (y-16)/(235-16);
        if (y>0.9) continue;
        
        float score = (s+0.1)*x;
        if (score>maxScore) {
            maxScore = score;
        }
        MaxColor=@[@(red),@(green),@(blue),@(alpha)];
        //[cls addObject:clr];
    }
    CGContextRelease(context);
    
    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
}
#pragma mark - Private Methods (PrivateColorWithHexAndAlpha)
+ (UIColor *)tfy_colorWith3DigitHex:(NSString *)hex andAlpha:(CGFloat)alpha
{
    // Red Value
    NSString *redHexString = [hex substringWithRange:NSMakeRange(0, 1)];
    NSString *modifiedRedHexString = [NSString stringWithFormat:@"%@%@", redHexString, redHexString];
    NSScanner *redScanner = [NSScanner scannerWithString:modifiedRedHexString];
    unsigned int redHexInt = 0;
    [redScanner scanHexInt:&redHexInt];
    CGFloat redValue = redHexInt/255.0f;
    
    // Green Value
    NSString *greenHexString = [hex substringWithRange:NSMakeRange(1, 1)];
    NSString *modifiedGreenHexString = [NSString stringWithFormat:@"%@%@", greenHexString, greenHexString];
    NSScanner *greenScanner = [NSScanner scannerWithString:modifiedGreenHexString];
    unsigned int  greenHexInt = 0;
    [greenScanner scanHexInt:&greenHexInt];
    CGFloat greenValue = greenHexInt/255.0f;
    
    // Blue Value
    NSString *blueHexString = [hex substringWithRange:NSMakeRange(2, 1)];
    NSString *modifiedBlueHexString = [NSString stringWithFormat:@"%@%@", blueHexString, blueHexString];
    NSScanner *blueScanner = [NSScanner scannerWithString:modifiedBlueHexString];
    unsigned int  blueHexInt = 0;
    [blueScanner scanHexInt:&blueHexInt];
    CGFloat blueValue = blueHexInt/255.0f;
    
    return [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
}

+ (UIColor *)tfy_colorWith6DigitHex:(NSString *)hex andAlpha:(CGFloat)alpha
{
    // Red Value
    NSString *redHexString = [hex substringWithRange:NSMakeRange(0, 2)];
    NSScanner *redScanner = [NSScanner scannerWithString:redHexString];
    unsigned int  redHexInt = 0;
    [redScanner scanHexInt:&redHexInt];
    CGFloat redValue = redHexInt/255.0f;
    
    // Green Value
    NSString *greenHexString = [hex substringWithRange:NSMakeRange(2, 2)];
    NSScanner *greenScanner = [NSScanner scannerWithString:greenHexString];
    unsigned int  greenHexInt = 0;
    [greenScanner scanHexInt:&greenHexInt];
    CGFloat greenValue = greenHexInt/255.0f;
    
    // Blue Value
    NSString *blueHexString = [hex substringWithRange:NSMakeRange(4, 2)];
    NSScanner *blueScanner = [NSScanner scannerWithString:blueHexString];
    unsigned int  blueHexInt = 0;
    [blueScanner scanHexInt:&blueHexInt];
    CGFloat blueValue = blueHexInt/255.0f;
    
    return [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
}
/**
 *   ios 13 添加颜色的判断 提供了的新方法，可以在 block 中判断 traitCollection.userInterfaceStyle，根据系统模式设置返回的颜色。
 */
+(UIColor *)tfy_generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor{
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return lightColor;
            }else {
                return darkColor;
            }
        }];
        return dyColor;
    }else{
        return lightColor;
    }
}


///  获取canvas用的颜色字符串
- (NSString *)tfy_canvasColorString
{
    CGFloat *arrRGBA = [self tfy_getRGB];
    int r = arrRGBA[0] * 255;
    int g = arrRGBA[1] * 255;
    int b = arrRGBA[2] * 255;
    float a = arrRGBA[3];
    return [NSString stringWithFormat:@"rgba(%d,%d,%d,%f)", r, g, b, a];
}
 
///  获取网页颜色字串
- (NSString *)tfy_webColorString
{
    CGFloat *arrRGBA = [self tfy_getRGB];
    int r = arrRGBA[0] * 255;
    int g = arrRGBA[1] * 255;
    int b = arrRGBA[2] * 255;
    NSLog(@"%d,%d,%d", r, g, b);
    NSString *webColor = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
    return webColor;
}
 
/// 加亮
- (UIColor *)tfy_lighten
{
    CGFloat *rgb = [self tfy_getRGB];
    CGFloat r = rgb[0];
    CGFloat g = rgb[1];
    CGFloat b = rgb[2];
    CGFloat alpha = rgb[3];
    
    r = r + (1 - r) / 6.18;
    g = g + (1 - g) / 6.18;
    b = b + (1 - b) / 6.18;
    
    UIColor * uiColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return uiColor;
}
 
- (UIColor *)tfy_darken{ //变暗
    CGFloat *rgb = [self tfy_getRGB];
    CGFloat r = rgb[0];
    CGFloat g = rgb[1];
    CGFloat b = rgb[2];
    CGFloat alpha = rgb[3];
    
    r = r * 0.618;
    g = g * 0.618;
    b = b * 0.618;
    
    UIColor *uiColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return uiColor;
}
 
- (UIColor *)tfy_mix:(UIColor *)color{
    CGFloat * rgb1 = [self tfy_getRGB];
    CGFloat r1 = rgb1[0];
    CGFloat g1 = rgb1[1];
    CGFloat b1 = rgb1[2];
    CGFloat alpha1 = rgb1[3];
 
    CGFloat * rgb2 = [color tfy_getRGB];
    CGFloat r2 = rgb2[0];
    CGFloat g2 = rgb2[1];
    CGFloat b2 = rgb2[2];
    CGFloat alpha2 = rgb2[3];
    
    //mix them!!
    CGFloat r = (r1 + r2) / 2.0;
    CGFloat g = (g1 + g2) / 2.0;
    CGFloat b = (b1 + b2) / 2.0;
    CGFloat alpha = (alpha1 + alpha2) / 2.0;
    
    UIColor * uiColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return uiColor;
}
//获取颜色对象的RGB数值
- (CGFloat *)tfy_getRGB{
    UIColor * uiColor = self;
    
    CGColorRef cgColor = [uiColor CGColor];
    
    NSUInteger numComponents = CGColorGetNumberOfComponents(cgColor);
 
    if (numComponents == 4){
        static CGFloat * components = Nil;
        components = (CGFloat *) CGColorGetComponents(cgColor);
        return (CGFloat *)components;
    } else { //否则默认返回黑色
        static CGFloat components[4] = {0};
        CGFloat f = 0;
         //非RGB空间的系统颜色单独处理
        if ([uiColor isEqual:[UIColor whiteColor]]) {
            f = 1.0;
        } else if ([uiColor isEqual:[UIColor lightGrayColor]]) {
            f = 0.8;
        } else if ([uiColor isEqual:[UIColor grayColor]]) {
            f = 0.5;
        }
        components[0] = f;
        components[1] = f;
        components[2] = f;
        components[3] = 1.0;
        return (CGFloat *)components;
    }
}

+(NSString*)tfy_stringWithColor:(UIColor *)color
{
    if (color==nil) {
        return @"";
    }
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    //rgba
    return [NSString stringWithFormat:@"[%d,%d,%d,%f]",(int)(r*255),(int)(g*255),(int)(b*255),a];
}

@end
