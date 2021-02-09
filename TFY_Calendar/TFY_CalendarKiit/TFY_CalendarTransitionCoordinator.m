//
//  TFY_CalendarTransitionCoordinator.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarTransitionCoordinator.h"
#import "TFY_CalendarExtensions.h"
#import "TFY_CalendarDynamic.h"

@interface TFY_CalendarTransitionCoordinator ()

@property (weak, nonatomic) TFY_CalendarCollectionView *collectionView;
@property (weak, nonatomic) TFY_CalendarCollectionViewLayout *collectionViewLayout;
@property (weak, nonatomic) TFY_Calendar *calendar;

@property (strong, nonatomic) TFY_CalendarTransitionAttributes *transitionAttributes;

- (TFY_CalendarTransitionAttributes *)createTransitionAttributesTargetingScope:(TFYCa_CalendarScope)targetScope;

- (void)performTransitionCompletionAnimated:(BOOL)animated;

- (void)performAlphaAnimationWithProgress:(CGFloat)progress;
- (void)performPathAnimationWithProgress:(CGFloat)progress;

- (void)scopeTransitionDidBegin:(UIPanGestureRecognizer *)panGesture;
- (void)scopeTransitionDidUpdate:(UIPanGestureRecognizer *)panGesture;
- (void)scopeTransitionDidEnd:(UIPanGestureRecognizer *)panGesture;

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated;

@end

@implementation TFY_CalendarTransitionCoordinator

- (instancetype)initWithCalendar:(TFY_Calendar *)calendar
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
        self.collectionView = self.calendar.collectionView;
        self.collectionViewLayout = self.calendar.collectionViewLayout;
    }
    return self;
}

#pragma mark - Target actions

- (void)handleScopeGesture:(UIPanGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            [self scopeTransitionDidBegin:sender];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self scopeTransitionDidUpdate:sender];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            [self scopeTransitionDidEnd:sender];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.state != TFYCa_CalendarTransitionStateIdle) {
        return NO;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    
    if (gestureRecognizer == self.calendar.scopeGesture && self.calendar.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [[gestureRecognizer valueForKey:@"_targets"] containsObject:self.calendar]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
        BOOL shouldStart = self.calendar.scope == TFYCa_CalendarScopeWeek ? velocity.y >= 0 : velocity.y <= 0;
        if (!shouldStart) return NO;
        shouldStart = (ABS(velocity.x)<=ABS(velocity.y));
        if (shouldStart) {
            self.calendar.collectionView.panGestureRecognizer.enabled = NO;
            self.calendar.collectionView.panGestureRecognizer.enabled = YES;
        }
        return shouldStart;
    }
    return YES;
    
#pragma GCC diagnostic pop
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return otherGestureRecognizer == self.collectionView.panGestureRecognizer && self.collectionView.decelerating;
}

- (void)scopeTransitionDidBegin:(UIPanGestureRecognizer *)panGesture
{
    if (self.state != TFYCa_CalendarTransitionStateIdle) return;
    
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    if (self.calendar.scope == TFYCa_CalendarScopeMonth && velocity.y >= 0) {
        return;
    }
    if (self.calendar.scope == TFYCa_CalendarScopeWeek && velocity.y <= 0) {
        return;
    }
    self.state = TFYCa_CalendarTransitionStateChanging;
    
    self.transitionAttributes = [self createTransitionAttributesTargetingScope:1-self.calendar.scope];
    
    if (self.transitionAttributes.targetScope == TFYCa_CalendarScopeMonth) {
        [self prepareWeekToMonthTransition];
    }
}

- (void)scopeTransitionDidUpdate:(UIPanGestureRecognizer *)panGesture
{
    if (self.state != TFYCa_CalendarTransitionStateChanging) return;
    
    CGFloat translation = ABS([panGesture translationInView:panGesture.view].y);
    CGFloat progress = ({
        CGFloat maxTranslation = ABS(CGRectGetHeight(self.transitionAttributes.targetBounds) - CGRectGetHeight(self.transitionAttributes.sourceBounds));
        translation = MIN(maxTranslation, translation);
        translation = MAX(0, translation);
        CGFloat progress = translation/maxTranslation;
        progress;
    });
    [self performAlphaAnimationWithProgress:progress];
    [self performPathAnimationWithProgress:progress];
}

- (void)scopeTransitionDidEnd:(UIPanGestureRecognizer *)panGesture
{
    if (self.state != TFYCa_CalendarTransitionStateChanging) return;
    
    self.state = TFYCa_CalendarTransitionStateFinishing;

    CGFloat translation = [panGesture translationInView:panGesture.view].y;
    CGFloat velocity = [panGesture velocityInView:panGesture.view].y;
    
    CGFloat progress = ({
        CGFloat maxTranslation = CGRectGetHeight(self.transitionAttributes.targetBounds) - CGRectGetHeight(self.transitionAttributes.sourceBounds);
        translation = MAX(0, translation);
        translation = MIN(maxTranslation, translation);
        CGFloat progress = translation/maxTranslation;
        progress;
    });
    if (velocity * translation < 0) {
        [self.transitionAttributes revert];
    }
    [self performTransition:self.transitionAttributes.targetScope fromProgress:progress toProgress:1.0 animated:YES];
}

#pragma mark - Public methods

- (void)performScopeTransitionFromScope:(TFYCa_CalendarScope)fromScope toScope:(TFYCa_CalendarScope)toScope animated:(BOOL)animated
{
    if (fromScope == toScope) {
        [self.calendar willChangeValueForKey:@"scope"];
        [self.calendar tfyCa_setUnsignedIntegerVariable:toScope forKey:@"_scope"];
        [self.calendar didChangeValueForKey:@"scope"];
        return;
    }
    // Start transition
    self.state = TFYCa_CalendarTransitionStateFinishing;
    TFY_CalendarTransitionAttributes *attr = [self createTransitionAttributesTargetingScope:toScope];
    self.transitionAttributes = attr;
    if (toScope == TFYCa_CalendarScopeMonth) {
        [self prepareWeekToMonthTransition];
    }
    [self performTransition:self.transitionAttributes.targetScope fromProgress:0 toProgress:1 animated:animated];
}

- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration
{
    if (!self.calendar.adjustsBoundingRectWhenChangingMonths) return;
    if (self.calendar.scope != TFYCa_CalendarScopeMonth) return;
    NSInteger lastRowCount = [self.calendar.calculator numberOfRowsInMonth:fromMonth];
    NSInteger currentRowCount = [self.calendar.calculator numberOfRowsInMonth:toMonth];
    if (lastRowCount != currentRowCount) {
        CGFloat animationDuration = duration;
        CGRect bounds = [self boundingRectForScope:TFYCa_CalendarScopeMonth page:toMonth];
        self.state = TFYCa_CalendarTransitionStateChanging;
        void (^completion)(BOOL) = ^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(0, duration-animationDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar setNeedsLayout];
                self.state = TFYCa_CalendarTransitionStateIdle;
            });
        };
        if (TFYCa_CalendarInAppExtension) {
            // Detect today extension: http://stackoverflow.com/questions/25048026/ios-8-extension-how-to-detect-running
            [self boundingRectWillChange:bounds animated:YES];
            completion(YES);
        } else {
            [UIView animateWithDuration:animationDuration delay:0  options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self boundingRectWillChange:bounds animated:YES];
            } completion:completion];
        }
        
    }
}

#pragma mark - Private properties

- (void)performTransitionCompletionAnimated:(BOOL)animated
{
    switch (self.transitionAttributes.targetScope) {
        case TFYCa_CalendarScopeWeek: {
            self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.calendar.calendarHeaderView.scrollDirection = self.collectionViewLayout.scrollDirection;
            self.calendar.needsAdjustingViewFrame = YES;
            [self.collectionView reloadData];
            [self.calendar.calendarHeaderView reloadData];
            break;
        }
        case TFYCa_CalendarScopeMonth: {
            self.calendar.needsAdjustingViewFrame = YES;
            break;
        }
        default:
            break;
    }
    self.state = TFYCa_CalendarTransitionStateIdle;
    self.transitionAttributes = nil;
    [self.calendar setNeedsLayout];
    [self.calendar layoutIfNeeded];
}

- (TFY_CalendarTransitionAttributes *)createTransitionAttributesTargetingScope:(TFYCa_CalendarScope)targetScope
{
    TFY_CalendarTransitionAttributes *attributes = [[TFY_CalendarTransitionAttributes alloc] init];
    attributes.sourceBounds = self.calendar.bounds;
    attributes.sourcePage = self.calendar.currentPage;
    attributes.targetScope = targetScope;
    attributes.focusedDate = ({
        NSArray<NSDate *> *candidates = ({
            NSMutableArray *dates = self.calendar.selectedDates.reverseObjectEnumerator.allObjects.mutableCopy;
            if (self.calendar.today) {
                [dates addObject:self.calendar.today];
            }
            if (targetScope == TFYCa_CalendarScopeWeek) {
                [dates addObject:self.calendar.currentPage];
            } else {
                [dates addObject:[self.calendar.gregorian dateByAddingUnit:NSCalendarUnitDay value:3 toDate:self.calendar.currentPage options:0]];
            }
            dates.copy;
        });
        NSArray<NSDate *> *visibleCandidates = [candidates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDate *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSIndexPath *indexPath = [self.calendar.calculator indexPathForDate:evaluatedObject scope:1-targetScope];
            NSInteger currentSection = [self.calendar.calculator indexPathForDate:self.calendar.currentPage scope:1-targetScope].section;
            return indexPath.section == currentSection;
        }]];
        NSDate *date = visibleCandidates.firstObject;
        date;
    });
    attributes.focusedRow = ({
        NSIndexPath *indexPath = [self.calendar.calculator indexPathForDate:attributes.focusedDate scope:TFYCa_CalendarScopeMonth];
        TFY_CalendarCoordinate coordinate = [self.calendar.calculator coordinateForIndexPath:indexPath];
        coordinate.row;
    });
    attributes.targetPage = ({
        NSDate *targetPage = targetScope == TFYCa_CalendarScopeMonth ? [self.calendar.gregorian tfyCa_firstDayOfMonth:attributes.focusedDate] : [self.calendar.gregorian tfyCa_middleDayOfWeek:attributes.focusedDate];
        targetPage;
    });
    attributes.targetBounds = [self boundingRectForScope:attributes.targetScope page:attributes.targetPage];
    return attributes;
}

#pragma mark - Private properties

- (TFYCa_CalendarScope)representingScope
{
    switch (self.state) {
        case TFYCa_CalendarTransitionStateIdle: {
            return self.calendar.scope;
        }
        case TFYCa_CalendarTransitionStateChanging:
        case TFYCa_CalendarTransitionStateFinishing: {
            return TFYCa_CalendarScopeMonth;
        }
    }
}

#pragma mark - Private methods

- (CGRect)boundingRectForScope:(TFYCa_CalendarScope)scope page:(NSDate *)page
{
    CGSize contentSize;
    switch (scope) {
        case TFYCa_CalendarScopeMonth: {
            contentSize = self.calendar.adjustsBoundingRectWhenChangingMonths ? [self.calendar sizeThatFits:self.calendar.frame.size scope:scope] : self.cachedMonthSize;
            break;
        }
        case TFYCa_CalendarScopeWeek: {
            contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:scope];
            break;
        }
    }
    return (CGRect){CGPointZero, contentSize};
}

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated
{
    self.calendar.contentView.tfyCa_height = CGRectGetHeight(targetBounds);
    self.calendar.daysContainer.tfyCa_height = CGRectGetHeight(targetBounds)-self.calendar.preferredHeaderHeight-self.calendar.preferredWeekdayHeight;
    [[self.calendar valueForKey:@"delegateProxy"] calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
}

- (void)performTransition:(TFYCa_CalendarScope)targetScope fromProgress:(CGFloat)fromProgress toProgress:(CGFloat)toProgress animated:(BOOL)animated
{
    TFY_CalendarTransitionAttributes *attr = self.transitionAttributes;
    
    [self.calendar willChangeValueForKey:@"scope"];
    [self.calendar tfyCa_setUnsignedIntegerVariable:targetScope forKey:@"_scope"];
    if (targetScope == TFYCa_CalendarScopeWeek) {
        [self.calendar tfyCa_setVariable:attr.targetPage forKey:@"_currentPage"];
    }
    [self.calendar didChangeValueForKey:@"scope"];
    
    if (animated) {
        if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)])) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self performAlphaAnimationWithProgress:toProgress];
                self.collectionView.tfyCa_top = [self calculateOffsetForProgress:toProgress];
                [self boundingRectWillChange:attr.targetBounds animated:YES];
            } completion:^(BOOL finished) {
                [self performTransitionCompletionAnimated:YES];
            }];
        }
    } else {
        [self performTransitionCompletionAnimated:animated];
        [self boundingRectWillChange:attr.targetBounds animated:animated];
    }
}

- (void)performAlphaAnimationWithProgress:(CGFloat)progress
{
    CGFloat opacity = self.transitionAttributes.targetScope == TFYCa_CalendarScopeWeek ? MAX((1-progress*1.1), 0) : progress;
    NSArray<TFY_CalendarCell *> *surroundingCells = [self.calendar.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TFY_CalendarCell *  _Nullable cell, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (!CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
            return NO;
        }
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSInteger row = [self.calendar.calculator coordinateForIndexPath:indexPath].row;
        return row != self.transitionAttributes.focusedRow;
    }]];
    [surroundingCells setValue:@(opacity) forKey:@"alpha"];
}

- (void)performPathAnimationWithProgress:(CGFloat)progress
{
    CGFloat targetHeight = CGRectGetHeight(self.transitionAttributes.targetBounds);
    CGFloat sourceHeight = CGRectGetHeight(self.transitionAttributes.sourceBounds);
    CGFloat currentHeight = sourceHeight - (sourceHeight-targetHeight)*progress;
    CGRect currentBounds = CGRectMake(0, 0, CGRectGetWidth(self.transitionAttributes.targetBounds), currentHeight);
    self.collectionView.tfyCa_top = [self calculateOffsetForProgress:progress];
    [self boundingRectWillChange:currentBounds animated:NO];
    if (self.transitionAttributes.targetScope == TFYCa_CalendarScopeMonth) {
        self.calendar.contentView.tfyCa_height = targetHeight;
    }
}

- (CGFloat)calculateOffsetForProgress:(CGFloat)progress
{
    NSIndexPath *indexPath = [self.calendar.calculator indexPathForDate:self.transitionAttributes.focusedDate scope:TFYCa_CalendarScopeMonth];
    CGRect frame = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
    CGFloat ratio = self.transitionAttributes.targetScope == TFYCa_CalendarScopeWeek ? progress : (1 - progress);
    CGFloat offset = (-frame.origin.y + self.collectionViewLayout.sectionInsets.top) * ratio;
    return offset;
}

- (void)prepareWeekToMonthTransition
{
    [self.calendar tfyCa_setVariable:self.transitionAttributes.targetPage forKey:@"_currentPage"];
    self.calendar.contentView.tfyCa_height = CGRectGetHeight(self.transitionAttributes.targetBounds);
    self.collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.calendar.scrollDirection;
    self.calendar.calendarHeaderView.scrollDirection = self.collectionViewLayout.scrollDirection;
    self.calendar.needsAdjustingViewFrame = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [self.collectionView reloadData];
    [self.calendar.calendarHeaderView reloadData];
    [self.calendar layoutIfNeeded];
    [CATransaction commit];
    
    self.collectionView.tfyCa_top = [self calculateOffsetForProgress:0];
}

@end

@implementation TFY_CalendarTransitionAttributes

- (void)revert
{
    CGRect tempRect = self.sourceBounds;
    self.sourceBounds = self.targetBounds;
    self.targetBounds = tempRect;

    NSDate *tempDate = self.sourcePage;
    self.sourcePage = self.targetPage;
    self.targetPage = tempDate;
    
    self.targetScope = 1 - self.targetScope;
}
    
@end
