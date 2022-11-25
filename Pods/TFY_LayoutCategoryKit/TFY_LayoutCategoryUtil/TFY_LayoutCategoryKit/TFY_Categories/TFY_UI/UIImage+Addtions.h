//
//  UIImage+Addtions.h
//  TFY_ChatIMInterface
//
//  Created by 田风有 on 2022/2/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AvatarType) {
    ///微信模式
    AvatarTypeWeChat,
    ///qq模式
    AvatarTypeQQ,
};

/**
 用于定义每个小头像的开角的角度，从哪开到哪。
 */
typedef struct {
    CGFloat startAngle;
    CGFloat endAngle;
    CGFloat halfAngle;
} RoundedAngle;

typedef NS_ENUM(NSUInteger, WeChatType) {
    WeChatTypeOne = 1,
    WeChatTypeTwo = 2,
    WeChatTypeThree = 3,
    WeChatTypeFour = 4,
    WeChatTypeFive = 5,
    WeChatTypeSix = 6,
    WeChatTypeSeven = 7,
    WeChatTypeEight = 8,
    WeChatTypeNine = 9
};

typedef NS_ENUM(NSUInteger, QQType) {
    QQTypeOne = 1,
    QQTypeTwo = 2,
    QQTypeThree,
    QQTypeFour,
    QQTypeFive,
};

static inline float radians(double degrees) {
    return M_PI * (degrees / 180.0f);
}

/**
 计算凹槽最低点距离圆心的距离
 */
static inline CGFloat distanceForDeepRadius(CGFloat halfAngle, CGFloat radius) {
    return radius * cos(halfAngle) - radius * sin(halfAngle) * tan(halfAngle);
}


#ifndef sn
#define sn(arg) ((arg && ![arg isKindOfClass:[NSNull class]]) ? arg:@"")
#endif

@interface UIImage (Addtions)

#pragma mark --- 微信群组头像拼接 默认 100 * 100 的大小
///  支持urrl 地址传值
+ (UIImage *)tfy_groupIconWith:(NSArray *)array bgColor:(UIColor *)bgColor;
/// 支持本地url 和 image
+ (UIImage *)tfy_groupIconWithURLArray:(NSArray *)URLArray bgColor:(UIColor *)bgColor;

@end

@interface TFY_ColorTool : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSArray <NSString *>*hexStringSource;

- (UIColor *)colorFromHexString:(NSString *)hexString;

- (UIColor *)colorAJWithString:(NSString *)aStr;

@end


@interface TFY_AvatarMaker : NSObject

///QQ
///多边形中心点距离每个小头像的边的距离系数\ 默认值为 3.5 / 80 即头像大小为80的时候，距离为3.5;
@property (nonatomic, assign) CGFloat distanceFactor;
//当头像为QQ头像时候的背景色            默认值为[UIColor whiteColor]
@property (nonatomic, strong) UIColor *avatarBackGroundColorQQ;

///WeChat
///大头像的边框大小                    默认值为1.0f
@property (nonatomic, assign) CGFloat leadingWeChat;
///小头像的间距大                      默认值为2.0f
@property (nonatomic, assign) CGFloat spacingWeChat;
///当头像为微信头像时候的背景色          默认值为[UIColor colorWithWhite: 239.0f / 255.0f alpha:1]
@property (nonatomic, strong) UIColor *avatarBackGroundColorWeChat;
///文字填充属性                       默认值白色，8号字
@property (nonatomic, strong) NSDictionary *textAttributes;
/**
 更新颜色规则
 
 ahexStringSource 颜色hexString
 默认值为 @[@"#97c5e8", @"#9acbe1", @"#84d1d9", @"#f2b591", @"#e3c097", @"#b9a29a"]
 
 */
- (void)updateColorRegular:(NSArray *)ahexStringSource;

/**
 制作群聊头像
 
 aModel 头像类型
 aSize 头像大小
 aDatasource 数据源，类型是UIImage 或者字符串
 一个图片
 */
- (UIImage *)makeGroupHeader:(AvatarType)aModel
                  headerSize:(CGSize)aSize
                  dataSource:(NSArray *)aDatasource;

@end
