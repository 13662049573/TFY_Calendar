//
//  TFY_CalendarExtensions.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarExtensions.h"
#import <objc/runtime.h>

@implementation UIView (TFY_CalendarExtensions)

- (CGFloat)tfyCa_width
{
    return CGRectGetWidth(self.frame);
}


- (void)setTfyCa_width:(CGFloat)tfyCa_width
{
    self.frame = CGRectMake(self.tfyCa_left, self.tfyCa_top, tfyCa_width, self.tfyCa_height);
}

- (CGFloat)tfyCa_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setTfyCa_height:(CGFloat)tfyCa_height
{
    self.frame = CGRectMake(self.tfyCa_left, self.tfyCa_top, self.tfyCa_width, tfyCa_height);
}

- (CGFloat)tfyCa_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setTfyCa_top:(CGFloat)tfyCa_top
{
    self.frame = CGRectMake(self.tfyCa_left, tfyCa_top, self.tfyCa_width, self.tfyCa_height);
}

- (CGFloat)tfyCa_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setTfyCa_bottom:(CGFloat)tfyCa_bottom
{
    self.tfyCa_top = tfyCa_bottom - self.tfyCa_height;
}

- (CGFloat)tfyCa_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setTfyCa_left:(CGFloat)tfyCa_left
{
    self.frame = CGRectMake(tfyCa_left, self.tfyCa_top, self.tfyCa_width, self.tfyCa_height);
}

- (CGFloat)tfyCa_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setTfyCa_right:(CGFloat)tfyCa_right
{
    self.tfyCa_left = self.tfyCa_right - self.tfyCa_width;
}

@end


@implementation CALayer (TFY_CalendarExtensions)

- (CGFloat)tfyCa_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setTfyCa_width:(CGFloat)tfyCa_width
{
    self.frame = CGRectMake(self.tfyCa_left, self.tfyCa_top, tfyCa_width, self.tfyCa_height);
}

- (CGFloat)tfyCa_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setTfyCa_height:(CGFloat)tfyCa_height
{
    self.frame = CGRectMake(self.tfyCa_left, self.tfyCa_top, self.tfyCa_width, tfyCa_height);
}

- (CGFloat)tfyCa_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setTfyCa_top:(CGFloat)tfyCa_top
{
    self.frame = CGRectMake(self.tfyCa_left, tfyCa_top, self.tfyCa_width, self.tfyCa_height);
}

- (CGFloat)tfyCa_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setTfyCa_bottom:(CGFloat)tfyCa_bottom
{
    self.tfyCa_top = tfyCa_bottom - self.tfyCa_height;
}

- (CGFloat)tfyCa_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setTfyCa_left:(CGFloat)tfyCa_left
{
    self.frame = CGRectMake(tfyCa_left, self.tfyCa_top, self.tfyCa_width, self.tfyCa_height);
}

- (CGFloat)tfyCa_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setTfyCa_right:(CGFloat)tfyCa_right
{
    self.tfyCa_left = self.tfyCa_right - self.tfyCa_width;
}

@end

@interface NSCalendar (TFY_CalendarExtensionsPrivate)

@property (readonly, nonatomic) NSDateComponents *tfyCa_privateComponents;

@end

@implementation NSCalendar (TFY_CalendarExtensions)

- (nullable NSDate *)tfyCa_firstDayOfMonth:(NSDate *)month
{
    if (!month) return nil;
    NSDateComponents *components = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    components.day = 1;
    return [self dateFromComponents:components];
}

- (nullable NSDate *)tfyCa_lastDayOfMonth:(NSDate *)month
{
    if (!month) return nil;
    NSDateComponents *components = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    components.month++;
    components.day = 0;
    return [self dateFromComponents:components];
}

- (nullable NSDate *)tfyCa_firstDayOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.tfyCa_privateComponents;
    components.day = - (weekdayComponents.weekday - self.firstWeekday);
    components.day = (components.day-7) % 7;
    NSDate *firstDayOfWeek = [self dateByAddingComponents:components toDate:week options:0];
    firstDayOfWeek = [self dateBySettingHour:0 minute:0 second:0 ofDate:firstDayOfWeek options:0];
    components.day = NSIntegerMax;
    return firstDayOfWeek;
}

- (nullable NSDate *)tfyCa_lastDayOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.tfyCa_privateComponents;
    components.day = - (weekdayComponents.weekday - self.firstWeekday);
    components.day = (components.day-7) % 7 + 6;
    NSDate *lastDayOfWeek = [self dateByAddingComponents:components toDate:week options:0];
    lastDayOfWeek = [self dateBySettingHour:0 minute:0 second:0 ofDate:lastDayOfWeek options:0];
    components.day = NSIntegerMax;
    return lastDayOfWeek;
}

- (nullable NSDate *)tfyCa_middleDayOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *componentsToSubtract = self.tfyCa_privateComponents;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.firstWeekday) + 3;
    NSDate *middleDayOfWeek = [self dateByAddingComponents:componentsToSubtract toDate:week options:0];
    NSDateComponents *components = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:middleDayOfWeek];
    middleDayOfWeek = [self dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleDayOfWeek;
}

- (NSInteger)tfyCa_numberOfDaysInMonth:(NSDate *)month
{
    if (!month) return 0;
    NSRange days = [self rangeOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitMonth
                                       forDate:month];
    return days.length;
}

- (NSDateComponents *)tfyCa_privateComponents
{
    NSDateComponents *components = objc_getAssociatedObject(self, _cmd);
    if (!components) {
        components = [[NSDateComponents alloc] init];
        objc_setAssociatedObject(self, _cmd, components, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return components;
}

@end

@implementation NSDate (ZbCalendarExtensions)

- (NSDate *)tfyCa_dateByAddingYears:(NSInteger)years
{
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)tfyCa_dateByMinusYears:(NSInteger)years
{
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:-years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)tfyCa_dateByAddingMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)tfyCa_dateByMinusMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:-months];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)tfyCa_dateByAddingWeeks:(NSInteger)weeks
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:weeks];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)tfyCa_dateByMinusWeeks:(NSInteger)weeks
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:-weeks];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)tfyCa_dateByAddingDays:(NSInteger)days
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByMinusDays:(NSInteger)days
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByAddingHours:(NSInteger)hours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 3600 * hours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByMinusHours:(NSInteger)hours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - 3600 * hours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByAddingMinutes:(NSInteger)minutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 60 * minutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByMinusMinutes:(NSInteger)minutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - 60 * minutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByAddingSeconds:(NSInteger)seconds
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + seconds;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)tfyCa_dateByMinusSeconds:(NSInteger)seconds
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - seconds;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


@end



@implementation NSMapTable (TFY_CalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if (!key) return;
    
    if (obj) {
        [self setObject:obj forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self objectForKey:key];
}

@end

@implementation NSCache (TFY_CalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if (!key) return;
    
    if (obj) {
        [self setObject:obj forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self objectForKey:key];
}

@end

@implementation NSObject (TFY_CalendarExtensions)

#define IVAR_IMP(SET,GET,TYPE) \
- (void)tfyCa_set##SET##Variable:(TYPE)value forKey:(NSString *)key \
{ \
    Ivar ivar = class_getInstanceVariable([self class], key.UTF8String); \
    ((void (*)(id, Ivar, TYPE))object_setIvar)(self, ivar, value); \
} \
- (TYPE)tfyCa_##GET##VariableForKey:(NSString *)key \
{ \
    Ivar ivar = class_getInstanceVariable([self class], key.UTF8String); \
    ptrdiff_t offset = ivar_getOffset(ivar); \
    unsigned char *bytes = (unsigned char *)(__bridge void *)self; \
    TYPE value = *((TYPE *)(bytes+offset)); \
    return value; \
}
IVAR_IMP(Bool,bool,BOOL)
IVAR_IMP(Float,float,CGFloat)
IVAR_IMP(Integer,integer,NSInteger)
IVAR_IMP(UnsignedInteger,unsignedInteger,NSUInteger)
#undef IVAR_IMP

- (void)tfyCa_setVariable:(id)variable forKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable(self.class, key.UTF8String);
    object_setIvar(self, ivar, variable);
}

- (id)tfyCa_variableForKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable(self.class, key.UTF8String);
    id variable = object_getIvar(self, ivar);
    return variable;
}

- (id)tfyCa_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ...
{
    if (!selector) return nil;
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (!signature) return nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (!invocation) return nil;
    invocation.target = self;
    invocation.selector = selector;
    
    // Parameters
    if (firstObject) {
        int index = 2;
        va_list args;
        va_start(args, firstObject);
        if (firstObject) {
            id obj = firstObject;
            do {
                const char *argType = [signature getArgumentTypeAtIndex:index];
                if(!strcmp(argType, @encode(id))){
                    // object
                    [invocation setArgument:&obj atIndex:index++];
                } else {
                    NSString *argTypeString = [NSString stringWithUTF8String:argType];
                    if ([argTypeString hasPrefix:@"{"] && [argTypeString hasSuffix:@"}"]) {
                        // struct
#define PARAM_STRUCT_TYPES(_type,_getter,_default) \
if (!strcmp(argType, @encode(_type))) { \
    _type value = [obj respondsToSelector:@selector(_getter)]?[obj _getter]:_default; \
    [invocation setArgument:&value atIndex:index]; \
}
                        PARAM_STRUCT_TYPES(CGPoint, CGPointValue, CGPointZero)
                        PARAM_STRUCT_TYPES(CGSize, CGSizeValue, CGSizeZero)
                        PARAM_STRUCT_TYPES(CGRect, CGRectValue, CGRectZero)
                        PARAM_STRUCT_TYPES(CGAffineTransform, CGAffineTransformValue, CGAffineTransformIdentity)
                        PARAM_STRUCT_TYPES(CATransform3D, CATransform3DValue, CATransform3DIdentity)
                        PARAM_STRUCT_TYPES(CGVector, CGVectorValue, CGVectorMake(0, 0))
                        PARAM_STRUCT_TYPES(UIEdgeInsets, UIEdgeInsetsValue, UIEdgeInsetsZero)
                        PARAM_STRUCT_TYPES(UIOffset, UIOffsetValue, UIOffsetZero)
                        PARAM_STRUCT_TYPES(NSRange, rangeValue, NSMakeRange(NSNotFound, 0))
                        
#undef PARAM_STRUCT_TYPES
                        index++;
                    } else {
                        // basic type
#define PARAM_BASIC_TYPES(_type,_getter) \
if (!strcmp(argType, @encode(_type))) { \
    _type value = [obj respondsToSelector:@selector(_getter)]?[obj _getter]:0; \
    [invocation setArgument:&value atIndex:index]; \
}
                        PARAM_BASIC_TYPES(BOOL, boolValue)
                        PARAM_BASIC_TYPES(int, intValue)
                        PARAM_BASIC_TYPES(unsigned int, unsignedIntValue)
                        PARAM_BASIC_TYPES(char, charValue)
                        PARAM_BASIC_TYPES(unsigned char, unsignedCharValue)
                        PARAM_BASIC_TYPES(long, longValue)
                        PARAM_BASIC_TYPES(unsigned long, unsignedLongValue)
                        PARAM_BASIC_TYPES(long long, longLongValue)
                        PARAM_BASIC_TYPES(unsigned long long, unsignedLongLongValue)
                        PARAM_BASIC_TYPES(float, floatValue)
                        PARAM_BASIC_TYPES(double, doubleValue)
                        
#undef PARAM_BASIC_TYPES
                        index++;
                    }
                }
            } while((obj = va_arg(args, id)));
            
        }
        va_end(args);
        [invocation retainArguments];
    }
    
    // Execute
    [invocation invoke];
    
    // Return
    const char *returnType = signature.methodReturnType;
    NSUInteger length = [signature methodReturnLength];
    id returnValue;
    if (!strcmp(returnType, @encode(void))){
        // void
        returnValue = nil;
    } else if(!strcmp(returnType, @encode(id))){
        // id
        void *value;
        [invocation getReturnValue:&value];
        returnValue = (__bridge id)(value);
        return returnValue;
    } else {
        NSString *returnTypeString = [NSString stringWithUTF8String:returnType];
        if ([returnTypeString hasPrefix:@"{"] && [returnTypeString hasSuffix:@"}"]) {
            // struct
#define RETURN_STRUCT_TYPES(_type) \
if (!strcmp(returnType, @encode(_type))) { \
    _type value; \
    [invocation getReturnValue:&value]; \
    returnValue = [NSValue value:&value withObjCType:@encode(_type)]; \
}
            RETURN_STRUCT_TYPES(CGPoint)
            RETURN_STRUCT_TYPES(CGSize)
            RETURN_STRUCT_TYPES(CGRect)
            RETURN_STRUCT_TYPES(CGAffineTransform)
            RETURN_STRUCT_TYPES(CATransform3D)
            RETURN_STRUCT_TYPES(CGVector)
            RETURN_STRUCT_TYPES(UIEdgeInsets)
            RETURN_STRUCT_TYPES(UIOffset)
            RETURN_STRUCT_TYPES(NSRange)
            
#undef RETURN_STRUCT_TYPES
        } else {
            // basic
            void *buffer = (void *)malloc(length);
            [invocation getReturnValue:buffer];
#define RETURN_BASIC_TYPES(_type) \
    if (!strcmp(returnType, @encode(_type))) { \
    returnValue = @(*((_type*)buffer)); \
}
            RETURN_BASIC_TYPES(BOOL)
            RETURN_BASIC_TYPES(int)
            RETURN_BASIC_TYPES(unsigned int)
            RETURN_BASIC_TYPES(char)
            RETURN_BASIC_TYPES(unsigned char)
            RETURN_BASIC_TYPES(long)
            RETURN_BASIC_TYPES(unsigned long)
            RETURN_BASIC_TYPES(long long)
            RETURN_BASIC_TYPES(unsigned long long)
            RETURN_BASIC_TYPES(float)
            RETURN_BASIC_TYPES(double)
            
#undef RETURN_BASIC_TYPES
            free(buffer);
        }
    }
    return returnValue;
}

@end
