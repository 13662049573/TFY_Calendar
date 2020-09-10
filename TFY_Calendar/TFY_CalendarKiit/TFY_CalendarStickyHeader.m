//
//  TFY_CalendarStickyHeader.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarStickyHeader.h"
#import "TFY_Calendar.h"
#import "TFY_CalendarWeekdayView.h"
#import "TFY_CalendarExtensions.h"
#import "TFY_CalendarConstants.h"
#import "TFY_CalendarDynamic.h"

@interface TFY_CalendarStickyHeader ()
@property (weak  , nonatomic) UIView  *contentView;
@property (weak  , nonatomic) UIView  *bottomBorder;
@property (weak  , nonatomic) TFY_CalendarWeekdayView *weekdayView;
@end

@implementation TFY_CalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view;
        UILabel *label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        self.contentView = view;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_contentView addSubview:label];
        self.titleLabel = label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = TFYCa_CalendarStandardLineColor;
        [_contentView addSubview:view];
        self.bottomBorder = view;
        
        TFY_CalendarWeekdayView *weekdayView = [[TFY_CalendarWeekdayView alloc] init];
        [self.contentView addSubview:weekdayView];
        self.weekdayView = weekdayView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
    CGFloat weekdayHeight = _calendar.preferredWeekdayHeight;
    CGFloat weekdayMargin = weekdayHeight * 0.1;
    CGFloat titleWidth = _contentView.tfyCa_width;
    
    self.weekdayView.frame = CGRectMake(0, _contentView.tfyCa_height-weekdayHeight-weekdayMargin, self.contentView.tfyCa_width, weekdayHeight);
    
    CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:self.calendar.appearance.headerTitleFont}].height*1.5 + weekdayMargin*3;
    
    _bottomBorder.frame = CGRectMake(0, _contentView.tfyCa_height-weekdayHeight-weekdayMargin*2, _contentView.tfyCa_width, 1.0);
    _titleLabel.frame = CGRectMake(0, _bottomBorder.tfyCa_bottom-titleHeight-weekdayMargin, titleWidth,titleHeight);
    
}

#pragma mark - Properties

- (void)setCalendar:(TFY_Calendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _weekdayView.calendar = calendar;
        [self configureAppearance];
    }
}

#pragma mark - Private methods

- (void)configureAppearance
{
    _titleLabel.font = self.calendar.appearance.headerTitleFont;
    _titleLabel.textColor = self.calendar.appearance.headerTitleColor;
    [self.weekdayView configureAppearance];
}

- (void)setMonth:(NSDate *)month
{
    _month = month;
    _calendar.formatter.dateFormat = self.calendar.appearance.headerDateFormat;
    BOOL usesUpperCase = (self.calendar.appearance.caseOptions & 15) == TFYCa_CalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = [_calendar.formatter stringFromDate:_month];
    text = usesUpperCase ? text.uppercaseString : text;
    self.titleLabel.text = text;
}
@end
