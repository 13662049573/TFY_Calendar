//
//  TFY_CalendarProtocol.h
//  TFY_Calendar
//
//  Created by 田风有 on 2021/2/10.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Ensure NS_SWIFT_NAME is available
#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(name)
#endif

@class TFY_CalendarCell;
#import "TFY_CalendarAppearance.h"
#import "TFY_CalendarConstants.h"
#import "TFY_CalendarWeekdayView.h"
#import "TFY_CalendarHeaderView.h"

typedef NS_ENUM(NSUInteger, TFYCa_CalendarScope) {
    TFYCa_CalendarScopeMonth,// 月
    TFYCa_CalendarScopeWeek // 周
} NS_SWIFT_NAME(CalendarScope);

typedef NS_ENUM(NSUInteger, TFYCa_CalendarScrollDirection) {
    TFYCa_CalendarScrollDirectionVertical,//垂直
    TFYCa_CalendarScrollDirectionHorizontal// 水平
} NS_SWIFT_NAME(CalendarScrollDirection);

typedef NS_ENUM(NSUInteger, TFYCa_CalendarPlaceholderType) {
    TFYCa_CalendarPlaceholderTypeNone          = 0,// 默认没有占位
    TFYCa_CalendarPlaceholderTypeFillHeadTail  = 1,// 占位符类型填充头尾
    TFYCa_CalendarPlaceholderTypeFillSixRows   = 2// 占位符类型填充六行
} NS_SWIFT_NAME(CalendarPlaceholderType);

typedef NS_ENUM(NSUInteger, TFYCa_CalendarMonthPosition) {
    TFYCa_CalendarMonthPositionPrevious,// 月之前的位置
    TFYCa_CalendarMonthPositionCurrent,// 月的当前位置
    TFYCa_CalendarMonthPositionNext,// 月下位置
    TFYCa_CalendarMonthPositionNotFound = NSNotFound
} NS_SWIFT_NAME(CalendarMonthPosition);

/// 联动填充颜色 类型判断
typedef NS_ENUM(NSUInteger, TFYCa_fillTypeLinkageSelectionType) {
    TFYCa_fillTypeLinkageSelectionTypeNone,  // 没有选中
    TFYCa_fillTypeLinkageSelectionTypeSingle, // 单独点击
    TFYCa_fillTypeLinkageSelectionTypeLeftBorder, // 最左边选中
    TFYCa_fillTypeLinkageSelectionTypeMiddle,// 中间选中
    TFYCa_fillTypeLinkageSelectionTypeRightBorder // 最右边选中
} NS_SWIFT_NAME(FillTypeLinkageSelectionType);

@class TFY_Calendar;

/**
 * TFYCa_CalendarDataSource是TFY_Calendar的源集。基本角色是提供要显示的事件，字幕和最小/最大日期，或为日历定制日期单元。
 */
@protocol TFYCa_CalendarDataSource <NSObject>

@optional

/**
 * 向数据源询问特定日期的标题，以替换日期文本
 */
- (nullable NSString *)calendar:(TFY_Calendar *_Nullable)calendar titleForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:titleForDate:));

/**
 * 日期下面面添加文案。
 */
- (nullable NSString *)calendar:(TFY_Calendar *_Nullable)calendar subtitleForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:subtitleForDate:));

/**
 * 日期上面添加文案。
 */
- (nullable NSString *)calendar:(TFY_Calendar *_Nullable)calendar subToptitleDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:subToptitleForDate:));

/**
 * 下面日期添加对应图片
 */
- (nullable UIImage *)calendar:(TFY_Calendar *_Nullable)calendar imageForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:imageForDate:));

/**
 * 上面日期添加对应图片
 */
- (nullable UIImage *)calendar:(TFY_Calendar *_Nullable)calendar imageTopForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:imageTopForDate:));

/**
 * 要求dataSource显示的最小日期。
 */
- (NSDate *_Nonnull)minimumDateForCalendar:(TFY_Calendar *_Nullable)calendar NS_SWIFT_NAME(minimumDate(for:));

/**
 * 要求dataSource显示的最大日期。
 */
- (NSDate *_Nonnull)maximumDateForCalendar:(TFY_Calendar *_Nullable)calendar NS_SWIFT_NAME(maximumDate(for:));

/**
 * 向数据源询问要插入日历的特定数据中的单元格。
 */
- (__kindof TFY_CalendarCell *_Nullable)calendar:(TFY_Calendar *_Nullable)calendar cellForDate:(NSDate *_Nonnull)date atMonthPosition:(TFYCa_CalendarMonthPosition)position NS_SWIFT_NAME(calendar(_:cellForDate:atMonthPosition:));

/**
 * 向dataSource询问特定日期的事件点数。
 *
 * @see
 *   - (UIColor *)calendar:(TFYCa_Calendar *)calendar appearance:(TFYCa_CalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
 *   - (NSArray *)calendar:(TFYCa_Calendar *)calendar appearance:(TFYCa_CalendarAppearance *)appearance eventColorsForDate:(NSDate *)date;
 */
- (NSInteger)calendar:(TFY_Calendar *_Nullable)calendar numberOfEventsForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:numberOfEventsForDate:));

@end


/**
 * TFYCa_Calendar对象的委托必须采用TFYCa_CalendarDelegate协议。 TFYCa_CalendarDelegate的可选方法可以管理选择，用户事件并帮助管理日历框架。
 */
@protocol TFYCa_CalendarDelegate <NSObject>

@optional

/**
 询问代表是否允许通过点击选择特定日期。
 */
- (BOOL)calendar:(TFY_Calendar *_Nullable)calendar shouldSelectDate:(NSDate *_Nonnull)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition NS_SWIFT_NAME(calendar(_:shouldSelectDate:atMonthPosition:));

/**
 告诉代表日历中的日期是通过点击选择的。
 */
- (void)calendar:(TFY_Calendar *_Nullable)calendar didSelectDate:(NSDate *_Nonnull)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition NS_SWIFT_NAME(calendar(_:didSelectDate:atMonthPosition:));

/**
 询问代表是否允许通过点击取消选择特定日期。
 */
- (BOOL)calendar:(TFY_Calendar *_Nullable)calendar shouldDeselectDate:(NSDate *_Nonnull)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition NS_SWIFT_NAME(calendar(_:shouldDeselectDate:atMonthPosition:));

/**
 告诉代表日历中的日期，通过点击取消选择。
 */
- (void)calendar:(TFY_Calendar *_Nullable)calendar didDeselectDate:(NSDate *_Nonnull)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition NS_SWIFT_NAME(calendar(_:didDeselectDate:atMonthPosition:));


/**
 告诉代表日历将要更改边界矩形。
 */
- (void)calendar:(TFY_Calendar *_Nullable)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated NS_SWIFT_NAME(calendar(_:boundingRectWillChange:animated:));

/**
 告知代表指定的单元格将在日历中显示。
 */
- (void)calendar:(TFY_Calendar *_Nullable)calendar willDisplayCell:(TFY_CalendarCell *_Nullable)cell forDate:(NSDate *_Nonnull)date atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition NS_SWIFT_NAME(calendar(_:willDisplayCell:forDate:atMonthPosition:));

/**
 告诉代表日历将要更改当前页面。
 */
- (void)calendarCurrentPageDidChange:(TFY_Calendar *_Nullable)calendar NS_SWIFT_NAME(calendarCurrentPageDidChange(_:));

/**
  更改年月头部数据。暂时不支持直接修改titleBtn的frame 位置，如果修改frame，需要配合appearance.liftrightSpacing  的值使用
 */
- (void)calendar:(TFY_CalendarHeaderView *_Nonnull)calendarHerderView DateButton:(UIButton *_Nonnull)titleBtn WeekButtonTitle:(NSString *_Nonnull)textString NS_SWIFT_NAME(calendar(_:dateButton:weekButtonTitle:));

/**
 滑动停止或者切换停止后调用方法 targetdate 上个月末时间 lastPageDate 显示本月月末时间
 */
- (void)calendar:(TFY_Calendar *_Nullable)calendar scrollViewWillEndDraggingTargetDate:(NSDate *_Nonnull)targetdate lastPageDate:(NSDate *_Nonnull)lastPageDate NS_SWIFT_NAME(calendar(_:scrollViewWillEndDraggingTargetDate:lastPageDate:));

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
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance fillDefaultColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:fillDefaultColorForDate:));

/**
 * 向代表询问特定日期处于选定状态的填充颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance fillSelectionColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:fillSelectionColorForDate:));

/**
 * 向代表询问特定日期处于未选择状态的日期文本颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance titleDefaultColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:titleDefaultColorForDate:));

/**
 * 向代表询问特定日期在选定状态下的日文本颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance titleSelectionColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:titleSelectionColorForDate:));

/**
 * 日期下面文字的默认颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subtitleDefaultColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:subtitleDefaultColorForDate:));

/**
 * 日期上面文字的默认颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subToptitleDefaultColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:subToptitleDefaultColorForDate:));
//
/**
 * 日期下面文字的选中颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subtitleSelectionColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:subtitleSelectionColorForDate:));


/**
 * 日期上面文字的选中颜色
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subToptitleSelectionColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:subToptitleSelectionColorForDate:));

/**
 * 向代表询问特定日期的事件颜色。
 */
- (nullable NSArray<UIColor *> *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance eventDefaultColorsForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:eventDefaultColorsForDate:));

/**
 * 向代表询问特定日期处于选定状态的多种事件颜色。
 */
- (nullable NSArray<UIColor *> *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance eventSelectionColorsForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:eventSelectionColorsForDate:));

/**
 * 要求代表提供特定日期处于未选择状态的边框颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance borderDefaultColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:borderDefaultColorForDate:));

/**
 * 向代表询问特定日期处于选定状态的边框颜色。
 */
- (nullable UIColor *)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance borderSelectionColorForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:borderSelectionColorForDate:));

/**
 * 要求代表提供特定日期的日文本偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance titleOffsetForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:titleOffsetForDate:));

/**
 * 日期下面文字偏移量
 */
- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subtitleOffsetForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:subtitleOffsetForDate:));

/**
 * 日期上面面文字偏移量
 */
- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance subToptitleOffsetForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:subToptitleOffsetForDate:));

/**
 * 日历下面图像偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance imageOffsetForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:imageOffsetForDate:));

/**
 * 日历上面图像偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance imageTopOffsetForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:imageTopOffsetForDate:));

/**
 * 要求代表提供特定日期的事件点偏移量。
 */
- (CGPoint)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance eventOffsetForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:eventOffsetForDate:));
/**
 * 向代表询问特定日期的边界半径。
 */
- (CGFloat)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance borderRadiusForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:borderRadiusForDate:));

/**
 选择不同填充颜色类型
 */
- (TFYCa_CellfillType)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance fillTypeForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:fillTypeForDate:));

/**
 联动选中默认数组 必须在 TFYCa_CellfillTypeLinkage 情况下，需要默认选中的时候使用
 */
- (TFYCa_fillTypeLinkageSelectionType)calendar:(TFY_Calendar *_Nullable)calendar appearance:(TFY_CalendarAppearance *_Nullable)appearance LinkageDefaultForDate:(NSDate *_Nonnull)date NS_SWIFT_NAME(calendar(_:appearance:linkageDefaultForDate:));

@end
