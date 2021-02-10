//
//  TFY_Calendar.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_Calendar.h"
#import "TFY_CalendarStickyHeader.h"
#import "TFY_CalendarWeekdayView.h"
#import "TFY_CalendarStickyHeader.h"
#import "TFY_CalendarCollectionViewLayout.h"
#import "TFY_CalendarExtensions.h"
#import "TFY_CalendarDynamic.h"
#import "TFY_CalendarCollectionView.h"
#import "TFY_CalendarTransitionCoordinator.h"
#import "TFY_CalendarCalculator.h"
#import "TFY_CalendarDelegationFactory.h"

#define TFYCa_CalendarInvalidateCellAppearance(SEL1,SEL2) \
    cell.SEL1 = [self.delegateProxy calendar:self appearance:self.appearance SEL2:date];
    
#define TFYCa_CalendarInvalidateCellAppearanceWithDefault(SEL1,SEL2,DEFAULT) \
    if ([self.delegateProxy respondsToSelector:@selector(calendar:appearance:SEL2:)]) { \
        cell.SEL1 = [self.delegateProxy calendar:self appearance:self.appearance SEL2:date]; \
    } else { \
        cell.SEL1 = DEFAULT; \
    }

NS_ASSUME_NONNULL_BEGIN

static inline void TFYCa_CalendarAssertDateInBounds(NSDate *date, NSCalendar *calendar, NSDate *minimumDate, NSDate *maximumDate) {
    BOOL valid = YES;
    NSInteger minOffset = [calendar components:NSCalendarUnitDay fromDate:minimumDate toDate:date options:0].day;
    valid &= minOffset >= 0;
    if (valid) {
        NSInteger maxOffset = [calendar components:NSCalendarUnitDay fromDate:maximumDate toDate:date options:0].day;
        valid &= maxOffset <= 0;
    }
    if (!valid) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
        [NSException raise:@"TFYCa_Calendar date out of bounds exception" format:@"Target date %@ beyond bounds [%@ - %@]", [formatter stringFromDate:date], [formatter stringFromDate:minimumDate], [formatter stringFromDate:maximumDate]];
    }
}

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSUInteger, TFYCa_CalendarOrientation) {
    TFYCa_CalendarOrientationLandscape,
    TFYCa_CalendarOrientationPortrait
};


@interface TFY_Calendar ()<UICollectionViewDataSource,UICollectionViewDelegate,TFYCa_CalendarCollectionViewInternalDelegate,UIGestureRecognizerDelegate>{
    NSMutableArray  *_selectedDates;
}

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSTimeZone *timeZone;

@property (weak  , nonatomic) UIView                     *contentView;
@property (weak  , nonatomic) UIView                     *daysContainer;
@property (weak  , nonatomic) TFY_CalendarCollectionView   *collectionView;
@property (weak  , nonatomic) TFY_CalendarCollectionViewLayout *collectionViewLayout;

@property (strong, nonatomic) TFY_CalendarTransitionCoordinator *transitionCoordinator;
@property (strong, nonatomic) TFY_CalendarCalculator       *calculator;

@property (weak  , nonatomic) TFY_CalendarHeaderTouchDeliver *deliver;

@property (assign, nonatomic) BOOL                       needsAdjustingViewFrame;
@property (assign, nonatomic) BOOL                       needsRequestingBoundingDates;
@property (assign, nonatomic) CGFloat                    preferredHeaderHeight;
@property (assign, nonatomic) CGFloat                    preferredWeekdayHeight;
@property (assign, nonatomic) CGFloat                    preferredRowHeight;
@property (assign, nonatomic) TFYCa_CalendarOrientation      orientation;

@property (strong, nonatomic) NSMutableArray<NSOperation *> *didLayoutOperations;

@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) BOOL hasValidateVisibleLayout;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;
@property (readonly, nonatomic) TFYCa_CalendarOrientation currentCalendarOrientation;

@property (strong, nonatomic) TFY_CalendarDelegationProxy  *dataSourceProxy;
@property (strong, nonatomic) TFY_CalendarDelegationProxy  *delegateProxy;

@property (strong, nonatomic) NSIndexPath *lastPressedIndexPath;
@property (strong, nonatomic) NSMapTable *visibleSectionHeaders;

@end

@implementation TFY_Calendar
@dynamic selectedDate;
@synthesize scopeGesture = _scopeGesture, swipeToChooseGesture = _swipeToChooseGesture;


#pragma mark - Life Cycle && Initialize

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _appearance = [[TFY_CalendarAppearance alloc] init];
    _appearance.calendar = self;
    
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd";
    _locale = [NSLocale currentLocale];
    _timeZone = [NSTimeZone localTimeZone];
    _firstWeekday = 1;
    [self invalidateDateTools];
    
    _today = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    _currentPage = [self.gregorian tfyCa_firstDayOfMonth:_today];
    
    
    _minimumDate = [self.formatter dateFromString:@"1970-01-01"];
    _maximumDate = [self.formatter dateFromString:@"2099-12-31"];
    
    _headerHeight     = TFYCa_CalendarAutomaticDimension;
    _weekdayHeight    = TFYCa_CalendarAutomaticDimension;
    _rowHeight        = TFYCa_CalendarStandardRowHeight*MAX(1, TFYCa_CalendarDeviceIsIPad*1.5);
    
    _preferredHeaderHeight  = TFYCa_CalendarAutomaticDimension;
    _preferredWeekdayHeight = TFYCa_CalendarAutomaticDimension;
    _preferredRowHeight     = TFYCa_CalendarAutomaticDimension;
    
    _scrollDirection = TFYCa_CalendarScrollDirectionHorizontal;
    _scope = TFYCa_CalendarScopeMonth;
    _selectedDates = [NSMutableArray arrayWithCapacity:1];
    _visibleSectionHeaders = [NSMapTable weakToWeakObjectsMapTable];
    
    _pagingEnabled = YES;
    _scrollEnabled = YES;
    _needsAdjustingViewFrame = YES;
    _needsRequestingBoundingDates = YES;
    _orientation = self.currentCalendarOrientation;
    _placeholderType = TFYCa_CalendarPlaceholderTypeFillSixRows;
    
    _dataSourceProxy = [TFY_CalendarDelegationFactory dataSourceProxy];
    _delegateProxy = [TFY_CalendarDelegationFactory delegateProxy];
    
    self.didLayoutOperations = NSMutableArray.array;
    //整体容器View
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    //日期整体容器View
    UIView *daysContainer = [[UIView alloc] initWithFrame:CGRectZero];
    daysContainer.backgroundColor = [UIColor clearColor];
    daysContainer.clipsToBounds = YES;
    [contentView addSubview:daysContainer];
    self.daysContainer = daysContainer;
    
    TFY_CalendarCollectionViewLayout *collectionViewLayout = [[TFY_CalendarCollectionViewLayout alloc] init];
    collectionViewLayout.calendar = self;
    
    TFY_CalendarCollectionView *collectionView = [[TFY_CalendarCollectionView alloc] initWithFrame:CGRectZero
                                                                          collectionViewLayout:collectionViewLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.internalDelegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    collectionView.clipsToBounds = YES;
    [collectionView registerClass:[TFY_CalendarCell class] forCellWithReuseIdentifier:TFYCa_CalendarDefaultCellReuseIdentifier];
    [collectionView registerClass:[TFY_CalendarBlankCell class] forCellWithReuseIdentifier:TFYCa_CalendarBlankCellReuseIdentifier];
    [collectionView registerClass:[TFY_CalendarStickyHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"placeholderHeader"];
    [daysContainer addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionViewLayout = collectionViewLayout;
    
    [self invalidateLayout];
    
    // Assistants
    self.transitionCoordinator = [[TFY_CalendarTransitionCoordinator alloc] initWithCalendar:self];
    self.calculator = [[TFY_CalendarCalculator alloc] initWithCalendar:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Overriden methods

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (!CGRectIsEmpty(bounds) && self.transitionCoordinator.state == TFYCa_CalendarTransitionStateIdle) {
        [self invalidateViewFrames];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!CGRectIsEmpty(frame) && self.transitionCoordinator.state == TFYCa_CalendarTransitionStateIdle) {
        [self invalidateViewFrames];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
#if !TARGET_INTERFACE_BUILDER
    if ([key hasPrefix:@"fake"]) {
        return;
    }
#endif
    if (key.length) {
        NSString *setter = [NSString stringWithFormat:@"set%@%@:",[key substringToIndex:1].uppercaseString,[key substringFromIndex:1]];
        SEL selector = NSSelectorFromString(setter);
        if ([self.appearance respondsToSelector:selector]) {
            return [self.appearance setValue:value forKey:key];
        } else if ([self.collectionViewLayout respondsToSelector:selector]) {
            return [self.collectionViewLayout setValue:value forKey:key];
        }
    }
    
    return [super setValue:value forUndefinedKey:key];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needsAdjustingViewFrame) {
        _needsAdjustingViewFrame = NO;
        
        if (CGSizeEqualToSize(_transitionCoordinator.cachedMonthSize, CGSizeZero)) {
            _transitionCoordinator.cachedMonthSize = self.frame.size;
        }
        
        _contentView.frame = self.bounds;
        CGFloat headerHeight = self.preferredHeaderHeight;
        CGFloat weekdayHeight = self.preferredWeekdayHeight;
        CGFloat rowHeight = self.preferredRowHeight;
        CGFloat padding = 5;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            rowHeight = TFYCa_CalendarFloor(rowHeight*2)*0.5; // 四舍五入到0.5的整数倍。例如(16.8 - > 16.5),(16.2 - > 16.0)
        }
        
        switch (self.appearance.swapplaces) {
            case TFYCa_CalendarSwapplacesYearTop:
                self.calendarHeaderView.frame = CGRectMake(0, 0, self.tfyCa_width, headerHeight);
                self.calendarWeekdayView.frame = CGRectMake(0, self.calendarHeaderView.tfyCa_bottom, self.contentView.tfyCa_width, weekdayHeight);
                break;
            case TFYCa_CalendarSwapplacesWeekTop:
                self.calendarWeekdayView.frame = CGRectMake(0, 0, self.contentView.tfyCa_width, weekdayHeight);
                self.calendarHeaderView.frame = CGRectMake(0, self.calendarWeekdayView.tfyCa_bottom, self.tfyCa_width, headerHeight);
                break;
        }
       
        _deliver.frame = CGRectMake(self.calendarHeaderView.tfyCa_left, self.calendarHeaderView.tfyCa_top, self.calendarHeaderView.tfyCa_width, headerHeight+weekdayHeight);
        _deliver.hidden = self.calendarHeaderView.hidden;
        if (!self.floatingMode) {
            switch (self.transitionCoordinator.representingScope) {
                case TFYCa_CalendarScopeMonth: {
                    CGFloat contentHeight = rowHeight*6 + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.tfyCa_width, contentHeight);
                    _collectionView.frame = CGRectMake(0, 0, _daysContainer.tfyCa_width, contentHeight);
                    break;
                }
                case TFYCa_CalendarScopeWeek: {
                    CGFloat contentHeight = rowHeight + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.tfyCa_width, contentHeight);
                    _collectionView.frame = CGRectMake(0, 0, _daysContainer.tfyCa_width, contentHeight);
                    break;
                }
            }
        } else {
            
            CGFloat contentHeight = _contentView.tfyCa_height;
            _daysContainer.frame = CGRectMake(0, 0, self.tfyCa_width, contentHeight);
            _collectionView.frame = _daysContainer.bounds;
            
        }
        _collectionView.tfyCa_height = TFYCa_CalendarHalfFloor(_collectionView.tfyCa_height);
    }
    
}

#if TARGET_INTERFACE_BUILDER
- (void)prepareForInterfaceBuilder
{
    NSDate *date = [NSDate date];
    NSDateComponents *components = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    components.day = _appearance.fakedSelectedDay?:1;
    [_selectedDates addObject:[self.gregorian dateFromComponents:components]];
    [self.collectionView reloadData];
}
#endif

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self sizeThatFits:size scope:self.transitionCoordinator.representingScope];
}

- (CGSize)sizeThatFits:(CGSize)size scope:(TFYCa_CalendarScope)scope
{
    CGFloat headerHeight = self.preferredHeaderHeight;
    CGFloat weekdayHeight = self.preferredWeekdayHeight;
    CGFloat rowHeight = self.preferredRowHeight;
    CGFloat paddings = self.collectionViewLayout.sectionInsets.top + self.collectionViewLayout.sectionInsets.bottom;
    
    if (!self.floatingMode) {
        switch (scope) {
            case TFYCa_CalendarScopeMonth: {
                CGFloat height = weekdayHeight + headerHeight + [self.calculator numberOfRowsInMonth:_currentPage]*rowHeight + paddings;
                return CGSizeMake(size.width, height);
            }
            case TFYCa_CalendarScopeWeek: {
                CGFloat height = weekdayHeight + headerHeight + rowHeight + paddings;
                return CGSizeMake(size.width, height);
            }
        }
    } else {
        return CGSizeMake(size.width, self.tfyCa_height);
    }
    return size;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    [self requestBoundingDatesIfNecessary];
    return self.calculator.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.floatingMode) {
        NSInteger numberOfRows = [self.calculator numberOfRowsInSection:section];
        return numberOfRows * 7;
    }
    switch (self.transitionCoordinator.representingScope) {
        case TFYCa_CalendarScopeMonth: {
            return 42;
        }
        case TFYCa_CalendarScopeWeek: {
            return 7;
        }
    }
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    
    switch (self.placeholderType) {
        case TFYCa_CalendarPlaceholderTypeNone: {
            if (self.transitionCoordinator.representingScope == TFYCa_CalendarScopeMonth && monthPosition != TFYCa_CalendarMonthPositionCurrent) {
                return [collectionView dequeueReusableCellWithReuseIdentifier:TFYCa_CalendarBlankCellReuseIdentifier forIndexPath:indexPath];
            }
            break;
        }
        case TFYCa_CalendarPlaceholderTypeFillHeadTail: {
            if (self.transitionCoordinator.representingScope == TFYCa_CalendarScopeMonth) {
                if (indexPath.item >= 7 * [self.calculator numberOfRowsInSection:indexPath.section]) {
                    return [collectionView dequeueReusableCellWithReuseIdentifier:TFYCa_CalendarBlankCellReuseIdentifier forIndexPath:indexPath];
                }
            }
            break;
        }
        case TFYCa_CalendarPlaceholderTypeFillSixRows: {
            break;
        }
    }
    
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    TFY_CalendarCell *cell = [self.dataSourceProxy calendar:self cellForDate:date atMonthPosition:monthPosition];
    if (!cell) {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:TFYCa_CalendarDefaultCellReuseIdentifier forIndexPath:indexPath];
    }
    [self reloadDataForCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.floatingMode) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            TFY_CalendarStickyHeader *stickyHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
            stickyHeader.calendar = self;
            stickyHeader.month = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.section toDate:[self.gregorian tfyCa_firstDayOfMonth:_minimumDate] options:0];
            self.visibleSectionHeaders[indexPath] = stickyHeader;
            [stickyHeader setNeedsLayout];
            return stickyHeader;
        }
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"placeholderHeader" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.floatingMode) {
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            self.visibleSectionHeaders[indexPath] = nil;
        }
    }
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    if (self.placeholderType == TFYCa_CalendarPlaceholderTypeNone && monthPosition != TFYCa_CalendarMonthPositionCurrent) {
        return NO;
    }
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    return [self isDateInRange:date] && (![self.delegateProxy respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldSelectDate:date atMonthPosition:monthPosition]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *selectedDate = [self.calculator dateForIndexPath:indexPath];
    TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    TFY_CalendarCell *cell;
    if (monthPosition == TFYCa_CalendarMonthPositionCurrent) {
        cell = (TFY_CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    } else {
        cell = [self cellForDate:selectedDate atMonthPosition:TFYCa_CalendarMonthPositionCurrent];
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        if (indexPath) {
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    if (![_selectedDates containsObject:selectedDate]) {
        cell.selected = YES;
        [cell performSelecting];
    }
    [self enqueueSelectedDate:selectedDate];
    [self.delegateProxy calendar:self didSelectDate:selectedDate atMonthPosition:monthPosition];
    [self selectCounterpartDate:selectedDate];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    if (self.placeholderType == TFYCa_CalendarPlaceholderTypeNone && monthPosition != TFYCa_CalendarMonthPositionCurrent) {
        return NO;
    }
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    return [self isDateInRange:date] && (![self.delegateProxy respondsToSelector:@selector(calendar:shouldDeselectDate:atMonthPosition:)]||[self.delegateProxy calendar:self shouldDeselectDate:date atMonthPosition:monthPosition]);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *selectedDate = [self.calculator dateForIndexPath:indexPath];
    TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    TFY_CalendarCell *cell;
    if (monthPosition == TFYCa_CalendarMonthPositionCurrent) {
        cell = (TFY_CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    } else {
        cell = [self cellForDate:selectedDate atMonthPosition:TFYCa_CalendarMonthPositionCurrent];
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        if (indexPath) {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
    }
    cell.selected = NO;
    [cell configureAppearance];
    
    [_selectedDates removeObject:selectedDate];
    [self.delegateProxy calendar:self didDeselectDate:selectedDate atMonthPosition:monthPosition];
    [self deselectCounterpartDate:selectedDate];
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[TFY_CalendarCell class]]) {
        return;
    }
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    [self.delegateProxy calendar:self willDisplayCell:(TFY_CalendarCell *)cell forDate:date atMonthPosition:monthPosition];
}

- (void)collectionViewDidFinishLayoutSubviews:(TFY_CalendarCollectionView *)collectionView
{
    [self executePendingOperationsIfNeeded];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.window) return;
    if (self.floatingMode && _collectionView.indexPathsForVisibleItems.count) {
        // Do nothing on bouncing
        if (_collectionView.contentOffset.y < 0 || _collectionView.contentOffset.y > _collectionView.contentSize.height-_collectionView.tfyCa_height) {
            return;
        }
        NSDate *currentPage = _currentPage;
        CGPoint significantPoint = CGPointMake(_collectionView.tfyCa_width*0.5,MIN(self.collectionViewLayout.estimatedItemSize.height*2.75, _collectionView.tfyCa_height*0.5)+_collectionView.contentOffset.y);
        NSIndexPath *significantIndexPath = [_collectionView indexPathForItemAtPoint:significantPoint];
        if (significantIndexPath) {
            currentPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:significantIndexPath.section toDate:[self.gregorian tfyCa_firstDayOfMonth:_minimumDate] options:0];
        } else {
            TFY_CalendarStickyHeader *significantHeader = [self.visibleStickyHeaders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TFY_CalendarStickyHeader * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return CGRectContainsPoint(evaluatedObject.frame, significantPoint);
            }]].firstObject;
            if (significantHeader) {
                currentPage = significantHeader.month;
            }
        }
        
        if (![self.gregorian isDate:currentPage equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth]) {
            [self willChangeValueForKey:@"currentPage"];
            _currentPage = currentPage;
            [self.delegateProxy calendarCurrentPageDidChange:self];
            [self didChangeValueForKey:@"currentPage"];
        }
        
    } else if (self.hasValidateVisibleLayout) {
        CGFloat scrollOffset = 0;
        switch (_collectionViewLayout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
                scrollOffset = scrollView.contentOffset.x/scrollView.tfyCa_width;
                break;
            }
            case UICollectionViewScrollDirectionVertical: {
                scrollOffset = scrollView.contentOffset.y/scrollView.tfyCa_height;
                break;
            }
        }
        _calendarHeaderView.scrollOffset = scrollOffset;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!_pagingEnabled || !_scrollEnabled) {
        return;
    }
    CGFloat targetOffset = 0, contentSize = 0;
    switch (_collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            targetOffset = targetContentOffset->x;
            contentSize = scrollView.tfyCa_width;
            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            targetOffset = targetContentOffset->y;
            contentSize = scrollView.tfyCa_height;
            break;
        }
    }
    
    NSInteger sections = lrint(targetOffset/contentSize);
    NSDate *targetPage = nil;
    switch (_scope) {
        case TFYCa_CalendarScopeMonth: {
            NSDate *minimumPage = [self.gregorian tfyCa_firstDayOfMonth:_minimumDate];
            targetPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:sections toDate:minimumPage options:0];
            break;
        }
        case TFYCa_CalendarScopeWeek: {
            NSDate *minimumPage = [self.gregorian tfyCa_firstDayOfWeek:_minimumDate];
            targetPage = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:sections toDate:minimumPage options:0];
            break;
        }
    }
    BOOL shouldTriggerPageChange = [self isDateInDifferentPage:targetPage];
    if (shouldTriggerPageChange) {
        NSDate *lastPage = _currentPage;
        [self willChangeValueForKey:@"currentPage"];
        _currentPage = targetPage;
        [self.delegateProxy calendarCurrentPageDidChange:self];
        if (_placeholderType != TFYCa_CalendarPlaceholderTypeFillSixRows) {
            [self.transitionCoordinator performBoundingRectTransitionFromMonth:lastPage toMonth:_currentPage duration:0.25];
        }
        [self didChangeValueForKey:@"currentPage"];
    }
    
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Notification

- (void)orientationDidChange:(NSNotification *)notification
{
    self.orientation = self.currentCalendarOrientation;
}

#pragma mark - Properties

- (void)setScrollDirection:(TFYCa_CalendarScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        
        if (self.floatingMode) return;
        
        switch (_scope) {
            case TFYCa_CalendarScopeMonth: {
                _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)scrollDirection;
                _calendarHeaderView.scrollDirection = _collectionViewLayout.scrollDirection;
                if (self.hasValidateVisibleLayout) {
                    [_collectionView reloadData];
                    [_calendarHeaderView reloadData];
                }
                _needsAdjustingViewFrame = YES;
                [self setNeedsLayout];
                break;
            }
            case TFYCa_CalendarScopeWeek: {
                break;
            }
        }
    }
}

+ (BOOL)automaticallyNotifiesObserversOfScope
{
    return NO;
}

- (void)setScope:(TFYCa_CalendarScope)scope
{
    [self setScope:scope animated:NO];
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
    if (_firstWeekday != firstWeekday) {
        _firstWeekday = firstWeekday;
        _needsRequestingBoundingDates = YES;
        [self invalidateDateTools];
        [self invalidateHeaders];
        [self.collectionView reloadData];
        [self configureAppearance];
    }
}

- (void)setToday:(NSDate *)today
{
    if (!today) {
        _today = nil;
    } else {
        TFYCa_CalendarAssertDateInBounds(today,self.gregorian,self.minimumDate,self.maximumDate);
        _today = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:today options:0];
    }
    if (self.hasValidateVisibleLayout) {
        [self.visibleCells makeObjectsPerformSelector:@selector(setDateIsToday:) withObject:nil];
        if (today) [[_collectionView cellForItemAtIndexPath:[self.calculator indexPathForDate:today]] setValue:@YES forKey:@"dateIsToday"];
        [self.visibleCells makeObjectsPerformSelector:@selector(configureAppearance)];
    }
}

- (void)setCurrentPage:(NSDate *)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated
{
    [self requestBoundingDatesIfNecessary];
    if (self.floatingMode || [self isDateInDifferentPage:currentPage]) {
        currentPage = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:currentPage options:0];
        if ([self isPageInRange:currentPage]) {
            [self scrollToPageForDate:currentPage animated:animated];
        }
    }
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    if (!identifier.length) {
        [NSException raise:TFYCa_CalendarInvalidArgumentsExceptionName format:@"This identifier must not be nil and must not be an empty string."];
    }
    if (![cellClass isSubclassOfClass:[TFY_CalendarCell class]]) {
        [NSException raise:@"The cell class must be a subclass of TFY_CalendarCell." format:@""];
    }
    if ([identifier isEqualToString:TFYCa_CalendarBlankCellReuseIdentifier]) {
        [NSException raise:TFYCa_CalendarInvalidArgumentsExceptionName format:@"Do not use %@ as the cell reuse identifier.", identifier];
    }
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];

}

- (TFY_CalendarCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position;
{
    if (!identifier.length) {
        [NSException raise:TFYCa_CalendarInvalidArgumentsExceptionName format:@"This identifier must not be nil and must not be an empty string."];
    }
    NSIndexPath *indexPath = [self.calculator indexPathForDate:date atMonthPosition:position];
    if (!indexPath) {
        [NSException raise:TFYCa_CalendarInvalidArgumentsExceptionName format:@"Attempting to dequeue a cell with invalid date."];
    }
    TFY_CalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (nullable TFY_CalendarCell *)cellForDate:(NSDate *)date atMonthPosition:(TFYCa_CalendarMonthPosition)position
{
    NSIndexPath *indexPath = [self.calculator indexPathForDate:date atMonthPosition:position];
    return (TFY_CalendarCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (NSDate *)dateForCell:(TFY_CalendarCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return [self.calculator dateForIndexPath:indexPath];
}

- (TFYCa_CalendarMonthPosition)monthPositionForCell:(TFY_CalendarCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return [self.calculator monthPositionForIndexPath:indexPath];
}

- (NSArray<TFY_CalendarCell *> *)visibleCells
{
    return [self.collectionView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:[TFY_CalendarCell class]];
    }]];
}

- (CGRect)frameForDate:(NSDate *)date
{
    if (!self.superview) {
        return CGRectZero;
    }
    CGRect frame = [_collectionViewLayout layoutAttributesForItemAtIndexPath:[self.calculator indexPathForDate:date]].frame;
    frame = [self.superview convertRect:frame fromView:_collectionView];
    return frame;
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        _needsAdjustingViewFrame = YES;
        [self setNeedsLayout];
    }
}

- (void)setWeekdayHeight:(CGFloat)weekdayHeight
{
    if (_weekdayHeight != weekdayHeight) {
        _weekdayHeight = weekdayHeight;
        _needsAdjustingViewFrame = YES;
        [self setNeedsLayout];
    }
}

- (void)setLocale:(NSLocale *)locale
{
    if (![_locale isEqual:locale]) {
        _locale = locale.copy;
        [self invalidateDateTools];
        [self configureAppearance];
        if (self.hasValidateVisibleLayout) {
            [self invalidateHeaders];
        }
    }
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _collectionView.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection
{
    return _collectionView.allowsMultipleSelection;
}

- (void)setAllowsSelection:(BOOL)allowsSelection
{
    _collectionView.allowsSelection = allowsSelection;
}

- (BOOL)allowsSelection
{
    return _collectionView.allowsSelection;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    if (_pagingEnabled != pagingEnabled) {
        _pagingEnabled = pagingEnabled;
        
        [self invalidateLayout];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        
        _collectionView.scrollEnabled = scrollEnabled;
        _calendarHeaderView.scrollEnabled = scrollEnabled;
        
        [self invalidateLayout];
    }
}

- (void)setOrientation:(TFYCa_CalendarOrientation)orientation
{
    if (_orientation != orientation) {
        _orientation = orientation;
        
        _needsAdjustingViewFrame = YES;
        _preferredWeekdayHeight = TFYCa_CalendarAutomaticDimension;
        _preferredRowHeight = TFYCa_CalendarAutomaticDimension;
        _preferredHeaderHeight = TFYCa_CalendarAutomaticDimension;
        [self setNeedsLayout];
    }
}

- (NSDate *)selectedDate
{
    return _selectedDates.lastObject;
}

- (NSArray *)selectedDates
{
    return [NSArray arrayWithArray:_selectedDates];
}

- (CGFloat)preferredHeaderHeight
{
    if (_headerHeight == TFYCa_CalendarAutomaticDimension) {
        if (_preferredWeekdayHeight == TFYCa_CalendarAutomaticDimension) {
            if (!self.floatingMode) {
                CGFloat DIYider = TFYCa_CalendarStandardMonthlyPageHeight;
                CGFloat contentHeight = self.transitionCoordinator.cachedMonthSize.height;
                _preferredHeaderHeight = (TFYCa_CalendarStandardHeaderHeight/DIYider)*contentHeight;
                _preferredHeaderHeight -= (_preferredHeaderHeight-TFYCa_CalendarStandardHeaderHeight)*0.5;
            } else {
                _preferredHeaderHeight = TFYCa_CalendarStandardHeaderHeight*MAX(1, TFYCa_CalendarDeviceIsIPad*1.5);
            }
        }
        return _preferredHeaderHeight;
    }
    return _headerHeight;
}

- (CGFloat)preferredWeekdayHeight
{
    if (_weekdayHeight == TFYCa_CalendarAutomaticDimension) {
        if (_preferredWeekdayHeight == TFYCa_CalendarAutomaticDimension) {
            if (!self.floatingMode) {
                CGFloat DIYider = TFYCa_CalendarStandardMonthlyPageHeight;
                CGFloat contentHeight = self.transitionCoordinator.cachedMonthSize.height;
                _preferredWeekdayHeight = (TFYCa_CalendarStandardWeekdayHeight/DIYider)*contentHeight;
            } else {
                _preferredWeekdayHeight = TFYCa_CalendarStandardWeekdayHeight*MAX(1, TFYCa_CalendarDeviceIsIPad*1.5);
            }
        }
        return _preferredWeekdayHeight;
    }
    return _weekdayHeight;
}

- (CGFloat)preferredRowHeight
{
    if (_preferredRowHeight == TFYCa_CalendarAutomaticDimension) {
        CGFloat headerHeight = self.preferredHeaderHeight;
        CGFloat weekdayHeight = self.preferredWeekdayHeight;
        CGFloat contentHeight = self.transitionCoordinator.cachedMonthSize.height-headerHeight-weekdayHeight;
        CGFloat padding = 5;
        if (!self.floatingMode) {
            _preferredRowHeight = (contentHeight-padding*2)/6.0;
        } else {
            _preferredRowHeight = _rowHeight;
        }
    }
    return _preferredRowHeight;
}

- (BOOL)floatingMode
{
    return _scope == TFYCa_CalendarScopeMonth && _scrollEnabled && !_pagingEnabled;
}

- (UIPanGestureRecognizer *)scopeGesture
{
    if (!_scopeGesture) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitionCoordinator action:@selector(handleScopeGesture:)];
        panGesture.delegate = self.transitionCoordinator;
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 2;
        panGesture.enabled = NO;
        [self.daysContainer addGestureRecognizer:panGesture];
        _scopeGesture = panGesture;
    }
    return _scopeGesture;
}

- (UILongPressGestureRecognizer *)swipeToChooseGesture
{
    if (!_swipeToChooseGesture) {
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToChoose:)];
        pressGesture.enabled = NO;
        pressGesture.numberOfTapsRequired = 0;
        pressGesture.numberOfTouchesRequired = 1;
        pressGesture.minimumPressDuration = 0.7;
        [self.daysContainer addGestureRecognizer:pressGesture];
        [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:pressGesture];
        _swipeToChooseGesture = pressGesture;
    }
    return _swipeToChooseGesture;
}

- (void)setDataSource:(id<TFYCa_CalendarDataSource>)dataSource
{
    self.dataSourceProxy.delegation = dataSource;
}

- (id<TFYCa_CalendarDataSource>)dataSource
{
    return self.dataSourceProxy.delegation;
}

- (void)setDelegate:(id<TFYCa_CalendarDelegate>)delegate
{
    self.delegateProxy.delegation = delegate;
}

- (id<TFYCa_CalendarDelegate>)delegate
{
    return self.delegateProxy.delegation;
}

#pragma mark - Public methods

- (void)reloadData
{
    _needsRequestingBoundingDates = YES;
    if ([self requestBoundingDatesIfNecessary] || !self.collectionView.indexPathsForVisibleItems.count) {
        [self invalidateHeaders];
    }
    [self.collectionView reloadData];
}

- (void)setScope:(TFYCa_CalendarScope)scope animated:(BOOL)animated
{
    if (self.floatingMode) return;
    if (self.transitionCoordinator.state != TFYCa_CalendarTransitionStateIdle) return;
    
    [self performEnsuringValidLayout:^{
        [self.transitionCoordinator performScopeTransitionFromScope:self.scope toScope:scope animated:animated];
    }];
}

- (void)setPlaceholderType:(TFYCa_CalendarPlaceholderType)placeholderType
{
    _placeholderType = placeholderType;
    if (self.hasValidateVisibleLayout) {
        _preferredRowHeight = TFYCa_CalendarAutomaticDimension;
        [_collectionView reloadData];
    }
    [self adjustBoundingRectIfNecessary];
}

- (void)setAdjustsBoundingRectWhenChangingMonths:(BOOL)adjustsBoundingRectWhenChangingMonths
{
    _adjustsBoundingRectWhenChangingMonths = adjustsBoundingRectWhenChangingMonths;
    [self adjustBoundingRectIfNecessary];
}

- (void)selectDate:(NSDate *)date
{
    [self selectDate:date scrollToDate:YES];
}

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate
{
    [self selectDate:date scrollToDate:scrollToDate atMonthPosition:TFYCa_CalendarMonthPositionCurrent];
}

- (void)deselectDate:(NSDate *)date
{
    date = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    if (![_selectedDates containsObject:date]) {
        return;
    }
    [_selectedDates removeObject:date];
    [self deselectCounterpartDate:date];
    NSIndexPath *indexPath = [self.calculator indexPathForDate:date];
    if ([_collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:YES];
        TFY_CalendarCell *cell = (TFY_CalendarCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        [cell configureAppearance];
    }
}

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate atMonthPosition:(TFYCa_CalendarMonthPosition)monthPosition
{
    if (!self.allowsSelection || !date) return;
        
    [self requestBoundingDatesIfNecessary];
    
    TFYCa_CalendarAssertDateInBounds(date,self.gregorian,self.minimumDate,self.maximumDate);
    
    NSDate *targetDate = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    NSIndexPath *targetIndexPath = [self.calculator indexPathForDate:targetDate];
    
    BOOL shouldSelect = YES;
    // 跨月份点击
    if (monthPosition==TFYCa_CalendarMonthPositionPrevious||monthPosition==TFYCa_CalendarMonthPositionNext) {
        if (self.allowsMultipleSelection) {
            if ([self isDateSelected:targetDate]) {
                BOOL shouldDeselect = ![self.delegateProxy respondsToSelector:@selector(calendar:shouldDeselectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldDeselectDate:targetDate atMonthPosition:monthPosition];
                if (!shouldDeselect) {
                    return;
                }
            } else {
                shouldSelect &= (![self.delegateProxy respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldSelectDate:targetDate atMonthPosition:monthPosition]);
                if (!shouldSelect) {
                    return;
                }
                [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                [self collectionView:_collectionView didSelectItemAtIndexPath:targetIndexPath];
            }
        } else {
            shouldSelect &= (![self.delegateProxy respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldSelectDate:targetDate atMonthPosition:monthPosition]);
            if (shouldSelect) {
                if ([self isDateSelected:targetDate]) {
                    [self.delegateProxy calendar:self didSelectDate:targetDate atMonthPosition:monthPosition];
                } else {
                    NSDate *selectedDate = self.selectedDate;
                    if (selectedDate) {
                        [self deselectDate:selectedDate];
                    }
                    [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    [self collectionView:_collectionView didSelectItemAtIndexPath:targetIndexPath];
                }
            } else {
                return;
            }
        }
        
    } else if (![self isDateSelected:targetDate]){
        if (self.selectedDate && !self.allowsMultipleSelection) {
            [self deselectDate:self.selectedDate];
        }
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        TFY_CalendarCell *cell = (TFY_CalendarCell *)[_collectionView cellForItemAtIndexPath:targetIndexPath];
        [cell performSelecting];
        [self enqueueSelectedDate:targetDate];
        [self selectCounterpartDate:targetDate];
        
    } else if (![_collectionView.indexPathsForSelectedItems containsObject:targetIndexPath]) {
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    if (scrollToDate) {
        if (!shouldSelect) {
            return;
        }
        [self scrollToPageForDate:targetDate animated:YES];
    }
}

- (void)handleScopeGesture:(UIPanGestureRecognizer *)sender
{
    if (self.floatingMode) return;
    [self.transitionCoordinator handleScopeGesture:sender];
}

#pragma mark - Private methods

- (void)scrollToDate:(NSDate *)date
{
    [self scrollToDate:date animated:NO];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    if (!_minimumDate || !_maximumDate) {
        return;
    }
    animated &= _scrollEnabled; // No animation if _scrollEnabled == NO;
    
    date = [self.calculator safeDateForDate:date];
    NSInteger scrollOffset = [self.calculator indexPathForDate:date atMonthPosition:TFYCa_CalendarMonthPositionCurrent].section;
    
    if (!self.floatingMode) {
        switch (_collectionViewLayout.scrollDirection) {
            case UICollectionViewScrollDirectionVertical: {
                [_collectionView setContentOffset:CGPointMake(0, scrollOffset * _collectionView.tfyCa_height) animated:animated];
                break;
            }
            case UICollectionViewScrollDirectionHorizontal: {
                [_collectionView setContentOffset:CGPointMake(scrollOffset * _collectionView.tfyCa_width, 0) animated:animated];
                break;
            }
        }
        
    } else if (self.hasValidateVisibleLayout) {
        [_collectionViewLayout layoutAttributesForElementsInRect:_collectionView.bounds];
        CGRect headerFrame = [_collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:scrollOffset]].frame;
        CGPoint targetOffset = CGPointMake(0, MIN(headerFrame.origin.y,MAX(0,_collectionViewLayout.collectionViewContentSize.height-_collectionView.tfyCa_bottom)));
        [_collectionView setContentOffset:targetOffset animated:animated];
    }
    if (!animated) {
        self.calendarHeaderView.scrollOffset = scrollOffset;
    }
}

- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date) return;
    if (![self isDateInRange:date]) {
        date = [self.calculator safeDateForDate:date];
        if (!date) return;
    }
    
    if (!self.floatingMode) {
        if ([self isDateInDifferentPage:date]) {
            [self willChangeValueForKey:@"currentPage"];
            NSDate *lastPage = _currentPage;
            switch (self.transitionCoordinator.representingScope) {
                case TFYCa_CalendarScopeMonth: {
                    _currentPage = [self.gregorian tfyCa_firstDayOfMonth:date];
                    break;
                }
                case TFYCa_CalendarScopeWeek: {
                    _currentPage = [self.gregorian tfyCa_firstDayOfWeek:date];
                    break;
                }
            }
            if (self.hasValidateVisibleLayout) {
                [self.delegateProxy calendarCurrentPageDidChange:self];
                if (_placeholderType != TFYCa_CalendarPlaceholderTypeFillSixRows && self.transitionCoordinator.state == TFYCa_CalendarTransitionStateIdle) {
                    [self.transitionCoordinator performBoundingRectTransitionFromMonth:lastPage toMonth:_currentPage duration:0.33];
                }
            }
            [self didChangeValueForKey:@"currentPage"];
        }
        [self scrollToDate:_currentPage animated:animated];
    } else {
        [self scrollToDate:[self.gregorian tfyCa_firstDayOfMonth:date] animated:animated];
    }
}


- (BOOL)isDateInRange:(NSDate *)date
{
    BOOL flag = YES;
    flag &= [self.gregorian components:NSCalendarUnitDay fromDate:date toDate:self.minimumDate options:0].day <= 0;
    flag &= [self.gregorian components:NSCalendarUnitDay fromDate:date toDate:self.maximumDate options:0].day >= 0;;
    return flag;
}

- (BOOL)isPageInRange:(NSDate *)page
{
    BOOL flag = YES;
    switch (self.transitionCoordinator.representingScope) {
        case TFYCa_CalendarScopeMonth: {
            NSDateComponents *c1 = [self.gregorian components:NSCalendarUnitDay fromDate:[self.gregorian tfyCa_firstDayOfMonth:self.minimumDate] toDate:page options:0];
            flag &= (c1.day>=0);
            if (!flag) break;
            NSDateComponents *c2 = [self.gregorian components:NSCalendarUnitDay fromDate:page toDate:[self.gregorian tfyCa_lastDayOfMonth:self.maximumDate] options:0];
            flag &= (c2.day>=0);
            break;
        }
        case TFYCa_CalendarScopeWeek: {
            NSDateComponents *c1 = [self.gregorian components:NSCalendarUnitDay fromDate:[self.gregorian tfyCa_firstDayOfWeek:self.minimumDate] toDate:page options:0];
            flag &= (c1.day>=0);
            if (!flag) break;
            NSDateComponents *c2 = [self.gregorian components:NSCalendarUnitDay fromDate:page toDate:[self.gregorian tfyCa_lastDayOfWeek:self.maximumDate] options:0];
            flag &= (c2.day>=0);
            break;
        }
        default:
            break;
    }
    return flag;
}

- (BOOL)isDateSelected:(NSDate *)date
{
    return [_selectedDates containsObject:date] || [_collectionView.indexPathsForSelectedItems containsObject:[self.calculator indexPathForDate:date]];
}

- (BOOL)isDateInDifferentPage:(NSDate *)date
{
    if (self.floatingMode) {
        return ![self.gregorian isDate:date equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth];
    }
    switch (_scope) {
        case TFYCa_CalendarScopeMonth:
            return ![self.gregorian isDate:date equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth];
        case TFYCa_CalendarScopeWeek:
            return ![self.gregorian isDate:date equalToDate:_currentPage toUnitGranularity:NSCalendarUnitWeekOfYear];
    }
}

- (BOOL)hasValidateVisibleLayout
{
#if TARGET_INTERFACE_BUILDER
    return YES;
#else
    return self.superview  && !CGRectIsEmpty(_collectionView.frame) && !CGSizeEqualToSize(_collectionViewLayout.collectionViewContentSize, CGSizeZero);
#endif
}

- (void)invalidateDateTools
{
    _gregorian.locale = _locale;
    _gregorian.timeZone = _timeZone;
    _gregorian.firstWeekday = _firstWeekday;
    _formatter.calendar = _gregorian;
    _formatter.timeZone = _timeZone;
    _formatter.locale = _locale;
}

- (void)invalidateLayout
{
    if (!self.floatingMode) {
        
        if (!_calendarHeaderView) {
            
            TFY_CalendarHeaderView *headerView = [[TFY_CalendarHeaderView alloc] initWithFrame:CGRectZero];
            headerView.calendar = self;
            headerView.scrollEnabled = _scrollEnabled;
            [_contentView addSubview:headerView];
            self.calendarHeaderView = headerView;
            
        }
        
        if (!_calendarWeekdayView) {
            TFY_CalendarWeekdayView *calendarWeekdayView = [[TFY_CalendarWeekdayView alloc] initWithFrame:CGRectZero];
            calendarWeekdayView.calendar = self;
            [_contentView addSubview:calendarWeekdayView];
            _calendarWeekdayView = calendarWeekdayView;
        }
        
        if (_scrollEnabled) {
            if (!_deliver) {
                TFY_CalendarHeaderTouchDeliver *deliver = [[TFY_CalendarHeaderTouchDeliver alloc] initWithFrame:CGRectZero];
                deliver.header = _calendarHeaderView;
                deliver.calendar = self;
                [_contentView addSubview:deliver];
                self.deliver = deliver;
            }
        } else if (_deliver) {
            [_deliver removeFromSuperview];
        }
        
        _collectionView.pagingEnabled = YES;
        _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.scrollDirection;
        
    } else {
        
        [self.calendarHeaderView removeFromSuperview];
        [self.deliver removeFromSuperview];
        [self.calendarWeekdayView removeFromSuperview];
        
        _collectionView.pagingEnabled = NO;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
    }
    
    _preferredHeaderHeight = TFYCa_CalendarAutomaticDimension;
    _preferredWeekdayHeight = TFYCa_CalendarAutomaticDimension;
    _preferredRowHeight = TFYCa_CalendarAutomaticDimension;
    _needsAdjustingViewFrame = YES;
    [self setNeedsLayout];
}

- (void)invalidateHeaders
{
    [self.calendarHeaderView.collectionView reloadData];
    [self.visibleStickyHeaders makeObjectsPerformSelector:@selector(configureAppearance)];
}

- (void)invalidateAppearanceForCell:(TFY_CalendarCell *)cell forDate:(NSDate *)date
{
    TFYCa_CalendarInvalidateCellAppearance(preferredFillDefaultColor,fillDefaultColorForDate);
    TFYCa_CalendarInvalidateCellAppearance(preferredFillSelectionColor,fillSelectionColorForDate);
    TFYCa_CalendarInvalidateCellAppearance(preferredTitleDefaultColor,titleDefaultColorForDate);
    TFYCa_CalendarInvalidateCellAppearance(preferredTitleSelectionColor,titleSelectionColorForDate);

    TFYCa_CalendarInvalidateCellAppearanceWithDefault(preferredTitleOffset,titleOffsetForDate,CGPointInfinity);
    if (cell.subtitle) {
        TFYCa_CalendarInvalidateCellAppearance(preferredSubtitleDefaultColor,subtitleDefaultColorForDate);
        TFYCa_CalendarInvalidateCellAppearance(preferredSubtitleSelectionColor,subtitleSelectionColorForDate);
        TFYCa_CalendarInvalidateCellAppearanceWithDefault(preferredSubtitleOffset,subtitleOffsetForDate,CGPointInfinity);
    }
    if (cell.numberOfEvents) {
        TFYCa_CalendarInvalidateCellAppearance(preferredEventDefaultColors,eventDefaultColorsForDate);
        TFYCa_CalendarInvalidateCellAppearance(preferredEventSelectionColors,eventSelectionColorsForDate);
        TFYCa_CalendarInvalidateCellAppearanceWithDefault(preferredEventOffset,eventOffsetForDate,CGPointInfinity);
    }
    TFYCa_CalendarInvalidateCellAppearance(preferredBorderDefaultColor,borderDefaultColorForDate);
    TFYCa_CalendarInvalidateCellAppearance(preferredBorderSelectionColor,borderSelectionColorForDate);
    TFYCa_CalendarInvalidateCellAppearanceWithDefault(preferredBorderRadius,borderRadiusForDate,-1);

    if (cell.image) {
        TFYCa_CalendarInvalidateCellAppearanceWithDefault(preferredImageOffset,imageOffsetForDate,CGPointInfinity);
    }
    
#undef TFYCa_CalendarInvalidateCellAppearance
#undef TFYCa_CalendarInvalidateCellAppearanceWithDefault
    
}

- (void)reloadDataForCell:(TFY_CalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.calendar = self;
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    cell.image = [self.dataSourceProxy calendar:self imageForDate:date];
    cell.numberOfEvents = [self.dataSourceProxy calendar:self numberOfEventsForDate:date];
    cell.titleLabel.text = [self.dataSourceProxy calendar:self titleForDate:date] ?: @([self.gregorian component:NSCalendarUnitDay fromDate:date]).stringValue;
    cell.subtitle  = [self.dataSourceProxy calendar:self subtitleForDate:date];
    cell.selected = [_selectedDates containsObject:date];
    cell.dateIsToday = self.today?[self.gregorian isDate:date inSameDayAsDate:self.today]:NO;
    cell.weekend = [self.gregorian isDateInWeekend:date];
    cell.monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    switch (self.transitionCoordinator.representingScope) {
        case TFYCa_CalendarScopeMonth: {
            cell.placeholder = (cell.monthPosition == TFYCa_CalendarMonthPositionPrevious || cell.monthPosition == TFYCa_CalendarMonthPositionNext) || ![self isDateInRange:date];
            if (cell.placeholder) {
                cell.selected &= _pagingEnabled;
                cell.dateIsToday &= _pagingEnabled;
            }
            break;
        }
        case TFYCa_CalendarScopeWeek: {
            cell.placeholder = ![self isDateInRange:date];
            break;
        }
    }
    // Synchronize selecion state to the collection view, otherwise delegate methods would not be triggered.
    if (cell.selected) {
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [self invalidateAppearanceForCell:cell forDate:date];
    [cell configureAppearance];
}


- (void)handleSwipeToChoose:(UILongPressGestureRecognizer *)pressGesture
{
    switch (pressGesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[pressGesture locationInView:self.collectionView]];
            if (indexPath && ![indexPath isEqual:self.lastPressedIndexPath]) {
                NSDate *date = [self.calculator dateForIndexPath:indexPath];
                TFYCa_CalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
                if (![self.selectedDates containsObject:date] && [self collectionView:self.collectionView shouldSelectItemAtIndexPath:indexPath]) {
                    [self selectDate:date scrollToDate:NO atMonthPosition:monthPosition];
                    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
                } else if (self.collectionView.allowsMultipleSelection && [self collectionView:self.collectionView shouldDeselectItemAtIndexPath:indexPath]) {
                    [self deselectDate:date];
                    [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
                }
            }
            self.lastPressedIndexPath = indexPath;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.lastPressedIndexPath = nil;
            break;
        }
        default:
            break;
    }
   
}

- (void)selectCounterpartDate:(NSDate *)date
{
    if (_placeholderType == TFYCa_CalendarPlaceholderTypeNone) return;
    if (self.scope == TFYCa_CalendarScopeWeek) return;
    NSInteger numberOfDays = [self.gregorian tfyCa_numberOfDaysInMonth:date];
    NSInteger day = [self.gregorian component:NSCalendarUnitDay fromDate:date];
    TFY_CalendarCell *cell;
    if (day < numberOfDays/2+1) {
        cell = [self cellForDate:date atMonthPosition:TFYCa_CalendarMonthPositionNext];
    } else {
        cell = [self cellForDate:date atMonthPosition:TFYCa_CalendarMonthPositionPrevious];
    }
    if (cell) {
        cell.selected = YES;
        if (self.collectionView.allowsMultipleSelection) {
            [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForCell:cell] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    [cell configureAppearance];
}

- (void)deselectCounterpartDate:(NSDate *)date
{
    if (_placeholderType == TFYCa_CalendarPlaceholderTypeNone) return;
    if (self.scope == TFYCa_CalendarScopeWeek) return;
    NSInteger numberOfDays = [self.gregorian tfyCa_numberOfDaysInMonth:date];
    NSInteger day = [self.gregorian component:NSCalendarUnitDay fromDate:date];
    TFY_CalendarCell *cell;
    if (day < numberOfDays/2+1) {
        cell = [self cellForDate:date atMonthPosition:TFYCa_CalendarMonthPositionNext];
    } else {
        cell = [self cellForDate:date atMonthPosition:TFYCa_CalendarMonthPositionPrevious];
    }
    if (cell) {
        cell.selected = NO;
        [self.collectionView deselectItemAtIndexPath:[self.collectionView indexPathForCell:cell] animated:NO];
    }
    [cell configureAppearance];
}

- (void)enqueueSelectedDate:(NSDate *)date
{
    if (!self.allowsMultipleSelection) {
        [_selectedDates removeAllObjects];
    }
    if (![_selectedDates containsObject:date]) {
        [_selectedDates addObject:date];
    }
}

- (NSArray *)visibleStickyHeaders
{
    return [self.visibleSectionHeaders.dictionaryRepresentation allValues];
}

- (void)invalidateViewFrames
{
    _needsAdjustingViewFrame = YES;
    
    _preferredHeaderHeight  = TFYCa_CalendarAutomaticDimension;
    _preferredWeekdayHeight = TFYCa_CalendarAutomaticDimension;
    _preferredRowHeight     = TFYCa_CalendarAutomaticDimension;
    
    [self setNeedsLayout];
    
}

- (TFYCa_CalendarOrientation)currentCalendarOrientation
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize nativeSize = [UIScreen mainScreen].currentMode.size;
    CGSize sizeInPoints = [UIScreen mainScreen].bounds.size;
    TFYCa_CalendarOrientation orientation = scale * sizeInPoints.width == nativeSize.width ? TFYCa_CalendarOrientationPortrait : TFYCa_CalendarOrientationLandscape;
    return orientation;
}

- (void)adjustMonthPosition
{
    [self requestBoundingDatesIfNecessary];
    NSDate *targetPage = self.pagingEnabled?self.currentPage:(self.currentPage?:self.selectedDate);
    [self scrollToPageForDate:targetPage animated:NO];
}

- (BOOL)requestBoundingDatesIfNecessary
{
    if (_needsRequestingBoundingDates) {
        _needsRequestingBoundingDates = NO;
        self.formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *newMin = [self.dataSourceProxy minimumDateForCalendar:self]?:[self.formatter dateFromString:@"1970-01-01"];
        newMin = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:newMin options:0];
        NSDate *newMax = [self.dataSourceProxy maximumDateForCalendar:self]?:[self.formatter dateFromString:@"2099-12-31"];
        newMax = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:newMax options:0];
        
        NSAssert([self.gregorian compareDate:newMin toDate:newMax toUnitGranularity:NSCalendarUnitDay] != NSOrderedDescending, @"The minimum date of calendar should be earlier than the maximum.");
        
        BOOL res = ![self.gregorian isDate:newMin inSameDayAsDate:_minimumDate] || ![self.gregorian isDate:newMax inSameDayAsDate:_maximumDate];
        _minimumDate = newMin;
        _maximumDate = newMax;
        [self.calculator reloadSections];
        
        return res;
    }
    return NO;
}

- (void)configureAppearance
{
    [self.visibleCells makeObjectsPerformSelector:@selector(configureAppearance)];
    [self.visibleStickyHeaders makeObjectsPerformSelector:@selector(configureAppearance)];
    [self.calendarHeaderView configureAppearance];
    [self.calendarWeekdayView configureAppearance];
}

- (void)adjustBoundingRectIfNecessary
{
    if (self.placeholderType == TFYCa_CalendarPlaceholderTypeFillSixRows) {
        return;
    }
    if (!self.adjustsBoundingRectWhenChangingMonths) {
        return;
    }
    [self performEnsuringValidLayout:^{
        if (@available(iOS 13.0, *)) {
            [self.transitionCoordinator performBoundingRectTransitionFromMonth:[NSDate now] toMonth:self.currentPage duration:0];
        }
    }];
}

- (void)performEnsuringValidLayout:(void (^)(void))block
{
    if (self.collectionView.visibleCells.count) {
        block();
    } else {
        [self setNeedsLayout];
        [self.didLayoutOperations addObject:[NSBlockOperation blockOperationWithBlock:block]];
    }
}

- (void)executePendingOperationsIfNeeded
{
    NSArray<NSOperation *> *operations = nil;
    if (self.didLayoutOperations.count) {
        operations = self.didLayoutOperations.copy;
        [self.didLayoutOperations removeAllObjects];
    }
    [operations makeObjectsPerformSelector:@selector(start)];
}



@end
