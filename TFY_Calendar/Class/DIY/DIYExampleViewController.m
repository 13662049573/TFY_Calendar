//
//  DIYExampleViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "DIYExampleViewController.h"
#import <EventKit/EventKit.h>

@interface DIYExampleViewController () <TFYCa_CalendarDataSource,TFYCa_CalendarDelegate,TFYCa_CalendarDelegateAppearance>

@property (weak, nonatomic) TFY_Calendar *calendar;

@property (weak, nonatomic) UILabel *eventLabel;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) BOOL showsLunar;
@property (assign, nonatomic) BOOL showsEvents;
@property (strong, nonatomic) NSCache *cache;
@property (strong, nonatomic) NSDate *minimumDate;
@property (strong, nonatomic) NSDate *maximumDate;
@property (strong, nonatomic) TFY_LunarFormatter *lunarFormatter;
@property (strong, nonatomic) NSArray<EKEvent *> *events;

@end

@implementation DIYExampleViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"日历";
         _lunarFormatter = [[TFY_LunarFormatter alloc] init];
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0,  0, view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    calendar.calendarHeaderView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    calendar.calendarWeekdayView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:1];
    calendar.appearance.eventSelectionColor = [UIColor whiteColor];
    calendar.today = nil; // Hide the today circle
    [view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.minimumDate = [self.dateFormatter dateFromString:@"2025-02-03"];
    self.maximumDate = [self.dateFormatter dateFromString:@"2029-12-30"];
    
    [self loadCalendarEvents];
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(todayItemClicked:)];
    
    UIBarButtonItem *lunarItem = [[UIBarButtonItem alloc] initWithTitle:@"农历" style:UIBarButtonItemStylePlain target:self action:@selector(lunarItemClicked:)];
    [lunarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor magentaColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *eventItem = [[UIBarButtonItem alloc] initWithTitle:@"事件" style:UIBarButtonItemStylePlain target:self action:@selector(eventItemClicked:)];
    [eventItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]} forState:UIControlStateNormal];
    

    self.navigationItem.rightBarButtonItems = @[eventItem ,lunarItem, todayItem];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.cache removeAllObjects];
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)todayItemClicked:(id)sender
{
    [self.calendar setCurrentPage:[NSDate date] animated:YES];
}

- (void)lunarItemClicked:(UIBarButtonItem *)item
{
    self.showsLunar = !self.showsLunar;
    [self.calendar reloadData];
}

- (void)eventItemClicked:(id)sender
{
    self.showsEvents = !self.showsEvents;
    [self.calendar reloadData];
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(TFY_Calendar *)calendar
{
    return self.minimumDate;
}

- (NSDate *)maximumDateForCalendar:(TFY_Calendar *)calendar
{
    return self.maximumDate;
}

- (NSString *)calendar:(TFY_Calendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (NSString *)calendar:(TFY_Calendar *)calendar subtitleForDate:(NSDate *)date
{
    if (self.showsEvents) {
        EKEvent *event = [self eventsForDate:date].firstObject;
        if (event) {
            return event.title;
        }
    }
    if (self.showsLunar) {
        return [self.lunarFormatter stringFromDate:date];
    }
    return nil;
}

- (NSInteger)calendar:(TFY_Calendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if (!self.showsEvents) return 0;
    if (!self.events) return 0;
    NSArray<EKEvent *> *events = [self eventsForDate:date];
    return events.count;
}

#pragma mark - CalendarDelegate

- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance fillSelectionColorForDate:(NSDate *_Nonnull)date {
    return UIColor.orangeColor;
}

- (TFYCa_CellfillType)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance fillTypeForDate:(NSDate *_Nonnull)date {
    return TFYCa_CellfillTypeLinkage;
}

#pragma mark - Private methods

- (void)loadCalendarEvents
{
    __weak typeof(self) weakSelf = self;
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if(granted) {
            NSDate *startDate = self.minimumDate;
            NSDate *endDate = self.maximumDate;
            NSPredicate *fetchCalendarEvents = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
            NSArray<EKEvent *> *eventList = [store eventsMatchingPredicate:fetchCalendarEvents];
            NSArray<EKEvent *> *events = [eventList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable event, NSDictionary<NSString *,id> * _Nullable bindings) {
                return event.calendar.subscribed;
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf) return;
                weakSelf.events = events;
                [weakSelf.calendar reloadData];
            });
            
        } else {
            
            // Alert
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Permission Error" message:@"Permission of calendar is required for fetching events." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

- (NSArray<EKEvent *> *)eventsForDate:(NSDate *)date
{
    NSArray<EKEvent *> *events = [self.cache objectForKey:date];
    if ([events isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSArray<EKEvent *> *filteredEvents = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.occurrenceDate isEqualToDate:date];
    }]];
    if (filteredEvents.count) {
        [self.cache setObject:filteredEvents forKey:date];
    } else {
        [self.cache setObject:[NSNull null] forKey:date];
    }
    return filteredEvents;
}

@end
