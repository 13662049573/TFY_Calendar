//
//  TFY_CalendarConstants.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarConstants.h"

CGFloat const TFYCa_CalendarStandardHeaderHeight = 40;
CGFloat const TFYCa_CalendarStandardWeekdayHeight = 25;
CGFloat const TFYCa_CalendarStandardMonthlyPageHeight = 300.0;
CGFloat const TFYCa_CalendarStandardWeeklyPageHeight = 108+1/3.0;
CGFloat const TFYCa_CalendarStandardCellDiameter = 100/3.0;
CGFloat const TFYCa_CalendarStandardSeparatorThickness = 0.5;
CGFloat const TFYCa_CalendarAutomaticDimension = -1;
CGFloat const TFYCa_CalendarDefaultBounceAnimationDuration = 0.15;
CGFloat const TFYCa_CalendarStandardRowHeight = 38;
CGFloat const TFYCa_CalendarStandardTitleTextSize = 13.5;
CGFloat const TFYCa_CalendarStandardSubtitleTextSize = 10;
CGFloat const TFYCa_CalendarStandardWeekdayTextSize = 14;
CGFloat const TFYCa_CalendarStandardHeaderTextSize = 16.5;
CGFloat const TFYCa_CalendarMaximumEventDotDiameter = 4.8;

NSInteger const TFYCa_CalendarDefaultHourComponent = 0;
NSInteger const TFYCa_CalendarMaximumNumberOfEvents = 3;

NSString * const TFYCa_CalendarDefaultCellReuseIdentifier = @"_TFYCaCalendarDefaultCellReuseIdentifier";
NSString * const TFYCa_CalendarBlankCellReuseIdentifier = @"_TFYCaCalendarBlankCellReuseIdentifier";
NSString * const TFYCa_CalendarInvalidArgumentsExceptionName = @"Invalid argument exception";

CGPoint const CGPointInfinity = {
    .x =  CGFLOAT_MAX,
    .y =  CGFLOAT_MAX
};

CGSize const CGSizeAutomatic = {
    .width =  TFYCa_CalendarAutomaticDimension,
    .height =  TFYCa_CalendarAutomaticDimension
};



