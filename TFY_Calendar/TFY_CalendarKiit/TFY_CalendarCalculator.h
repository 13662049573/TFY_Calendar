//
//  TFY_CalendarCalculator.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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

- (instancetype)initWithCalendar:(TFY_Calendar *)calendar TFY_CalendarSwiftName(init(calendar:));

- (NSDate *)safeDateForDate:(NSDate *)date TFY_CalendarSwiftName(safeDate(forDate:));

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath TFY_CalendarSwiftName(date(forIndexPath:));
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(TFYCa_CalendarScope)scope TFY_CalendarSwiftName(date(forIndexPath:scope:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date TFY_CalendarSwiftName(indexPath(forDate:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(TFYCa_CalendarScope)scope TFY_CalendarSwiftName(indexPath(forDate:scope:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position TFY_CalendarSwiftName(indexPath(forDate:atMonthPosition:));
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position scope:(TFYCa_CalendarScope)scope TFY_CalendarSwiftName(indexPath(forDate:atMonthPosition:scope:));

- (NSDate *)pageForSection:(NSInteger)section TFY_CalendarSwiftName(page(forSection:));
- (NSDate *)weekForSection:(NSInteger)section TFY_CalendarSwiftName(week(forSection:));
- (NSDate *)monthForSection:(NSInteger)section TFY_CalendarSwiftName(month(forSection:));
- (NSDate *)monthHeadForSection:(NSInteger)section TFY_CalendarSwiftName(monthHead(forSection:));

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month TFY_CalendarSwiftName(numberOfHeadPlaceholders(forMonth:));
- (NSInteger)numberOfRowsInMonth:(NSDate *)month TFY_CalendarSwiftName(numberOfRows(inMonth:));
- (NSInteger)numberOfRowsInSection:(NSInteger)section TFY_CalendarSwiftName(numberOfRows(inSection:));

- (TFYCa_CalendarMonthPosition)monthPositionForIndexPath:(NSIndexPath *)indexPath TFY_CalendarSwiftName(monthPosition(forIndexPath:));
- (TFY_CalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath TFY_CalendarSwiftName(coordinate(forIndexPath:));

- (void)reloadSections TFY_CalendarSwiftName(reloadSections());

@end

NS_ASSUME_NONNULL_END
