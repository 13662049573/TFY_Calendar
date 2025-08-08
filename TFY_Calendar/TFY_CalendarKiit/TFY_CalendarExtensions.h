//
//  TFY_CalendarExtensions.h
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

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TFY_CalendarExtensions)

@property (nonatomic) CGFloat tfyCa_width;
@property (nonatomic) CGFloat tfyCa_height;

@property (nonatomic) CGFloat tfyCa_top;
@property (nonatomic) CGFloat tfyCa_left;
@property (nonatomic) CGFloat tfyCa_bottom;
@property (nonatomic) CGFloat tfyCa_right;

@end


@interface CALayer (TFY_CalendarExtensions)

@property (nonatomic) CGFloat tfyCa_width;
@property (nonatomic) CGFloat tfyCa_height;

@property (nonatomic) CGFloat tfyCa_top;
@property (nonatomic) CGFloat tfyCa_left;
@property (nonatomic) CGFloat tfyCa_bottom;
@property (nonatomic) CGFloat tfyCa_right;

@end


@interface NSCalendar (TFY_CalendarExtensions)

- (nullable NSDate *)tfyCa_firstDayOfMonth:(NSDate *)month NS_SWIFT_NAME(firstDay(ofMonth:));
- (nullable NSDate *)tfyCa_lastDayOfMonth:(NSDate *)month NS_SWIFT_NAME(lastDay(ofMonth:));
- (nullable NSDate *)tfyCa_firstDayOfWeek:(NSDate *)week NS_SWIFT_NAME(firstDay(ofWeek:));
- (nullable NSDate *)tfyCa_lastDayOfWeek:(NSDate *)week NS_SWIFT_NAME(lastDay(ofWeek:));
- (nullable NSDate *)tfyCa_middleDayOfWeek:(NSDate *)week NS_SWIFT_NAME(middleDay(ofWeek:));
- (NSInteger)tfyCa_numberOfDaysInMonth:(NSDate *)month NS_SWIFT_NAME(numberOfDays(inMonth:));

@end

@interface NSDate (ZbCalendarExtensions)
/**当前日期加几年*/
- (NSDate *)tfyCa_dateByAddingYears:(NSInteger)years NS_SWIFT_NAME(date(byAddingYears:));
/**当前日期减几年*/
- (NSDate *)tfyCa_dateByMinusYears:(NSInteger)years NS_SWIFT_NAME(date(byMinusYears:));
/**当前日期加几月*/
- (NSDate *)tfyCa_dateByAddingMonths:(NSInteger)months NS_SWIFT_NAME(date(byAddingMonths:));
/**当前日期减几月*/
- (NSDate *)tfyCa_dateByMinusMonths:(NSInteger)months NS_SWIFT_NAME(date(byMinusMonths:));
/**当前日期加几周*/
- (NSDate *)tfyCa_dateByAddingWeeks:(NSInteger)weeks NS_SWIFT_NAME(date(byAddingWeeks:));
/**当前日期减几周*/
- (NSDate *)tfyCa_dateByMinusWeeks:(NSInteger)weeks NS_SWIFT_NAME(date(byMinusWeeks:));
/**当前日期加几天*/
- (NSDate *)tfyCa_dateByAddingDays:(NSInteger)days NS_SWIFT_NAME(date(byAddingDays:));
/**当前日期减几天*/
- (NSDate *)tfyCa_dateByMinusDays:(NSInteger)days NS_SWIFT_NAME(date(byMinusDays:));
/**当前日期加几小时*/
- (NSDate *)tfyCa_dateByAddingHours:(NSInteger)hours NS_SWIFT_NAME(date(byAddingHours:));
/**当前日期减几小时*/
- (NSDate *)tfyCa_dateByMinusHours:(NSInteger)hours NS_SWIFT_NAME(date(byMinusHours:));
/**当前日期加几分钟*/
- (NSDate *)tfyCa_dateByAddingMinutes:(NSInteger)minutes NS_SWIFT_NAME(date(byAddingMinutes:));
/**当前日期减几分钟*/
- (NSDate *)tfyCa_dateByMinusMinutes:(NSInteger)minutes NS_SWIFT_NAME(date(byMinusMinutes:));
/**当前日期加几秒*/
- (NSDate *)tfyCa_dateByAddingSeconds:(NSInteger)seconds NS_SWIFT_NAME(date(byAddingSeconds:));
/***当前日期减几秒*/
- (NSDate *)tfyCa_dateByMinusSeconds:(NSInteger)seconds NS_SWIFT_NAME(date(byMinusSeconds:));
/**将字符串转成NSDate类型 yyyy-MM-dd */
+ (NSDate *)tfyCa_dateWithString:(NSString *)string format:(NSString *)format NS_SWIFT_NAME(date(withString:format:));

@end

@interface NSMapTable (TFY_CalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@end

@interface NSCache (TFY_CalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@end


@interface NSObject (TFY_CalendarExtensions)

#define IVAR_DEF(SET,GET,TYPE) \
- (void)tfyCa_set##SET##Variable:(TYPE)value forKey:(NSString *)key; \
- (TYPE)tfyCa_##GET##VariableForKey:(NSString *)key;
IVAR_DEF(Bool, bool, BOOL)
IVAR_DEF(Float, float, CGFloat)
IVAR_DEF(Integer, integer, NSInteger)
IVAR_DEF(UnsignedInteger, unsignedInteger, NSUInteger)
#undef IVAR_DEF

- (void)tfyCa_setVariable:(id)variable forKey:(NSString *)key NS_SWIFT_NAME(setVariable(_:forKey:));
- (id)tfyCa_variableForKey:(NSString *)key NS_SWIFT_NAME(variable(forKey:));

- (nullable id)tfyCa_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_NAME(performSelector(_:withObjects:));

@end


NS_ASSUME_NONNULL_END
