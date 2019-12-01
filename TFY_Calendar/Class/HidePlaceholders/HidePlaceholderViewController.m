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

- (void)nextClicked:(id)sender;
- (void)prevClicked:(id)sender;

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
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    // 400 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 400 : 300;
    TFY_Calendar *calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), height)];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.placeholderType = TFYCa_CalendarPlaceholderTypeNone;
    calendar.adjustsBoundingRectWhenChangingMonths = YES;
    calendar.currentPage = [self.dateFormatter dateFromString:@"2016-06-01"];
    calendar.firstWeekday = 2;
    calendar.scrollDirection = TFYCa_CalendarScrollDirectionVertical;
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
    return [self.dateFormatter dateFromString:@"2016-01-08"];
}

- (NSDate *)maximumDateForCalendar:(TFY_Calendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2018-10-08"];
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
