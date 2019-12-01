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

- (nullable NSDate *)tfyCa_firstDayOfMonth:(NSDate *)month;
- (nullable NSDate *)tfyCa_lastDayOfMonth:(NSDate *)month;
- (nullable NSDate *)tfyCa_firstDayOfWeek:(NSDate *)week;
- (nullable NSDate *)tfyCa_lastDayOfWeek:(NSDate *)week;
- (nullable NSDate *)tfyCa_middleDayOfWeek:(NSDate *)week;
- (NSInteger)tfyCa_numberOfDaysInMonth:(NSDate *)month;

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

- (void)tfyCa_setVariable:(id)variable forKey:(NSString *)key;
- (id)tfyCa_variableForKey:(NSString *)key;

- (nullable id)tfyCa_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end


NS_ASSUME_NONNULL_END
