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

- (instancetype)initWithCalendar:(TFY_Calendar *)calendar;

- (NSDate *)safeDateForDate:(NSDate *)date;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(TFYCa_CalendarScope)scope;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;
- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(TFYCa_CalendarScope)scope;
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position;
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position scope:(TFYCa_CalendarScope)scope;

- (NSDate *)pageForSection:(NSInteger)section;
- (NSDate *)weekForSection:(NSInteger)section;
- (NSDate *)monthForSection:(NSInteger)section;
- (NSDate *)monthHeadForSection:(NSInteger)section;

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month;
- (NSInteger)numberOfRowsInMonth:(NSDate *)month;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (TFYCa_CalendarMonthPosition)monthPositionForIndexPath:(NSIndexPath *)indexPath;
- (TFY_CalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath;

- (void)reloadSections;
@end

NS_ASSUME_NONNULL_END
