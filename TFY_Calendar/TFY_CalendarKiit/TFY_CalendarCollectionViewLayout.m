//
//  TFY_CalendarCollectionViewLayout.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarCollectionViewLayout.h"
#import "TFY_Calendar.h"
#import "TFY_CalendarDynamic.h"
#import "TFY_CalendarCollectionView.h"
#import "TFY_CalendarExtensions.h"
#import "TFY_CalendarConstants.h"
#import "TFY_CalendarCalculator.h"
#import "TFY_CalendarSeparatorDecorationView.h"

#define kTFY_CalendarSeparatorInterRows @"TFY_CalendarSeparatorInterRows"
#define kTFY_CalendarSeparatorInterColumns @"TFY_CalendarSeparatorInterColumns"

@interface TFY_CalendarCollectionViewLayout ()
@property (assign, nonatomic) CGFloat *widths;
@property (assign, nonatomic) CGFloat *heights;
@property (assign, nonatomic) CGFloat *lefts;
@property (assign, nonatomic) CGFloat *tops;

@property (assign, nonatomic) CGFloat *sectionHeights;
@property (assign, nonatomic) CGFloat *sectionTops;
@property (assign, nonatomic) CGFloat *sectionBottoms;
@property (assign, nonatomic) CGFloat *sectionRowCounts;

@property (assign, nonatomic) CGSize estimatedItemSize;

@property (assign, nonatomic) CGSize contentSize;
@property (assign, nonatomic) CGSize collectionViewSize;
@property (assign, nonatomic) CGSize headerReferenceSize;
@property (assign, nonatomic) NSInteger numberOfSections;

@property (assign, nonatomic) TFYCa_CalendarSeparators separators;

@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *itemAttributes;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *headerAttributes;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *rowSeparatorAttributes;

@end

@implementation TFY_CalendarCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.estimatedItemSize = CGSizeZero;
        self.widths = NULL;
        self.heights = NULL;
        self.tops = NULL;
        self.lefts = NULL;
        
        self.sectionHeights = NULL;
        self.sectionTops = NULL;
        self.sectionBottoms = NULL;
        self.sectionRowCounts = NULL;
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        
        self.itemAttributes = NSMutableDictionary.dictionary;
        self.headerAttributes = NSMutableDictionary.dictionary;
        self.rowSeparatorAttributes = NSMutableDictionary.dictionary;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [self registerClass:TFY_CalendarSeparatorDecorationView.class forDecorationViewOfKind:kTFY_CalendarSeparatorInterRows];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    free(self.widths);
    free(self.heights);
    free(self.tops);
    free(self.lefts);
    
    free(self.sectionHeights);
    free(self.sectionTops);
    free(self.sectionRowCounts);
    free(self.sectionBottoms);
}

- (void)prepareLayout
{
    if (CGSizeEqualToSize(self.collectionViewSize, self.collectionView.frame.size) && self.numberOfSections == self.collectionView.numberOfSections && self.separators == self.calendar.appearance.separators) {
        return;
    }
    self.collectionViewSize = self.collectionView.frame.size;
    self.separators = self.calendar.appearance.separators;
    
    [self.itemAttributes removeAllObjects];
    [self.headerAttributes removeAllObjects];
    [self.rowSeparatorAttributes removeAllObjects];
    
    self.headerReferenceSize = ({
        CGSize headerSize = CGSizeZero;
        if (self.calendar.floatingMode) {
            CGFloat headerHeight = self.calendar.preferredWeekdayHeight*1.5+self.calendar.preferredHeaderHeight;
            headerSize = CGSizeMake(self.collectionView.tfyCa_width, headerHeight);
        }
        headerSize;
    });
    self.estimatedItemSize = ({
        CGFloat width = (self.collectionView.tfyCa_width-self.sectionInsets.left-self.sectionInsets.right)/7.0;
        CGFloat height = ({
            CGFloat height = TFYCa_CalendarStandardRowHeight;
            if (!self.calendar.floatingMode) {
                switch (self.calendar.transitionCoordinator.representingScope) {
                    case TFYCa_CalendarScopeMonth: {
                        height = (self.collectionView.tfyCa_height-self.sectionInsets.top-self.sectionInsets.bottom)/6.0;
                        break;
                    }
                    case TFYCa_CalendarScopeWeek: {
                        height = (self.collectionView.tfyCa_height-self.sectionInsets.top-self.sectionInsets.bottom);
                        break;
                    }
                    default:
                        break;
                }
            } else {
                height = self.calendar.rowHeight;
            }
            height;
        });
        CGSize size = CGSizeMake(width, height);
        size;
    });
    
    //计算项目的宽度和左边
    free(self.widths);
    self.widths = ({
        NSInteger columnCount = 7;
        size_t columnSize = sizeof(CGFloat)*columnCount;
        CGFloat *widths = malloc(columnSize);
        CGFloat contentWidth = self.collectionView.tfyCa_width - self.sectionInsets.left - self.sectionInsets.right;
        TFYCa_CalendarSliceCake(contentWidth, columnCount, widths);
        widths;
    });
    
    free(self.lefts);
    self.lefts = ({
        NSInteger columnCount = 7;
        size_t columnSize = sizeof(CGFloat)*columnCount;
        CGFloat *lefts = malloc(columnSize);
        lefts[0] = self.sectionInsets.left;
        for (int i = 1; i < columnCount; i++) {
            lefts[i] = lefts[i-1] + self.widths[i-1];
        }
        lefts;
    });
    
    // 计算物品的高度和顶部
    free(self.heights);
    self.heights = ({
        NSInteger rowCount = self.calendar.transitionCoordinator.representingScope == TFYCa_CalendarScopeWeek ? 1 : 6;
        size_t rowSize = sizeof(CGFloat)*rowCount;
        CGFloat *heights = malloc(rowSize);
        if (!self.calendar.floatingMode) {
            CGFloat contentHeight = self.collectionView.tfyCa_height - self.sectionInsets.top - self.sectionInsets.bottom;
            TFYCa_CalendarSliceCake(contentHeight, rowCount, heights);
        } else {
            for (int i = 0; i < rowCount; i++) {
                heights[i] = self.estimatedItemSize.height;
            }
        }
        heights;
    });
    
    free(self.tops);
    self.tops = ({
        NSInteger rowCount = self.calendar.transitionCoordinator.representingScope == TFYCa_CalendarScopeWeek ? 1 : 6;
        size_t rowSize = sizeof(CGFloat)*rowCount;
        CGFloat *tops = malloc(rowSize);
        tops[0] = self.sectionInsets.top;
        for (int i = 1; i < rowCount; i++) {
            tops[i] = tops[i-1] + self.heights[i-1];
        }
        tops;
    });
    
    // 计算内容大小
    self.numberOfSections = self.collectionView.numberOfSections;
    self.contentSize = ({
        CGSize contentSize = CGSizeZero;
        if (!self.calendar.floatingMode) {
            CGFloat width = self.collectionView.tfyCa_width;
            CGFloat height = self.collectionView.tfyCa_height;
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    width *= self.numberOfSections;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    height *= self.numberOfSections;
                    break;
                }
                default:
                    break;
            }
            contentSize = CGSizeMake(width, height);
        } else {
            free(self.sectionHeights);
            self.sectionHeights = malloc(sizeof(CGFloat)*self.numberOfSections);
            free(self.sectionRowCounts);
            self.sectionRowCounts = malloc(sizeof(NSInteger)*self.numberOfSections);
            CGFloat width = self.collectionView.tfyCa_width;
            CGFloat height = 0;
            for (int i = 0; i < self.numberOfSections; i++) {
                NSInteger rowCount = [self.calendar.calculator numberOfRowsInSection:i];
                self.sectionRowCounts[i] = rowCount;
                CGFloat sectionHeight = self.headerReferenceSize.height;
                for (int j = 0; j < rowCount; j++) {
                    sectionHeight += self.heights[j];
                }
                self.sectionHeights[i] = sectionHeight;
                height += sectionHeight;
            }
            free(self.sectionTops);
            self.sectionTops = malloc(sizeof(CGFloat)*self.numberOfSections);
            free(self.sectionBottoms);
            self.sectionBottoms = malloc(sizeof(CGFloat)*self.numberOfSections);
            self.sectionTops[0] = 0;
            self.sectionBottoms[0] = self.sectionHeights[0];
            for (int i = 1; i < self.numberOfSections; i++) {
                self.sectionTops[i] = self.sectionTops[i-1] + self.sectionHeights[i-1];
                self.sectionBottoms[i] = self.sectionTops[i] + self.sectionHeights[i];
            }
            contentSize = CGSizeMake(width, height);
        }
        contentSize;
    });
    
    [self.calendar adjustMonthPosition];
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 剪裁
    rect = CGRectIntersection(rect, CGRectMake(0, 0, self.contentSize.width, self.contentSize.height));
    if (CGRectIsEmpty(rect)) return nil;
    
    // 计算属性
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray array];
    
    if (!self.calendar.floatingMode) {
        
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
                
                NSInteger startColumn = ({
                    NSInteger startSection = rect.origin.x/self.collectionView.tfyCa_width;
                    CGFloat widthDelta = TFYCa_CalendarMod(CGRectGetMinX(rect), self.collectionView.tfyCa_width)-self.sectionInsets.left;
                    widthDelta = MIN(MAX(0, widthDelta), self.collectionView.tfyCa_width-self.sectionInsets.left);
                    NSInteger countDelta = TFYCa_CalendarFloor(widthDelta/self.estimatedItemSize.width);
                    NSInteger startColumn = startSection*7 + countDelta;
                    startColumn;
                });
                
                NSInteger endColumn = ({
                    NSInteger endColumn;
                    CGFloat section = CGRectGetMaxX(rect)/self.collectionView.tfyCa_width;
                    CGFloat remainder = TFYCa_CalendarMod(section, 1);
                    if (remainder <= MAX(100*FLT_EPSILON*ABS(remainder), FLT_MIN)) {
                        endColumn = TFYCa_CalendarFloor(section)*7 - 1;
                    } else {
                        CGFloat widthDelta = TFYCa_CalendarMod(CGRectGetMaxX(rect), self.collectionView.tfyCa_width)-self.sectionInsets.left;
                        widthDelta = MIN(MAX(0, widthDelta), self.collectionView.tfyCa_width - self.sectionInsets.left);
                        NSInteger countDelta = TFYCa_CalendarCeil(widthDelta/self.estimatedItemSize.width);
                        endColumn = TFYCa_CalendarFloor(section)*7 + countDelta - 1;
                    }
                    endColumn;
                });
                
                NSInteger numberOfRows = self.calendar.transitionCoordinator.representingScope == TFYCa_CalendarScopeMonth ? 6 : 1;
                
                for (NSInteger column = startColumn; column <= endColumn; column++) {
                    for (NSInteger row = 0; row < numberOfRows; row++) {
                        NSInteger section = column / 7;
                        NSInteger item = column % 7 + row * 7;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                        UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                        [layoutAttributes addObject:itemAttributes];
                        
                        UICollectionViewLayoutAttributes *rowSeparatorAttributes = [self layoutAttributesForDecorationViewOfKind:kTFY_CalendarSeparatorInterRows atIndexPath:indexPath];
                        if (rowSeparatorAttributes) {
                            [layoutAttributes addObject:rowSeparatorAttributes];
                        }
                    }
                }
                
                break;
            }
            case UICollectionViewScrollDirectionVertical: {
                
                NSInteger startRow = ({
                    NSInteger startSection = rect.origin.y/self.collectionView.tfyCa_height;
                    CGFloat heightDelta = TFYCa_CalendarMod(CGRectGetMinY(rect), self.collectionView.tfyCa_height)-self.sectionInsets.top;
                    heightDelta = MIN(MAX(0, heightDelta), self.collectionView.tfyCa_height-self.sectionInsets.top);
                    NSInteger countDelta = TFYCa_CalendarFloor(heightDelta/self.estimatedItemSize.height);
                    NSInteger startRow = startSection*6 + countDelta;
                    startRow;
                });
                
                NSInteger endRow = ({
                    NSInteger endRow;
                    CGFloat section = CGRectGetMaxY(rect)/self.collectionView.tfyCa_height;
                    CGFloat remainder = TFYCa_CalendarMod(section, 1);
                    if (remainder <= MAX(100*FLT_EPSILON*ABS(remainder), FLT_MIN)) {
                        endRow = TFYCa_CalendarFloor(section)*6 - 1;
                    } else {
                        CGFloat heightDelta = TFYCa_CalendarMod(CGRectGetMaxY(rect), self.collectionView.tfyCa_height)-self.sectionInsets.top;
                        heightDelta = MIN(MAX(0, heightDelta), self.collectionView.tfyCa_height-self.sectionInsets.top);
                        NSInteger countDelta = TFYCa_CalendarCeil(heightDelta/self.estimatedItemSize.height);
                        endRow = TFYCa_CalendarFloor(section)*6 + countDelta-1;
                    }
                    endRow;
                });
                
                for (NSInteger row = startRow; row <= endRow; row++) {
                    for (NSInteger column = 0; column < 7; column++) {
                        NSInteger section = row / 6;
                        NSInteger item = column + (row % 6) * 7;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                        UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                        [layoutAttributes addObject:itemAttributes];
                        
                        UICollectionViewLayoutAttributes *rowSeparatorAttributes = [self layoutAttributesForDecorationViewOfKind:kTFY_CalendarSeparatorInterRows atIndexPath:indexPath];
                        if (rowSeparatorAttributes) {
                            [layoutAttributes addObject:rowSeparatorAttributes];
                        }
                        
                    }
                }
                
                break;
            }
            default:
                break;
        }
        
    } else {
        
        NSInteger startSection = [self searchStartSection:rect :0 :self.numberOfSections-1];
        NSInteger startRowIndex = ({
            CGFloat heightDelta1 = MIN(self.sectionBottoms[startSection]-CGRectGetMinY(rect)-self.sectionInsets.bottom, self.sectionRowCounts[startSection]*self.estimatedItemSize.height);
            NSInteger startRowCount = TFYCa_CalendarCeil(heightDelta1/self.estimatedItemSize.height);
            NSInteger startRowIndex = self.sectionRowCounts[startSection]-startRowCount;
            startRowIndex;
        });
        
        NSInteger endSection = [self searchEndSection:rect :startSection :self.numberOfSections-1];
        NSInteger endRowIndex = ({
            CGFloat heightDelta2 = MAX(CGRectGetMaxY(rect) - self.sectionTops[endSection]- self.headerReferenceSize.height - self.sectionInsets.top, 0);
            NSInteger endRowCount = TFYCa_CalendarCeil(heightDelta2/self.estimatedItemSize.height);
            NSInteger endRowIndex = endRowCount - 1;
            endRowIndex;
        });
        for (NSInteger section = startSection; section <= endSection; section++) {
            NSInteger startRow = (section == startSection) ? startRowIndex : 0;
            NSInteger endRow = (section == endSection) ? endRowIndex : self.sectionRowCounts[section]-1;
            UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            [layoutAttributes addObject:headerAttributes];
            for (NSInteger row = startRow; row <= endRow; row++) {
                for (NSInteger column = 0; column < 7; column++) {
                    NSInteger item = row * 7 + column;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                    UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                    [layoutAttributes addObject:itemAttributes];
                    UICollectionViewLayoutAttributes *rowSeparatorAttributes = [self layoutAttributesForDecorationViewOfKind:kTFY_CalendarSeparatorInterRows atIndexPath:indexPath];
                    if (rowSeparatorAttributes) {
                        [layoutAttributes addObject:rowSeparatorAttributes];
                    }
                }
            }
        }
        
    }
    return [NSArray arrayWithArray:layoutAttributes];
    
}

// Items
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFY_CalendarCoordinate coordinate = [self.calendar.calculator coordinateForIndexPath:indexPath];
    NSInteger column = coordinate.column;
    NSInteger row = coordinate.row;
    NSInteger numberOfRows = [self.calendar.calculator numberOfRowsInSection:indexPath.section];
    UICollectionViewLayoutAttributes *attributes = self.itemAttributes[indexPath];
    if (!attributes) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGRect frame = ({
            CGFloat width = self.widths[column];
            CGFloat height = self.heights[row];
            CGFloat x, y;
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    x = self.lefts[column] + indexPath.section * self.collectionView.tfyCa_width;
                    y = [self calculateRowOffset:row totalRows:numberOfRows];
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    x = self.lefts[column];
                    if (!self.calendar.floatingMode) {
                        CGFloat sectionTop = indexPath.section * self.collectionView.tfyCa_height;
                        CGFloat rowOffset = [self calculateRowOffset:row totalRows:numberOfRows];
                        y = sectionTop + rowOffset;
                    } else {
                        y = self.sectionTops[indexPath.section] + self.headerReferenceSize.height + self.tops[row];
                    }
                    break;
                }
                default:
                    break;
            }
            CGRect frame = CGRectMake(x, y, width, height);
            frame;
        });
        attributes.frame = frame;
        self.itemAttributes[indexPath] = attributes;
    }
    return attributes;
}

// 节标题
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *attributes = self.headerAttributes[indexPath];
        if (!attributes) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
            attributes.frame = CGRectMake(0, self.sectionTops[indexPath.section], self.collectionView.tfyCa_width, self.headerReferenceSize.height);
            self.headerAttributes[indexPath] = attributes;
        }
        return attributes;
    }
    return nil;
}

// 分离器
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:kTFY_CalendarSeparatorInterRows] && (self.separators & TFYCa_CalendarSeparatorInterRows)) {
        UICollectionViewLayoutAttributes *attributes = self.rowSeparatorAttributes[indexPath];
        if (!attributes) {
            TFY_CalendarCoordinate coordinate = [self.calendar.calculator coordinateForIndexPath:indexPath];
            if (coordinate.row >= [self.calendar.calculator numberOfRowsInSection:indexPath.section]-1) {
                return nil;
            }
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kTFY_CalendarSeparatorInterRows withIndexPath:indexPath];
            CGFloat x, y;
            if (!self.calendar.floatingMode) {
                CGFloat rowOffset = [self calculateRowOffset:coordinate.row totalRows:[self.calendar.calculator numberOfRowsInSection:indexPath.section]] + self.heights[coordinate.row];
                switch (self.scrollDirection) {
                    case UICollectionViewScrollDirectionHorizontal: {
                        x = self.lefts[coordinate.column] + indexPath.section * self.collectionView.tfyCa_width;
                        y = rowOffset;
                        break;
                    }
                    case UICollectionViewScrollDirectionVertical: {
                        x = 0;
                        y = indexPath.section * self.collectionView.tfyCa_height + rowOffset;
                        break;
                    }
                    default:
                        break;
                }
            } else {
                x = 0;
                y = self.sectionTops[indexPath.section] + self.headerReferenceSize.height + self.tops[coordinate.row] + self.heights[coordinate.row];
            }
            CGFloat width = self.collectionView.tfyCa_width;
            CGFloat height = TFYCa_CalendarStandardSeparatorThickness;
            attributes.frame = CGRectMake(x, y, width, height);
            attributes.zIndex = NSIntegerMax;
            self.rowSeparatorAttributes[indexPath] = attributes;
        }
        return attributes;
    }
    return nil;
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection
{
    return YES;
}

#pragma mark - Notifications

- (void)didReceiveNotifications:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIDeviceOrientationDidChangeNotification]) {
        [self invalidateLayout];
    }
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self.itemAttributes removeAllObjects];
        [self.headerAttributes removeAllObjects];
        [self.rowSeparatorAttributes removeAllObjects];
    }
}

#pragma mark - Private properties

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        self.collectionViewSize = CGSizeAutomatic;
    }
}

#pragma mark - Private functions

- (CGFloat)calculateRowOffset:(NSInteger)row totalRows:(NSInteger)totalRows
{
    if (self.calendar.adjustsBoundingRectWhenChangingMonths) {
        return self.tops[row];
    }
    CGFloat height = self.heights[row];
    switch (totalRows) {
        case 4:
        case 5: {
            CGFloat contentHeight = self.collectionView.tfyCa_height - self.sectionInsets.top - self.sectionInsets.bottom;
            CGFloat rowSpan = contentHeight/totalRows;
            return (row + 0.5) * rowSpan - height * 0.5 + self.sectionInsets.top;
        }
        case 6:
        default:
            return self.tops[row];
    }
}

- (NSInteger)searchStartSection:(CGRect)rect :(NSInteger)left :(NSInteger)right
{
    NSInteger mid = left + (right-left)/2;
    CGFloat y = rect.origin.y;
    CGFloat minY = self.sectionTops[mid];
    CGFloat maxY = self.sectionBottoms[mid];
    if (y >= minY && y < maxY) {
        return mid;
    } else if (y < minY) {
        return [self searchStartSection:rect :left :mid];
    } else {
        return [self searchStartSection:rect :mid+1 :right];
    }
}

- (NSInteger)searchEndSection:(CGRect)rect :(NSInteger)left :(NSInteger)right
{
    NSInteger mid = left + (right-left)/2;
    CGFloat y = CGRectGetMaxY(rect);
    CGFloat minY = self.sectionTops[mid];
    CGFloat maxY = self.sectionBottoms[mid];
    if (y > minY && y <= maxY) {
        return mid;
    } else if (y <= minY) {
        return [self searchEndSection:rect :left :mid];
    } else {
        return [self searchEndSection:rect :mid+1 :right];
    }
}

@end


#undef kTFY_CalendarSeparatorInterColumns
#undef kTFY_CalendarSeparatorInterRows

