//
//  TFY_CalendarAppearance.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarAppearance.h"
#import "TFY_CalendarDynamic.h"
#import "TFY_CalendarExtensions.h"

@interface TFY_CalendarAppearance ()
@property (weak  , nonatomic) TFY_Calendar *calendar;

@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;
@property (strong, nonatomic) NSMutableDictionary *borderColors;
@end

@implementation TFY_CalendarAppearance
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _titleFont = [UIFont systemFontOfSize:TFYCa_CalendarStandardTitleTextSize];
        _subtitleFont = [UIFont systemFontOfSize:TFYCa_CalendarStandardSubtitleTextSize];
        _weekdayFont = [UIFont systemFontOfSize:TFYCa_CalendarStandardWeekdayTextSize];
        _headerTitleFont = [UIFont systemFontOfSize:TFYCa_CalendarStandardHeaderTextSize];
        _contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        _headerTitleColor = TFYCa_CalendarStandardTitleTextColor;
        _headerDateFormat = @"yyyy年MM月";
        _headerMinimumDissolvedAlpha = 0.2;
        _weekdayTextColor = TFYCa_CalendarStandardTitleTextColor;
        _caseOptions = TFYCa_CalendarCaseOptionsHeaderUsesDefaultCase|TFYCa_CalendarCaseOptionsWeekdayUsesDefaultCase;
        
        _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _backgroundColors[@(TFYCa_CalendarCellStateNormal)]      = [UIColor clearColor];
        _backgroundColors[@(TFYCa_CalendarCellStateSelected)]    = TFYCa_CalendarStandardSelectionColor;
        _backgroundColors[@(TFYCa_CalendarCellStateDisabled)]    = [UIColor clearColor];
        _backgroundColors[@(TFYCa_CalendarCellStatePlaceholder)] = [UIColor clearColor];
        _backgroundColors[@(TFYCa_CalendarCellStateToday)]       = TFYCa_CalendarStandardTodayColor;
        
        _titleColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _titleColors[@(TFYCa_CalendarCellStateNormal)]      = [UIColor blackColor];
        _titleColors[@(TFYCa_CalendarCellStateSelected)]    = [UIColor whiteColor];
        _titleColors[@(TFYCa_CalendarCellStateDisabled)]    = [UIColor grayColor];
        _titleColors[@(TFYCa_CalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _titleColors[@(TFYCa_CalendarCellStateToday)]       = [UIColor whiteColor];
        
        _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _subtitleColors[@(TFYCa_CalendarCellStateNormal)]      = [UIColor darkGrayColor];
        _subtitleColors[@(TFYCa_CalendarCellStateSelected)]    = [UIColor whiteColor];
        _subtitleColors[@(TFYCa_CalendarCellStateDisabled)]    = [UIColor lightGrayColor];
        _subtitleColors[@(TFYCa_CalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _subtitleColors[@(TFYCa_CalendarCellStateToday)]       = [UIColor whiteColor];
        
        _borderColors[@(TFYCa_CalendarCellStateSelected)] = [UIColor clearColor];
        _borderColors[@(TFYCa_CalendarCellStateNormal)] = [UIColor clearColor];
        
        _borderRadius = 1.0;
        _eventDefaultColor = TFYCa_CalendarStandardEventDotColor;
        _eventSelectionColor = TFYCa_CalendarStandardEventDotColor;
        
        _borderColors = [NSMutableDictionary dictionaryWithCapacity:2];
        
#if TARGET_INTERFACE_BUILDER
        _fakeEventDots = YES;
#endif
        
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (![_titleFont isEqual:titleFont]) {
        _titleFont = titleFont;
        [self.calendar configureAppearance];
    }
}

- (void)setSubtitleFont:(UIFont *)subtitleFont
{
    if (![_subtitleFont isEqual:subtitleFont]) {
        _subtitleFont = subtitleFont;
        [self.calendar configureAppearance];
    }
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    if (![_weekdayFont isEqual:weekdayFont]) {
        _weekdayFont = weekdayFont;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderTitleFont:(UIFont *)headerTitleFont
{
    if (![_headerTitleFont isEqual:headerTitleFont]) {
        _headerTitleFont = headerTitleFont;
        [self.calendar configureAppearance];
    }
}

- (void)setTitleOffset:(CGPoint)titleOffset
{
    if (!CGPointEqualToPoint(_titleOffset, titleOffset)) {
        _titleOffset = titleOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setSubtitleOffset:(CGPoint)subtitleOffset
{
    if (!CGPointEqualToPoint(_subtitleOffset, subtitleOffset)) {
        _subtitleOffset = subtitleOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setImageOffset:(CGPoint)imageOffset
{
    if (!CGPointEqualToPoint(_imageOffset, imageOffset)) {
        _imageOffset = imageOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setEventOffset:(CGPoint)eventOffset
{
    if (!CGPointEqualToPoint(_eventOffset, eventOffset)) {
        _eventOffset = eventOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(TFYCa_CalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(TFYCa_CalendarCellStateNormal)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleDefaultColor
{
    return _titleColors[@(TFYCa_CalendarCellStateNormal)];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(TFYCa_CalendarCellStateSelected)] = color;
    } else {
        [_titleColors removeObjectForKey:@(TFYCa_CalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleSelectionColor
{
    return _titleColors[@(TFYCa_CalendarCellStateSelected)];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(TFYCa_CalendarCellStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(TFYCa_CalendarCellStateToday)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleTodayColor
{
    return _titleColors[@(TFYCa_CalendarCellStateToday)];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(TFYCa_CalendarCellStatePlaceholder)] = color;
    } else {
        [_titleColors removeObjectForKey:@(TFYCa_CalendarCellStatePlaceholder)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titlePlaceholderColor
{
    return _titleColors[@(TFYCa_CalendarCellStatePlaceholder)];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(TFYCa_CalendarCellStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(TFYCa_CalendarCellStateWeekend)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleWeekendColor
{
    return _titleColors[@(TFYCa_CalendarCellStateWeekend)];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(TFYCa_CalendarCellStateNormal)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(TFYCa_CalendarCellStateNormal)];
    }
    [self.calendar configureAppearance];
}

-(UIColor *)subtitleDefaultColor
{
    return _subtitleColors[@(TFYCa_CalendarCellStateNormal)];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(TFYCa_CalendarCellStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(TFYCa_CalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitleSelectionColor
{
    return _subtitleColors[@(TFYCa_CalendarCellStateSelected)];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(TFYCa_CalendarCellStateToday)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(TFYCa_CalendarCellStateToday)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitleTodayColor
{
    return _subtitleColors[@(TFYCa_CalendarCellStateToday)];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(TFYCa_CalendarCellStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(TFYCa_CalendarCellStatePlaceholder)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitlePlaceholderColor
{
    return _subtitleColors[@(TFYCa_CalendarCellStatePlaceholder)];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(TFYCa_CalendarCellStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(TFYCa_CalendarCellStateWeekend)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitleWeekendColor
{
    return _subtitleColors[@(TFYCa_CalendarCellStateWeekend)];
}

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(TFYCa_CalendarCellStateSelected)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(TFYCa_CalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)selectionColor
{
    return _backgroundColors[@(TFYCa_CalendarCellStateSelected)];
}

- (void)setTodayColor:(UIColor *)todayColor
{
    if (todayColor) {
        _backgroundColors[@(TFYCa_CalendarCellStateToday)] = todayColor;
    } else {
        [_backgroundColors removeObjectForKey:@(TFYCa_CalendarCellStateToday)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)todayColor
{
    return _backgroundColors[@(TFYCa_CalendarCellStateToday)];
}

- (void)setTodaySelectionColor:(UIColor *)todaySelectionColor
{
    if (todaySelectionColor) {
        _backgroundColors[@(TFYCa_CalendarCellStateToday|TFYCa_CalendarCellStateSelected)] = todaySelectionColor;
    } else {
        [_backgroundColors removeObjectForKey:@(TFYCa_CalendarCellStateToday|TFYCa_CalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)todaySelectionColor
{
    return _backgroundColors[@(TFYCa_CalendarCellStateToday|TFYCa_CalendarCellStateSelected)];
}

- (void)setEventDefaultColor:(UIColor *)eventDefaultColor
{
    if (![_eventDefaultColor isEqual:eventDefaultColor]) {
        _eventDefaultColor = eventDefaultColor;
        [self.calendar configureAppearance];
    }
}

- (void)setBorderDefaultColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(TFYCa_CalendarCellStateNormal)] = color;
    } else {
        [_borderColors removeObjectForKey:@(TFYCa_CalendarCellStateNormal)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)borderDefaultColor
{
    return _borderColors[@(TFYCa_CalendarCellStateNormal)];
}

- (void)setBorderSelectionColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(TFYCa_CalendarCellStateSelected)] = color;
    } else {
        [_borderColors removeObjectForKey:@(TFYCa_CalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)borderSelectionColor
{
    return _borderColors[@(TFYCa_CalendarCellStateSelected)];
}

- (void)setBorderRadius:(CGFloat)borderRadius
{
    borderRadius = MAX(0.0, borderRadius);
    borderRadius = MIN(1.0, borderRadius);
    if (_borderRadius != borderRadius) {
        _borderRadius = borderRadius;
        [self.calendar configureAppearance];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderMinimumDissolvedAlpha:(CGFloat)headerMinimumDissolvedAlpha
{
    if (_headerMinimumDissolvedAlpha != headerMinimumDissolvedAlpha) {
        _headerMinimumDissolvedAlpha = headerMinimumDissolvedAlpha;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderDateFormat:(NSString *)headerDateFormat
{
    if (![_headerDateFormat isEqual:headerDateFormat]) {
        _headerDateFormat = headerDateFormat;
        [self.calendar configureAppearance];
    }
}

- (void)setCaseOptions:(TFYCa_CalendarCaseOptions)caseOptions
{
    if (_caseOptions != caseOptions) {
        _caseOptions = caseOptions;
        [self.calendar configureAppearance];
    }
}

- (void)setSeparators:(TFYCa_CalendarSeparators)separators
{
    if (_separators != separators) {
        _separators = separators;
        [_calendar.collectionView.collectionViewLayout invalidateLayout];
    }
}

@end


@implementation TFY_CalendarAppearance (Deprecated)

- (void)setUseVeryShortWeekdaySymbols:(BOOL)useVeryShortWeekdaySymbols
{
    _caseOptions &= 15;
    self.caseOptions |= (useVeryShortWeekdaySymbols*TFYCa_CalendarCaseOptionsWeekdayUsesSingleUpperCase);
}

- (BOOL)useVeryShortWeekdaySymbols
{
    return (_caseOptions & (15<<4) ) == TFYCa_CalendarCaseOptionsWeekdayUsesSingleUpperCase;
}

- (void)setTitleVerticalOffset:(CGFloat)titleVerticalOffset
{
    self.titleOffset = CGPointMake(0, titleVerticalOffset);
}

- (CGFloat)titleVerticalOffset
{
    return self.titleOffset.y;
}

- (void)setSubtitleVerticalOffset:(CGFloat)subtitleVerticalOffset
{
    self.subtitleOffset = CGPointMake(0, subtitleVerticalOffset);
}

- (CGFloat)subtitleVerticalOffset
{
    return self.subtitleOffset.y;
}

- (void)setEventColor:(UIColor *)eventColor
{
    self.eventDefaultColor = eventColor;
}

- (UIColor *)eventColor
{
    return self.eventDefaultColor;
}

- (void)setTitleTextSize:(CGFloat)titleTextSize
{
    self.titleFont = [self.titleFont fontWithSize:titleTextSize];
}

- (void)setSubtitleTextSize:(CGFloat)subtitleTextSize
{
    self.subtitleFont = [self.subtitleFont fontWithSize:subtitleTextSize];
}

- (void)setWeekdayTextSize:(CGFloat)weekdayTextSize
{
    self.weekdayFont = [self.weekdayFont fontWithSize:weekdayTextSize];
}

- (void)setHeaderTitleTextSize:(CGFloat)headerTitleTextSize
{
    self.headerTitleFont = [self.headerTitleFont fontWithSize:headerTitleTextSize];
}

- (void)invalidateAppearance
{
    [self.calendar configureAppearance];
}

@end
