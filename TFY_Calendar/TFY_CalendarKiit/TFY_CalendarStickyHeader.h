//
//  TFY_CalendarStickyHeader.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_Calendar,TFY_CalendarAppearance;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarStickyHeader : UICollectionReusableView
@property (weak, nonatomic) TFY_Calendar *calendar;

@property (weak, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) NSDate *month;

- (void)configureAppearance;
@end

NS_ASSUME_NONNULL_END
