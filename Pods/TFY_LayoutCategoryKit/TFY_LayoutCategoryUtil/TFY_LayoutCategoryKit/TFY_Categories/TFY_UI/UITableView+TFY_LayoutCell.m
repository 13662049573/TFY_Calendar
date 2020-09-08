//
//  UITableView+TFY_LayoutCell.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//


#import "UITableView+TFY_LayoutCell.h"

#import <objc/runtime.h>

typedef NSMutableArray<NSMutableArray<NSNumber *> *> IndexPathHeightsBySection;

@interface IndexPathHeightCache ()
@property (nonatomic, strong) IndexPathHeightsBySection *tfy_heightsBySectionForPortrait;
@property (nonatomic, strong) IndexPathHeightsBySection *tfy_heightsBySectionForLandscape;
@end

@implementation IndexPathHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _tfy_heightsBySectionForPortrait = [NSMutableArray array];
        _tfy_heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (IndexPathHeightsBySection *)tfy_heightsBySectionForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.tfy_heightsBySectionForPortrait: self.tfy_heightsBySectionForLandscape;
}

- (void)tfy_enumerateAllOrientationsUsingBlock:(void (^)(IndexPathHeightsBySection *heightsBySection))block {
    block(self.tfy_heightsBySectionForPortrait);
    block(self.tfy_heightsBySectionForLandscape);
}

- (BOOL)tfy_existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self tfy_buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.tfy_heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)tfy_cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    self.tfy_automaticallyInvalidateEnabled = YES;
    [self tfy_buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.tfy_heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)tfy_heightForIndexPath:(NSIndexPath *)indexPath {
    [self tfy_buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.tfy_heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)tfy_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self tfy_buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)tfy_invalidateAllHeightCache {
    [self tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)tfy_buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths {
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self tfy_buildSectionsIfNeeded:indexPath.section];
        [self tfy_buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)tfy_buildSectionsIfNeeded:(NSInteger)targetSection {
    [self tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)tfy_buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    [self tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @-1;
            }
        }
    }];
}

@end

@implementation UITableView (IndexPathHeightCache)

- (IndexPathHeightCache *)tfy_indexPathHeightCache {
    IndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [IndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

static void __TFY_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(void (^callout)(void)) {
    callout();
}
#define PrimaryCall(...) do {__TFY_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(^{__VA_ARGS__});} while(0)

@implementation UITableView (IndexPathHeightCacheInvalidation)

- (void)tfy_reloadDataWithoutInvalidateIndexPathHeightCache {
    PrimaryCall([self tfy_reloadData];);
}

+ (void)load {
    
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"tfy_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)tfy_reloadData {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    PrimaryCall([self tfy_reloadData];);
}

- (void)tfy_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.tfy_indexPathHeightCache tfy_buildSectionsIfNeeded:section];
            [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    PrimaryCall([self tfy_insertSections:sections withRowAnimation:animation];);
}

- (void)tfy_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.tfy_indexPathHeightCache tfy_buildSectionsIfNeeded:section];
            [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    PrimaryCall([self tfy_deleteSections:sections withRowAnimation:animation];);
}

- (void)tfy_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.tfy_indexPathHeightCache tfy_buildSectionsIfNeeded:section];
            [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
            
        }];
    }
    PrimaryCall([self tfy_reloadSections:sections withRowAnimation:animation];);
}

- (void)tfy_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [self.tfy_indexPathHeightCache tfy_buildSectionsIfNeeded:section];
        [self.tfy_indexPathHeightCache tfy_buildSectionsIfNeeded:newSection];
        [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    PrimaryCall([self tfy_moveSection:section toSection:newSection];);
}

- (void)tfy_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [self.tfy_indexPathHeightCache tfy_buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[indexPath.section] insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    PrimaryCall([self tfy_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)tfy_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [self.tfy_indexPathHeightCache tfy_buildCachesAtIndexPathsIfNeeded:indexPaths];
        
        NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[key.integerValue] removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    PrimaryCall([self tfy_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)tfy_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [self.tfy_indexPathHeightCache tfy_buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                heightsBySection[indexPath.section][indexPath.row] = @-1;
            }];
        }];
    }
    PrimaryCall([self tfy_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)tfy_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.tfy_indexPathHeightCache.tfy_automaticallyInvalidateEnabled) {
        [self.tfy_indexPathHeightCache tfy_buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.tfy_indexPathHeightCache tfy_enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
            NSMutableArray<NSNumber *> *sourceRows = heightsBySection[sourceIndexPath.section];
            NSMutableArray<NSNumber *> *destinationRows = heightsBySection[destinationIndexPath.section];
            NSNumber *sourceValue = sourceRows[sourceIndexPath.row];
            NSNumber *destinationValue = destinationRows[destinationIndexPath.row];
            sourceRows[sourceIndexPath.row] = destinationValue;
            destinationRows[destinationIndexPath.row] = sourceValue;
        }];
    }
    PrimaryCall([self tfy_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];);
}

@end


@interface KeyedHeightCache ()
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *mutableHeightsByKeyForPortrait;
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *mutableHeightsByKeyForLandscape;
@end

@implementation KeyedHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary<id<NSCopying>, NSNumber *> *)mutableHeightsByKeyForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.mutableHeightsByKeyForPortrait: self.mutableHeightsByKeyForLandscape;
}

- (BOOL)tfy_existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.mutableHeightsByKeyForCurrentOrientation[key];
    return number && ![number isEqualToNumber:@-1];
}

- (void)tfy_cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    self.mutableHeightsByKeyForCurrentOrientation[key] = @(height);
}

- (CGFloat)tfy_heightForKey:(id<NSCopying>)key {
#if CGFLOAT_IS_DOUBLE
    return [self.mutableHeightsByKeyForCurrentOrientation[key] doubleValue];
#else
    return [self.mutableHeightsByKeyForCurrentOrientation[key] floatValue];
#endif
}

- (void)tfy_invalidateHeightForKey:(id<NSCopying>)key {
    [self.mutableHeightsByKeyForPortrait removeObjectForKey:key];
    [self.mutableHeightsByKeyForLandscape removeObjectForKey:key];
}

- (void)tfy_invalidateAllHeightCache {
    [self.mutableHeightsByKeyForPortrait removeAllObjects];
    [self.mutableHeightsByKeyForLandscape removeAllObjects];
}

@end

@implementation UITableView (KeyedHeightCache)

- (KeyedHeightCache *)tfy_keyedHeightCache {
    KeyedHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [KeyedHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UITableView (TemplateLayoutCellDebug)

- (BOOL)tfy_debugLogEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTfy_debugLogEnabled:(BOOL)debugLogEnabled {
    objc_setAssociatedObject(self, @selector(tfy_debugLogEnabled), @(debugLogEnabled), OBJC_ASSOCIATION_RETAIN);
}

- (void)tfy_debugLog:(NSString *)message {
    if (self.tfy_debugLogEnabled) {
        NSLog(@"** TFY_TemplateLayoutCell ** %@", message);
    }
}

@end



@implementation UITableView (TFY_LayoutCell)

- (CGFloat)tfy_systemFittingHeightForConfiguratedCell:(UITableViewCell *)cell {
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    
    if (cell.accessoryView) {
        contentViewWidth -= 16 + CGRectGetWidth(cell.accessoryView.frame);
    } else {
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        contentViewWidth -= systemAccessoryWidths[cell.accessoryType];
    }
    
    CGFloat fittingHeight = 0;
    
    if (!cell.tfy_enforceFrameLayout && contentViewWidth > 0) {
       
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
        
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) {
            
            widthFenceConstraint.priority = UILayoutPriorityRequired - 1;
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [cell addConstraints:edgeConstraints];
        }
        
        [cell.contentView addConstraint:widthFenceConstraint];
        
        fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        [cell.contentView removeConstraint:widthFenceConstraint];
        if (isSystemVersionEqualOrGreaterThen10_2) {
            [cell removeConstraints:edgeConstraints];
        }
        
        [self tfy_debugLog:[NSString stringWithFormat:@"calculate using system fitting size (AutoLayout) - %@", @(fittingHeight)]];
    }
    
    if (fittingHeight == 0) {
#if DEBUG
        
        if (cell.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[FDTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        fittingHeight = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
        
        [self tfy_debugLog:[NSString stringWithFormat:@"calculate using sizeThatFits - %@", @(fittingHeight)]];
    }

    if (fittingHeight == 0) {
        fittingHeight = 44;
    }
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingHeight += 1.0 / [UIScreen mainScreen].scale;
    }
    
    return fittingHeight;
}

- (__kindof UITableViewCell *)tfy_templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    
    if (!templateCell) {
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.tfy_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
        [self tfy_debugLog:[NSString stringWithFormat:@"layout cell created - %@", identifier]];
    }
    
    return templateCell;
}

- (CGFloat)tfy_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration {
    if (!identifier) {
        return 0;
    }
    
    UITableViewCell *templateLayoutCell = [self tfy_templateCellForReuseIdentifier:identifier];
    
    [templateLayoutCell prepareForReuse];
    
    if (configuration) {
        configuration(templateLayoutCell);
    }
    
    return [self tfy_systemFittingHeightForConfiguratedCell:templateLayoutCell];
}

- (CGFloat)tfy_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier || !indexPath) {
        return 0;
    }

    if ([self.tfy_indexPathHeightCache tfy_existsHeightAtIndexPath:indexPath]) {
        [self tfy_debugLog:[NSString stringWithFormat:@"hit cache by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @([self.tfy_indexPathHeightCache tfy_heightForIndexPath:indexPath])]];
        return [self.tfy_indexPathHeightCache tfy_heightForIndexPath:indexPath];
    }
    
    CGFloat height = [self tfy_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.tfy_indexPathHeightCache tfy_cacheHeight:height byIndexPath:indexPath];
    [self tfy_debugLog:[NSString stringWithFormat: @"cached by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @(height)]];
    
    return height;
}

- (CGFloat)tfy_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration {
    if (!identifier || !key) {
        return 0;
    }
    if ([self.tfy_keyedHeightCache tfy_existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.tfy_keyedHeightCache tfy_heightForKey:key];
        [self tfy_debugLog:[NSString stringWithFormat:@"hit cache by key[%@] - %@", key, @(cachedHeight)]];
        return cachedHeight;
    }
    
    CGFloat height = [self tfy_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.tfy_keyedHeightCache tfy_cacheHeight:height byKey:key];
    [self tfy_debugLog:[NSString stringWithFormat:@"cached by key[%@] - %@", key, @(height)]];
    
    return height;
}

- (void)tfy_updateWithBlock:(void (^)(UITableView *tableView))block {
    [self beginUpdates];
    block(self);
    [self endUpdates];
}

- (void)tfy_scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)tfy_insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)tfy_insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toInsert = [NSIndexPath indexPathForRow:row inSection:section];
    [self tfy_insertRowAtIndexPath:toInsert withRowAnimation:animation];
}

- (void)tfy_reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)tfy_reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toReload = [NSIndexPath indexPathForRow:row inSection:section];
    [self tfy_reloadRowAtIndexPath:toReload withRowAnimation:animation];
}

- (void)tfy_deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)tfy_deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toDelete = [NSIndexPath indexPathForRow:row inSection:section];
    [self tfy_deleteRowAtIndexPath:toDelete withRowAnimation:animation];
}

- (void)tfy_insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self insertSections:sections withRowAnimation:animation];
}

- (void)tfy_deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self deleteSections:sections withRowAnimation:animation];
}

- (void)tfy_reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:indexSet withRowAnimation:animation];
}

- (void)tfy_clearSelectedRowsAnimated:(BOOL)animated {
    NSArray *indexs = [self indexPathsForSelectedRows];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath* path, NSUInteger idx, BOOL *stop) {
        [self deselectRowAtIndexPath:path animated:animated];
    }];
}

+ (UITableView *)tfy_tableViewStyle:(UITableViewStyle)style{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    return tableView;
}

@end

@implementation UITableView (TemplateLayoutHeaderFooterView)

- (__kindof UITableViewHeaderFooterView *)tfy_templateHeaderFooterViewForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewHeaderFooterView *> *templateHeaderFooterViews = objc_getAssociatedObject(self, _cmd);
    if (!templateHeaderFooterViews) {
        templateHeaderFooterViews = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateHeaderFooterViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewHeaderFooterView *templateHeaderFooterView = templateHeaderFooterViews[identifier];
    
    if (!templateHeaderFooterView) {
        templateHeaderFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        NSAssert(templateHeaderFooterView != nil, @"HeaderFooterView must be registered to table view for identifier - %@", identifier);
        templateHeaderFooterView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateHeaderFooterViews[identifier] = templateHeaderFooterView;
        [self tfy_debugLog:[NSString stringWithFormat:@"layout header footer view created - %@", identifier]];
    }
    
    return templateHeaderFooterView;
}

- (CGFloat)tfy_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id))configuration {
    UITableViewHeaderFooterView *templateHeaderFooterView = [self tfy_templateHeaderFooterViewForReuseIdentifier:identifier];
    
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    [templateHeaderFooterView addConstraint:widthFenceConstraint];
    CGFloat fittingHeight = [templateHeaderFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [templateHeaderFooterView removeConstraint:widthFenceConstraint];
    
    if (fittingHeight == 0) {
        fittingHeight = [templateHeaderFooterView sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), 0)].height;
    }
    
    return fittingHeight;
}

@end

@implementation UITableViewCell (TemplateLayoutCell)

- (BOOL)tfy_isTemplateLayoutCell {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTfy_isTemplateLayoutCell:(BOOL)isTemplateLayoutCell {
    objc_setAssociatedObject(self, @selector(tfy_isTemplateLayoutCell), @(isTemplateLayoutCell), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)tfy_enforceFrameLayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTfy_enforceFrameLayout:(BOOL)enforceFrameLayout {
    objc_setAssociatedObject(self, @selector(tfy_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}

@end

