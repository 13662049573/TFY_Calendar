//
//  LoadViewExampleViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "LoadViewExampleViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoadViewExampleViewController()<TFYCa_CalendarDataSource,TFYCa_CalendarDelegate>

@property (weak, nonatomic) TFY_Calendar *calendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *images;

@end

NS_ASSUME_NONNULL_END

@implementation LoadViewExampleViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"TFY_Calendar";
        
        self.images = @{@"2022/03/11":[UIImage imageNamed:@"icon_cat"],
                        @"2022/03/13":[UIImage imageNamed:@"icon_footprint"],
                        @"2022/03/15":[UIImage imageNamed:@"icon_cat"],
                        @"2022/03/17":[UIImage imageNamed:@"icon_footprint"]};
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    // 450 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scrollDirection = TFYCa_CalendarScrollDirectionVertical;
    calendar.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:calendar];
    self.calendar = calendar;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    
    // [self.calendar selectDate:[self.dateFormatter dateFromString:@"2016/02/03"]];

    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.calendar setScope:FSCalendarScopeMonth animated:YES];
        });
    });
     */
    
    
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(TFY_Calendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    NSLog(@"should select date %@",[self.dateFormatter stringFromDate:date]);
    return YES;
}

- (void)calendar:(TFY_Calendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    if (monthPosition == TFYCa_CalendarMonthPositionNext || monthPosition == TFYCa_CalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
}

- (void)calendarCurrentPageDidChange:(TFY_Calendar *)calendar
{
    NSLog(@"did change to page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

- (void)calendar:(TFY_Calendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

#pragma mark - <FSCalendarDataSource>


- (NSDate *)minimumDateForCalendar:(TFY_Calendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2019/10/01"];
}

- (NSDate *)maximumDateForCalendar:(TFY_Calendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2030/10/10"];
}


- (UIImage *)calendar:(TFY_Calendar *)calendar imageForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return self.images[dateString];
}

- (UIImage *)calendar:(TFY_Calendar *)calendar imageTopForDate:(NSDate * _Nonnull)date
{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return self.images[dateString];
}

- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance imageTopOffsetForDate:(NSDate *_Nonnull)date {
    
    NSString *key = [self.dateFormatter stringFromDate:date];
    if ([self.images.allKeys containsObject:key]) {
        return CGPointMake(0, -10);
    }
    return CGPointMake(0, 0);
}
@end
