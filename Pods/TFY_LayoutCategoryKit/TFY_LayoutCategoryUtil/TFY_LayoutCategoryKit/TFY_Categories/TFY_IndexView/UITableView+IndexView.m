//
//  UITableView+IndexView.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/6/8.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "UITableView+IndexView.h"
#import <objc/runtime.h>

@interface TFY_IndexWeakProxy : NSObject
@property (nonatomic, weak) TFY_IndexView *indexView;
@end
@implementation TFY_IndexWeakProxy
@end

@interface UITableView () <IndexViewDelegate>

@property (nonatomic, strong) TFY_IndexView *tfy_indexView;

@end

@implementation UITableView (IndexView)

#pragma mark - Swizzle Method

+ (void)load
{
    [self swizzledSelector:@selector(IndexView_didMoveToSuperview) originalSelector:@selector(didMoveToSuperview)];
    [self swizzledSelector:@selector(IndexView_removeFromSuperview) originalSelector:@selector(removeFromSuperview)];
}

+ (void)swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma Add and Remove View

- (void)IndexView_didMoveToSuperview
{
    [self IndexView_didMoveToSuperview];
    if (self.tfy_indexViewDataSource.count && !self.tfy_indexView && self.superview) {
        TFY_IndexView *indexView = [[TFY_IndexView alloc] initWithTableView:self configuration:self.tfy_indexViewConfiguration];
        indexView.translucentForTableViewInNavigationBar = self.tfy_translucentForTableViewInNavigationBar;
        indexView.delegate = self;
        indexView.dataSource = self.tfy_indexViewDataSource;
        [self.superview addSubview:indexView];
        
        self.tfy_indexView = indexView;
    }
}

- (void)IndexView_removeFromSuperview
{
    if (self.tfy_indexView) {
        [self.tfy_indexView removeFromSuperview];
        self.tfy_indexView = nil;
    }
    [self IndexView_removeFromSuperview];
}

#pragma mark - IndexViewDelegate

- (void)indexView:(TFY_IndexView *)indexView didSelectAtSection:(NSUInteger)section
{
    if (self.tfy_indexViewDelegate && [self.delegate respondsToSelector:@selector(tableView:didSelectIndexViewAtSection:)]) {
        [self.tfy_indexViewDelegate tableView:self didSelectIndexViewAtSection:section];
    }
}

- (NSUInteger)sectionOfIndexView:(TFY_IndexView *)indexView tableViewDidScroll:(UITableView *)tableView
{
    if (self.tfy_indexViewDelegate && [self.delegate respondsToSelector:@selector(sectionOfTableViewDidScroll:)]) {
        return [self.tfy_indexViewDelegate sectionOfTableViewDidScroll:self];
    } else {
        return TFY_IndexViewInvalidSection;
    }
}

#pragma mark - Getter and Setter

- (TFY_IndexView *)tfy_indexView
{
    TFY_IndexWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(tfy_indexView));
    return weakProxy.indexView;
}

- (void)setTfy_indexView:(TFY_IndexView *)tfy_indexView
{
    if (self.tfy_indexView == tfy_indexView) return;
    
    TFY_IndexWeakProxy *weakProxy = [TFY_IndexWeakProxy new];
    weakProxy.indexView = tfy_indexView;
    objc_setAssociatedObject(self, @selector(tfy_indexView), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TFY_IndexViewConfiguration *)tfy_indexViewConfiguration
{
    TFY_IndexViewConfiguration *tfy_indexViewConfiguration = objc_getAssociatedObject(self, @selector(tfy_indexViewConfiguration));
    if (!tfy_indexViewConfiguration) {
        tfy_indexViewConfiguration = [TFY_IndexViewConfiguration configuration];
    }
    return tfy_indexViewConfiguration;
}

- (void)setTfy_indexViewConfiguration:(TFY_IndexViewConfiguration *)tfy_indexViewConfiguration
{
    if (self.tfy_indexViewConfiguration == tfy_indexViewConfiguration) return;
    
    objc_setAssociatedObject(self, @selector(tfy_indexViewConfiguration), tfy_indexViewConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<TableViewSectionIndexDelegate>)tfy_indexViewDelegate
{
    return objc_getAssociatedObject(self, @selector(tfy_indexViewDelegate));
}

- (void)setTfy_indexViewDelegate:(id<TableViewSectionIndexDelegate>)tfy_indexViewDelegate
{
    if (self.tfy_indexViewDelegate == tfy_indexViewDelegate) return;
    
    objc_setAssociatedObject(self, @selector(tfy_indexViewDelegate), tfy_indexViewDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tfy_translucentForTableViewInNavigationBar
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_translucentForTableViewInNavigationBar));
    return number.boolValue;
}

- (void)setTfy_translucentForTableViewInNavigationBar:(BOOL)tfy_translucentForTableViewInNavigationBar
{
    if (self.tfy_translucentForTableViewInNavigationBar == tfy_translucentForTableViewInNavigationBar) return;
    
    objc_setAssociatedObject(self, @selector(tfy_translucentForTableViewInNavigationBar), @(tfy_translucentForTableViewInNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.tfy_indexView.translucentForTableViewInNavigationBar = tfy_translucentForTableViewInNavigationBar;
}

- (NSArray<NSString *> *)tfy_indexViewDataSource
{
    return objc_getAssociatedObject(self, @selector(tfy_indexViewDataSource));
}

- (void)setTfy_indexViewDataSource:(NSArray<NSString *> *)tfy_indexViewDataSource
{
    if (self.tfy_indexViewDataSource == tfy_indexViewDataSource) return;
    objc_setAssociatedObject(self, @selector(tfy_indexViewDataSource), tfy_indexViewDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!tfy_indexViewDataSource || tfy_indexViewDataSource.count == 0) {
        [self.tfy_indexView removeFromSuperview];
        self.tfy_indexView = nil;
        return;
    }
    
    if (!self.tfy_indexView && self.superview) {
        TFY_IndexView *indexView = [[TFY_IndexView alloc] initWithTableView:self configuration:self.tfy_indexViewConfiguration];
        indexView.translucentForTableViewInNavigationBar = self.tfy_translucentForTableViewInNavigationBar;
        indexView.startSection = self.tfy_startSection;
        indexView.delegate = self;
        [self.superview addSubview:indexView];

        self.tfy_indexView = indexView;
    }
    
    self.tfy_indexView.dataSource = tfy_indexViewDataSource.copy;
}

- (NSUInteger)tfy_startSection {
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_startSection));
    return number.unsignedIntegerValue;
}

- (void)setTfy_startSection:(NSUInteger)tfy_startSection {
    if (self.tfy_startSection == tfy_startSection) return;
    
    objc_setAssociatedObject(self, @selector(tfy_startSection), @(tfy_startSection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.tfy_indexView.startSection = tfy_startSection;
}


@end
