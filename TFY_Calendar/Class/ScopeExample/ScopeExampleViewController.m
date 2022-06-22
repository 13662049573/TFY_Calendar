//
//  ScopeExampleViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2022/6/21.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "ScopeExampleViewController.h"

@interface ScopeExampleViewController ()<UIGestureRecognizerDelegate,TFYCa_CalendarDataSource,TFYCa_CalendarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) TFY_Calendar *calendar;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIPanGestureRecognizer *scopeGesture;
@end

@implementation ScopeExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0, 0, TFY_Width_W(), 300)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.headerMinimumDissolvedAlpha = 0;
    calendar.appearance.caseOptions = TFYCa_CalendarCaseOptionsWeekdayUsesSingleUpperCase;
    calendar.appearance.headerDateFormat = @"yyyy年MM月";
    calendar.appearance.titleFont = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    calendar.appearance.todayColor = UIColor.redColor;
    calendar.appearance.selectionColor = UIColor.blueColor;
    calendar.appearance.headerTitleColor = UIColor.blackColor;
    calendar.appearance.headerTitleFont = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    calendar.appearance.weekdayTextColor = UIColor.greenColor;
    calendar.appearance.weekdayFont = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    calendar.placeholderType = TFYCa_CalendarPlaceholderTypeNone;
    calendar.scope = TFYCa_CalendarScopeWeek;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
    [self.calendar selectDate:[NSDate date] scrollToDate:YES];
   
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.calendar action:@selector(handleScopeGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGesture];
    self.scopeGesture = panGesture;
    
    [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
    
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, CGRectGetHeight(calendar.frame), TFY_Width_W(), TFY_Height_H() - TFY_kBottomBarHeight());
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.makeChain
        .delegate(self)
        .dataSource(self);
    }
    return _tableView;
}

#pragma mark - <UIGestureRecognizerDelegate>

// Whether scope gesture should begin
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top;
    if (shouldBegin) {
        CGPoint velocity = [self.scopeGesture velocityInView:self.view];
        switch (self.calendar.scope) {
            case TFYCa_CalendarScopeMonth:
                return velocity.y < 0;
            case TFYCa_CalendarScopeWeek:
                return velocity.y > 0;
        }
    }
    return shouldBegin;
}

#pragma mark - <FSCalendarDelegate>

- (void)calendar:(TFY_Calendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
     CGFloat constant = CGRectGetHeight(bounds);
     calendar.tfyCa_height = constant;
    self.tableView.tfyCa_top = constant;
     [self.view layoutIfNeeded];
}

- (void)calendar:(TFY_Calendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition {
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    NSMutableArray *selectedDates = [NSMutableArray arrayWithCapacity:calendar.selectedDates.count];
    [calendar.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedDates addObject:[NSDate tfy_stringWithDate:obj format:NSDate.tfy_ymdHmsFormat]];
    }];
    if (monthPosition == TFYCa_CalendarMonthPositionNext || monthPosition == TFYCa_CalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    NSLog(@"selected dates is %@",selectedDates);
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numbers[2] = {2,20};
    return numbers[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *identifier = @[@"cell_month",@"cell_week"][indexPath.row];
        UITableViewCell *cell = [UITableViewCell tfy_cellFromCodeWithTableView:tableView identifier:identifier];
        cell.textLabel.text = identifier;
        return cell;
    } else {
        UITableViewCell *cell = [UITableViewCell tfy_cellFromCodeWithTableView:tableView];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld--%ld",indexPath.row,indexPath.section];
        return cell;
    }
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        TFYCa_CalendarScope selectedScope = indexPath.row == 0 ? TFYCa_CalendarScopeMonth : TFYCa_CalendarScopeWeek;
        [self.calendar setScope:selectedScope animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


@end
