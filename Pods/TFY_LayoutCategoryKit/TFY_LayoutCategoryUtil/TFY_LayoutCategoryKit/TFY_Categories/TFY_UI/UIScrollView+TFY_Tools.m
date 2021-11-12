//
//  UIScrollView+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIScrollView+TFY_Tools.h"
#import <objc/runtime.h>

#define TFY_KeyPath(objc,keyPath) @(((void)objc.keyPath,#keyPath))
/**
 *  分类的目的：实现两个方法实现的交换，调用原有方法，有现有方法(自己实现方法)的实现。
 */
@interface NSObject (MethodSwizzling)

/**
 *  交换对象方法  origSelector    原有方法  swizzleSelector 现有方法(自己实现方法)
 *
 */
+ (void)tfy_swizzleInstanceSelector:(SEL)origSelector swizzleSelector:(SEL)swizzleSelector;

/**
 *  交换类方法  origSelector    原有方法  swizzleSelector 现有方法(自己实现方法)
 */
+ (void)tfy_swizzleClassSelector:(SEL)origSelector swizzleSelector:(SEL)swizzleSelector;

@end

@implementation NSObject (MethodSwizzling)

+ (void)tfy_swizzleInstanceSelector:(SEL)origSelector swizzleSelector:(SEL)swizzleSelector {
    
    // 获取原有方法
    Method origMethod = class_getInstanceMethod(self, origSelector);
    // 获取交换方法
    Method swizzleMethod = class_getInstanceMethod(self, swizzleSelector);
    
    // 注意：不能直接交换方法实现，需要判断原有方法是否存在,存在才能交换
    // 如何判断？添加原有方法，如果成功，表示原有方法不存在，失败，表示原有方法存在
    // 原有方法可能没有实现，所以这里添加方法实现，用自己方法实现
    // 这样做的好处：方法不存在，直接把自己方法的实现作为原有方法的实现，调用原有方法，就会来到当前方法的实现
    BOOL isAdd = class_addMethod(self, origSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    
    if (!isAdd) { // 添加方法失败，表示原有方法存在，直接替换
        method_exchangeImplementations(origMethod, swizzleMethod);
    }else {
        class_replaceMethod(self, swizzleSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
}

+ (void)tfy_swizzleClassSelector:(SEL)origSelector swizzleSelector:(SEL)swizzleSelector
{
    // 获取原有方法
    Method origMethod = class_getClassMethod(self, origSelector);
    // 获取交换方法
    Method swizzleMethod = class_getClassMethod(self, swizzleSelector);
    
    // 添加原有方法实现为当前方法实现
    BOOL isAdd = class_addMethod(self, origSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    
    if (!isAdd) { // 添加方法失败，原有方法存在，直接替换
        method_exchangeImplementations(origMethod, swizzleMethod);
    }
}

@end

@interface UIView (ConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute;

@end

@interface WeakObjectContainer : NSObject

@property (nonatomic, readonly, weak) id weakObject;

- (instancetype)initWithWeakObject:(id)object;

@end

@interface EmptyDataSetView : UIView

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *detailLabel;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIButton *button;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat verticalSpace;

@property (nonatomic, assign) BOOL fadeInOnDisplay;

- (void)setupConstraints;
- (void)prepareForReuse;

@end


static char * const headerImageViewKey = "headerImageViewKey";
static char * const headerImageViewHeight = "headerImageViewHeight";
static char * const isInitialKey = "isInitialKey";
static char const * const kEmptyDataSetSource =     "emptyDataSetSource";
static char const * const kEmptyDataSetDelegate =   "emptyDataSetDelegate";
static char const * const kEmptyDataSetView =       "emptyDataSetView";
static NSMutableDictionary *_impLookupTable;
static NSString *const SwizzleInfoPointerKey = @"pointer";
static NSString *const SwizzleInfoOwnerKey = @"owner";
static NSString *const SwizzleInfoSelectorKey = @"selector";
// 默认图片高度
static CGFloat const oriImageH = 200;

#define kEmptyImageViewAnimationKey @"com.dzn.emptyDataSet.imageViewAnimation"

@interface UIScrollView () <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) EmptyDataSetView *emptyDataSetView;
@end


@implementation UIScrollView (TFY_Tools)

- (void)tfy_adJustedContentIOS11{
    if (@available(iOS 11.0, *)) {
        [self setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}

+ (void)load{
    [self tfy_swizzleInstanceSelector:@selector(setTableHeaderView:) swizzleSelector:@selector(setTfy_TableHeaderView:)];
}

- (void)tfy_screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock{
    if (!finishBlock)return;
    
    __block UIImage* snapshotImage = nil;
    
    //保存offset
    CGPoint oldContentOffset = self.contentOffset;
    //保存frame
    CGRect oldFrame = self.frame;
    
    if (self.contentSize.height > self.frame.size.height) {
        self.contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
    }
    self.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    //延迟0.3秒，避免有时候渲染不出来的情况
    [NSThread sleepForTimeInterval:0.3];
    
    self.contentOffset = CGPointZero;
    @autoreleasepool{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,[UIScreen mainScreen].scale);

        CGContextRef context = UIGraphicsGetCurrentContext();

        [self.layer renderInContext:context];
        
//        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
        
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    self.frame = oldFrame;
    //还原
    self.contentOffset = oldContentOffset;
    
    if (snapshotImage != nil) {
        finishBlock(snapshotImage);
    }
}

#pragma mark - 获取屏幕快照
/*
 *  snapshotView:需要截取的view
 */
+(UIImage *)tfy_screenSnapshotWithSnapshotView:(UIView *)snapshotView
{
    return [self tfy_screenSnapshotWithSnapshotView:snapshotView snapshotSize:CGSizeZero];
}

/*
 *  snapshotView:需要截取的view
 *  snapshotSize:需要截取的size
 */
+(UIImage *)tfy_screenSnapshotWithSnapshotView:(UIView *)snapshotView snapshotSize:(CGSize )snapshotSize
{
    UIImage *snapshotImg;

    @autoreleasepool{
        if (snapshotSize.height == 0|| snapshotSize.width == 0) {//宽高为0的时候没有意义
            snapshotSize = snapshotView.bounds.size;
        }
        //创建
        UIGraphicsBeginImageContextWithOptions(snapshotSize,NO,[UIScreen mainScreen].scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();

        [snapshotView.layer renderInContext:context];
//        [snapshotView drawViewHierarchyInRect:snapshotView.bounds afterScreenUpdates:NO];
        
        //获取图片
        snapshotImg = UIGraphicsGetImageFromCurrentImageContext();
        
        //关闭
        UIGraphicsEndImageContext();
    }
    return snapshotImg;
}

// 拦截通过代码设置tableView头部视图
- (void)setTfy_TableHeaderView:(UIView *)tableHeaderView
{
    
    // 不是UITableView,就不需要做下面的事情
    if (![self isMemberOfClass:[UITableView class]]) return;
    
    // 设置tableView头部视图
    [self setTfy_TableHeaderView:tableHeaderView];
    
    // 设置头部视图的位置
    UITableView *tableView = (UITableView *)self;
    
    self.tfy_headerScaleImageHeight = tableView.tableHeaderView.frame.size.height;
    
}

// 懒加载头部imageView
- (UIImageView *)tfy_headerImageView
{
    UIImageView *imageView = objc_getAssociatedObject(self, headerImageViewKey);
    if (imageView == nil) {
        
        imageView = [[UIImageView alloc] init];
        
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self insertSubview:imageView atIndex:0];
        
        // 保存imageView
        objc_setAssociatedObject(self, headerImageViewKey, imageView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return imageView;
}

// 属性：yz_isInitial
- (BOOL)tfy_isInitial
{
    return [objc_getAssociatedObject(self, isInitialKey) boolValue];
}

- (void)setTfy_isInitial:(BOOL)tfy_isInitial
{
    objc_setAssociatedObject(self, isInitialKey, @(tfy_isInitial),OBJC_ASSOCIATION_ASSIGN);
}

// 属性： yz_headerImageViewHeight
- (void)setTfy_headerScaleImageHeight:(CGFloat)tfy_headerScaleImageHeight
{
    objc_setAssociatedObject(self, headerImageViewHeight, @(tfy_headerScaleImageHeight),OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // 设置头部视图的位置
    [self setupHeaderImageViewFrame];
}
- (CGFloat)tfy_headerScaleImageHeight
{
    CGFloat headerImageHeight = [objc_getAssociatedObject(self, headerImageViewHeight) floatValue];
    return headerImageHeight == 0?oriImageH:headerImageHeight;
}

// 属性：yz_headerImage
- (UIImage *)tfy_headerScaleImage
{
    return self.tfy_headerImageView.image;
}

// 设置头部imageView的图片
- (void)setTfy_headerScaleImage:(UIImage *)tfy_headerScaleImage
{
    self.tfy_headerImageView.image = tfy_headerScaleImage;
    
    // 初始化头部视图
    [self setupHeaderImageView];
    
}

// 设置头部视图的位置
- (void)setupHeaderImageViewFrame
{
    self.tfy_headerImageView.frame = CGRectMake(0 , 0, self.bounds.size.width , self.tfy_headerScaleImageHeight);
    
}

// 初始化头部视图
- (void)setupHeaderImageView
{
    
    // 设置头部视图的位置
    [self setupHeaderImageViewFrame];
    
    // KVO监听偏移量，修改头部imageView的frame
    if (self.tfy_isInitial == NO) {
        [self addObserver:self forKeyPath:TFY_KeyPath(self, contentOffset) options:NSKeyValueObservingOptionNew context:nil];
        self.tfy_isInitial = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    // 获取当前偏移量
    CGFloat offsetY = self.contentOffset.y;
    
    if (offsetY < 0) {
        self.tfy_headerImageView.frame = CGRectMake(offsetY, offsetY, self.bounds.size.width - offsetY * 2, self.tfy_headerScaleImageHeight - offsetY);
    } else {
        self.tfy_headerImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.tfy_headerScaleImageHeight);
    }
    
}
- (void)dealloc
{
    if (self.tfy_isInitial) { // 初始化过，就表示有监听contentOffset属性，才需要移除
        [self removeObserver:self forKeyPath:TFY_KeyPath(self, contentOffset)];
    }
}

#pragma mark - Getters (Public)

- (id<EmptyDataSetSource>)tfy_emptyDataSetSource
{
    WeakObjectContainer *container = objc_getAssociatedObject(self, kEmptyDataSetSource);
    return container.weakObject;
}

- (id<EmptyDataSetDelegate>)tfy_emptyDataSetDelegate
{
    WeakObjectContainer *container = objc_getAssociatedObject(self, kEmptyDataSetDelegate);
    return container.weakObject;
}

- (BOOL)tfy_isEmptyDataSetVisible
{
    UIView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    return view ? !view.hidden : NO;
}


#pragma mark - Getters (Private)

- (EmptyDataSetView *)emptyDataSetView
{
    EmptyDataSetView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    if (!view)
    {
        view = [EmptyDataSetView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        view.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tfy_didTapContentView:)];
        view.tapGesture.delegate = self;
        [view addGestureRecognizer:view.tapGesture];
        [self setEmptyDataSetView:view];
    }
    return view;
}

- (BOOL)tfy_canDisplay
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource conformsToProtocol:@protocol(EmptyDataSetSource)]) {
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]] || [self isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)tfy_itemsCount
{
    NSInteger items = 0;
    
    // UIScollView没有响应'dataSource'所以我们退出
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    // UITableView支持
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    // UITableView支持
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;

        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return items;
}


#pragma mark - Data Source Getters

- (NSAttributedString *)tfy_titleLabelString
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(titleForEmptyDataSet:)]) {
        NSAttributedString *string = [self.tfy_emptyDataSetSource titleForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -titleForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (NSAttributedString *)tfy_detailLabelString
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(descriptionForEmptyDataSet:)]) {
        NSAttributedString *string = [self.tfy_emptyDataSetSource descriptionForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -descriptionForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (UIImage *)tfy_image
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(imageForEmptyDataSet:)]) {
        UIImage *image = [self.tfy_emptyDataSetSource imageForEmptyDataSet:self];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -imageForEmptyDataSet:");
        return image;
    }
    return nil;
}

- (CAAnimation *)tfy_imageAnimation
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(imageAnimationForEmptyDataSet:)]) {
        CAAnimation *imageAnimation = [self.tfy_emptyDataSetSource imageAnimationForEmptyDataSet:self];
        if (imageAnimation) NSAssert([imageAnimation isKindOfClass:[CAAnimation class]], @"You must return a valid CAAnimation object for -imageAnimationForEmptyDataSet:");
        return imageAnimation;
    }
    return nil;
}

- (UIColor *)tfy_imageTintColor
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(imageTintColorForEmptyDataSet:)]) {
        UIColor *color = [self.tfy_emptyDataSetSource imageTintColorForEmptyDataSet:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -imageTintColorForEmptyDataSet:");
        return color;
    }
    return nil;
}

- (NSAttributedString *)tfy_buttonTitleForState:(UIControlState)state
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(buttonTitleForEmptyDataSet:forState:)]) {
        NSAttributedString *string = [self.tfy_emptyDataSetSource buttonTitleForEmptyDataSet:self forState:state];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -buttonTitleForEmptyDataSet:forState:");
        return string;
    }
    return nil;
}

- (UIImage *)tfy_buttonImageForState:(UIControlState)state
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(buttonImageForEmptyDataSet:forState:)]) {
        UIImage *image = [self.tfy_emptyDataSetSource buttonImageForEmptyDataSet:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonImageForEmptyDataSet:forState:");
        return image;
    }
    return nil;
}

- (UIImage *)tfy_buttonBackgroundImageForState:(UIControlState)state
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(buttonBackgroundImageForEmptyDataSet:forState:)]) {
        UIImage *image = [self.tfy_emptyDataSetSource buttonBackgroundImageForEmptyDataSet:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonBackgroundImageForEmptyDataSet:forState:");
        return image;
    }
    return nil;
}

- (UIColor *)tfy_dataSetBackgroundColor
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(backgroundColorForEmptyDataSet:)]) {
        UIColor *color = [self.tfy_emptyDataSetSource backgroundColorForEmptyDataSet:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -backgroundColorForEmptyDataSet:");
        return color;
    }
    return [UIColor clearColor];
}

- (UIView *)tfy_customView
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(customViewForEmptyDataSet:)]) {
        UIView *view = [self.tfy_emptyDataSetSource customViewForEmptyDataSet:self];
        if (view) NSAssert([view isKindOfClass:[UIView class]], @"You must return a valid UIView object for -customViewForEmptyDataSet:");
        return view;
    }
    return nil;
}

- (CGFloat)tfy_verticalOffset
{
    CGFloat offset = 0.0;
    
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(verticalOffsetForEmptyDataSet:)]) {
        offset = [self.tfy_emptyDataSetSource verticalOffsetForEmptyDataSet:self];
    }
    return offset;
}

- (CGFloat)tfy_verticalSpace
{
    if (self.tfy_emptyDataSetSource && [self.tfy_emptyDataSetSource respondsToSelector:@selector(spaceHeightForEmptyDataSet:)]) {
        return [self.tfy_emptyDataSetSource spaceHeightForEmptyDataSet:self];
    }
    return 0.0;
}


#pragma mark - Delegate Getters & Events (Private)

- (BOOL)tfy_shouldFadeIn {
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldFadeIn:)]) {
        return [self.tfy_emptyDataSetDelegate emptyDataSetShouldFadeIn:self];
    }
    return YES;
}

- (BOOL)tfy_shouldDisplay
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldDisplay:)]) {
        return [self.tfy_emptyDataSetDelegate emptyDataSetShouldDisplay:self];
    }
    return YES;
}

- (BOOL)tfy_shouldBeForcedToDisplay
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldBeForcedToDisplay:)]) {
        return [self.tfy_emptyDataSetDelegate emptyDataSetShouldBeForcedToDisplay:self];
    }
    return NO;
}

- (BOOL)tfy_isTouchAllowed
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowTouch:)]) {
        return [self.tfy_emptyDataSetDelegate emptyDataSetShouldAllowTouch:self];
    }
    return YES;
}

- (BOOL)tfy_isScrollAllowed
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowScroll:)]) {
        return [self.tfy_emptyDataSetDelegate emptyDataSetShouldAllowScroll:self];
    }
    return NO;
}

- (BOOL)tfy_isImageViewAnimateAllowed
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAnimateImageView:)]) {
        return [self.tfy_emptyDataSetDelegate emptyDataSetShouldAnimateImageView:self];
    }
    return NO;
}

- (void)tfy_willAppear
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillAppear:)]) {
        [self.tfy_emptyDataSetDelegate emptyDataSetWillAppear:self];
    }
}

- (void)tfy_didAppear
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidAppear:)]) {
        [self.tfy_emptyDataSetDelegate emptyDataSetDidAppear:self];
    }
}

- (void)tfy_willDisappear
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillDisappear:)]) {
        [self.tfy_emptyDataSetDelegate emptyDataSetWillDisappear:self];
    }
}

- (void)tfy_didDisappear
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidDisappear:)]) {
        [self.tfy_emptyDataSetDelegate emptyDataSetDidDisappear:self];
    }
}

- (void)tfy_didTapContentView:(id)sender
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSet:didTapView:)]) {
        [self.tfy_emptyDataSetDelegate emptyDataSet:self didTapView:sender];
    }
}

- (void)tfy_didTapDataButton:(id)sender
{
    if (self.tfy_emptyDataSetDelegate && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(emptyDataSet:didTapButton:)]) {
        [self.tfy_emptyDataSetDelegate emptyDataSet:self didTapButton:sender];
    }
}


#pragma mark - Setters (Public)

- (void)setTfy_emptyDataSetSource:(id<EmptyDataSetSource>)tfy_emptyDataSetSource
{
    if (!tfy_emptyDataSetSource || ![self tfy_canDisplay]) {
        [self tfy_invalidate];
    }
    
    objc_setAssociatedObject(self, kEmptyDataSetSource, [[WeakObjectContainer alloc] initWithWeakObject:tfy_emptyDataSetSource], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 我们添加了sizzling方法来将-tfy_reloadData实现注入到本机-reloadData实现中
    [self swizzleIfPossible:@selector(reloadData)];
    
    // 我们也专门为UITableView注入-tfy_reloadData到- endpdate
    if ([self isKindOfClass:[UITableView class]]) {
        [self swizzleIfPossible:@selector(endUpdates)];
    }
}

- (void)setTfy_emptyDataSetDelegate:(id<EmptyDataSetDelegate>)tfy_emptyDataSetDelegate
{
    if (!tfy_emptyDataSetDelegate) {
        [self tfy_invalidate];
    }
    objc_setAssociatedObject(self, kEmptyDataSetDelegate, [[WeakObjectContainer alloc] initWithWeakObject:tfy_emptyDataSetDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Setters (Private)

- (void)setEmptyDataSetView:(EmptyDataSetView *)view
{
    objc_setAssociatedObject(self, kEmptyDataSetView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Reload APIs (Private)

- (void)tfy_reloadEmptyDataSet
{
    if (![self tfy_canDisplay]) {
        return;
    }
    
    if (([self tfy_shouldDisplay] && [self tfy_itemsCount] == 0) || [self tfy_shouldBeForcedToDisplay])
    {
        // 通知空数据集视图将出现
        [self tfy_willAppear];
        
        EmptyDataSetView *view = self.emptyDataSetView;
        
        if (!view.superview) {
            // 将视图一直发送到后面，以防出现页眉和/或页脚，以及sectionHeaders或任何其他内容
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
                [self insertSubview:view atIndex:0];
            }
            else {
                [self addSubview:view];
            }
        }
        
        // 移除视图重置视图及其约束，保证良好的状态非常重要
        [view prepareForReuse];
        
        UIView *customView = [self tfy_customView];
        
        // 如果一个非nil自定义视图可用，让我们来配置它
        if (customView) {
            view.customView = customView;
        }
        else {
            // 从数据源获取数据
            NSAttributedString *titleLabelString = [self tfy_titleLabelString];
            NSAttributedString *detailLabelString = [self tfy_detailLabelString];
            
            UIImage *buttonImage = [self tfy_buttonImageForState:UIControlStateNormal];
            NSAttributedString *buttonTitle = [self tfy_buttonTitleForState:UIControlStateNormal];
            
            UIImage *image = [self tfy_image];
            UIColor *imageTintColor = [self tfy_imageTintColor];
            UIImageRenderingMode renderingMode = imageTintColor ? UIImageRenderingModeAlwaysTemplate : UIImageRenderingModeAlwaysOriginal;
            
            view.verticalSpace = [self tfy_verticalSpace];
            
            // 配置图片
            if (image) {
                if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
                    view.imageView.image = [image imageWithRenderingMode:renderingMode];
                    view.imageView.tintColor = imageTintColor;
                }
                else {
                    // iOS 6回退:如果需要，插入代码转换图像
                    view.imageView.image = image;
                }
            }
            
            // 配置标题标签
            if (titleLabelString) {
                view.titleLabel.attributedText = titleLabelString;
            }
            
            // 配置详细标签
            if (detailLabelString) {
                view.detailLabel.attributedText = detailLabelString;
            }
            
            // 配置按钮
            if (buttonImage) {
                [view.button setImage:buttonImage forState:UIControlStateNormal];
                [view.button setImage:[self tfy_buttonImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }
            else if (buttonTitle) {
                [view.button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
                [view.button setAttributedTitle:[self tfy_buttonTitleForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                [view.button setBackgroundImage:[self tfy_buttonBackgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
                [view.button setBackgroundImage:[self tfy_buttonBackgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }
        }
        
        // 配置抵消
        view.verticalOffset = [self tfy_verticalOffset];
        
        // 配置空数据集视图
        view.backgroundColor = [self tfy_dataSetBackgroundColor];
        view.hidden = NO;
        view.clipsToBounds = YES;
        
        // 配置空数据集userInteraction权限
        view.userInteractionEnabled = [self tfy_isTouchAllowed];
        
        // 配置空数据集淡入显示
        view.fadeInOnDisplay = [self tfy_shouldFadeIn];
        
        [view setupConstraints];
        
        [UIView performWithoutAnimation:^{
            [view layoutIfNeeded];
        }];
        
        // 配置滚动许可
        self.scrollEnabled = [self tfy_isScrollAllowed];
        
        // 配置图像视图动画
        if ([self tfy_isImageViewAnimateAllowed])
        {
            CAAnimation *animation = [self tfy_imageAnimation];
            
            if (animation) {
                [self.emptyDataSetView.imageView.layer addAnimation:animation forKey:kEmptyImageViewAnimationKey];
            }
        }
        else if ([self.emptyDataSetView.imageView.layer animationForKey:kEmptyImageViewAnimationKey]) {
            [self.emptyDataSetView.imageView.layer removeAnimationForKey:kEmptyImageViewAnimationKey];
        }
        
        // 通知空数据集视图已出现
        [self tfy_didAppear];
    }
    else if (self.tfy_isEmptyDataSetVisible) {
        [self tfy_invalidate];
    }
}

- (void)tfy_invalidate
{
    // 通知空数据集视图将消失
    [self tfy_willDisappear];
    
    if (self.emptyDataSetView) {
        [self.emptyDataSetView prepareForReuse];
        [self.emptyDataSetView removeFromSuperview];
        
        [self setEmptyDataSetView:nil];
    }
    self.scrollEnabled = YES;
    // 通知空数据集视图已消失
    [self tfy_didDisappear];
}


#pragma mark - Method Swizzling

void dzn_original_implementation(id self, SEL _cmd)
{
    // 从查找表中获取原始实现
    Class baseClass = tfy_baseClassToSwizzleForTarget(self);
    NSString *key = tfy_implementationKey(baseClass, _cmd);
    NSDictionary *swizzleInfo = [_impLookupTable objectForKey:key];
    NSValue *impValue = [swizzleInfo valueForKey:SwizzleInfoPointerKey];
    
    IMP impPointer = [impValue pointerValue];

    //然后注入额外的实现来重新加载空数据集
    //在调用原始实现之前执行此操作会及时更新'isEmptyDataSetVisible'标志。
    [self tfy_reloadEmptyDataSet];
    
    // 如果找到，调用原始实现
    if (impPointer) {
        ((void(*)(id,SEL))impPointer)(self,_cmd);
    }
}

NSString *tfy_implementationKey(Class class, SEL selector)
{
    if (!class || !selector) {
        return nil;
    }
    NSString *className = NSStringFromClass([class class]);
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@",className,selectorName];
}

Class tfy_baseClassToSwizzleForTarget(id target)
{
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }
    else if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }
    else if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    return nil;
}

- (void)swizzleIfPossible:(SEL)selector
{
    // 检查目标是否响应选择器
    if (![self respondsToSelector:selector]) {
        return;
    }
    
    // 创建查找表
    if (!_impLookupTable) {
        _impLookupTable = [[NSMutableDictionary alloc] initWithCapacity:3]; // 3 表示受支持的基类
    }
    
    // 我们确保setImplementation会在每个类中调用一次，UITableView或UICollectionView。
    for (NSDictionary *info in [_impLookupTable allValues]) {
        Class class = [info objectForKey:SwizzleInfoOwnerKey];
        NSString *selectorName = [info objectForKey:SwizzleInfoSelectorKey];
        
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    Class baseClass = tfy_baseClassToSwizzleForTarget(self);
    NSString *key = tfy_implementationKey(baseClass, selector);
    NSValue *impValue = [[_impLookupTable objectForKey:key] valueForKey:SwizzleInfoPointerKey];
    
    // 如果这个类的实现已经存在，请跳过!!
    if (impValue || !key || !baseClass) {
        return;
    }
    
    // 通过注入额外的实现实现混合
    Method method = class_getInstanceMethod(baseClass, selector);
    IMP dzn_newImplementation = method_setImplementation(method, (IMP)dzn_original_implementation);
    
    // 将新实现存储在查找表中
    NSDictionary *swizzledInfo = @{SwizzleInfoOwnerKey: baseClass,
                                   SwizzleInfoSelectorKey: NSStringFromSelector(selector),
                                   SwizzleInfoPointerKey: [NSValue valueWithPointer:dzn_newImplementation]};
    
    [_impLookupTable setObject:swizzledInfo forKey:key];
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isEqual:self.emptyDataSetView]) {
        return [self tfy_isTouchAllowed];
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIGestureRecognizer *tapGesture = self.emptyDataSetView.tapGesture;
    
    if ([gestureRecognizer isEqual:tapGesture] || [otherGestureRecognizer isEqual:tapGesture]) {
        return YES;
    }
    // 如果可用，请遵从emptyDataSetDelegate的实现
    if ( (self.tfy_emptyDataSetDelegate != (id)self) && [self.tfy_emptyDataSetDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [(id)self.tfy_emptyDataSetDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    return NO;
}

@end


#pragma mark - EmptyDataSetView

@interface EmptyDataSetView ()
@end

@implementation EmptyDataSetView
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel, detailLabel = _detailLabel, imageView = _imageView, button = _button;

#pragma mark - Initialization Methods

- (instancetype)init
{
    self =  [super init];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didMoveToSuperview
{
    self.frame = self.superview.bounds;
    
    void(^fadeInBlock)(void) = ^{_contentView.alpha = 1.0;};
    
    if (self.fadeInOnDisplay) {
        [UIView animateWithDuration:0.25
                         animations:fadeInBlock
                         completion:NULL];
    }
    else {
        fadeInBlock();
    }
}


#pragma mark - Getters

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [UIView new];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = YES;
        _contentView.alpha = 0;
    }
    return _contentView;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = NO;
        _imageView.accessibilityIdentifier = @"空白背景图像";
        
        [_contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel.font = [UIFont systemFontOfSize:27.0];
        _titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.accessibilityIdentifier = @"空集标题";
        
        [_contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [UILabel new];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.backgroundColor = [UIColor clearColor];
        
        _detailLabel.font = [UIFont systemFontOfSize:17.0];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.numberOfLines = 0;
        _detailLabel.accessibilityIdentifier = @"空集详细标号";
        
        [_contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIButton *)button
{
    if (!_button)
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.backgroundColor = [UIColor clearColor];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _button.accessibilityIdentifier = @"空集按钮";
        
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:_button];
    }
    return _button;
}

- (BOOL)canShowImage
{
    return (_imageView.image && _imageView.superview);
}

- (BOOL)canShowTitle
{
    return (_titleLabel.attributedText.string.length > 0 && _titleLabel.superview);
}

- (BOOL)canShowDetail
{
    return (_detailLabel.attributedText.string.length > 0 && _detailLabel.superview);
}

- (BOOL)canShowButton
{
    if ([_button attributedTitleForState:UIControlStateNormal].string.length > 0 || [_button imageForState:UIControlStateNormal]) {
        return (_button.superview != nil);
    }
    return NO;
}


#pragma mark - Setters

- (void)setCustomView:(UIView *)view
{
    if (!view) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    _customView = view;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_customView];
}


#pragma mark - Action Methods

- (void)didTapButton:(id)sender
{
    SEL selector = NSSelectorFromString(@"dzn_didTapDataButton:");
    
    if ([self.superview respondsToSelector:selector]) {
        [self.superview performSelector:selector withObject:sender afterDelay:0.0f];
    }
}

- (void)removeAllConstraints
{
    [self removeConstraints:self.constraints];
    [_contentView removeConstraints:_contentView.constraints];
}

- (void)prepareForReuse
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _titleLabel = nil;
    _detailLabel = nil;
    _imageView = nil;
    _button = nil;
    _customView = nil;
    
    [self removeAllConstraints];
}


#pragma mark - Auto-Layout Configuration

- (void)setupConstraints
{
    //首先，配置内容视图约束
    //内容视图必须始终位于父视图的中心
    NSLayoutConstraint *centerXConstraint = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterX];
    NSLayoutConstraint *centerYConstraint = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterY];
    
    [self addConstraint:centerXConstraint];
    [self addConstraint:centerYConstraint];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
    
    // 当自定义偏移可用时，我们调整垂直约束的常量
    if (self.verticalOffset != 0 && self.constraints.count > 0) {
        centerYConstraint.constant = self.verticalOffset;
    }
    
    // 如果适用，设置自定义视图的约束
    if (_customView) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|" options:0 metrics:nil views:@{@"customView":_customView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|" options:0 metrics:nil views:@{@"customView":_customView}]];
    }
    else {
        CGFloat width = CGRectGetWidth(self.frame) ? : CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat padding = roundf(width/16.0);
        CGFloat verticalSpace = self.verticalSpace ? : 11.0; // Default is 11 pts
        
        NSMutableArray *subviewStrings = [NSMutableArray array];
        NSMutableDictionary *views = [NSMutableDictionary dictionary];
        NSDictionary *metrics = @{@"padding": @(padding)};
        
        // 指定图像视图的水平约束
        if (_imageView.superview) {
            [subviewStrings addObject:@"imageView"];
            views[[subviewStrings lastObject]] = _imageView;
            [self.contentView addConstraint:[self.contentView equallyRelatedConstraintWithView:_imageView attribute:NSLayoutAttributeCenterX]];
        }
        
        // 分配标题标签的水平约束
        if ([self canShowTitle]) {
            [subviewStrings addObject:@"titleLabel"];
            views[[subviewStrings lastObject]] = _titleLabel;
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[titleLabel(>=0)]-(padding@750)-|"
                                                                                     options:0 metrics:metrics views:views]];
        }
        // 或从它的父视图中删除
        else {
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
        }
        // 分配细节标签的水平约束
        if ([self canShowDetail]) {
            [subviewStrings addObject:@"detailLabel"];
            views[[subviewStrings lastObject]] = _detailLabel;
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[detailLabel(>=0)]-(padding@750)-|"
                                                                                     options:0 metrics:metrics views:views]];
        }
        // 或从它的父视图中删除
        else {
            [_detailLabel removeFromSuperview];
            _detailLabel = nil;
        }
        // 指定按钮的水平约束
        if ([self canShowButton]) {
            [subviewStrings addObject:@"button"];
            views[[subviewStrings lastObject]] = _button;
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[button(>=0)]-(padding@750)-|"
                                                                                     options:0 metrics:metrics views:views]];
        }
        // 或从它的父视图中删除
        else {
            [_button removeFromSuperview];
            _button = nil;
        }
        NSMutableString *verticalFormat = [NSMutableString new];
        // 为垂直约束构建动态字符串格式，在每个元素之间添加边距。默认得分是11。
        for (int i = 0; i < subviewStrings.count; i++) {
            
            NSString *string = subviewStrings[i];
            [verticalFormat appendFormat:@"[%@]", string];
            
            if (i < subviewStrings.count-1) {
                [verticalFormat appendFormat:@"-(%.f@750)-", verticalSpace];
            }
        }
        // 将垂直约束分配给content视图
        if (verticalFormat.length > 0) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|%@|", verticalFormat]
                                                                                     options:0 metrics:metrics views:views]];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if ([hitView isKindOfClass:[UIControl class]]) {
        return hitView;
    }
    if ([hitView isEqual:_contentView] || [hitView isEqual:_customView]) {
        return hitView;
    }
    return nil;
}

@end


#pragma mark - UIView+ConstraintBasedLayoutExtensions

@implementation UIView (ConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

@end

#pragma mark - WeakObjectContainer

@implementation WeakObjectContainer

- (instancetype)initWithWeakObject:(id)object
{
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    return self;
}

@end

