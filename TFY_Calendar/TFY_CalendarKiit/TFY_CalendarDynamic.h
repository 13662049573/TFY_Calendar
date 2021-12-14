//
//  TFY_CalendarDynamic.h
//  TFY_Calendar
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_CalendarKiit.h"

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
@property (readonly, nonatomic) NSDictionary *subToptitleColors;
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
