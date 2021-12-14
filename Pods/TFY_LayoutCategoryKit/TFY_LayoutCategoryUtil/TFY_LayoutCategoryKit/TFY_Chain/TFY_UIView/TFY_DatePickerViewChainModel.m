//
//  TFY_DatePickerViewChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DatePickerViewChainModel.h"
#define TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_DatePickerViewChainModel *,UIDatePicker)
@implementation TFY_DatePickerViewChainModel

TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(datePickerMode, UIDatePickerMode)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(locale, NSLocale *)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(calendar, NSCalendar *)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(timeZone, NSTimeZone *)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(date, NSDate *)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(minimumDate, NSDate *)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(maximumDate, NSDate *)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(countDownDuration, NSTimeInterval)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(minuteInterval, NSInteger)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(preferredDatePickerStyle, UIDatePickerStyle)
TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION(roundsToMinuteInterval, BOOL)

- (TFY_DatePickerViewChainModel * _Nonnull (^)(NSDate * _Nonnull, BOOL))setDateWithAnimated{
    return ^ (NSDate *date, BOOL animated){
        [self enumerateObjectsUsingBlock:^(UIDatePicker * _Nonnull obj) {
            [obj setDate:date animated:animated];
        }];
        return self;
    };
}

@end
TFY_CATEGORY_VIEW_IMPLEMENTATION(UIDatePicker, TFY_DatePickerViewChainModel)
#undef TFY_CATEGORY_CHAIN_DATEPICKER_IMPLEMENTATION
