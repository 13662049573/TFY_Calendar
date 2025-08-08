//
//  TFY_CalendarCalculator.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Ensure NS_SWIFT_NAME is available
#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(name)
#endif

#import "TFY_Calendar.h"

struct TFY_CalendarCoordinate {
    NSInteger row;
    NSInteger column;
};
typedef struct TFY_CalendarCoordinate TFY_CalendarCoordinate;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarCalculator : NSObject

@property (weak  , nonatomic) TFY_Calendar *calendar;

@property (readonly, nonatomic) NSInteger numberOfSections;

- (instancetype)initWithCalendar:(TFY_Calendar *)calendar NS_SWIFT_NAME(init(calendar:));

- (NSDate *)safeDateForDate:(NSDate *)date NS_SWIFT_NAME(safeDate(forDate:));

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(date(forIndexPath:));
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(TFYCa_CalendarScope)scope NS_SWIFT_NAME(date(forIndexPath:scope:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date NS_SWIFT_NAME(indexPath(forDate:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(TFYCa_CalendarScope)scope NS_SWIFT_NAME(indexPath(forDate:scope:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position NS_SWIFT_NAME(indexPath(forDate:atMonthPosition:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position scope:(TFYCa_CalendarScope)scope NS_SWIFT_NAME(indexPath(forDate:atMonthPosition:scope:));

- (NSDate *)pageForSection:(NSInteger)section NS_SWIFT_NAME(page(forSection:));
- (NSDate *)weekForSection:(NSInteger)section NS_SWIFT_NAME(week(forSection:));
- (NSDate *)monthForSection:(NSInteger)section NS_SWIFT_NAME(month(forSection:));
- (NSDate *)monthHeadForSection:(NSInteger)section NS_SWIFT_NAME(monthHead(forSection:));

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month NS_SWIFT_NAME(numberOfHeadPlaceholders(forMonth:));
- (NSInteger)numberOfRowsInMonth:(NSDate *)month NS_SWIFT_NAME(numberOfRows(inMonth:));
- (NSInteger)numberOfRowsInSection:(NSInteger)section NS_SWIFT_NAME(numberOfRows(inSection:));

- (TFYCa_CalendarMonthPosition)monthPositionForIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(monthPosition(forIndexPath:));
- (TFY_CalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(coordinate(forIndexPath:));

- (void)reloadSections NS_SWIFT_NAME(reloadSections());

@end

NS_ASSUME_NONNULL_END
