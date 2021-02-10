//
//  DIYExampleViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "DIYExampleViewController.h"
#import "DIYCalendarCell.h"
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
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0,  0, view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
//    calendar.swipeToChooseGesture.enabled = YES;
    calendar.allowsMultipleSelection = YES;
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    [view addSubview:calendar];
    self.calendar = calendar;
    
    calendar.calendarHeaderView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    calendar.calendarWeekdayView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:1];
    calendar.appearance.eventSelectionColor = [UIColor whiteColor];
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[DIYCalendarCell class] forCellReuseIdentifier:@"cell"];
    //需要滑动开启
//    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
//    [calendar addGestureRecognizer:scopeGesture];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor yellowColor];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:label];
    self.eventLabel = label;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    NSTextAttachment *attatchment = [[NSTextAttachment alloc] init];
    attatchment.image = [UIImage imageNamed:@"icon_cat"];
    attatchment.bounds = CGRectMake(0, -3, attatchment.image.size.width, attatchment.image.size.height);
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  嘿每日活动  "]];
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    self.eventLabel.attributedText = attributedText.copy;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.minimumDate = [self.dateFormatter dateFromString:@"2016-02-03"];
    self.maximumDate = [self.dateFormatter dateFromString:@"2021-04-10"];

    self.calendar.accessibilityIdentifier = @"calendar";
    
    [self loadCalendarEvents];
    //三个默认颜色选项
    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:[NSDate date] options:0] scrollToDate:NO];
    [self.calendar selectDate:[NSDate date] scrollToDate:NO];
    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate date] options:0] scrollToDate:NO];
    
    // 取消注释以执行“初始周范围”
     self.calendar.scope = TFYCa_CalendarScopeWeek;
    
   
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(todayItemClicked:)];
    
    UIBarButtonItem *lunarItem = [[UIBarButtonItem alloc] initWithTitle:@"农历" style:UIBarButtonItemStylePlain target:self action:@selector(lunarItemClicked:)];
    [lunarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor magentaColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *eventItem = [[UIBarButtonItem alloc] initWithTitle:@"事件" style:UIBarButtonItemStylePlain target:self action:@selector(eventItemClicked:)];
    [eventItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *toggle = [[UIBarButtonItem alloc] initWithTitle:@"展开/关闭" style:UIBarButtonItemStylePlain target:self action:@selector(toggleClicked:)];
    [toggle setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]} forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItems = @[eventItem ,lunarItem, todayItem,toggle];
    
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
- (void)toggleClicked:(id)sender
{
    if (self.calendar.scope == TFYCa_CalendarScopeMonth) {
        [self.calendar setScope:TFYCa_CalendarScopeWeek animated:YES];
    } else {
        [self.calendar setScope:TFYCa_CalendarScopeMonth animated:YES];
    }
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

- (TFY_CalendarCell *)calendar:(TFY_Calendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    DIYCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(TFY_Calendar *)calendar willDisplayCell:(TFY_CalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (TFYCa_CalendarMonthPosition)monthPosition
{
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (NSInteger)calendar:(TFY_Calendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if (!self.showsEvents) return 0;
    if (!self.events) return 0;
    NSArray<EKEvent *> *events = [self eventsForDate:date];
    return events.count;
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(TFY_Calendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    
    self.eventLabel.frame = CGRectMake(0, CGRectGetMaxY(calendar.frame)+10, self.view.frame.size.width, 50);
    
}

- (BOOL)calendar:(TFY_Calendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    return monthPosition == TFYCa_CalendarMonthPositionCurrent;
}

- (BOOL)calendar:(TFY_Calendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    return monthPosition == TFYCa_CalendarMonthPositionCurrent;
}

- (void)calendar:(TFY_Calendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    [self configureVisibleCells];
}

- (void)calendar:(TFY_Calendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    NSLog(@"did deselect date %@",[self.dateFormatter stringFromDate:date]);
    [self configureVisibleCells];
}

- (NSArray<UIColor *> *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

#pragma mark - Private methods

- (void)configureVisibleCells
{
    [self.calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof TFY_CalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.calendar dateForCell:obj];
        TFYCa_CalendarMonthPosition position = [self.calendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(TFY_CalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    
    DIYCalendarCell *diyCell = (DIYCalendarCell *)cell;
    
    // Custom today circle
    diyCell.circleImageView.hidden = ![self.gregorian isDateInToday:date];
    
    // Configure selection layer
    if (monthPosition == TFYCa_CalendarMonthPositionCurrent) {
        
        SelectionType selectionType = SelectionTypeNone;
        if ([self.calendar.selectedDates containsObject:date]) {
            NSDate *previousDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:date options:0];
            NSDate *nextDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
            if ([self.calendar.selectedDates containsObject:date]) {
                if ([self.calendar.selectedDates containsObject:previousDate] && [self.calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeMiddle;
                } else if ([self.calendar.selectedDates containsObject:previousDate] && [self.calendar.selectedDates containsObject:date]) {
                    selectionType = SelectionTypeRightBorder;
                } else if ([self.calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeLeftBorder;
                } else {
                    selectionType = SelectionTypeSingle;
                }
            }
        } else {
            selectionType = SelectionTypeNone;
        }
        
        if (selectionType == SelectionTypeNone) {
            diyCell.selectionLayer.hidden = YES;
            return;
        }
        
        diyCell.selectionLayer.hidden = NO;
        diyCell.selectionType = selectionType;
        
    } else {
        
        diyCell.circleImageView.hidden = YES;
        diyCell.selectionLayer.hidden = YES;
        
    }
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
