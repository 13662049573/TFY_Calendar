//
//  TFY_CalendarCollectionViewLayout.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_Calendar;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarCollectionViewLayout : UICollectionViewLayout

@property (weak, nonatomic) TFY_Calendar *calendar;

@property (assign, nonatomic) UIEdgeInsets sectionInsets;
@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END
