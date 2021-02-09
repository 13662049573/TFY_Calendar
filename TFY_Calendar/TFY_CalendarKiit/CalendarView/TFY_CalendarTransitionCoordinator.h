//
//  TFY_CalendarTransitionCoordinator.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_Calendar.h"
#import "TFY_CalendarCollectionView.h"
#import "TFY_CalendarCollectionViewLayout.h"

typedef NS_ENUM(NSUInteger, TFYCa_CalendarTransitionState) {
    TFYCa_CalendarTransitionStateIdle,
    TFYCa_CalendarTransitionStateChanging,
    TFYCa_CalendarTransitionStateFinishing,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarTransitionCoordinator : NSObject<UIGestureRecognizerDelegate>
@property (assign, nonatomic) TFYCa_CalendarTransitionState state;

@property (assign, nonatomic) CGSize cachedMonthSize;

@property (readonly, nonatomic) TFYCa_CalendarScope representingScope;

- (instancetype)initWithCalendar:(TFY_Calendar *)calendar;

- (void)performScopeTransitionFromScope:(TFYCa_CalendarScope)fromScope toScope:(TFYCa_CalendarScope)toScope animated:(BOOL)animated;
- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration;
- (CGRect)boundingRectForScope:(TFYCa_CalendarScope)scope page:(NSDate *)page;

- (void)handleScopeGesture:(id)sender;

@end

@interface TFY_CalendarTransitionAttributes : NSObject

@property (assign, nonatomic) CGRect sourceBounds;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) NSDate *sourcePage;
@property (strong, nonatomic) NSDate *targetPage;
@property (assign, nonatomic) NSInteger focusedRow;
@property (strong, nonatomic) NSDate *focusedDate;
@property (assign, nonatomic) TFYCa_CalendarScope targetScope;

- (void)revert;
    
@end

NS_ASSUME_NONNULL_END
