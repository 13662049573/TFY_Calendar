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

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(name)
#endif

typedef NS_ENUM(NSUInteger, TFYCa_CalendarTransitionState) {
    TFYCa_CalendarTransitionStateIdle,
    TFYCa_CalendarTransitionStateChanging,
    TFYCa_CalendarTransitionStateFinishing,
} NS_SWIFT_NAME(CalendarTransitionState);

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarTransitionCoordinator : NSObject<UIGestureRecognizerDelegate>
@property (assign, nonatomic) TFYCa_CalendarTransitionState state;

@property (assign, nonatomic) CGSize cachedMonthSize;

@property (readonly, nonatomic) TFYCa_CalendarScope representingScope;

- (instancetype)initWithCalendar:(TFY_Calendar *)calendar NS_SWIFT_NAME(init(calendar:));

- (void)performScopeTransitionFromScope:(TFYCa_CalendarScope)fromScope toScope:(TFYCa_CalendarScope)toScope animated:(BOOL)animated NS_SWIFT_NAME(performScopeTransition(fromScope:toScope:animated:));
- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration NS_SWIFT_NAME(performBoundingRectTransition(fromMonth:toMonth:duration:));
- (CGRect)boundingRectForScope:(TFYCa_CalendarScope)scope page:(NSDate *)page NS_SWIFT_NAME(boundingRect(forScope:page:));

- (void)handleScopeGesture:(id)sender NS_SWIFT_NAME(handleScopeGesture(_:));

@end

@interface TFY_CalendarTransitionAttributes : NSObject

@property (assign, nonatomic) CGRect sourceBounds;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) NSDate *sourcePage;
@property (strong, nonatomic) NSDate *targetPage;
@property (assign, nonatomic) NSInteger focusedRow;
@property (strong, nonatomic) NSDate *focusedDate;
@property (assign, nonatomic) TFYCa_CalendarScope targetScope;

- (void)revert NS_SWIFT_NAME(revert());
    
@end

NS_ASSUME_NONNULL_END
