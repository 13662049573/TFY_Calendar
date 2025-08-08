//
//  HidePlaceholderViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "HidePlaceholderViewController.h"

#define kContainerFrame (CGRectMake(0, CGRectGetMaxY(calendar.frame), CGRectGetWidth(self.view.frame), 50))

NS_ASSUME_NONNULL_BEGIN

@interface HidePlaceholderViewController()<TFYCa_CalendarDataSource,TFYCa_CalendarDelegate,TFYCa_CalendarDelegateAppearance>

@property (weak, nonatomic) TFY_Calendar *calendar;

@property (weak, nonatomic) UIView *bottomContainer;
@property (weak, nonatomic) UILabel *eventLabel;
@property (weak, nonatomic) UIButton *nextButton;
@property (weak, nonatomic) UIButton *prevButton;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

NS_ASSUME_NONNULL_END

@implementation HidePlaceholderViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"TFY_Calendar";
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

- (void)loadView
{
    UIView *view;
    UIButton *button;
    
    view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.view = view;
    
    // 400 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 400 : 350;
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.placeholderType = TFYCa_CalendarPlaceholderTypeFillHeadTail;
    calendar.adjustsBoundingRectWhenChangingMonths = YES;
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    calendar.scrollDirection = TFYCa_CalendarScrollDirectionVertical;
    calendar.appearance.caseOptions = TFYCa_CalendarCaseOptionsWeekdayUsesSingleUpperCase;
    calendar.calendarHeaderView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    calendar.appearance.weekdayTextColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    calendar.appearance.headerTitleColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
    calendar.appearance.headerDateFormat = @"yyyy-MM-dd";//内部特殊处理一下，必须这样传值，后期有需求可以更改
    calendar.appearance.swapplaces = TFYCa_CalendarSwapplacesWeekTop;
    calendar.appearance.liftrightSpacing = 15;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
    view = [[UIView alloc] initWithFrame:kContainerFrame];
    [self.view addSubview:view];
    self.bottomContainer = view;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 170, 50)];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.bottomContainer addSubview:label];
    self.eventLabel = label;
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(CGRectGetMaxX(self.eventLabel.frame)+5, 10, 60, 30);
    [button setTitle:@"上一个" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(prevClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1;
    button.layer.borderColor = button.tintColor.CGColor;
    button.layer.cornerRadius = 6;
    [self.bottomContainer addSubview:button];
    self.prevButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(CGRectGetMaxX(self.prevButton.frame)+5, 10, 60, 30);
    [button setTitle:@"下一个" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1;
    button.layer.borderColor = button.tintColor.CGColor;
    button.layer.cornerRadius = 6;
    [self.bottomContainer addSubview:button];
    self.nextButton = button;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    NSTextAttachment *attatchment = [[NSTextAttachment alloc] init];
    attatchment.image = [UIImage imageNamed:@"icon_cat"];
    attatchment.bounds = CGRectMake(0, -3, attatchment.image.size.width, attatchment.image.size.height);
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  Hey Daily Event  "]];
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    self.eventLabel.attributedText = attributedText.copy;
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.calendar.appearance.separators = TFYCa_CalendarSeparatorInterRows;
    self.calendar.swipeToChooseGesture.enabled = YES;
    
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
    
}

- (NSDate *)minimumDateForCalendar:(TFY_Calendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2025-01-08"];
}

- (NSDate *)maximumDateForCalendar:(TFY_Calendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2021-10-08"];
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - <FSCalendarDelegate>

- (void)calendar:(TFY_Calendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    self.bottomContainer.frame = kContainerFrame;
}

- (void)calendar:(TFY_CalendarHeaderView *)calendarHerderView DateButton:(UIButton *)titleBtn WeekButtonTitle:(NSString *)textString {
    
    titleBtn.backgroundColor = UIColor.yellowColor;
    titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}


#pragma mark - Target action

- (void)nextClicked:(id)sender
{
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:self.calendar.currentPage options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (void)prevClicked:(id)sender
{
    NSDate *prevMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:self.calendar.currentPage options:0];
    [self.calendar setCurrentPage:prevMonth animated:YES];
}


@end
