//
//  UIButton+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+TFY_Tools.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ButtonImageDirection) {
    ButtonDirectionCenterImageTop = 1,    //内容居中>>图上文右
    ButtonDirectionCenterImageLeft,   //内容居中>>图左文右
    ButtonDirectionCenterImageRight,  //内容居中>>图右文左
    ButtonDirectionCenterImageBottom, //内容居中>>图下文上
    ButtonDirectionLeftImageLeft,     //内容居左>>图左文右
    ButtonDirectionLeftImageRight,    //内容居左>>图右文左
    ButtonDirectionRightImageLeft,    //内容居右>>图左文右
    ButtonDirectionRightImageRight    //内容居右>>图右文左
};

typedef void(^ButtonLimitTimesTapBlock)(NSUInteger time, BOOL *stop, UIButton *button);

@interface UIButton (TFY_Tools)

- (void)tfy_imageDirection:(ButtonImageDirection)direction space:(CGFloat)space;

#pragma mark - 限制点击次数 -
/**
 * 点击次数
 */
@property (nonatomic, copy, readonly) UIButton * (^tfy_buttonTapTime) (ButtonLimitTimesTapBlock block);

/**
 * 时间间隔
 */
@property (nonatomic, copy, readonly) UIButton* (^tfy_tapSpaceTime) (NSTimeInterval spaceTime);
/**
 是否开始随意移动模式
 */
@property(nonatomic , assign) BOOL tfy_dragEnable;
/**
 是否允许边际显示
 */
@property(nonatomic , assign) BOOL tfy_adsorbEnable;
/**
   边际两边的显示的距离
 */
@property(nonatomic , assign) CGFloat tfy_padding;
/**
 * 清除限制
 */
- (void)tfy_cancelRecordTime;

/**
 *  🐶计时时间    👇
 */
@property(nonatomic,assign,readwrite)NSInteger tfy_time;
/**
 *  🐶format   👇
 */
@property(nonatomic,copy)NSString *tfy_format;
/**
 * 开启计时器
 */
- (void)tfy_startTimer;
/**
 * 干掉计时器
 */
- (void)tfy_endTimer;
/**
 * 倒计时完成后的回调
 */
@property(nonatomic,copy)void(^CompleteBlock)(void);
@end

NS_ASSUME_NONNULL_END
