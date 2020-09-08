//
//  TFY_DatePickerViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_DatePickerViewChainModel;
@interface TFY_DatePickerViewChainModel : TFY_BaseControlChainModel<TFY_DatePickerViewChainModel *>
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ datePickerMode) (UIDatePickerMode);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ locale) (NSLocale*);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ calendar) (NSCalendar*);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ timeZone) (NSTimeZone*);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ date) (NSDate *);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ minimumDate) (NSDate *);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ maximumDate) (NSDate *);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ countDownDuration) (NSTimeInterval);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ minuteInterval) (NSInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_DatePickerViewChainModel * (^ setDateWithAnimated) (NSDate *date, BOOL animated);
@end
TFY_CATEGORY_EXINTERFACE(UIDatePicker, TFY_DatePickerViewChainModel)
NS_ASSUME_NONNULL_END
