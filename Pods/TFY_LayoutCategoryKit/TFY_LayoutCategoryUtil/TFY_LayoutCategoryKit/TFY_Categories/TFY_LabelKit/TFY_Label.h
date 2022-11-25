//
//  TFY_Label.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "TFY_BaseLabel.h"

typedef NS_OPTIONS(NSUInteger, TFYDataDetectorTypes) {
    TFYDataDetectorTypeURL           = 1 << 1,          // 链接，不用link定义，是因为link作为统称
    TFYDataDetectorTypePhoneNumber   = 1 << 0,          // 电话
    TFYDataDetectorTypeNone          = 0,               // 禁用
    TFYDataDetectorTypeAll           = NSUIntegerMax,    // 所有
    //上面4个和UIDataDetectorTypes的对应，下面是自己加的
    
    TFYDataDetectorTypeEmail         = 1 << 4,          // 邮箱
    TFYDataDetectorTypeUserHandle    = 1 << 5,          //@..
    TFYDataDetectorTypeHashtag       = 1 << 6,          //#..
    //上面是个性化的匹配
    
    
    //这个是对attributedText里带有Link属性的检测，至于为什么30，预留上面空间以添加新的个性化
    //这个东西和dataDetectorTypesOfAttributedLinkValue对应起来，会对带有NSLinkAttributeName区间的value进行检测，匹配则给予对应的LinkType，找不到则为Other
    //注意NSLinkAttributeName所对应的值一定得是NSURL、NSString、NSAttributedString的一种
    TFYDataDetectorTypeAttributedLink = 1 << 30,
};


typedef NS_ENUM(NSUInteger, TFYLinkType) {
    TFYLinkTypeNone          = 0,
    TFYLinkTypeURL           = 1,          // 链接
    TFYLinkTypePhoneNumber   = 2,          // 电话
    TFYLinkTypeEmail         = 3,          // 邮箱
    TFYLinkTypeUserHandle    = 4,          //@
    TFYLinkTypeHashtag       = 5,          //#..
    
    TFYLinkTypeOther        = 30,          //这个一般是和TFYDataDetectorTypeAttributedLink对应的，但是也可以自己随意添加啦，不过是一个标识而已，至于为什么30，随便定的，预留上面空间以添加新的个性化
};

#define kDefaultLinkColorFor [UIColor colorWithRed:0.061 green:0.515 blue:0.862 alpha:1.000]
#define kDefaultActiveLinkBackgroundColorFor [UIColor colorWithWhite:0.215 alpha:0.300]

@class TFY_Link,TFY_Label;
NS_ASSUME_NONNULL_BEGIN

@protocol TFYLinkLabelDelegate <NSObject>

- (void)didClickLink:(TFY_Link*)link linkText:(NSString*)linkText linkLabel:(TFY_Label*)linkLabel;

@optional

- (void)didLongPressLink:(TFY_Link*)link linkText:(NSString*)linkText linkLabel:(TFY_Label*)linkLabel;

@end


@interface TFY_Label : TFY_BaseLabel

//默认为TFYDataDetectorTypeURL|TFYDataDetectorTypePhoneNumber|TFYDataDetectorTypeEmail|TFYDataDetectorTypeAttributedLink，自动检测除了@和#话题的全部类型并且转换为链接
@property (nonatomic, assign) TFYDataDetectorTypes dataDetectorTypes;

//这个是当dataDetectorTypes的TFYDataDetectorTypeAttributedLink可用时候，自动对attributedText里Link属性value检测给予linkType的检测类型，默认为TFYDataDetectorTypeNone，也就是默认最终得到的linkType为TFYLinkTypeOther
@property (nonatomic, assign) TFYDataDetectorTypes dataDetectorTypesOfAttributedLinkValue;

@property (nonatomic, strong) NSDictionary *linkTextAttributes;
@property (nonatomic, strong) NSDictionary *activeLinkTextAttributes;

//这个主要是为了不会在点击非常快速结束触摸的情况下，激活的链接样式基本没体现，这里的delay可以让其多体现那个一会，显得有反馈。
//默认为0.3秒
@property (nonatomic, assign) NSTimeInterval activeLinkToNilDelay;

//是否允许在link内line break，默认为YES，即为允许，这样的话链接会能折行就折行和正常文本一样
@property (nonatomic, assign) BOOL allowLineBreakInsideLinks;

//优先级比delegate高
@property (nonatomic, copy) void(^didClickLinkBlock)(TFY_Link *link,NSString *linkText,TFY_Label *label);
@property (nonatomic, copy) void(^didLongPressLinkBlock)(TFY_Link *link,NSString *linkText,TFY_Label *label);

@property (nonatomic, weak) id<TFYLinkLabelDelegate> delegate; //这个优先级没有block高

@property (nonatomic, strong, readonly) NSMutableArray *links; //可以遍历针对自定义

/**
 *  link在正式add之前可以自定义修改属性的block
 */
@property (nonatomic, copy) void(^beforeAddLinkBlock)(TFY_Link *link);


- (TFY_Link *)linkAtPoint:(CGPoint)location;

/**
 *  设置文本后添加link。注意如果在此之后设置了text、attributedText、dataDetectorTypes或dataDetectorTypesOfAttributedLinkValue属性的话添加的link会丢失。
 */
- (BOOL)addLink:(TFY_Link*)link;
/**
 * 设置文本后添加link，注意如果在此之后设置了text、attributedText、dataDetectorTypes或dataDetectorTypesOfAttributedLinkValue属性的话添加的link会丢失。
 */
- (TFY_Link*)addLinkWithType:(TFYLinkType)type value:(NSString*)value range:(NSRange)range;
/**
 * 设置文本后添加link，注意如果在此之后设置了text、attributedText、dataDetectorTypes或dataDetectorTypesOfAttributedLinkValue属性的话添加的link会丢失。
 */
- (NSArray*)addLinks:(NSArray*)links;

//下面俩是为了编写代码时候外部设置block时候不需要自定义名字了，方便。
- (void)setDidClickLinkBlock:(void (^)(TFY_Link *link, NSString *linkText, TFY_Label *label))didClickLinkBlock;
- (void)setDidLongPressLinkBlock:(void (^)(TFY_Link *link, NSString *linkText, TFY_Label *label))didLongPressLinkBlock;

/**
 *  一般用在修改了某些link的样式属性之后效果不会立马启用，使用此方法可启用。
 */
- (void)invalidateDisplayForLinks;


@end

@interface TFY_Link : NSObject

@property (nonatomic, assign) TFYLinkType linkType;
@property (nonatomic, copy) NSString *linkValue;
@property (readonly, nonatomic, assign) NSRange linkRange;

//可以单独设置且覆盖label的三个参数
@property (nonatomic, strong) NSDictionary *linkTextAttributes;
@property (nonatomic, strong) NSDictionary *activeLinkTextAttributes;

//初始化
+ (instancetype)linkWithType:(TFYLinkType)type value:(NSString*)value range:(NSRange)range;
+ (instancetype)linkWithType:(TFYLinkType)type value:(NSString*)value range:(NSRange)range linkTextAttributes:(NSDictionary*__nullable)linkTextAttributes activeLinkTextAttributes:(NSDictionary*__nullable)activeLinkTextAttributes;

@property (nonatomic, copy) void(^didClickLinkBlock)(TFY_Link *link,NSString *linkText,TFY_Label *label);
@property (nonatomic, copy) void(^didLongPressLinkBlock)(TFY_Link *link,NSString *linkText,TFY_Label *label);

//下面俩是为了编写代码时候外部设置block时候不需要自定义名字了，方便。
- (void)setDidClickLinkBlock:(void (^)(TFY_Link *link, NSString *linkText, TFY_Label *label))didClickLinkBlock;
- (void)setDidLongPressLinkBlock:(void (^)(TFY_Link *link, NSString *linkText, TFY_Label *label))didLongPressLinkBlock;

@end

NS_ASSUME_NONNULL_END
