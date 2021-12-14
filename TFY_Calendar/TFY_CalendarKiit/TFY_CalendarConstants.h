//
//  TFY_CalendarConstants.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

CG_EXTERN CGFloat const TFYCa_CalendarStandardHeaderHeight;
CG_EXTERN CGFloat const TFYCa_CalendarStandardWeekdayHeight;
CG_EXTERN CGFloat const TFYCa_CalendarStandardMonthlyPageHeight;
CG_EXTERN CGFloat const TFYCa_CalendarStandardWeeklyPageHeight;
CG_EXTERN CGFloat const TFYCa_CalendarStandardCellDiameter;
CG_EXTERN CGFloat const TFYCa_CalendarStandardSeparatorThickness;
CG_EXTERN CGFloat const TFYCa_CalendarAutomaticDimension;
CG_EXTERN CGFloat const TFYCa_CalendarDefaultBounceAnimationDuration;
CG_EXTERN CGFloat const TFYCa_CalendarStandardRowHeight;
CG_EXTERN CGFloat const TFYCa_CalendarStandardTitleTextSize;
CG_EXTERN CGFloat const TFYCa_CalendarStandardSubtitleTextSize;
CG_EXTERN CGFloat const TFYCa_CalendarStandardSubToptitleTextSize;
CG_EXTERN CGFloat const TFYCa_CalendarStandardWeekdayTextSize;
CG_EXTERN CGFloat const TFYCa_CalendarStandardHeaderTextSize;
CG_EXTERN CGFloat const TFYCa_CalendarMaximumEventDotDiameter;

UIKIT_EXTERN NSInteger const TFYCa_CalendarDefaultHourComponent;
UIKIT_EXTERN NSInteger const TFYCa_CalendarMaximumNumberOfEvents;

UIKIT_EXTERN NSString * const TFYCa_CalendarDefaultCellReuseIdentifier;
UIKIT_EXTERN NSString * const TFYCa_CalendarBlankCellReuseIdentifier;
UIKIT_EXTERN NSString * const TFYCa_CalendarInvalidArgumentsExceptionName;

CG_EXTERN CGPoint const CGPointInfinity;
CG_EXTERN CGSize const CGSizeAutomatic;

#if TARGET_INTERFACE_BUILDER
#define TFYCa_CalendarDeviceIsIPad NO
#else
#define TFYCa_CalendarDeviceIsIPad [[UIDevice currentDevice].model hasPrefix:@"iPad"]
#endif

#define TFYCa_CalendarStandardSelectionColor   TFYCa_ColorRGBA(31,119,219,1.0)//选择填充颜色
#define TFYCa_CalendarStandardTodayColor       TFYCa_ColorRGBA(198,51,42 ,1.0)
#define TFYCa_CalendarStandardTitleTextColor   TFYCa_ColorRGBA(14,69,221 ,1.0)
#define TFYCa_CalendarStandardEventDotColor    TFYCa_ColorRGBA(31,119,219,0.75)

#define TFYCa_CalendarStandardLineColor        [[UIColor lightGrayColor] colorWithAlphaComponent:0.30]
#define TFYCa_CalendarStandardSeparatorColor   [[UIColor lightGrayColor] colorWithAlphaComponent:0.60]

#define TFYCa_ColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define TFYCa_CalendarInAppExtension [[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]

#define TFYCa_CalendarFloor(c) floorf(c)
#define TFYCa_CalendarRound(c) roundf(c)
#define TFYCa_CalendarCeil(c) ceilf(c)
#define TFYCa_CalendarMod(c1,c2) fmodf(c1,c2)

#define TFYCa_CalendarHalfRound(c) (TFYCa_CalendarRound(c*2)*0.5)
#define TFYCa_CalendarHalfFloor(c) (TFYCa_CalendarFloor(c*2)*0.5)
#define TFYCa_CalendarHalfCeil(c) (TFYCa_CalendarCeil(c*2)*0.5)

#define TFYCa_CalendarUseWeakSelf __weak __typeof__(self) TFYCa_CalendarWeakSelf = self;
#define TFYCa_CalendarUseStrongSelf __strong __typeof__(self) self = TFYCa_CalendarWeakSelf;


#define TFYCa_WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;
/**需要传入的值*/
#define TFYCa_CALENDARSTATEMENTCHAINFUNCTION(className,propertyModifier,propertyPointerType,propertyName) \
@property(nonatomic,propertyModifier)propertyPointerType  propertyName;\
- (className * (^) (propertyPointerType propertyName))propertyName##Set;

/**回调数据*/
#define TFYCa_CALENDARFUNCIMPLEMENTATION(className,propertyPointerType, propertyName)  \
- (className * (^) (propertyPointerType propertyName))propertyName##Set{ \
   TFYCa_WSelf(myself);\
    return ^(propertyPointerType propertyName){\
        myself.propertyName = propertyName;\
        return myself;\
    };\
}


#pragma mark - Deprecated

#define TFYCa_CalendarDeprecated(instead) DEPRECATED_MSG_ATTRIBUTE(" Use " # instead " instead")

static inline void TFYCa_CalendarSliceCake(CGFloat cake, NSInteger count, CGFloat *pieces) {
    CGFloat total = cake;
    for (int i = 0; i < count; i++) {
        NSInteger remains = count - i;
        CGFloat piece = TFYCa_CalendarRound(total/remains*2)*0.5;
        total -= piece;
        pieces[i] = piece;
    }
}


NS_ASSUME_NONNULL_END

