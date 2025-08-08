//
//  TFY_CalendarExtensions.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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

- (nullable NSDate *)tfyCa_firstDayOfMonth:(NSDate *)month TFY_CalendarSwiftName(firstDay(ofMonth:));
- (nullable NSDate *)tfyCa_lastDayOfMonth:(NSDate *)month TFY_CalendarSwiftName(lastDay(ofMonth:));
- (nullable NSDate *)tfyCa_firstDayOfWeek:(NSDate *)week TFY_CalendarSwiftName(firstDay(ofWeek:));
- (nullable NSDate *)tfyCa_lastDayOfWeek:(NSDate *)week TFY_CalendarSwiftName(lastDay(ofWeek:));
- (nullable NSDate *)tfyCa_middleDayOfWeek:(NSDate *)week TFY_CalendarSwiftName(middleDay(ofWeek:));
- (NSInteger)tfyCa_numberOfDaysInMonth:(NSDate *)month TFY_CalendarSwiftName(numberOfDays(inMonth:));

@end

@interface NSDate (ZbCalendarExtensions)
/**当前日期加几年*/
- (NSDate *)tfyCa_dateByAddingYears:(NSInteger)years TFY_CalendarSwiftName(date(byAddingYears:));
/**当前日期减几年*/
- (NSDate *)tfyCa_dateByMinusYears:(NSInteger)years TFY_CalendarSwiftName(date(byMinusYears:));
/**当前日期加几月*/
- (NSDate *)tfyCa_dateByAddingMonths:(NSInteger)months TFY_CalendarSwiftName(date(byAddingMonths:));
/**当前日期减几月*/
- (NSDate *)tfyCa_dateByMinusMonths:(NSInteger)months TFY_CalendarSwiftName(date(byMinusMonths:));
/**当前日期加几周*/
- (NSDate *)tfyCa_dateByAddingWeeks:(NSInteger)weeks TFY_CalendarSwiftName(date(byAddingWeeks:));
/**当前日期减几周*/
- (NSDate *)tfyCa_dateByMinusWeeks:(NSInteger)weeks TFY_CalendarSwiftName(date(byMinusWeeks:));
/**当前日期加几天*/
- (NSDate *)tfyCa_dateByAddingDays:(NSInteger)days TFY_CalendarSwiftName(date(byAddingDays:));
/**当前日期减几天*/
- (NSDate *)tfyCa_dateByMinusDays:(NSInteger)days TFY_CalendarSwiftName(date(byMinusDays:));
/**当前日期加几小时*/
- (NSDate *)tfyCa_dateByAddingHours:(NSInteger)hours TFY_CalendarSwiftName(date(byAddingHours:));
/**当前日期减几小时*/
- (NSDate *)tfyCa_dateByMinusHours:(NSInteger)hours TFY_CalendarSwiftName(date(byMinusHours:));
/**当前日期加几分钟*/
- (NSDate *)tfyCa_dateByAddingMinutes:(NSInteger)minutes TFY_CalendarSwiftName(date(byAddingMinutes:));
/**当前日期减几分钟*/
- (NSDate *)tfyCa_dateByMinusMinutes:(NSInteger)minutes TFY_CalendarSwiftName(date(byMinusMinutes:));
/**当前日期加几秒*/
- (NSDate *)tfyCa_dateByAddingSeconds:(NSInteger)seconds TFY_CalendarSwiftName(date(byAddingSeconds:));
/***当前日期减几秒*/
- (NSDate *)tfyCa_dateByMinusSeconds:(NSInteger)seconds TFY_CalendarSwiftName(date(byMinusSeconds:));
/**将字符串转成NSDate类型 yyyy-MM-dd */
+ (NSDate *)tfyCa_dateWithString:(NSString *)string format:(NSString *)format TFY_CalendarSwiftName(date(withString:format:));

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

- (void)tfyCa_setVariable:(id)variable forKey:(NSString *)key TFY_CalendarSwiftName(setVariable(_:forKey:));
- (id)tfyCa_variableForKey:(NSString *)key TFY_CalendarSwiftName(variable(forKey:));

- (nullable id)tfyCa_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ... NS_REQUIRES_NIL_TERMINATION TFY_CalendarSwiftName(performSelector(_:withObjects:));

@end


NS_ASSUME_NONNULL_END
