//
//  TFY_CalendarKiit.h
//  TFY_Calendar
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 田风有. All rights reserved.
//  最新版本号: 2.3.4

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double TFY_CalendarKiitVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_CalendarKiitVersionString[];

#define TFY_CalendarKiitRelease 0

#if TFY_CalendarKiitRelease

#import <TFY_CalendarKiit/TFY_Calendar.h>
#import <TFY_CalendarKiit/TFY_CalendarCell.h>
#import <TFY_CalendarKiit/TFY_CalendarHeaderView.h>
#import <TFY_CalendarKiit/TFY_CalendarAppearance.h>
#import <TFY_CalendarKiit/TFY_CalendarCollectionView.h>
#import <TFY_CalendarKiit/TFY_CalendarCollectionViewLayout.h>
#import <TFY_CalendarKiit/TFY_CalendarCalculator.h>
#import <TFY_CalendarKiit/TFY_CalendarTransitionCoordinator.h>
#import <TFY_CalendarKiit/TFY_CalendarDelegationProxy.h>
#import <TFY_CalendarKiit/TFY_CalendarWeekdayView.h>
#import <TFY_CalendarKiit/TFY_LunarFormatter.h>
#import <TFY_CalendarKiit/TFY_CalendarExtensions.h>

#else

#import "TFY_Calendar.h"
#import "TFY_CalendarCell.h"
#import "TFY_CalendarHeaderView.h"
#import "TFY_CalendarAppearance.h"
#import "TFY_CalendarCollectionView.h"
#import "TFY_CalendarCollectionViewLayout.h"
#import "TFY_CalendarCalculator.h"
#import "TFY_CalendarTransitionCoordinator.h"
#import "TFY_CalendarDelegationProxy.h"
#import "TFY_CalendarWeekdayView.h"
#import "TFY_LunarFormatter.h"
#import "TFY_CalendarExtensions.h"

#endif
