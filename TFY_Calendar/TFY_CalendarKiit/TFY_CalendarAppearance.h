//
//  TFY_CalendarAppearance.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_CalendarConstants.h"

@class TFY_Calendar;

typedef NS_ENUM(NSInteger, TFYCa_CalendarCellState) {
    TFYCa_CalendarCellStateNormal      = 0,
    TFYCa_CalendarCellStateSelected    = 1,
    TFYCa_CalendarCellStatePlaceholder = 1 << 1,
    TFYCa_CalendarCellStateDisabled    = 1 << 2,
    TFYCa_CalendarCellStateToday       = 1 << 3,
    TFYCa_CalendarCellStateWeekend     = 1 << 4,
    TFYCa_CalendarCellStateTodaySelected = TFYCa_CalendarCellStateToday|TFYCa_CalendarCellStateSelected
};

typedef NS_ENUM(NSUInteger, TFYCa_CalendarSeparators) {
    TFYCa_CalendarSeparatorNone          = 0,
    TFYCa_CalendarSeparatorInterRows     = 1
};

typedef NS_OPTIONS(NSUInteger, TFYCa_CalendarCaseOptions) {
    TFYCa_CalendarCaseOptionsHeaderUsesDefaultCase      = 0,
    TFYCa_CalendarCaseOptionsHeaderUsesUpperCase        = 1,
    
    TFYCa_CalendarCaseOptionsWeekdayUsesDefaultCase     = 0 << 4,
    TFYCa_CalendarCaseOptionsWeekdayUsesUpperCase       = 1 << 4,
    TFYCa_CalendarCaseOptionsWeekdayUsesSingleUpperCase = 2 << 4,
};

///星期和年份上下位置交换
typedef NS_ENUM(NSUInteger, TFYCa_CalendarSwapplaces) {
    TFYCa_CalendarSwapplacesYearTop  = 0,///年份
    TFYCa_CalendarSwapplacesWeekTop  = 1///星期
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarAppearance : NSObject
///日文本的字体。
@property (strong, nonatomic) UIFont   *titleFont;

///字幕文本的字体
@property (strong, nonatomic) UIFont   *subtitleFont;

///字幕文本的字体
@property (strong, nonatomic) UIFont   *subToptitleFont;

///工作日文本的字体。
@property (strong, nonatomic) UIFont   *weekdayFont;

///月文本的字体。
@property (strong, nonatomic) UIFont   *headerTitleFont;

///日期文本与默认位置的偏移量。
@property (assign, nonatomic) CGPoint  titleOffset;

///日期文本与下默认位置的偏移量。
@property (assign, nonatomic) CGPoint  subtitleOffset;

///日期文本与上默认位置的偏移量。
@property (assign, nonatomic) CGPoint  subToptitleOffset;

///事件点与默认位置的偏移量。
@property (assign, nonatomic) CGPoint eventOffset;

///日期下面图片位置的偏移量。
@property (assign, nonatomic) CGPoint imageOffset;

///日期上面图片位置的偏移量。
@property (assign, nonatomic) CGPoint imageTopOffset;

///事件点的颜色。
@property (strong, nonatomic) UIColor  *eventDefaultColor;

///事件点的颜色。
@property (strong, nonatomic) UIColor  *eventSelectionColor;

///工作日文字的颜色。
@property (strong, nonatomic) UIColor  *weekdayTextColor;

///月标题文本的颜色。
@property (strong, nonatomic) UIColor  *headerTitleColor;

///月标题的日期格式。
@property (strong, nonatomic) NSString *headerDateFormat;

///月标签的alpha值停留在边缘。
@property (assign, nonatomic) CGFloat  headerMinimumDissolvedAlpha;

///未选择状态的日期文本颜色。
@property (strong, nonatomic) UIColor  *titleDefaultColor;

///所选状态的日期文本颜色。
@property (strong, nonatomic) UIColor  *titleSelectionColor;

///日历中今天的日文本颜色。
@property (strong, nonatomic) UIColor  *titleTodayColor;

///当前月份中几天的日期文本颜色。
@property (strong, nonatomic) UIColor  *titlePlaceholderColor;

///日期周末文字颜色。
@property (strong, nonatomic) UIColor  *titleWeekendColor;

///未选择状态的字幕文本颜色。
@property (strong, nonatomic) UIColor  *subtitleDefaultColor;

///未选择状态的字幕文本颜色。
@property (strong, nonatomic) UIColor  *subToptitleDefaultColor;

///所选状态的字幕文本颜色。
@property (strong, nonatomic) UIColor  *subtitleSelectionColor;

///所选状态的字幕文本颜色。
@property (strong, nonatomic) UIColor  *subToptitleSelectionColor;

///日历中今天的字幕文字颜色。
@property (strong, nonatomic) UIColor  *subtitleTodayColor;

///当前月份中几天的字幕文本颜色。
@property (strong, nonatomic) UIColor  *subtitlePlaceholderColor;

///周末的字幕文本颜色。
@property (strong, nonatomic) UIColor  *subtitleWeekendColor;

///所选状态的形状的填充颜色。
@property (strong, nonatomic) UIColor  *selectionColor;

///今天形状的填充颜色。
@property (strong, nonatomic) UIColor  *todayColor;

///今天和选定状态的形状的填充颜色。
@property (strong, nonatomic) UIColor  *todaySelectionColor;

///未选择状态的形状的边框颜色。
@property (strong, nonatomic) UIColor  *borderDefaultColor;

///所选状态的形状的边框颜色。
@property (strong, nonatomic) UIColor  *borderSelectionColor;

///边界半径，而1表示一个圆，0表示一个矩形，中间值将为其指定拐角半径。
@property (assign, nonatomic) CGFloat borderRadius;

///日期开启左右位置 如 ：UIControlContentHorizontalAlignmentLeft  时，可以设置左右间距
@property (assign, nonatomic) CGFloat  liftrightSpacing;

///案例选项管理月份标签和工作日符号的大小写。
@property (assign, nonatomic) TFYCa_CalendarCaseOptions caseOptions;

///日历的线路集成。
@property (assign, nonatomic) TFYCa_CalendarSeparators separators;

///星期和年份上下位置交换 默认 年份在上。
@property (assign, nonatomic) TFYCa_CalendarSwapplaces swapplaces;

#if TARGET_INTERFACE_BUILDER

// 仅用于预览
@property (assign, nonatomic) BOOL      fakeSubtitles;
@property (assign, nonatomic) BOOL      fakeSubToptitles;
@property (assign, nonatomic) BOOL      fakeEventDots;
@property (assign, nonatomic) NSInteger fakedSelectedDay;

#endif

@end

NS_ASSUME_NONNULL_END
