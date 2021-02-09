//
//  TFY_Calendar.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_CalendarCell.h"
#import "TFY_CalendarAppearance.h"
#import "TFY_CalendarConstants.h"
#import "TFY_CalendarWeekdayView.h"
#import "TFY_CalendarCell.h"
#import "TFY_CalendarHeaderView.h"

//!TFYCa_Calendar的项目版本号。
FOUNDATION_EXPORT double TFYCa_CalendarVersionNumber;

//! TFYCa_Calendar的项目版本字符串。
FOUNDATION_EXPORT const unsigned char TFYCa_CalendarVersionString[];

typedef NS_ENUM(NSUInteger, TFYCa_CalendarScope) {
    TFYCa_CalendarScopeMonth,
    TFYCa_CalendarScopeWeek
};

typedef NS_ENUM(NSUInteger, TFYCa_CalendarScrollDirection) {
    TFYCa_CalendarScrollDirectionVertical,
    TFYCa_CalendarScrollDirectionHorizontal
};

typedef NS_ENUM(NSUInteger, TFYCa_CalendarPlaceholderType) {
    TFYCa_CalendarPlaceholderTypeNone          = 0,
    TFYCa_CalendarPlaceholderTypeFillHeadTail  = 1,
    TFYCa_CalendarPlaceholderTypeFillSixRows   = 2
};

typedef NS_ENUM(NSUInteger, TFYCa_CalendarMonthPosition) {
    TFYCa_CalendarMonthPositionPrevious,
    TFYCa_CalendarMonthPositionCurrent,
    TFYCa_CalendarMonthPositionNext,
    
    TFYCa_CalendarMonthPositionNotFound = NSNotFound
};

NS_ASSUME_NONNULL_BEGIN

@class TFY_Calendar;

/**
 * TFYCa_CalendarDataSource是TFY_Calendar的源集。基本角色是提供要显示的事件，字幕和最小/最大日期，或为日历定制日期单元。
 */
@protocol TFYCa_CalendarDataSource <NSObject>

@optional

/**
 * 向数据源询问特定日期的标题，以替换日期文本
 */
- (nullable NSString *)calendar:(TFY_Calendar *)calendar titleForDate:(NSDate *)date;

/**
 * 向数据源询问日期文本下特定日期的字幕。
 */
- (nullable NSString *)calendar:(TFY_Calendar *)calendar subtitleForDate:(NSDate *)date;

/**
 * 向数据源询问特定日期的图像。
 */
- (nullable UIImage *)calendar:(TFY_Calendar *)calendar imageForDate:(NSDate *)date;

/**
 * 要求dataSource显示的最小日期。
 */
- (NSDate *)minimumDateForCalendar:(TFY_Calendar *)calendar;

/**
 * 要求dataSource显示的最大日期。
 */
- (NSDate *)maximumDateForCalendar:(TFY_Calendar *)calendar;

/**
 * 向数据源询问要插入日历的特定数据中的单元格。
 */
- (__kindof TFY_CalendarCell *)calendar:(TFY_Calendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position;

/**
 * 向dataSource询问特定日期的事件点数。
 *
 * @see
 *   - (UIColor *)calendar:(TFYCa_Calendar *)calendar appearance:(TFYCa_CalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
 *   - (NSArray *)calendar:(TFYCa_Calendar *)calendar appearance:(TFYCa_CalendarAppearance *)appearance eventColorsForDate:(NSDate *)date;
 */
- (NSInteger)calendar:(TFY_Calendar *)calendar numberOfEventsForDate:(NSDate *)date;

@end


/**
 * TFYCa_Calendar对象的委托必须采用TFYCa_CalendarDelegate协议。 TFYCa_CalendarDelegate的可选方法可以管理选择，用户事件并帮助管理日历框架。
 */
@protocol TFYCa_CalendarDelegate <NSObject>

@optional

/**
 询问代表是否允许通过点击选择特定日期。
 */
- (BOOL)calendar:(TFY_Calendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition;

/**
 告诉代表日历中的日期是通过点击选择的。
 */
- (void)calendar:(TFY_Calendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition;

/**
 询问代表是否允许通过点击取消选择特定日期。
 */
- (BOOL)calendar:(TFY_Calendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition;

/**
 告诉代表日历中的日期，通过点击取消选择。
 */
- (void)calendar:(TFY_Calendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition;


/**
 告诉代表日历将要更改边界矩形。
 */
- (void)calendar:(TFY_Calendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;

/**
 告知代表指定的单元格将在日历中显示。
 */
- (void)calendar:(TFY_Calendar *)calendar willDisplayCell:(TFY_CalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition;

/**
 告诉代表日历将要更改当前页面。
 */
- (void)calendarCurrentPageDidChange:(TFY_Calendar *)calendar;

@end

/**
 * TFYCa_CalendarDelegateAppearance确定日历中组件的字体和颜色，但更具体地说。基本上，如果需要对日历的外观进行全局自定义，请使用TFYCa_CalendarAppearance。但是，如果您在不同的日子需要不同的外观，请使用TFYCa_CalendarDelegateAppearance。
 *
 * @see TFYCa_CalendarAppearance
 */
@protocol TFYCa_CalendarDelegateAppearance <TFYCa_CalendarDelegate>

@optional

/**
 * 要求代表提供特定日期处于未选择状态的填充颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date;

/**
 * 向代表询问特定日期处于选定状态的填充颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date;

/**
 * 向代表询问特定日期处于未选择状态的日期文本颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date;

/**
 * 向代表询问特定日期在选定状态下的日文本颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date;

/**
 * 向代表询问代表在特定日期处于未选择状态的字幕文本颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date;

/**
 * 向代表询问代表在特定日期处于选定状态的字幕文本颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance subtitleSelectionColorForDate:(NSDate *)date;

/**
 * 向代表询问特定日期的事件颜色。
 */
- (nullable NSArray<UIColor *> *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date;

/**
 * 向代表询问特定日期处于选定状态的多种事件颜色。
 */
- (nullable NSArray<UIColor *> *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance eventSelectionColorsForDate:(NSDate *)date;

/**
 * 要求代表提供特定日期处于未选择状态的边框颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date;

/**
 * 向代表询问特定日期处于选定状态的边框颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date;

/**
 * 要求代表提供特定日期的日文本偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance titleOffsetForDate:(NSDate *)date;

/**
 * 要求代表提供特定日期字幕的补偿。
 */
- (CGPoint)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance subtitleOffsetForDate:(NSDate *)date;

/**
 * 要求代表提供特定日期的图像偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance imageOffsetForDate:(NSDate *)date;

/**
 * 要求代表提供特定日期的事件点偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance eventOffsetForDate:(NSDate *)date;


/**
 * 向代表询问特定日期的边界半径。
 */
- (CGFloat)calendar:(TFY_Calendar *)calendar appearance:(TFY_CalendarAppearance *)appearance borderRadiusForDate:(NSDate *)date;

@end

#pragma mark - Primary

IB_DESIGNABLE

@interface TFY_Calendar : UIView
/**
 * 充当日历委托的对象。
 */
@property (weak, nonatomic) IBOutlet id<TFYCa_CalendarDelegate> delegate;

/**
 * 充当日历数据源的对象。
 */
@property (weak, nonatomic) IBOutlet id<TFYCa_CalendarDataSource> dataSource;

/**
 * 日历的“今天”将有一个特殊标记。
 */
@property (nullable, strong, nonatomic) NSDate *today;

/**
 * 日历的当前页面
 *
 * @desc在星期模式下，当前页面表示当前可见的星期；在月份模式下，表示当前可见月份。
 */
@property (strong, nonatomic) NSDate *currentPage;

/**
 * 月和周日符号的语言环境。更改它以使用您自己的语言显示它们
 * calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
 */
@property (copy, nonatomic) NSLocale *locale;

/**
 * TFYCa_Calendar的滚动方向。
 * 例如使日历垂直滚动
 * calendar.scrollDirection = TFYCa_CalendarScrollDirectionVertical;
 */
@property (assign, nonatomic) TFYCa_CalendarScrollDirection scrollDirection;

/**
 * 日历的范围，更改范围将触发内部框架更改，请确保已正确调整框架
 *
 *    - (void)calendar:(TFYCa_Calendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;
 */
@property (assign, nonatomic) TFYCa_CalendarScope scope;

/**
 一个UIPanGestureRecognizer实例，它可以控制整个日区域上的范围。如果scrollDirection是垂直的，则不可用。
  
  @不建议使用-handleScopeGesture：
  UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
 
 @see DIYExample
 @see TFYCa_CalendarScopeExample
 */
@property (readonly, nonatomic) UIPanGestureRecognizer *scopeGesture TFYCa_CalendarDeprecated(handleScopeGesture:);

/**
 * 一个UILongPressGestureRecognizer实例，该实例启用日历的滑动选择功能。 calendar.swipeToChooseGesture.enabled = YES;
 */
@property (readonly, nonatomic) UILongPressGestureRecognizer *swipeToChooseGesture;

/**
 * TFYCa_Calendar的占位符类型。默认值为FSCalendarPlaceholderTypeFillSixRows。
 *
 * e.g. To hide all placeholder of the calendar
 *
 * calendar.placeholderType = TFYCa_CalendarPlaceholderTypeNone;
 */
@property (assign, nonatomic) TFYCa_CalendarPlaceholderType placeholderType;

/**
 日历的第一个工作日的索引。在第一栏中输入“ 2”作为星期一。
 */
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;

/**
 日历的月标题高度。给出一个“ 0”以删除标题。
 */
@property (assign, nonatomic) IBInspectable CGFloat headerHeight;

/**
 日历中工作日标题的高度。
 */
@property (assign, nonatomic) IBInspectable CGFloat weekdayHeight;

/**
 日历的工作日视图
 */
@property (strong, nonatomic) TFY_CalendarWeekdayView *calendarWeekdayView;

/**
 日历的标题视图
 */
@property (strong, nonatomic) TFY_CalendarHeaderView *calendarHeaderView;

/**
 一个布尔值，确定用户是否可以选择日期。
 */
@property (assign, nonatomic) IBInspectable BOOL allowsSelection;

/**
 一个布尔值，确定用户是否可以选择多个日期。
 */
@property (assign, nonatomic) IBInspectable BOOL allowsMultipleSelection;

/**
 一个布尔值，它确定更改日历的显示月份时边界矩形是否更改。
 */
@property (assign, nonatomic) IBInspectable BOOL adjustsBoundingRectWhenChangingMonths;

/**
 一个布尔值，确定是否为日历启用分页。
 */
@property (assign, nonatomic) IBInspectable BOOL pagingEnabled;

/**
 一个布尔值，它确定是否为日历启用滚动。
 */
@property (assign, nonatomic) IBInspectable BOOL scrollEnabled;

/**
 如果启用了分页，则日历的行高为NO。
 */
@property (assign, nonatomic) IBInspectable CGFloat rowHeight;

/**
 日历外观用于控制全局字体，颜色等
 */
@property (readonly, nonatomic) TFY_CalendarAppearance *appearance;

/**
 表示最小日期启用，可见和可选的日期对象。 （只读）
 */
@property (readonly, nonatomic) NSDate *minimumDate;

/**
 一个日期对象，表示启用，可见和可选的最大日期。 （只读）
 */
@property (readonly, nonatomic) NSDate *maximumDate;

/**
 日期对象，标识选定日期的部分。 （只读）
 */
@property (nullable, readonly, nonatomic) NSDate *selectedDate;

/**
 代表所选日期的日期。 （只读）
 */
@property (readonly, nonatomic) NSArray<NSDate *> *selectedDates;

/**
 重新加载日历的日期和外观。
 */
- (void)reloadData;

/**
 更改日历的范围。确保`-calendar：boundingRectWillChange：animated`被正确采用。
 scope要更改的目标范围。
 如果要为范围设定动画，则为YES；否，如果更改应立即生效。
 */
- (void)setScope:(TFYCa_CalendarScope)scope animated:(BOOL)animated;

/**
 在日历中选择一个给定的日期。
 */
- (void)selectDate:(nullable NSDate *)date;

/**
 在日历中选择一个给定的日期，可以选择将日期滚动到可见区域。
 date日历中的日期。
 scrollToDate一个布尔值，它确定日历是否应滚动到可见区域的选定日期。
 */
- (void)selectDate:(nullable NSDate *)date scrollToDate:(BOOL)scrollToDate;

/**
 取消选择日历的给定日期。
 */
- (void)deselectDate:(NSDate *)date;

/**
 更改日历的当前页面。
 currentPage在周模式下表示weekOfYear，在月模式下表示月份。
 如果要为位置变化设置动画，则为YES；否，如果应该立即执行。
 */
- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated;

/**
 注册一个用于创建新日历单元格的类。
 cellClass您要在日历中使用的单元格的类。
 标识符与指定类关联的重用标识符。此参数不能为nil，也不能为空字符串。
 */
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/**
 返回通过其标识符定位的可重用日历单元格对象。
 标识符指定单元格的重用标识符。此参数不能为nil。
 date单元格的特定日期。
 一个有效的FSCalendarCell对象。
 */
- (__kindof TFY_CalendarCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position;

/**
  返回指定日期的日历单元格。
  date单元格的日期
  position单元格的月份位置
  一个代表日历单元格的对象，如果该单元格不可见或日期超出范围，则为nil。
 */
- (nullable TFY_CalendarCell *)cellForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position;


/**
 返回指定单元格的日期。
 cell所需日期的单元格对象。
 单元格的日期；如果指定的单元格不在日历中，则为nil。
 */
- (nullable NSDate *)dateForCell:(TFY_CalendarCell *)cell;

/**
 返回指定单元格的月份位置。
 cell您想要其月份位置的单元格对象。
 如果指定的单元格不在日历中，则该单元格或FSCalendarMonthPositionNotFound的月份位置。
 */
- (TFYCa_CalendarMonthPosition)monthPositionForCell:(TFY_CalendarCell *)cell;


/**
 返回日历当前显示的可见单元格数组。
 TFYCa_CalendarCell对象的数组。如果看不到任何单元格，则此方法返回一个空数组。
 */
- (NSArray<__kindof TFY_CalendarCell *> *)visibleCells;

/**
 返回相对于日历超级视图的非占位符单元格的框架。
 date日期是日历。
 */
- (CGRect)frameForDate:(NSDate *)date;

/**
 UIPanGestureRecognizer实例的操作选择器，用于控制范围转换
 sender一个UIPanGestureRecognizer实例，它控制日历的范围
 */
- (void)handleScopeGesture:(UIPanGestureRecognizer *)sender;

@end


IB_DESIGNABLE
@interface TFY_Calendar (IBExtension)

#if TARGET_INTERFACE_BUILDER

@property (assign, nonatomic) IBInspectable CGFloat  titleTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  subtitleTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  weekdayTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  headerTitleTextSize;

@property (strong, nonatomic) IBInspectable UIColor  *eventDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *eventSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *weekdayTextColor;

@property (strong, nonatomic) IBInspectable UIColor  *headerTitleColor;
@property (strong, nonatomic) IBInspectable NSString *headerDateFormat;
@property (assign, nonatomic) IBInspectable CGFloat  headerMinimumDissolvedAlpha;

@property (strong, nonatomic) IBInspectable UIColor  *titleDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleTodayColor;
@property (strong, nonatomic) IBInspectable UIColor  *titlePlaceholderColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleWeekendColor;

@property (strong, nonatomic) IBInspectable UIColor  *subtitleDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleTodayColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitlePlaceholderColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleWeekendColor;

@property (strong, nonatomic) IBInspectable UIColor  *selectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *todayColor;
@property (strong, nonatomic) IBInspectable UIColor  *todaySelectionColor;

@property (strong, nonatomic) IBInspectable UIColor *borderDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor *borderSelectionColor;

@property (assign, nonatomic) IBInspectable CGFloat borderRadius;
@property (assign, nonatomic) IBInspectable BOOL    useVeryShortWeekdaySymbols;

@property (assign, nonatomic) IBInspectable BOOL      fakeSubtitles;
@property (assign, nonatomic) IBInspectable BOOL      fakeEventDots;
@property (assign, nonatomic) IBInspectable NSInteger fakedSelectedDay;

#endif

@end

NS_ASSUME_NONNULL_END
