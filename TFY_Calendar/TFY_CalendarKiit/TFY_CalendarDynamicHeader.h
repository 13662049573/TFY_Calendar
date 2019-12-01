//
//  TFY_CalendarDynamicHeader.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//  仅供框架内部使用。

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TFY_Calendar.h"
#import "TFY_CalendarCell.h"
#import "TFY_CalendarHeaderView.h"
#import "TFY_CalendarAppearance.h"
#import "TFY_CalendarCollectionView.h"
#import "TFY_CalendarCollectionViewLayout.h"
#import "TFY_CalendarCalculator.h"
#import "TFY_CalendarTransitionCoordinator.h"
#import "TFY_CalendarDelegationProxy.h"
#import "TFY_CalendarWeekdayView.h"
#import "TFY_LunarFormatter.h"
#import "TFY_CalendarExtensions.h"


@interface TFY_Calendar (Dynamic)

@property (readonly, nonatomic) TFY_CalendarCollectionView *collectionView;
@property (readonly, nonatomic) TFY_CalendarCollectionViewLayout *collectionViewLayout;
@property (readonly, nonatomic) TFY_CalendarTransitionCoordinator *transitionCoordinator;
@property (readonly, nonatomic) TFY_CalendarCalculator *calculator;
@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;
@property (readonly, nonatomic) CGFloat preferredHeaderHeight;
@property (readonly, nonatomic) CGFloat preferredWeekdayHeight;
@property (readonly, nonatomic) UIView *bottomBorder;

@property (readonly, nonatomic) NSCalendar *gregorian;
@property (readonly, nonatomic) NSDateFormatter *formatter;

@property (readonly, nonatomic) UIView *contentView;
@property (readonly, nonatomic) UIView *daysContainer;

@property (assign, nonatomic) BOOL needsAdjustingViewFrame;

- (void)invalidateHeaders;
- (void)adjustMonthPosition;
- (void)configureAppearance;

- (BOOL)isPageInRange:(NSDate *)page;
- (BOOL)isDateInRange:(NSDate *)date;

- (CGSize)sizeThatFits:(CGSize)size scope:(TFYCa_CalendarScope)scope;

@end

@interface TFY_CalendarAppearance (Dynamic)

@property (readwrite, nonatomic) TFY_Calendar *calendar;

@property (readonly, nonatomic) NSDictionary *backgroundColors;
@property (readonly, nonatomic) NSDictionary *titleColors;
@property (readonly, nonatomic) NSDictionary *subtitleColors;
@property (readonly, nonatomic) NSDictionary *borderColors;

@end

@interface TFY_CalendarWeekdayView (Dynamic)

@property (readwrite, nonatomic) TFY_Calendar *calendar;

@end

@interface TFY_CalendarCollectionViewLayout (Dynamic)

@property (readonly, nonatomic) CGSize estimatedItemSize;

@end

@interface TFY_CalendarDelegationProxy()<TFYCa_CalendarDataSource,TFYCa_CalendarDelegate,TFYCa_CalendarDelegateAppearance>
@end



