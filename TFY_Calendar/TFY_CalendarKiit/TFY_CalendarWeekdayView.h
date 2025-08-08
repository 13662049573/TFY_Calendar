//
//  TFY_CalendarWeekdayView.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class TFY_Calendar;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarWeekdayView : UIView
/**
 显示工作日符号的UILabel对象数组。
 */
@property (readonly, nonatomic) NSArray<UILabel *> *weekdayLabels;

- (void)configureAppearance TFY_CalendarSwiftName(configureAppearance());
@end

NS_ASSUME_NONNULL_END
