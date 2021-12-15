//
//  RollViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2021/12/1.
//  Copyright © 2021 田风有. All rights reserved.
//

#import "DelegateAppearanceViewController.h"

#define kViolet [UIColor colorWithRed:170/255.0 green:114/255.0 blue:219/255.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@interface DelegateAppearanceViewController()<TFYCa_CalendarDataSource,TFYCa_CalendarDelegate,TFYCa_CalendarDelegateAppearance>

@property (weak, nonatomic) TFY_Calendar *calendar;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter1;
@property (strong, nonatomic) NSDateFormatter *dateFormatter2;

@property (strong, nonatomic) NSDictionary *fillSelectionColors;
@property (strong, nonatomic) NSDictionary *fillDefaultColors;
@property (strong, nonatomic) NSDictionary *borderDefaultColors;
@property (strong, nonatomic) NSDictionary *borderSelectionColors;

@property (strong, nonatomic) NSDictionary *subtitleDefaultTexts;
@property (strong, nonatomic) NSDictionary *subToptitleDefaultTexts;

@property (strong, nonatomic) NSDictionary *subtitleDefaultColors;
@property (strong, nonatomic) NSDictionary *subtitleSelectionColors;
@property (strong, nonatomic) NSDictionary *subToptitleDefaultColors;
@property (strong, nonatomic) NSDictionary *subToptitleSelectionColors;


@property (strong, nonatomic) NSArray *datesWithEvent;
@property (strong, nonatomic) NSArray *datesWithMultipleEvents;

@end

NS_ASSUME_NONNULL_END

@implementation DelegateAppearanceViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"TFY_Calendar";
        //默认选择颜色
        self.fillDefaultColors = @{@"2021/11/28":[UIColor purpleColor],
                                     @"2021/11/29":[UIColor greenColor],
                                     @"2021/11/30":[UIColor cyanColor],
                                     @"2021/11/27":[UIColor yellowColor],
                                     @"2021/10/1":[UIColor purpleColor],
                                     @"2021/10/2":[UIColor greenColor],
                                     @"2021/10/3":[UIColor cyanColor],
                                     @"2021/10/4":[UIColor yellowColor],
                                     @"2021/10/5":[UIColor purpleColor],
                                     @"2021/10/6":[UIColor greenColor],
                                     @"2021/10/7":[UIColor cyanColor],
                                     @"2021/10/8":[UIColor magentaColor]};
        //点击效果颜色
        self.fillSelectionColors = @{@"2021/12/08":[UIColor redColor],
                                 @"2021/10/06":[UIColor purpleColor],
                                 @"2021/10/17":[UIColor grayColor],
                                 @"2021/10/21":[UIColor cyanColor],
                                 @"2021/11/08":[UIColor greenColor],
                                 @"2021/11/06":[UIColor purpleColor],
                                 @"2021/11/17":[UIColor grayColor],
                                 @"2021/11/21":[UIColor cyanColor],
                                 @"2021/12/06":[UIColor purpleColor],
                                 @"2021/12/17":[UIColor grayColor],
                                 @"2021/12/21":[UIColor cyanColor]};
        //默认圈颜色
        self.borderDefaultColors = @{@"2021/12/10":[UIColor brownColor],
                                     @"2021/10/17":[UIColor magentaColor],
                                     @"2021/10/21":TFYCa_CalendarStandardSelectionColor,
                                     @"2021/10/25":[UIColor blackColor],
                                     @"2021/11/08":[UIColor brownColor],
                                     @"2021/11/17":[UIColor magentaColor],
                                     @"2021/11/21":TFYCa_CalendarStandardSelectionColor,
                                     @"2021/11/25":[UIColor blackColor],
                                     @"2021/12/08":[UIColor brownColor],
                                     @"2021/12/17":[UIColor magentaColor],
                                     @"2021/12/21":TFYCa_CalendarStandardSelectionColor,
                                     @"2021/12/25":[UIColor blackColor]};
        //选择颜色
        self.borderSelectionColors = @{@"2021/12/11":[UIColor redColor],
                                       @"2021/10/17":[UIColor purpleColor],
                                       @"2021/10/21":TFYCa_CalendarStandardSelectionColor,
                                       @"2021/10/25":TFYCa_CalendarStandardTodayColor,
                                       @"2021/11/08":[UIColor redColor],
                                       @"2021/11/17":[UIColor purpleColor],
                                       @"2021/11/21":TFYCa_CalendarStandardSelectionColor,
                                       @"2021/11/25":TFYCa_CalendarStandardTodayColor,
                                       @"2021/12/08":[UIColor redColor],
                                       @"2021/12/17":[UIColor purpleColor],
                                       @"2021/12/21":TFYCa_CalendarStandardSelectionColor,
                                       @"2021/12/25":TFYCa_CalendarStandardTodayColor};
        
        //日历下标一个点
        self.datesWithEvent = @[@"2021-12-03",
                            @"2021-12-04",
                            @"2021-12-05",
                            @"2021-12-06"];
        //日历下标三个个点
        self.datesWithMultipleEvents = @[@"2021-12-26",
                                     @"2021-12-27",
                                     @"2021-12-28",
                                     @"2021-12-29"];
        
        
        
        self.subtitleDefaultTexts = @{@"2021/12/08":@"上午",
                                 @"2021/10/06":@"晚上",
                                 @"2021/10/17":@"中午",
                                 @"2021/10/21":@"全天",
                                 @"2021/11/08":@"上午",
                                 @"2021/11/06":@"上午",
                                 @"2021/11/17":@"下午",
                                 @"2021/11/21":@"中午",
                                 @"2021/12/06":@"晚上",
                                 @"2021/12/17":@"中午",
                                 @"2021/12/21":@"下午"};
        
        self.subToptitleDefaultTexts = @{@"2021/12/08":@"上午",
                                 @"2021/10/06":@"晚上",
                                 @"2021/10/17":@"中午",
                                 @"2021/10/21":@"全天",
                                 @"2021/11/08":@"上午",
                                 @"2021/11/06":@"上午",
                                 @"2021/11/17":@"下午",
                                 @"2021/11/21":@"中午",
                                 @"2021/12/06":@"晚上",
                                 @"2021/12/17":@"中午",
                                 @"2021/12/21":@"下午"};
        
        
        self.subtitleDefaultColors = @{@"2021/11/28":[UIColor purpleColor],
                                     @"2021/11/29":[UIColor greenColor],
                                     @"2021/11/30":[UIColor cyanColor],
                                     @"2021/11/27":[UIColor yellowColor],
                                     @"2021/10/1":[UIColor purpleColor],
                                     @"2021/10/2":[UIColor greenColor],
                                     @"2021/10/3":[UIColor cyanColor],
                                     @"2021/10/4":[UIColor yellowColor],
                                     @"2021/10/5":[UIColor purpleColor],
                                     @"2021/10/6":[UIColor greenColor],
                                     @"2021/10/7":[UIColor cyanColor],
                                     @"2021/10/8":[UIColor magentaColor]};
        //点击效果颜色
        self.subToptitleDefaultColors = @{@"2021/12/08":[UIColor redColor],
                                 @"2021/10/06":[UIColor purpleColor],
                                 @"2021/10/17":[UIColor grayColor],
                                 @"2021/10/21":[UIColor cyanColor],
                                 @"2021/11/08":[UIColor greenColor],
                                 @"2021/11/06":[UIColor purpleColor],
                                 @"2021/11/17":[UIColor grayColor],
                                 @"2021/11/21":[UIColor cyanColor],
                                 @"2021/12/06":[UIColor purpleColor],
                                 @"2021/12/17":[UIColor grayColor],
                                 @"2021/12/21":[UIColor cyanColor]};
        
        
        //默认圈颜色
        self.subtitleSelectionColors = @{@"2021/12/10":[UIColor brownColor],
                                     @"2021/10/17":[UIColor magentaColor],
                                     @"2021/10/21":TFYCa_CalendarStandardSelectionColor,
                                     @"2021/10/25":[UIColor blackColor],
                                     @"2021/11/08":[UIColor brownColor],
                                     @"2021/11/17":[UIColor magentaColor],
                                     @"2021/11/21":TFYCa_CalendarStandardSelectionColor,
                                     @"2021/11/25":[UIColor blackColor],
                                     @"2021/12/08":[UIColor brownColor],
                                     @"2021/12/17":[UIColor magentaColor],
                                     @"2021/12/21":TFYCa_CalendarStandardSelectionColor,
                                     @"2021/12/25":[UIColor blackColor]};
        //选择颜色
        self.subToptitleSelectionColors = @{@"2021/12/11":[UIColor redColor],
                                       @"2021/10/17":[UIColor purpleColor],
                                       @"2021/10/21":TFYCa_CalendarStandardSelectionColor,
                                       @"2021/10/25":TFYCa_CalendarStandardTodayColor,
                                       @"2021/11/08":[UIColor redColor],
                                       @"2021/11/17":[UIColor purpleColor],
                                       @"2021/11/21":TFYCa_CalendarStandardSelectionColor,
                                       @"2021/11/25":TFYCa_CalendarStandardTodayColor,
                                       @"2021/12/08":[UIColor redColor],
                                       @"2021/12/17":[UIColor purpleColor],
                                       @"2021/12/21":TFYCa_CalendarStandardSelectionColor,
                                       @"2021/12/25":TFYCa_CalendarStandardTodayColor};
        
        
        self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        self.dateFormatter1 = [[NSDateFormatter alloc] init];
        self.dateFormatter1.dateFormat = @"yyyy/MM/dd";
        
        self.dateFormatter2 = [[NSDateFormatter alloc] init];
        self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    calendar.appearance.headerDateFormat = @"yyyy-MM-dd";
    calendar.appearance.caseOptions = TFYCa_CalendarCaseOptionsHeaderUsesUpperCase|TFYCa_CalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    //跳转到指定w日期
    [calendar setCurrentPage:[self.dateFormatter1 dateFromString:@"2021/12/03"] animated:NO];
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(todayItemClicked:)];
    self.navigationItem.rightBarButtonItem = todayItem;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - 回到今天

- (void)todayItemClicked:(id)sender
{
    [_calendar setCurrentPage:[NSDate date] animated:NO];
}

#pragma mark - 日历下标小圆点个数 最多显示三个点

- (NSInteger)calendar:(TFY_Calendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter2 stringFromDate:date];
    if ([_datesWithEvent containsObject:dateString]) {
        return 1;
    }
    if ([_datesWithMultipleEvents containsObject:dateString]) {
        return 3;
    }
    return 0;
}

#pragma mark - <TFYCa_CalendarDelegateAppearance> 日历下标小圆点颜色组设置

- (NSArray *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter2 stringFromDate:date];
    if ([_datesWithMultipleEvents containsObject:dateString]) {
        return @[[UIColor magentaColor],appearance.eventDefaultColor,[UIColor blackColor]];
    }
    else if ([self.datesWithEvent containsObject:dateString]) {
        return @[[UIColor blueColor]];
    }
    return nil;
}



-  (nullable NSArray<UIColor *> *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance eventSelectionColorsForDate:(NSDate *)date{
    NSString *dateString = [self.dateFormatter2 stringFromDate:date];
    if ([_datesWithMultipleEvents containsObject:dateString]) {
        return @[[UIColor redColor],appearance.eventDefaultColor,[UIColor purpleColor]];
    }
    else if ([self.datesWithEvent containsObject:dateString]) {
        return @[[UIColor blackColor]];
    }
    return nil;
}

- (NSString *)calendar:(TFY_Calendar *)calendar subtitleForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([self.subtitleDefaultTexts.allKeys containsObject:key]) {
        return self.subtitleDefaultTexts[key];
    }
    return nil;
}

/// 开启上下加文字
- (NSString *)calendar:(TFY_Calendar *)calendar subToptitleDate:(NSDate *)date {
    
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([self.subToptitleDefaultTexts.allKeys containsObject:key]) {
        return self.subToptitleDefaultTexts[key];
    }
    return nil;
}

/**
 * 日期下面文字的默认颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subtitleDefaultColorForDate:(NSDate *_Nonnull)date {
    
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([self.subtitleDefaultColors.allKeys containsObject:key]) {
        return self.subtitleDefaultColors[key];
    }
    return nil;
}

/**
 * 日期上面文字的默认颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subToptitleDefaultColorForDate:(NSDate *_Nonnull)date {
    
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([self.subToptitleDefaultColors.allKeys containsObject:key]) {
        return self.subToptitleDefaultColors[key];
    }
    return nil;
}

/**
 * 日期下面文字的选中颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subtitleSelectionColorForDate:(NSDate *_Nonnull)date {
    
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([self.subtitleSelectionColors.allKeys containsObject:key]) {
        return self.subtitleSelectionColors[key];
    }
    return nil;
}


/**
 * 日期上面文字的选中颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subToptitleSelectionColorForDate:(NSDate *_Nonnull)date {
    
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([self.subToptitleSelectionColors.allKeys containsObject:key]) {
        return self.subToptitleSelectionColors[key];
    }
    return nil;
}


- (UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_fillSelectionColors.allKeys containsObject:key]) {
        return _fillSelectionColors[key];
    }
    return appearance.selectionColor;
}

- (UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_fillDefaultColors.allKeys containsObject:key]) {
        return _fillDefaultColors[key];
    }
    return nil;
}

- (UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_borderDefaultColors.allKeys containsObject:key]) {
        return _borderDefaultColors[key];
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_borderSelectionColors.allKeys containsObject:key]) {
        return _borderSelectionColors[key];
    }
    return appearance.borderSelectionColor;
}

- (CGFloat)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance borderRadiusForDate:(nonnull NSDate *)date
{
    if ([@[@8,@17,@21,@25] containsObject:@([self.gregorian component:NSCalendarUnitDay fromDate:date])]) {
        return 0.0;
    }
    return 1.0;
}

@end
