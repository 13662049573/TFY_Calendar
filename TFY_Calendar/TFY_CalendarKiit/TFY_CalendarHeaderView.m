//
//  TFY_CalendarHeaderView.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarHeaderView.h"
#import "TFY_CalendarExtensions.h"
#import "TFY_Calendar.h"
#import "TFY_CalendarCollectionView.h"
#import "TFY_CalendarDynamic.h"

@interface TFY_CalendarHeaderView ()<UICollectionViewDataSource,UICollectionViewDelegate,TFYCa_CalendarCollectionViewInternalDelegate>
@end

@implementation TFY_CalendarHeaderView
#pragma mark - Life cycle

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
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _scrollEnabled = YES;
    
    TFY_CalendarHeaderLayout *collectionViewLayout = [[TFY_CalendarHeaderLayout alloc] init];
    self.collectionViewLayout = collectionViewLayout;
    
    TFY_CalendarCollectionView *collectionView = [[TFY_CalendarCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.scrollEnabled = NO;
    collectionView.userInteractionEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:collectionView];
    [collectionView registerClass:[TFY_CalendarHeaderCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView = collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, self.tfyCa_height*0.1, self.tfyCa_width, self.tfyCa_height*0.9);
}

- (void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfSections = self.calendar.collectionView.numberOfSections;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return numberOfSections;
    }
    return numberOfSections + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFY_CalendarHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.header = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

#pragma mark - Properties

- (void)setCalendar:(TFY_Calendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (void)setScrollOffset:(CGFloat)scrollOffset
{
    [self setScrollOffset:scrollOffset animated:NO];
}

- (void)setScrollOffset:(CGFloat)scrollOffset animated:(BOOL)animated
{
    [self scrollToOffset:scrollOffset animated:NO];
}

- (void)scrollToOffset:(CGFloat)scrollOffset animated:(BOOL)animated
{
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat step = self.collectionView.tfyCa_width*((self.scrollDirection==UICollectionViewScrollDirectionHorizontal)?0.5:1);
        [_collectionView setContentOffset:CGPointMake((scrollOffset+0.5)*step, 0) animated:animated];
    } else {
        CGFloat step = self.collectionView.tfyCa_height;
        [_collectionView setContentOffset:CGPointMake(0, scrollOffset*step) animated:animated];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _collectionViewLayout.scrollDirection = scrollDirection;
        [self setNeedsLayout];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

#pragma mark - Public

- (void)reloadData
{
    [_collectionView reloadData];
}

- (void)configureCell:(TFY_CalendarHeaderCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TFY_CalendarAppearance *appearance = self.calendar.appearance;
    cell.titlebtn.titleLabel.font = appearance.headerTitleFont;
    [cell.titlebtn setTitleColor:appearance.headerTitleColor forState:UIControlStateNormal];
    cell.titlebtn.contentHorizontalAlignment = appearance.contentHorizontalAlignment;
    
    _calendar.formatter.dateFormat = appearance.headerDateFormat;
    BOOL usesUpperCase = (appearance.caseOptions & 15) == TFYCa_CalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = nil;
    switch (self.calendar.transitionCoordinator.representingScope) {
        case TFYCa_CalendarScopeMonth: {
            if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                // 多出的两项需要制空
                if ((indexPath.item == 0 || indexPath.item == [self.collectionView numberOfItemsInSection:0] - 1)) {
                    text = nil;
                } else {
                    NSDate *date = [self.calendar.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.item-1 toDate:self.calendar.minimumDate options:0];
                    text = [_calendar.formatter stringFromDate:date];
                }
            } else {
                NSDate *date = [self.calendar.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.item toDate:self.calendar.minimumDate options:0];
                text = [_calendar.formatter stringFromDate:date];
            }
            break;
        }
        case TFYCa_CalendarScopeWeek: {
            if ((indexPath.item == 0 || indexPath.item == [self.collectionView numberOfItemsInSection:0] - 1)) {
                text = nil;
            } else {
                NSDate *firstPage = [self.calendar.gregorian tfyCa_middleDayOfWeek:self.calendar.minimumDate];
                NSDate *date = [self.calendar.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:indexPath.item-1 toDate:firstPage options:0];
                text = [_calendar.formatter stringFromDate:date];
            }
            break;
        }
        default: {
            break;
        }
    }
    text = usesUpperCase ? text.uppercaseString : text;
    [cell.titlebtn setTitle:text forState:UIControlStateNormal];
    [cell setNeedsLayout];
}

- (void)configureAppearance
{
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof TFY_CalendarHeaderCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        [self configureCell:cell atIndexPath:[self.collectionView indexPathForCell:cell]];
    }];
}



@end


@implementation TFY_CalendarHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *titlebtn = [[UIButton alloc] initWithFrame:CGRectZero];
        titlebtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titlebtn.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titlebtn];
        self.titlebtn = titlebtn;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.titlebtn.frame = bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.header.calendar.appearance.liftrightSpacing > 0) {
        CGFloat spacing = self.header.calendar.appearance.liftrightSpacing;
        self.titlebtn.frame = CGRectMake(spacing, 0, CGRectGetWidth(self.contentView.bounds)-2*spacing, CGRectGetHeight(self.contentView.bounds));
    } else {
        self.titlebtn.frame = self.contentView.bounds;
    }

    if (self.header.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].x;
        CGFloat center = CGRectGetMidX(self.header.bounds);
        if (self.header.scrollEnabled) {
            self.contentView.alpha = 1.0 - (1.0-self.header.calendar.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.tfyCa_width;
        } else {
            self.contentView.alpha = (position > self.header.tfyCa_width*0.25 && position < self.header.tfyCa_width*0.75);
        }
    } else if (self.header.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].y;
        CGFloat center = CGRectGetMidY(self.header.bounds);
        self.contentView.alpha = 1.0 - (1.0-self.header.calendar.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.tfyCa_height;
    }
}

@end


@implementation TFY_CalendarHeaderLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.sectionInset = UIEdgeInsetsZero;
        self.itemSize = CGSizeMake(1, 1);
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveOrientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(self.collectionView.tfyCa_width*((self.scrollDirection==UICollectionViewScrollDirectionHorizontal)?0.5:1),
                               self.collectionView.tfyCa_height
                              );
    
}

- (void)didReceiveOrientationChangeNotification:(NSNotification *)notificatino
{
    [self invalidateLayout];
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection
{
    return YES;
}

@end

@implementation TFY_CalendarHeaderTouchDeliver

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return _calendar.collectionView ?: hitView;
    }
    return hitView;
}

@end


