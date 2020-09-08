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

static char * const headerImageViewKey = "headerImageViewKey";
static char * const headerImageViewHeight = "headerImageViewHeight";
static char * const isInitialKey = "isInitialKey";

// 默认图片高度
static CGFloat const oriImageH = 200;

@implementation UIScrollView (TFY_Tools)

- (void)adJustedContentIOS11{
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
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
@end
