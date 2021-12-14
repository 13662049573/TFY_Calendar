//
//  TFY_CalendarCell.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_Calendar,TFY_CalendarAppearance,TFY_CalendarEventIndicator;

typedef NS_ENUM(NSUInteger, TFYCa_CalendarMonthPosition);

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarCell : UICollectionViewCell
#pragma mark - Public properties

/**
 单元格的日期文本标签
 */
@property (weak, nonatomic) UILabel  *titleLabel;


/**
 日期下面字幕标签
 */
@property (weak, nonatomic) UILabel  *subtitleLabel;

/**
 日期上面的字幕标签
 */
@property (weak, nonatomic) UILabel  *subToptitleLabel;

/**
 单元格的形状层
 */
@property (weak, nonatomic) CAShapeLayer *shapeLayer;

/**
 单元格形状层下方的imageView
 */
@property (weak, nonatomic) UIImageView *imageView;


/**
 单元事件点的集合
 */
@property (weak, nonatomic) TFY_CalendarEventIndicator *eventIndicator;

/**
 布尔值指示该单元格是否为“占位符”。默认为“否”。
 */
@property (assign, nonatomic, getter=isPlaceholder) BOOL placeholder;

#pragma mark - Private properties

@property (weak, nonatomic) TFY_Calendar *calendar;
@property (weak, nonatomic) TFY_CalendarAppearance *appearance;

@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *subToptitle;
@property (strong, nonatomic) UIImage  *image;
@property (assign, nonatomic) TFYCa_CalendarMonthPosition monthPosition;

@property (assign, nonatomic) NSInteger numberOfEvents;
@property (assign, nonatomic) BOOL dateIsToday;
@property (assign, nonatomic) BOOL weekend;

@property (strong, nonatomic) UIColor *preferredFillDefaultColor;
@property (strong, nonatomic) UIColor *preferredFillSelectionColor;
@property (strong, nonatomic) UIColor *preferredTitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredTitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredSubtitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredSubtitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredSubToptitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredSubToptitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredBorderDefaultColor;
@property (strong, nonatomic) UIColor *preferredBorderSelectionColor;
@property (assign, nonatomic) CGPoint preferredTitleOffset;
@property (assign, nonatomic) CGPoint preferredSubtitleOffset;
@property (assign, nonatomic) CGPoint preferredSubToptitleOffset;
@property (assign, nonatomic) CGPoint preferredImageOffset;
@property (assign, nonatomic) CGPoint preferredEventOffset;

@property (strong, nonatomic) NSArray<UIColor *> *preferredEventDefaultColors;
@property (strong, nonatomic) NSArray<UIColor *> *preferredEventSelectionColors;
@property (assign, nonatomic) CGFloat preferredBorderRadius;

/**
 *  将子视图添加到self.contentView并设置约束
 */
- (instancetype)initWithFrame:(CGRect)frame NS_REQUIRES_SUPER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;

// 对于DIY覆盖
- (void)layoutSubviews NS_REQUIRES_SUPER; // 配置子视图的框架
- (void)configureAppearance NS_REQUIRES_SUPER; // 配置单元格的外观

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;
- (void)performSelecting;

@end

@interface TFY_CalendarEventIndicator : UIView

@property (assign, nonatomic) NSInteger numberOfEvents;
@property (strong, nonatomic) id color;

@end

@interface TFY_CalendarBlankCell : UICollectionViewCell

- (void)configureAppearance;

@end
NS_ASSUME_NONNULL_END
