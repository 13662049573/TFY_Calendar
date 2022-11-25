//
//  UIImage+Addtions.m
//  TFY_ChatIMInterface
//
//  Created by 田风有 on 2022/2/11.
//

#import "UIImage+Addtions.h"

@implementation UIImage (Addtions)

+ (UIImage *)tfy_groupIconWithURLArray:(NSArray *)URLArray bgColor:(UIColor *)bgColor {
    UIImageView *imageView = [[UIImageView alloc] init];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i = 0; i<URLArray.count;  i++) {
        id urlData = URLArray[i];
        UIImage *image = [self tfy_groupIconWithURL:urlData];
        [imageArray addObject:image];
    }
    
    imageView.image = [UIImage tfy_groupIconWith:imageArray bgColor:bgColor];
    
    return imageView.image;
}

+ (UIImage *)tfy_groupIconWith:(NSArray *)array bgColor:(UIColor *)bgColor {

    CGSize finalSize = CGSizeMake(100, 100);
    CGRect rect = CGRectZero;
    rect.size = finalSize;

    UIGraphicsBeginImageContext(finalSize);

    if (bgColor) {

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, bgColor.CGColor);
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, 100);
        CGContextAddLineToPoint(context, 100, 100);
        CGContextAddLineToPoint(context, 100, 0);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }

    if (array.count == 1) {
        NSMutableArray *rectsArray = NSMutableArray.array;
        [self tfy_getRects:rectsArray padding:0 width:100 count:1];

        id obj = array.firstObject;
        UIImage *image = [self tfy_groupIconWithURL:obj];
        
        CGRect rect = CGRectFromString([rectsArray objectAtIndex:0]);
        [image drawInRect:rect];
    }
    if (array.count >= 2) {

        NSArray *rects = [self tfy_eachRectInGroupWithCount2:array.count];
        int count = 0;
        for (id obj in array) {
            if (count > rects.count-1) {
                break;
            }
            UIImage *image = [self tfy_groupIconWithURL:obj];
            
            CGRect rect = CGRectFromString([rects objectAtIndex:count]);
            [image drawInRect:rect];
            count++;
        }
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)tfy_groupIconWithURL:(id)urlData {
    NSData * data = nil;
    if ([urlData isKindOfClass:NSData.class]) {
        data = urlData;
    } else if ([urlData isKindOfClass:NSString.class]) {
        NSString *url = urlData;
        if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) {
            data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        } else {
            data = [[NSData alloc] initWithContentsOfFile:url];
            if (data == nil) {
                data = UIImagePNGRepresentation([UIImage imageNamed:url]);
            }
        }
    } else if ([urlData isKindOfClass:UIImage.class]) {
        data = UIImagePNGRepresentation(urlData);
    }
    UIImage *image = [[UIImage alloc]initWithData:data];
    return image;
}

+ (NSArray *)tfy_eachRectInGroupWithCount:(NSInteger)count {

    NSArray *rects = nil;
    
    CGFloat sizeValue = 100;
    CGFloat padding = 2;
    
    CGFloat eachWidth = (sizeValue - padding*3) / 2;
    
    CGRect rect1 = CGRectMake(sizeValue/2 - eachWidth/2, padding, eachWidth, eachWidth);
    
    CGRect rect2 = CGRectMake(padding, padding*2 + eachWidth, eachWidth, eachWidth);
    
    CGRect rect3 = CGRectMake(padding*2 + eachWidth, padding*2 + eachWidth, eachWidth, eachWidth);
    if (count == 3) {
        rects = @[NSStringFromCGRect(rect1), NSStringFromCGRect(rect2), NSStringFromCGRect(rect3)];
    } else if (count == 4) {
        CGRect rect0 = CGRectMake(padding, padding, eachWidth, eachWidth);
        rect1 = CGRectMake(padding*2, padding, eachWidth, eachWidth);
        rects = @[NSStringFromCGRect(rect0), NSStringFromCGRect(rect1), NSStringFromCGRect(rect2), NSStringFromCGRect(rect3)];
    }
    
    return rects;
}

+ (NSArray *)tfy_eachRectInGroupWithCount2:(NSInteger)count {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
    
    CGFloat sizeValue = 100;
    CGFloat padding = 2;
    
    CGFloat eachWidth;
    
    if (count <= 4) {
        eachWidth = (sizeValue - padding*3) / 2;
        [self tfy_getRects:array padding:padding width:eachWidth count:4];
    } else {
        padding = padding / 2;
        eachWidth = (sizeValue - padding*4) / 3;
        [self tfy_getRects:array padding:padding width:eachWidth count:9];
    }

    if (count < 4) {
        [array removeObjectAtIndex:0];
        CGRect rect = CGRectFromString([array objectAtIndex:0]);
        rect.origin.x = (sizeValue - eachWidth) / 2;
        [array replaceObjectAtIndex:0 withObject:NSStringFromCGRect(rect)];
        if (count == 2) {
            [array removeObjectAtIndex:0];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
            
            for (NSString *rectStr in array) {
                CGRect rect = CGRectFromString(rectStr);
                rect.origin.y -= (padding+eachWidth)/2;
                [tempArray addObject:NSStringFromCGRect(rect)];
            }
            [array removeAllObjects];
            [array addObjectsFromArray:tempArray];
        }
    } else if (count != 4 && count <= 6) {
        [array removeObjectsInRange:NSMakeRange(0, 3)];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:6];

        for (NSString *rectStr in array) {
            CGRect rect = CGRectFromString(rectStr);
            rect.origin.y -= (padding+eachWidth)/2;
            [tempArray addObject:NSStringFromCGRect(rect)];
        }
        [array removeAllObjects];
        [array addObjectsFromArray:tempArray];
        
        if (count == 5) {
            [tempArray removeAllObjects];
            [array removeObjectAtIndex:0];
            
            for (int i=0; i<2; i++) {
                CGRect rect = CGRectFromString([array objectAtIndex:i]);
                rect.origin.x -= (padding+eachWidth)/2;
                [tempArray addObject:NSStringFromCGRect(rect)];
            }
            [array replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:tempArray];
        }
        
    } else if (count != 4 && count < 9) {
        if (count == 8) {
            [array removeObjectAtIndex:0];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
            for (int i=0; i<2; i++) {
                CGRect rect = CGRectFromString([array objectAtIndex:i]);
                rect.origin.x -= (padding+eachWidth)/2;
                [tempArray addObject:NSStringFromCGRect(rect)];
            }
            [array replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:tempArray];
        } else {
            [array removeObjectAtIndex:2];
            [array removeObjectAtIndex:0];
        }
    }

    return array;
}

+ (void)tfy_getRects:(NSMutableArray *)array padding:(CGFloat)padding width:(CGFloat)eachWidth count:(int)count {

    for (int i=0; i<count; i++) {
        int sqrtInt = (int)sqrt(count);
        int line = i%sqrtInt;
        int row = i/sqrtInt;
        CGRect rect = CGRectMake(padding * (line+1) + eachWidth * line, padding * (row+1) + eachWidth * row, eachWidth, eachWidth);
        [array addObject:NSStringFromCGRect(rect)];
    }
}


@end

@implementation TFY_ColorTool
static TFY_ColorTool *_aColorInstance;
static dispatch_once_t _aOnce_t;

+ (instancetype)sharedInstance {
    dispatch_once(&_aOnce_t, ^{
        _aColorInstance = [self new];
    });
    return _aColorInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _hexStringSource = @[@"#97c5e8", @"#9acbe1", @"#84d1d9", @"#f2b591", @"#e3c097", @"#b9a29a"];
    }
    return self;
}

- (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [self colorWithR:((rgbValue & 0xFF0000) >> 16)
                          G:((rgbValue & 0xFF00) >> 8)
                          B:(rgbValue & 0xFF) A:1.0];
}

- (UIColor *)colorWithR:(CGFloat)red
                      G:(CGFloat)green
                      B:(CGFloat)blue
                      A:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha];
}

- (UIColor *)colorAJWithString:(NSString *)aStr {
    NSString *lastLetter = [TFY_ColorTool firstLetterOfString:sn(aStr)];
    
    int offset = [[lastLetter uppercaseString] characterAtIndex:0] - [@"A" characterAtIndex:0];
    
    if (offset > 0) {
        int colorIndex = offset % _hexStringSource.count;
        return [self colorFromHexString:_hexStringSource[colorIndex]];
    } else {
        return [self colorFromHexString:_hexStringSource[26 % _hexStringSource.count]];
    }
}

+ (NSString*)firstLetterOfString:(NSString *)chinese {
    if (!chinese || chinese.length == 0) {
        return @"#";
    }
    
    NSString *fullLetter = [chinese substringFromIndex:chinese.length - 1];
    
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (__bridge CFMutableStringRef)[NSMutableString stringWithString:fullLetter]);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
    NSMutableString *aNSString = (__bridge_transfer  NSMutableString *)string;

    NSString *tempFinalString = [[aNSString componentsSeparatedByString:@" "] lastObject];
    
    if([tempFinalString isEqualToString:@""]) {
        tempFinalString = @"#";
    }
    
    NSString *firstLetter = @"";
    
    if ([TFY_ColorTool letterStr:fullLetter]) {
        firstLetter = [[tempFinalString substringToIndex:1]uppercaseString];
    } else {
        firstLetter = [[tempFinalString substringFromIndex:tempFinalString.length - 1]uppercaseString];
    }
    
    if (!firstLetter || firstLetter.length <= 0) {
        firstLetter = @"#";
    } else {
        unichar letter = [firstLetter characterAtIndex:0];
        if (letter<65||letter>90) {
            firstLetter = @"#";
        }
    }
    return firstLetter;
}

+ (int)letterStr:(NSString *)aletter {
    NSUInteger len = aletter.length;
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:aletter options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    return  (numMatch > 0);
}

@end

@interface TFY_AvatarMaker ()
@property (nonatomic, assign) CGFloat distance;
@end

@implementation TFY_AvatarMaker

- (instancetype)init {
    if (self = [super init]) {
        ///设置一些默认值
        _avatarBackGroundColorQQ = [UIColor whiteColor];
        _avatarBackGroundColorWeChat = [UIColor colorWithWhite: 239.0f / 255.0f alpha:1];
        _distanceFactor = 3.5f / 80.0f;
        _leadingWeChat = 1.0f;
        _spacingWeChat = 2.0f;
        _textAttributes = [self builderTextAttributed];
    }
    return self;
}

- (NSDictionary *)builderTextAttributed {
    NSMutableParagraphStyle *stype = [[NSMutableParagraphStyle alloc] init];
    stype.alignment = NSTextAlignmentCenter;
    return @{
             NSParagraphStyleAttributeName:stype,
             NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold],
             NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:1]
             };
}

/**
 画一个群头像
 
 aModel 微信/QQ/钉钉
 aSize 画的大小
 aDatasource 内装的是UIImage，或者是NSString，
 返回一个图片
 */
- (UIImage *)makeGroupHeader:(AvatarType)aModel
                  headerSize:(CGSize)aSize
                  dataSource:(NSArray *)aDatasource {
    UIGraphicsBeginImageContextWithOptions(aSize, NO, UIScreen.mainScreen.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    _distance = _distanceFactor * aSize.width;
    switch (aModel) {
        case AvatarTypeQQ: {
            ///1、设置背景色
            CGContextSetFillColorWithColor(ctx, _avatarBackGroundColorQQ.CGColor);
            CGContextFillRect(ctx, CGRectMake(0, 0, aSize.width, aSize.height));
            ///2、取数组最大值
            uint maxNum = [self numberOfMaxCount:aModel];
            NSArray *effectiveDatasource = [aDatasource subarrayWithRange:NSMakeRange(0, MIN(aDatasource.count, maxNum))];
            if (!aDatasource.count) {
                break;
            }
            [self makeupQQAvatarContext:ctx size:aSize dataSource:effectiveDatasource];
        }
            break;
            
        case AvatarTypeWeChat: {
            CGContextSetFillColorWithColor(ctx, _avatarBackGroundColorWeChat.CGColor);
            CGContextFillRect(ctx, CGRectMake(0, 0, aSize.width, aSize.height));
            [self makeupWeChatAvatar:CGRectMake(0, 0, aSize.width, aSize.height) ctx:ctx dataSource:aDatasource];
        }
        default:
            break;
    }
    
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}
#pragma mark - QQ
- (uint)numberOfMaxCount:(AvatarType)aModel {
    switch (aModel) {
        case AvatarTypeQQ:
            return 5;
            break;
            
        case AvatarTypeWeChat:
            return 9;
            break;
    }
    return 0;
}

/**
 画QQ头像
 
 ctx 上下文
 aSize 整个群聊头像的边框大小
 aDatasource 数据源
 */
- (void)makeupQQAvatarContext:(CGContextRef)ctx size:(CGSize)aSize dataSource:(NSArray *)aDatasource {
    ///1、计算每个小图像的半径
    CGFloat smallcircleR = [self smallCircleRFromAvatarNum:aDatasource.count avatarWidth:aSize.width];
    ///2、计算中心点到各个小圆的半径
    CGFloat R = 0;
    CGFloat radiusOffset = 0;
    switch (aDatasource.count) {
        case QQTypeOne:
            R = 0;
            radiusOffset = 0;
        case QQTypeTwo:
            radiusOffset = -.75;
            R = smallcircleR - _distance;
            break;
            
        case QQTypeThree:
            radiusOffset = -.5;
            R = smallcircleR;
            break;
            
        case QQTypeFour:
            radiusOffset = -.75f;
            R = smallcircleR + _distance;
            break;
            
        case QQTypeFive:
            radiusOffset = -.5f;
            R = smallcircleR + _distance;
            break;
    }
    smallcircleR -= .5;
    ///3、计算整个头像的中心点坐标
    CGFloat estimateW = 0;
    CGFloat estimateH = 0;
    CGFloat centerY = 0;
    
    switch (aDatasource.count) {
        case QQTypeThree: {
            estimateW = aSize.width;
            estimateH = estimateW * (3 + 1 / 2.0f) / (2 + sqrt(3));
            centerY = 2 * R + (estimateW - estimateH) / 2.0f;
        }
            break;
        case QQTypeFive: {
            estimateW = aSize.width;
            estimateH = estimateW * (3 * smallcircleR + _distance + cos(radians(36)) * R) / (2 * smallcircleR + 2 * sin(radians(72)) * R);
            centerY = R + smallcircleR + (estimateW - estimateH) / 2.0f;
        }
            break;
            
        default:
            centerY = aSize.height / 2.0f;
            break;
    }
    CGPoint centerOfGroupHeader = CGPointMake(aSize.width / 2.0f, centerY);
    
    ///4、计算每个小图像的中心点，并画图
    for (int i = 0; i < aDatasource.count; i++) {
        id avatar = aDatasource[i];
        CGPoint center = [self qq_caculateOriginFromCurrentCount:i
                                                        maxCount:aDatasource.count
                                                       circularR:R
                                                    radiusOffset:radiusOffset
                                                          center:centerOfGroupHeader];
        
        if ([avatar isKindOfClass:[UIImage class]]) {
            [self makeupQQImgAvatar:avatar
                       avatarCenter:center
                             radius:smallcircleR
                     maxAvatarCount:aDatasource.count
                       currentIndex:i];
        } else if ([avatar isKindOfClass:[NSString class]]) {
            [self makeupQQStrAvatar:avatar
                       avatarCenter:center
                             radius:smallcircleR
                     maxAvatarCount:aDatasource.count
                       currentIndex:i
             ];
        }
    }
}

/**
 计算QQ的每个小头像的中心点坐标
 currentCount 当前第几个头像呢
 maxCount 最大几个头像
 circularR 中心点到每个小头像中点的距离
 radiusOffset 偏移角（为什么要有这个，因为每个头像的角度初始值为0M_PI第一个头像都在最右边。这显然不符合QQ的布局）
 center 多边形的中点坐标
 CGPoint
 */
- (CGPoint)qq_caculateOriginFromCurrentCount:(NSInteger)currentCount
                                    maxCount:(NSInteger)maxCount
                                   circularR:(CGFloat)circularR
                                radiusOffset:(CGFloat)radiusOffset
                                      center:(CGPoint)center {
    CGPoint rsCenter = CGPointMake(center.x + circularR * cosf(2 * M_PI * currentCount / maxCount + radiusOffset * M_PI), center.y + circularR * sinf(2 * M_PI * currentCount / maxCount + radiusOffset * M_PI));
    return rsCenter;
}

/**
 画每个小头像
 
 avatar 小头像（在这之前需要处理裁剪的问题，暂时不处理）
 avatarCenter 小头像的中心坐标
 radius 整个群聊大头像的半径
 maxAvatarCount 最大几个头像
 currentIndex 第几个头像
 */
- (void)makeupQQImgAvatar:(UIImage *)avatar
             avatarCenter:(CGPoint)avatarCenter
                   radius:(CGFloat)radius
           maxAvatarCount:(NSInteger)maxAvatarCount
             currentIndex:(NSInteger)currentIndex {
    ///1、先计算偏移角以及开口角的大小，单位为弧度即例入 1/3 * M_PI
    RoundedAngle angle = [self caculateAngleFromMaxCount:maxAvatarCount currentIndex:currentIndex radius:radius];
    
    ///2、分别计算最低点和起始点的坐标，用以画圆
    CGFloat x1 = avatarCenter.x + distanceForDeepRadius(angle.halfAngle, radius) * cos(angle.startAngle + angle.halfAngle);
    CGFloat y1 = avatarCenter.y + distanceForDeepRadius(angle.halfAngle, radius) * sin(angle.startAngle + angle.halfAngle);
    
    CGFloat x2 = avatarCenter.x + radius * cos(angle.startAngle);
    CGFloat y2 = avatarCenter.y + radius * sin(angle.startAngle);
    
    ///3、开始画圆（画圆之前要开始保存现有上下文状态）
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // !!!: CGContextSaveGState和CGContextRestoreGState是成对出现的，缺少了会崩溃
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, avatarCenter.x, avatarCenter.y, radius, angle.startAngle, angle.endAngle, 1);
    CGContextAddArcToPoint(ctx, x1, y1, x2, y2, radius);
    
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    
    ///4、画好圆后，画图
    CGRect avatarRect = CGRectMake(avatarCenter.x - radius, avatarCenter.y - radius, radius * 2, radius * 2);
    [avatar drawInRect:avatarRect];
    
    ///5、然后保存当前画图状态。
    CGContextRestoreGState(ctx);
}

/**
 通过计算好的中心点，去画文字
 
 avatar          NSString *
 avatarCenter    计算好的中心点
 radius          小头像的半径
 currentIndex    要画的第几个小头像
 */
- (void)makeupQQStrAvatar:(id)avatar
             avatarCenter:(CGPoint)avatarCenter
                   radius:(CGFloat)radius
           maxAvatarCount:(NSInteger)maxAvatarCount
             currentIndex:(int)currentIndex {
    ///1、计算开角大小和方向
    RoundedAngle angle = [self caculateAngleFromMaxCount:maxAvatarCount
                                        currentIndex:currentIndex
                                              radius:radius];
    /*-------------------这里是优化后的代码-------------------*/
    ///2、计算圆弧低点和起始点的坐标，用以画圆。
    CGFloat x1 = avatarCenter.x + distanceForDeepRadius(angle.halfAngle, radius) * cos(angle.startAngle + angle.halfAngle);
    CGFloat y1 = avatarCenter.y + distanceForDeepRadius(angle.halfAngle, radius) * sin(angle.startAngle + angle.halfAngle);
    
    CGFloat x2 = avatarCenter.x + radius * cos(angle.startAngle);
    CGFloat y2 = avatarCenter.y + radius * sin(angle.startAngle);
    
    ///3、开始画圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // !!!: CGContextSaveGState和CGContextRestoreGState是成对出现的，缺少了会崩溃
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, avatarCenter.x, avatarCenter.y, radius, angle.startAngle, angle.endAngle, 1);
    CGContextAddArcToPoint(ctx, x1, y1, x2, y2, radius);
    
    ///4、在这个部分填充颜色以及设置stroke的颜色大小等等属性
    [[[TFY_ColorTool sharedInstance] colorAJWithString:avatar] setFill];
    CGContextDrawPath(ctx, kCGPathEOFill);
    
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    
    CGContextRestoreGState(ctx);
    
    ///5、画好圆后画文字。
    NSString *avatarStr = [avatar substringToIndex:1];
    CGSize attriSize = [avatarStr sizeWithAttributes:self.textAttributes];
    
    [avatarStr drawInRect:CGRectMake(avatarCenter.x - attriSize.width / 2.0f, avatarCenter.y - attriSize.height / 2.0f, attriSize.width, attriSize.height) withAttributes:self.textAttributes];
}

/**
 计算每一个开口的偏移角
 
 maxCount 要画的是几边形
 currentIndex 几边形的第几个点
 @return 返回一个结构体，该结构体包含了两个CGFloat值。
 */
- (RoundedAngle)caculateAngleFromMaxCount:(NSInteger)maxCount currentIndex:(NSInteger)currentIndex radius:(CGFloat)radius {
    RoundedAngle angle;
    angle.startAngle = 0;
    angle.endAngle = 0;
    angle.halfAngle = 0;
    switch (maxCount) {
        case QQTypeOne:{
            angle.startAngle = 0;
            angle.endAngle = 0;
            angle.halfAngle = 0;
        }
            break;
        case QQTypeTwo: {
            switch (currentIndex) {
                case 0: {
                    CGFloat angleOffSet = .35 * M_PI;
                    angle.halfAngle = angleOffSet / 2.0f;
                    angle.startAngle = 2 * M_PI + 1 / 4.0f * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    break;
                case 1: {
                    CGFloat angleOffSet = - 2 * M_PI;
                    angle.halfAngle = angleOffSet / 2.0f;
                    angle.startAngle = 0 * M_PI;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    break;
            }
            
        }
            
            break;
        case QQTypeThree: {
            CGFloat x = acosf(sin(radians(60)) * (radius) / radius);
            angle.halfAngle = x;
            CGFloat angleOffSet = 2 * x;
            switch (currentIndex) {
                case 0: {
                    angle.startAngle = 2 * M_PI + 1 / 3.0f * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    break;
                    
                case 1: {
                    angle.startAngle = 3 * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    break;
                    
                case 2: {
                    angle.startAngle = 1.5 * M_PI + 1 / 6.0f * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    break;
            }
            
        }
            
            break;
        case QQTypeFour: {
            CGFloat x = acos(sin(radians(45)) * (radius + _distance) / radius);
            
            CGFloat angleOffSet = 2 * x;
            angle.halfAngle = angleOffSet / 2.0f;

            switch (currentIndex) {
                case 1: {
                    angle.startAngle = .5f * M_PI + - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 2: {
                    angle.startAngle = 1 * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 3: {
                    angle.startAngle = 1.5 * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 0: {
                    angle.startAngle = - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
            }
        }
            
            break;
        case QQTypeFive: {
            CGFloat x = acosf(sin(radians(36)) * (radius + _distance) / radius);
            angle.halfAngle = x;

            ///五边形的开角由distance决定 distance 越小，开角越大，最大不超过180度。
            CGFloat angleOffSet = 2 * x;
            switch (currentIndex) {
                case 0: {
                    angle.startAngle = 0 * M_PI + .2 * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 1: {
                    angle.startAngle = 0.5 * M_PI + .1 * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 2: {
                    angle.startAngle = 1 * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 3: {
                    angle.startAngle = 1 * M_PI + 2 / 5.0f * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                }
                    
                    break;
                    
                case 4: {
                    angle.startAngle = 1.5 * M_PI + 3 / 10.0f * M_PI - angleOffSet / 2.0f;
                    angle.endAngle = angle.startAngle + angleOffSet;
                    
                }
                    
                    break;
            }
        }
            break;
        default:
            break;
    }
    return angle;
}

/**
 返回每个小头像的直径
 
 num 一共几个头像
 avatarWidth 整个群聊头像框的宽
 单个头像的半径
 */
- (CGFloat)smallCircleRFromAvatarNum:(NSInteger)num avatarWidth:(CGFloat)avatarWidth {
    switch (num) {
        case 1:
            return avatarWidth;
            break;
        case 2:
            return (avatarWidth + sqrt(2) * _distance) / (2 + sqrt(2));
            break;
            
        case 3:
            return avatarWidth / (2 + sqrt(3));
            break;
            
        case 4:
            ///默认内切4个圆，同时该4个圆，两两相交于两点。
            return (sqrt(2) / 2.0f * avatarWidth - _distance) / (1 + sqrt(2));
            break;
            
        case 5:
            return (avatarWidth - 2 * sin(radians(72)) * _distance) / (2 + 2 * sin(radians(72)));
            
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - WeChat
- (void)makeupWeChatAvatar:(CGRect)rect ctx:(CGContextRef)ctx dataSource:(NSArray *)dataSource {
    ///1、计算每个小图像的大小
    CGFloat width = (rect.size.width - ((2 * _leadingWeChat) + ((dataSource.count < 5) ? 1 : 2) * _spacingWeChat)) / [self numberOfWeChatColumn:dataSource];
    CGFloat height = width;
    if (dataSource.count == 1) {
        width = rect.size.width;
        height = rect.size.height;
    }
    for (int i = 0; i < dataSource.count; i++) {
        ///2、计算每个小头像的坐标
        CGPoint origin = [self wechat_caculateOriginFromCurrentIndex:i
                                                           itemCount:dataSource.count
                                                               width:width
                                                              height:height
                                                                rect:rect];
        
        id avatar = dataSource[i];
        CGRect avatarRect = CGRectMake(origin.x, origin.y, width, height);
        
        if ([avatar isKindOfClass:[UIImage class]]) {
            [avatar drawInRect:avatarRect];
        } else if ([avatar isKindOfClass:[NSString class]]) {
            //创建图形路径句柄
            CGMutablePathRef path = CGPathCreateMutable();
            //设置矩形的边界
            //添加矩形到路径中
            CGPathAddRect(path,NULL, avatarRect);
            //添加路径到上下文中
            CGContextAddPath(ctx, path);
            
            ///填充颜色
            [[[TFY_ColorTool sharedInstance] colorAJWithString:avatar] setFill];
            CGContextDrawPath(ctx, kCGPathFill);
            ///释放路径
            CGPathRelease(path);
            
            NSString *avatarStr = [avatar substringToIndex:1];
            CGSize attriSize = [avatarStr sizeWithAttributes:self.textAttributes];
            
            CGRect rsRect = CGRectMake(avatarRect.origin.x + (avatarRect.size.width - attriSize.width) / 2.0f , avatarRect.origin.y + (avatarRect.size.height - attriSize.height) / 2.0f , attriSize.width, attriSize.height);
            
            [avatarStr drawInRect:rsRect withAttributes:self.textAttributes];
        }
    }
}

/**
 返回微信头像的最大列数

 dataSource 数据源
 @return 列数
 */
- (NSInteger)numberOfWeChatColumn:(NSArray *)dataSource {
    switch (dataSource.count) {
        case WeChatTypeOne:
            return 1;
            break;
        case WeChatTypeTwo:
        case WeChatTypeThree:
        case WeChatTypeFour:
            return 2;
            break;
        case WeChatTypeFive:
        case WeChatTypeSix:
        case WeChatTypeSeven:
        case WeChatTypeEight:
        case WeChatTypeNine:
            return 3;
            break;
    }
    return 0;
}

/**
 微信计算位置的方法
 
 currentIndex 当前第几个小图
 itemCount 一共多少个图
 width 每个小图的宽
 height 每个小兔的高
 rect 背景的位置。
 返回位置
 */
- (CGPoint)wechat_caculateOriginFromCurrentIndex:(NSInteger)currentIndex
                                       itemCount:(NSInteger)itemCount
                                           width:(CGFloat)width
                                          height:(CGFloat)height
                                            rect:(CGRect)rect {
    // FIXME: 有待优化成一个统一的方法。而不是区分的方法。
    CGFloat x = 0;
    CGFloat y = 0;
    switch (itemCount) {
        case WeChatTypeOne:
            x = 0;
            y = 0;
        case WeChatTypeTwo:
            x = _leadingWeChat + (currentIndex) * (_spacingWeChat + width);
            y = (rect.size.height - height) / 2.0f;
            
            break;
            
        case WeChatTypeThree: {
            if (currentIndex < 1) {
                x = (rect.size.width - width) / 2.0f;
                y = _leadingWeChat;
            } else {
                x = _leadingWeChat + (currentIndex - 1) * (_spacingWeChat + width);
                y = rect.size.height - _leadingWeChat - height;
            }
        }
            break;
        case WeChatTypeFour: {
            x = _leadingWeChat + (width + _spacingWeChat) * (currentIndex % 2);
            y = _leadingWeChat + (height + _spacingWeChat) * (currentIndex / 2);
        }
            
            break;
        case WeChatTypeFive: {
            if (currentIndex < 2) {
                x = (rect.size.width / 2.0f - width - _spacingWeChat / 2.0f) + currentIndex * (_spacingWeChat + width);
                y = (rect.size.height / 2.0f - height - _spacingWeChat / 2.0f);
            } else {
                x = ((currentIndex - 2) % 3) * (_spacingWeChat + width) + _leadingWeChat;
                y = (rect.size.height / 2.0f - height - _spacingWeChat / 2.0f) + _spacingWeChat + height;
            }
        }
            
            break;
        case WeChatTypeSix: {
            x = _leadingWeChat + (width + _spacingWeChat) * (currentIndex % 3);
            y = (rect.size.height / 2.0f - height - _spacingWeChat / 2.0f) + (height + _spacingWeChat) * (currentIndex / 3);
        }
            
            break;
        case WeChatTypeSeven: {
            if (currentIndex < 1) {
                x = (rect.size.width - width) / 2.0f;
                y = _leadingWeChat;
            } else {
                x = _leadingWeChat + ((currentIndex - 1) % 3) * (width + _spacingWeChat);
                y = _leadingWeChat + height + _spacingWeChat + (height + _spacingWeChat) * ((currentIndex - 1) / 3);
            }
        }
            
            break;
        case WeChatTypeEight: {
            if (currentIndex < 2) {
                x = rect.size.width / 2.0f - width - _spacingWeChat / 2.0f + (_spacingWeChat + width) * currentIndex;
                y = _leadingWeChat;
            } else {
                x = _leadingWeChat + ((currentIndex - 2) % 3) * (width + _spacingWeChat);
                y = _leadingWeChat + height + _spacingWeChat + (height + _spacingWeChat) * ((currentIndex - 2) / 3);
            }
        }
            
            break;
        case WeChatTypeNine: {
            x = _leadingWeChat + (width + _spacingWeChat) * (currentIndex % 3);
            y = _leadingWeChat + (height + _spacingWeChat) * (currentIndex / 3);
            break;
        }
    }
    return CGPointMake(x, y);
}

- (void)updateColorRegular:(NSArray *)ahexStringSource {
    [TFY_ColorTool sharedInstance].hexStringSource = ahexStringSource;
}

- (UIImage *)tfy_groupIconWithURL:(id)urlData {
    NSData * data = nil;
    if ([urlData isKindOfClass:NSData.class]) {
        data = urlData;
    } else if ([urlData isKindOfClass:NSString.class]) {
        NSString *url = urlData;
        if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) {
            data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        } else {
            data = [[NSData alloc] initWithContentsOfFile:url];
            if (data == nil) {
                data = UIImagePNGRepresentation([UIImage imageNamed:url]);
            }
        }
    } else if ([urlData isKindOfClass:UIImage.class]) {
        data = UIImagePNGRepresentation(urlData);
    }
    UIImage *image = [[UIImage alloc]initWithData:data];
    return image;
}


@end
