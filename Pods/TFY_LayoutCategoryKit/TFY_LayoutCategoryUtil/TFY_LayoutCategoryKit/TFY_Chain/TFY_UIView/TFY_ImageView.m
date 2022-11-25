//
//  TFY_ImageView.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/1/8.
//  Copyright © 2021 田风有. All rights reserved.
//

#import "TFY_ImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

// 从vm_param。h，定义iOS 8.0或更高版本的设备上构建。
#ifndef BYTE_SIZE
    #define BYTE_SIZE 8 // 以位为单位的字节大小
#endif

#define MEGABYTE (1024 * 1024)

#if defined(DEBUG) && DEBUG
@protocol TFY_AnimatedImageViewDebugDelegate <NSObject>
@optional
- (void)debug_animatedImageView:(TFY_ImageView *)animatedImageView waitingForFrame:(NSUInteger)index duration:(NSTimeInterval)duration;
@end
#endif

@interface TFY_ImageView ()

// 将公共的“readonly”属性重写为私有的“readwrite”
@property (nonatomic, strong, readwrite) UIImage *currentFrame;
@property (nonatomic, assign, readwrite) NSUInteger currentFrameIndex;

@property (nonatomic, assign) NSUInteger loopCountdown;
@property (nonatomic, assign) NSTimeInterval accumulator;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) BOOL shouldAnimate; // 在检查这个值之前，当动画图像或可见性(窗口，父视图，隐藏，alpha)发生变化时，调用' -updateShouldAnimate '。
@property (nonatomic, assign) BOOL needsDisplayWhenImageBecomesAvailable;

#if defined(DEBUG) && DEBUG
@property (nonatomic, weak) id<TFY_AnimatedImageViewDebugDelegate> debug_delegate;
#endif

@end

@implementation TFY_ImageView
@synthesize runLoopMode = _runLoopMode;

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self commonInit];
    }
    return self;
}

// -initWithImage:highlightedImage:也没有作为UIImageView的指定初始化器记录，但是它没有调用任何其他指定的初始化器。
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.runLoopMode = [[self class] defaultRunLoopMode];
    
    if (@available(iOS 11.0, *)) {
        self.accessibilityIgnoresInvertColors = YES;
    }
}


#pragma mark - Accessors
#pragma mark Public

- (void)setAnimatedImage:(TFY_AnimatedImage *)animatedImage
{
    if (![_animatedImage isEqual:animatedImage]) {
        if (animatedImage) {
            if (super.image) {
                super.image = animatedImage.posterImage;
                // 清除图像。
                super.image = nil;
            }
            // 确保残疾人高亮显示;不支持(参见' - sethighlit: ')。
            super.highlighted = NO;
            // UIImageView在计算其内在内容大小时似乎绕过了一些访问器，因此这确保了其内在内容大小来自动画图像。
            [self invalidateIntrinsicContentSize];
        } else {
            // 在动画图像被清除之前停止动画。
            [self stopAnimating];
        }
        
        _animatedImage = animatedImage;
        
        self.currentFrame = animatedImage.posterImage;
        self.currentFrameIndex = 0;
        if (animatedImage.loopCount > 0) {
            self.loopCountdown = animatedImage.loopCount;
        } else {
            self.loopCountdown = NSUIntegerMax;
        }
        self.accumulator = 0.0;
        
        // 设置好新的动画图像后开始动画。
        [self updateShouldAnimate];
        if (self.shouldAnimate) {
            [self startAnimating];
        }
        
        [self.layer setNeedsDisplay];
    }
}


#pragma mark - Life Cycle

- (void)dealloc
{
    // 从所有运行循环模式中移除显示链接。
    [_displayLink invalidate];
}


#pragma mark - UIView Method Overrides
#pragma mark Observing View-Related Changes

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    [self updateShouldAnimate];
    if (self.shouldAnimate) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}


- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    [self updateShouldAnimate];
    if (self.shouldAnimate) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];

    [self updateShouldAnimate];
    if (self.shouldAnimate) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];

    [self updateShouldAnimate];
    if (self.shouldAnimate) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}


#pragma mark Auto Layout

- (CGSize)intrinsicContentSize
{
    // 默认让UIImageView处理它的图像大小，以及它可能考虑的其他任何事情。
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    
    if (self.animatedImage) {
        intrinsicContentSize = self.image.size;
    }
    
    return intrinsicContentSize;
}

#pragma mark Smart Invert Colors

#pragma mark - UIImageView Method Overrides
#pragma mark Image Data

- (UIImage *)image
{
    UIImage *image = nil;
    if (self.animatedImage) {
        // 最初设置为海报图像。
        image = self.currentFrame;
    } else {
        image = super.image;
    }
    return image;
}


- (void)setImage:(UIImage *)image
{
    if (image) {
        // 清除动画图像和隐式暂停动画播放。
        _animatedImage = nil;
    }
    super.image = image;
}


#pragma mark Animating Images

- (NSTimeInterval)frameDelayGreatestCommonDivisor
{
    // 精度设置为“kFLAnimatedImageDelayTimeIntervalMinimum”的一半，以最小化帧下降。
    const NSTimeInterval kGreatestCommonDivisorPrecision = 2.0 / kAnimatedImageDelayTimeIntervalMinimum;

    NSArray *delays = self.animatedImage.delayTimesForIndexes.allValues;

    //通过' kGreatestCommonDivisorPrecision '来衡量帧延迟
    //然后将它转换为一个UInteger for以计算GCD。
    NSUInteger scaledGCD = lrint([delays.firstObject floatValue] * kGreatestCommonDivisorPrecision);
    for (NSNumber *value in delays) {
        scaledGCD = gcd(lrint([value floatValue] * kGreatestCommonDivisorPrecision), scaledGCD);
    }

    // 反向缩放以获得秒的值。
    return scaledGCD / kGreatestCommonDivisorPrecision;
}


static NSUInteger gcd(NSUInteger a, NSUInteger b)
{
    if (a < b) {
        return gcd(b, a);
    } else if (a == b) {
        return b;
    }

    while (true) {
        NSUInteger remainder = a % b;
        if (remainder == 0) {
            return b;
        }
        a = b;
        b = remainder;
    }
}


- (void)startAnimating
{
    if (self.animatedImage) {
        // Lazily create the display link.
        if (!self.displayLink) {
            TFY_WeakProxy *weakProxy = [TFY_WeakProxy weakProxyForObject:self];
            self.displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
            
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:self.runLoopMode];
        }
        const NSTimeInterval kDisplayRefreshRate = 60.0; // 60Hz
        self.displayLink.preferredFramesPerSecond = MAX([self frameDelayGreatestCommonDivisor] * kDisplayRefreshRate, 1);

        self.displayLink.paused = NO;
    } else {
        [super startAnimating];
    }
}

- (void)setRunLoopMode:(NSString *)runLoopMode
{
    if (![@[NSDefaultRunLoopMode, NSRunLoopCommonModes] containsObject:runLoopMode]) {
        NSAssert(NO, @"Invalid run loop mode: %@", runLoopMode);
        _runLoopMode = [[self class] defaultRunLoopMode];
    } else {
        _runLoopMode = runLoopMode;
    }
}

- (void)stopAnimating
{
    if (self.animatedImage) {
        self.displayLink.paused = YES;
    } else {
        [super stopAnimating];
    }
}


- (BOOL)isAnimating
{
    BOOL isAnimating = NO;
    if (self.animatedImage) {
        isAnimating = self.displayLink && !self.displayLink.isPaused;
    } else {
        isAnimating = [super isAnimating];
    }
    return isAnimating;
}


#pragma mark Highlighted Image Unsupport

- (void)setHighlighted:(BOOL)highlighted
{
    // 突出显示的图像不支持动画图像，但实现它会破坏嵌入到UICollectionViewCell中的图像视图。
    if (!self.animatedImage) {
        [super setHighlighted:highlighted];
    }
}


#pragma mark - Private Methods
#pragma mark Animation

//由于性能原因，不要在' -displayDidRefresh: '中重复检查window &父视图。
//当动画图像或可见性(window, superview, hidden, alpha)发生改变时，只需更新缓存的值。
- (void)updateShouldAnimate
{
    BOOL isVisible = self.window && self.superview && ![self isHidden] && self.alpha > 0.0;
    self.shouldAnimate = self.animatedImage && isVisible;
}


- (void)displayDidRefresh:(CADisplayLink *)displayLink
{
    //如果由于某些原因，在我们不应该处于动画状态时，一个野性的调用通过了，退出。
    //复位!
    if (!self.shouldAnimate) {
        TFY_Log(TFY_LogLevelWarn, @"Trying to animate image when we shouldn't: %@", self);
        return;
    }
    
    NSNumber *delayTimeNumber = [self.animatedImage.delayTimesForIndexes objectForKey:@(self.currentFrameIndex)];
    // 如果我们没有帧延迟(例如损坏帧)，不要更新视图，但跳过播放头到下一帧(在else块)。
    if (delayTimeNumber != nil) {
        NSTimeInterval delayTime = [delayTimeNumber floatValue];
        // 如果我们有一个空图像(例如等待帧)，不要更新视图或播放头。
        UIImage *image = [self.animatedImage imageLazilyCachedAtIndex:self.currentFrameIndex];
        if (image) {
            TFY_Log(TFY_LogLevelVerbose, @"Showing frame %lu for animated image: %@", (unsigned long)self.currentFrameIndex, self.animatedImage);
            self.currentFrame = image;
            if (self.needsDisplayWhenImageBecomesAvailable) {
                [self.layer setNeedsDisplay];
                self.needsDisplayWhenImageBecomesAvailable = NO;
            }
            
            self.accumulator += displayLink.duration * displayLink.preferredFramesPerSecond;
            
            while (self.accumulator >= delayTime) {
                self.accumulator -= delayTime;
                self.currentFrameIndex++;
                if (self.currentFrameIndex >= self.animatedImage.frameCount) {
                    // 如果我们已经循环了这个动画图像描述的次数，停止循环。
                    self.loopCountdown--;
                    if (self.loopCompletionBlock) {
                        self.loopCompletionBlock(self.loopCountdown);
                    }
                    
                    if (self.loopCountdown == 0) {
                        [self stopAnimating];
                        return;
                    }
                    self.currentFrameIndex = 0;
                }
                //调用' -setNeedsDisplay '将只绘制当前帧，而不是我们可能已经移动到的新帧。
                //相反，将' needsDisplayWhenImageBecomesAvailable '设置为' YES '——这将在加载后绘制新图像。
                self.needsDisplayWhenImageBecomesAvailable = YES;
            }
        } else {
            TFY_Log(TFY_LogLevelDebug, @"Waiting for frame %lu for animated image: %@", (unsigned long)self.currentFrameIndex, self.animatedImage);
#if defined(DEBUG) && DEBUG
            if ([self.debug_delegate respondsToSelector:@selector(debug_animatedImageView:waitingForFrame:duration:)]) {
                [self.debug_delegate debug_animatedImageView:self waitingForFrame:self.currentFrameIndex duration:(NSTimeInterval)displayLink.duration * displayLink.preferredFramesPerSecond];
            }
#endif
        }
    } else {
        self.currentFrameIndex++;
    }
}

+ (NSString *)defaultRunLoopMode
{
    // 关闭' activeProcessorCount '(与' processorCount '相反)，因为在某些情况下，系统可能会关闭核心。
    return [NSProcessInfo processInfo].activeProcessorCount > 1 ? NSRunLoopCommonModes : NSDefaultRunLoopMode;
}


#pragma mark - CALayerDelegate (Informal)
#pragma mark Providing the Layer's Content

- (void)displayLayer:(CALayer *)layer
{
    layer.contents = (__bridge id)self.image.CGImage;
}



@end

const NSTimeInterval kAnimatedImageDelayTimeIntervalMinimum = 0.02;

typedef NS_ENUM(NSUInteger, TFY_AnimatedImageDataSizeCategory) {
    TFY_AnimatedImageDataSizeCategoryAll = 10,       // 所有帧都永久保存在内存中(对CPU好一点)
    TFY_AnimatedImageDataSizeCategoryDefault = 75,   // 内存中默认大小的帧缓存(通常是实时性能和保持低内存配置)
    TFY_AnimatedImageDataSizeCategoryOnDemand = 250, // 每次只在内存中保存一帧(内存更容易，性能更慢)
    TFY_AnimatedImageDataSizeCategoryUnsupported     // 即使是太大的一帧，电脑也会拒绝。
};

typedef NS_ENUM(NSUInteger, TFY_AnimatedImageFrameCacheSize) {
    TFY_AnimatedImageFrameCacheSizeNoLimit = 0,                // 0表示没有特定的限制
    TFY_AnimatedImageFrameCacheSizeLowMemory = 1,              // 最小帧缓存大小;这将产生按需帧。
    TFY_AnimatedImageFrameCacheSizeGrowAfterMemoryWarning = 2, // 如果我们生产帧的速度比消耗帧的速度快，那么提前一帧就可以实现无口吃的回放。
    TFY_AnimatedImageFrameCacheSizeDefault = 5                 // 建立一个舒适的缓冲窗口来处理CPU的打嗝等。
};


#if defined(DEBUG) && DEBUG
@protocol TFY_AnimatedImageDebugDelegate <NSObject>
@optional
- (void)debug_animatedImage:(TFY_AnimatedImage *)animatedImage didUpdateCachedFrames:(NSIndexSet *)indexesOfFramesInCache;
- (void)debug_animatedImage:(TFY_AnimatedImage *)animatedImage didRequestCachedFrame:(NSUInteger)index;
- (CGFloat)debug_animatedImagePredrawingSlowdownFactor:(TFY_AnimatedImage *)animatedImage;
@end
#endif

@interface TFY_AnimatedImage ()

@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeOptimal; // 基于图像大小和帧数的最优缓存帧数;永远不会改变
@property (nonatomic, assign, readonly, getter=isPredrawingEnabled) BOOL predrawingEnabled; // 能够预先绘制图像以提高性能。
@property (nonatomic, assign) NSUInteger frameCacheSizeMaxInternal; // 允许限制缓存大小，例如当内存警告发生时;0表示没有特定的限制(默认值)
@property (nonatomic, assign) NSUInteger requestedFrameIndex; // 最近请求的帧索引
@property (nonatomic, assign, readonly) NSUInteger posterImageFrameIndex; // 不可净化的海报图像索引;永远不会改变
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedFramesForIndexes;
@property (nonatomic, strong, readonly) NSMutableIndexSet *cachedFrameIndexes; // 缓存帧的索引
@property (nonatomic, strong, readonly) NSMutableIndexSet *requestedFrameIndexes; // 当前在背景中产生的帧的索引
@property (nonatomic, strong, readonly) NSIndexSet *allFramesIndexSet; // 默认索引集与全部索引范围;永远不会改变
@property (nonatomic, assign) NSUInteger memoryWarningCount;
@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;
@property (nonatomic, strong, readonly) __attribute__((NSObject)) CGImageSourceRef imageSource;

//弱代理用于中断内存警告的延迟操作的retain周期。
//我们在这里谎报实际类型，以获得静态类型检查并消除类型转换。
//对象的实际类型是TFY_WeakProxy。
@property (nonatomic, strong, readonly) TFY_AnimatedImage *weakProxy;

#if defined(DEBUG) && DEBUG
@property (nonatomic, weak) id<TFY_AnimatedImageDebugDelegate> debug_delegate;
#endif

@end

// 因为NSNotificationCenter不保留它所通知的对象，所以自定义分派内存警告以避免重分配竞争。
static NSHashTable *allAnimatedImagesWeak;

@implementation TFY_AnimatedImage

// 这是帧缓存需要自身大小的确定值。
- (NSUInteger)frameCacheSizeCurrent
{
    NSUInteger frameCacheSizeCurrent = self.frameCacheSizeOptimal;
    
    // 如果设置了，请尊重大写。
    if (self.frameCacheSizeMax > TFY_AnimatedImageFrameCacheSizeNoLimit) {
        frameCacheSizeCurrent = MIN(frameCacheSizeCurrent, self.frameCacheSizeMax);
    }
    
    if (self.frameCacheSizeMaxInternal > TFY_AnimatedImageFrameCacheSizeNoLimit) {
        frameCacheSizeCurrent = MIN(frameCacheSizeCurrent, self.frameCacheSizeMaxInternal);
    }
    
    return frameCacheSizeCurrent;
}


- (void)setFrameCacheSizeMax:(NSUInteger)frameCacheSizeMax
{
    if (_frameCacheSizeMax != frameCacheSizeMax) {
        
        // 记住新的上限是否会导致当前的缓存大小收缩;然后，如果需要，我们将确保从缓存中清除。
        BOOL willFrameCacheSizeShrink = (frameCacheSizeMax < self.frameCacheSizeCurrent);
        
        // 更新值
        _frameCacheSizeMax = frameCacheSizeMax;
        
        if (willFrameCacheSizeShrink) {
            [self purgeFrameCacheIfNeeded];
        }
    }
}


#pragma mark Private

- (void)setFrameCacheSizeMaxInternal:(NSUInteger)frameCacheSizeMaxInternal
{
    if (_frameCacheSizeMaxInternal != frameCacheSizeMaxInternal) {
        
        // 记住新的上限是否会导致当前的缓存大小收缩;然后，如果需要，我们将确保从缓存中清除。
        BOOL willFrameCacheSizeShrink = (frameCacheSizeMaxInternal < self.frameCacheSizeCurrent);
        
        // 更新值
        _frameCacheSizeMaxInternal = frameCacheSizeMaxInternal;
        
        if (willFrameCacheSizeShrink) {
            [self purgeFrameCacheIfNeeded];
        }
    }
}


#pragma mark - Life Cycle

+ (void)initialize
{
    if (self == [TFY_AnimatedImage class]) {
        // 所有实例共享的UIKit内存警告通知处理器
        allAnimatedImagesWeak = [NSHashTable weakObjectsHashTable];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            // UIKit通知发布在主线程上。didReceiveMemoryWarning:正在等待主运行循环，我们没有锁定所有animateimagesweak
            NSAssert([NSThread isMainThread], @"Received memory warning on non-main thread");
            // 得到所有图片的一个强参考。如果在这个数组中返回一个实例，它仍然是活动的，并且没有进入dealloc。
            // 注意flanimateimages可以在任何线程上创建，所以哈希表必须被锁定。
            NSArray *images = nil;
            @synchronized(allAnimatedImagesWeak) {
                images = [[allAnimatedImagesWeak allObjects] copy];
            }
            // 现在发布通知给所有的图像，同时持有它们的强引用
            [images makeObjectsPerformSelector:@selector(didReceiveMemoryWarning:) withObject:note];
        }];
    }
}


- (instancetype)init
{
    TFY_AnimatedImage *animatedImage = [self initWithAnimatedGIFData:NSData.new];
    if (!animatedImage) {
        TFY_Log(TFY_LogLevelError, @"Use `-initWithAnimatedGIFData:` and supply the animated GIF data as an argument to initialize an object of type `FLAnimatedImage`.");
    }
    return animatedImage;
}


- (instancetype)initWithAnimatedGIFData:(NSData *)data
{
    return [self initWithAnimatedGIFData:data optimalFrameCacheSize:0 predrawingEnabled:YES];
}

- (instancetype)initWithAnimatedGIFData:(NSData *)data optimalFrameCacheSize:(NSUInteger)optimalFrameCacheSize predrawingEnabled:(BOOL)isPredrawingEnabled
{
    // 如果没有提供数据，请提前返回!
    BOOL hasData = ([data length] > 0);
    if (!hasData) {
        TFY_Log(TFY_LogLevelError, @"No animated GIF data supplied.");
        return nil;
    }
    
    self = [super init];
    if (self) {
        // 一次性初始化' readonly '属性直接到ivar，以防止隐式操作和避免需要私有的' readwrite '属性覆盖。
        
        // 保持对“数据”的强引用，并以只读方式公开它。
        // 然而，我们将在整个生命周期中使用' _imageSource '作为图像数据的处理程序。
        _data = data;
        _predrawingEnabled = isPredrawingEnabled;
        
        // 初始化内部数据结构
        _cachedFramesForIndexes = [[NSMutableDictionary alloc] init];
        _cachedFrameIndexes = [[NSMutableIndexSet alloc] init];
        _requestedFrameIndexes = [[NSMutableIndexSet alloc] init];

        // 注意:我们也可以利用“CGImageSourceCreateWithURL”来添加第二个初始化器“-initWithAnimatedGIFContentsOfURL:”。
        _imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                   (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @NO});
        // 早归失败!
        if (!_imageSource) {
            TFY_Log(TFY_LogLevelError, @"Failed to `CGImageSourceCreateWithData` for animated GIF data %@", data);
            return nil;
        }
        
        // 早回来如果不是GIF!
        CFStringRef imageSourceContainerType = CGImageSourceGetType(_imageSource);
        BOOL isGIFData = UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);
        if (!isGIFData) {
            TFY_Log(TFY_LogLevelError, @"Supplied data is of type %@ and doesn't seem to be GIF data %@", imageSourceContainerType, data);
            return nil;
        }
        
        NSDictionary *imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(_imageSource, NULL);
        _loopCount = [[[imageProperties objectForKey:(id)kCGImagePropertyGIFDictionary] objectForKey:(id)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
        
        // 迭代帧图像
        size_t imageCount = CGImageSourceGetCount(_imageSource);
        NSUInteger skippedFrameCount = 0;
        NSMutableDictionary *delayTimesForIndexesMutable = [NSMutableDictionary dictionaryWithCapacity:imageCount];
        for (size_t i = 0; i < imageCount; i++) {
            @autoreleasepool {
                CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(_imageSource, i, NULL);
                if (frameImageRef) {
                    UIImage *frameImage = [UIImage imageWithCGImage:frameImageRef];
                    // 在解析其属性之前检查有效的“frameImage”，因为帧可能被损坏(当“frameImageRef”有效时，“frameImage”甚至是“nil”)。
                    if (frameImage) {
                        // 设置海报图片
                        if (!self.posterImage) {
                            _posterImage = frameImage;
                            // 将其大小设置为代理我们的大小。
                            _size = _posterImage.size;
                            // 记住海报图像索引，所以我们不会清除它;还可以将其添加到缓存中。
                            _posterImageFrameIndex = i;
                            [self.cachedFramesForIndexes setObject:self.posterImage forKey:@(self.posterImageFrameIndex)];
                            [self.cachedFrameIndexes addIndex:self.posterImageFrameIndex];
                        }
                        
                        NSDictionary *frameProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(_imageSource, i, NULL);
                        NSDictionary *framePropertiesGIF = [frameProperties objectForKey:(id)kCGImagePropertyGIFDictionary];
                        
                        // 尽量使用无夹紧延迟时间;恢复到正常延迟时间。
                        NSNumber *delayTime = [framePropertiesGIF objectForKey:(id)kCGImagePropertyGIFUnclampedDelayTime];
                        if (delayTime == nil) {
                            delayTime = [framePropertiesGIF objectForKey:(id)kCGImagePropertyGIFDelayTime];
                        }
                        // 如果我们没有从属性中得到一个延迟时间，退回到' kDelayTimeIntervalDefault '或继承前一帧的值。
                        const NSTimeInterval kDelayTimeIntervalDefault = 0.1;
                        if (delayTime == nil) {
                            if (i == 0) {
                                TFY_Log(TFY_LogLevelInfo, @"Falling back to default delay time for first frame %@ because none found in GIF properties %@", frameImage, frameProperties);
                                delayTime = @(kDelayTimeIntervalDefault);
                            } else {
                                TFY_Log(TFY_LogLevelInfo, @"Falling back to preceding delay time for frame %zu %@ because none found in GIF properties %@", i, frameImage, frameProperties);
                                delayTime = delayTimesForIndexesMutable[@(i - 1)];
                            }
                        }
                        //支持低至' kFLAnimatedImageDelayTimeIntervalMinimum '的帧延迟，为了保持传统兼容性，任何低于' kDelayTimeIntervalDefault '的帧延迟都要向上取整。
                        //为了支持最小值，即使发生舍入错误，在比较时使用一个。我们向下投射到float因为这是从ImageIO获得的delayTime。
                        if ([delayTime floatValue] < ((float)kAnimatedImageDelayTimeIntervalMinimum - FLT_EPSILON)) {
                            TFY_Log(TFY_LogLevelInfo, @"Rounding frame %zu's `delayTime` from %f up to default %f (minimum supported: %f).", i, [delayTime floatValue], kDelayTimeIntervalDefault, kAnimatedImageDelayTimeIntervalMinimum);
                            delayTime = @(kDelayTimeIntervalDefault);
                        }
                        delayTimesForIndexesMutable[@(i)] = delayTime;
                    } else {
                        skippedFrameCount++;
                        TFY_Log(TFY_LogLevelInfo, @"Dropping frame %zu because valid `CGImageRef` %@ did result in `nil`-`UIImage`.", i, frameImageRef);
                    }
                    CFRelease(frameImageRef);
                } else {
                    skippedFrameCount++;
                   TFY_Log(TFY_LogLevelInfo, @"Dropping frame %zu because failed to `CGImageSourceCreateImageAtIndex` with image source %@", i, self->_imageSource);
                }
            }
        }
        _delayTimesForIndexes = [delayTimesForIndexesMutable copy];
        _frameCount = imageCount;
        
        if (self.frameCount == 0) {
            TFY_Log(TFY_LogLevelInfo, @"Failed to create any valid frames for GIF with properties %@", imageProperties);
            return nil;
        } else if (self.frameCount == 1) {
            // 当我们只有一个帧但返回一个有效的GIF时发出警告。
            TFY_Log(TFY_LogLevelInfo, @"Created valid GIF but with only a single frame. Image properties: %@", imageProperties);
        } else {
            //我们有很多帧，摇滚起来!
        }
        
        // 如果没有提供值，请根据GIF选择一个默认值。
        if (optimalFrameCacheSize == 0) {
            //计算最优帧缓存大小:尝试根据预测的图像大小选择一个更大的缓存窗口。
            //它只依赖于图像的大小和帧数，不会改变。
            CGFloat animatedImageDataSize = CGImageGetBytesPerRow(self.posterImage.CGImage) * self.size.height * (self.frameCount - skippedFrameCount) / MEGABYTE;
            if (animatedImageDataSize <= TFY_AnimatedImageDataSizeCategoryAll) {
                _frameCacheSizeOptimal = self.frameCount;
            } else if (animatedImageDataSize <= TFY_AnimatedImageDataSizeCategoryDefault) {
                // 这个值不依赖于设备内存太多,因为如果我们不保持所有帧在内存中我们总是会解码帧前面每1帧被演奏,在这一点上我们不妨把一小缓冲足以阻止的帧。
                _frameCacheSizeOptimal = TFY_AnimatedImageFrameCacheSizeDefault;
            } else {
                // 预测的大小超过了构建缓存的限制，我们从一开始就进入低内存模式。
                _frameCacheSizeOptimal = TFY_AnimatedImageFrameCacheSizeLowMemory;
            }
        } else {
            // 使用提供的值。
            _frameCacheSizeOptimal = optimalFrameCacheSize;
        }
        // 在任何情况下，限制最佳缓存大小为帧数。
        _frameCacheSizeOptimal = MIN(_frameCacheSizeOptimal, self.frameCount);
        
        // 方便/小性能优化;在' -frameIndexesToCache '中方便地设置索引和返回的完整范围。
        _allFramesIndexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.frameCount)];
        
        // 有关说明，请参阅属性声明。
        _weakProxy = (id)[TFY_WeakProxy weakProxyForObject:self];
        
        //将这个实例注册到弱表中，用于内存通知。当我们离开时，NSHashTable会自己清理。
        //注意flanimateimages可以在任何线程上创建，所以哈希表必须被锁定。
        @synchronized(allAnimatedImagesWeak) {
            [allAnimatedImagesWeak addObject:self];
        }
    }
    return self;
}


+ (instancetype)animatedImageWithGIFData:(NSData *)data
{
    TFY_AnimatedImage *animatedImage = [[TFY_AnimatedImage alloc] initWithAnimatedGIFData:data];
    animatedImage.loopCount = 0;
    return animatedImage;
}


- (void)dealloc
{
    if (_weakProxy) {
        [NSObject cancelPreviousPerformRequestsWithTarget:_weakProxy];
    }
    
    if (_imageSource) {
        CFRelease(_imageSource);
    }
}


#pragma mark - Public Methods

//详情见header。
//注意:消费者和生产者都是被限制的:消费者根据帧时间，生产者根据可用内存(最大缓冲区窗口大小)。
- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index
{
    //如果被请求的索引超出边界，则提前返回。
    //注意:我们在比较一个索引和一个计数，需要忽略大于或等于。
    if (index >= self.frameCount) {
        TFY_Log(TFY_LogLevelWarn, @"Skipping requested frame %lu beyond bounds (total frame count: %lu) for animated image: %@", (unsigned long)index, (unsigned long)self.frameCount, self);
        return nil;
    }
    
    // 记住，请求的帧索引，这影响我们下一步应该缓存什么。
    self.requestedFrameIndex = index;
#if defined(DEBUG) && DEBUG
    if ([self.debug_delegate respondsToSelector:@selector(debug_animatedImage:didRequestCachedFrame:)]) {
        [self.debug_delegate debug_animatedImage:self didRequestCachedFrame:index];
    }
#endif
    
    // 快速检查，避免做任何工作，如果我们已经有所有可能的帧缓存，一个常见的情况。
    if ([self.cachedFrameIndexes count] < self.frameCount) {
        //如果我们有应该被缓存但还没有被请求的帧，请求它们。
        //排除已经缓存的帧、已经请求的帧和特别缓存的海报图像。
        NSMutableIndexSet *frameIndexesToAddToCacheMutable = [self frameIndexesToCache];
        [frameIndexesToAddToCacheMutable removeIndexes:self.cachedFrameIndexes];
        [frameIndexesToAddToCacheMutable removeIndexes:self.requestedFrameIndexes];
        [frameIndexesToAddToCacheMutable removeIndex:self.posterImageFrameIndex];
        NSIndexSet *frameIndexesToAddToCache = [frameIndexesToAddToCacheMutable copy];
        
        // 异步添加帧到我们的缓存。
        if ([frameIndexesToAddToCache count] > 0) {
            [self addFrameIndexesToCache:frameIndexesToAddToCache];
        }
    }
    
    // 获取指定的图像。
    UIImage *image = self.cachedFramesForIndexes[@(index)];
    
    // 如果需要，根据当前播放头位置进行清除。
    [self purgeFrameCacheIfNeeded];
    
    return image;
}


// 从' -imageLazilyCachedAtIndex '只调用一次，但考虑到它自己的方法进行逻辑分组。
- (void)addFrameIndexesToCache:(NSIndexSet *)frameIndexesToAddToCache
{
    //顺序很重要。首先，从请求的帧索引开始遍历索引。然后，如果在请求的帧索引之前有任何索引，执行这些操作。
    NSRange firstRange = NSMakeRange(self.requestedFrameIndex, self.frameCount - self.requestedFrameIndex);
    NSRange secondRange = NSMakeRange(0, self.requestedFrameIndex);
    if (firstRange.length + secondRange.length != self.frameCount) {
        TFY_Log(TFY_LogLevelWarn, @"Two-part frame cache range doesn't equal full range.");
    }
    
    // 在我们实际启动它们之前，将它们添加到被请求的列表中，这样它们就不会两次进入队列。
    [self.requestedFrameIndexes addIndexes:frameIndexesToAddToCache];
    
    // 惰性地创建专用隔离队列。
    if (!self.serialQueue) {
        _serialQueue = dispatch_queue_create("com.flipboard.framecachingqueue", DISPATCH_QUEUE_SERIAL);
    }
    
    //开始在后台流请求帧到缓存。
    //避免在块中捕捉self，因为如果动画图像消失，没有理由继续工作。
    TFY_AnimatedImage * __weak weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        // 生成并缓存下一个需要的帧。
        void (^frameRangeBlock)(NSRange, BOOL *) = ^(NSRange range, BOOL *stop) {
            // 遍历连续索引;可以比' enumerateIndexesInRange:options:usingBlock: '更快。
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
#if defined(DEBUG) && DEBUG
                CFTimeInterval predrawBeginTime = CACurrentMediaTime();
#endif
                UIImage *image = [weakSelf imageAtIndex:i];
#if defined(DEBUG) && DEBUG
                CFTimeInterval predrawDuration = CACurrentMediaTime() - predrawBeginTime;
                CFTimeInterval slowdownDuration = 0.0;
                if ([self.debug_delegate respondsToSelector:@selector(debug_animatedImagePredrawingSlowdownFactor:)]) {
                    CGFloat predrawingSlowdownFactor = [self.debug_delegate debug_animatedImagePredrawingSlowdownFactor:self];
                    slowdownDuration = predrawDuration * predrawingSlowdownFactor - predrawDuration;
                    [NSThread sleepForTimeInterval:slowdownDuration];
                }
                TFY_Log(TFY_LogLevelVerbose, @"Predrew frame %lu in %f ms for animated image: %@", (unsigned long)i, (predrawDuration + slowdownDuration) * 1000, self);
#endif
                //结果一旦准备好(而不是批处理)就会一个接一个地返回。
                //当CPU突然繁忙时，拥有尽可能快的第一个帧的好处超过建立一个缓冲来处理潜在的中断。
                if (image && weakSelf) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.cachedFramesForIndexes[@(i)] = image;
                        [weakSelf.cachedFrameIndexes addIndex:i];
                        [weakSelf.requestedFrameIndexes removeIndex:i];
#if defined(DEBUG) && DEBUG
                        if ([weakSelf.debug_delegate respondsToSelector:@selector(debug_animatedImage:didUpdateCachedFrames:)]) {
                            [weakSelf.debug_delegate debug_animatedImage:weakSelf didUpdateCachedFrames:weakSelf.cachedFrameIndexes];
                        }
#endif
                    });
                }
            }
        };
        
        [frameIndexesToAddToCache enumerateRangesInRange:firstRange options:0 usingBlock:frameRangeBlock];
        [frameIndexesToAddToCache enumerateRangesInRange:secondRange options:0 usingBlock:frameRangeBlock];
    });
}


+ (CGSize)sizeForImage:(id)image
{
    CGSize imageSize = CGSizeZero;
    
    // 早退零
    if (!image) {
        return imageSize;
    }
    
    if ([image isKindOfClass:[UIImage class]]) {
        UIImage *uiImage = (UIImage *)image;
        imageSize = uiImage.size;
    } else if ([image isKindOfClass:[TFY_AnimatedImage class]]) {
        TFY_AnimatedImage *animatedImage = (TFY_AnimatedImage *)image;
        imageSize = animatedImage.size;
    } else {
        // 捕捉坏图像的捕熊器;我们在ios7上看到了crash。
        TFY_Log(TFY_LogLevelError, @"`image` isn't of expected types `UIImage` or `FLAnimatedImage`: %@", image);
    }
    
    return imageSize;
}


#pragma mark - Private Methods
#pragma mark Frame Loading

- (UIImage *)imageAtIndex:(NSUInteger)index
{
    // 使用缓存的“_imageSource”是非常重要的，因为随机访问带有“CGImageSourceCreateImageAtIndex”的帧会在每次重新初始化图像源时从O(1)变成O(n)操作。
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSource, index, NULL);

    // 早退零
    if (!imageRef) {
        return nil;
    }

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    
    // 加载图像对象只完成了一半的工作，正在显示的图像视图仍然需要同步等待和解码图像，所以我们继续在后台线程中做这些。
    if (self.isPredrawingEnabled) {
        image = [[self class] predrawnImageFromImage:image];
    }
    
    return image;
}


#pragma mark Frame Caching

- (NSMutableIndexSet *)frameIndexesToCache
{
    NSMutableIndexSet *indexesToCache = nil;
    // 如果缓存的帧数等于总帧数，快速检查以避免建立索引集。
    if (self.frameCacheSizeCurrent == self.frameCount) {
        indexesToCache = [self.allFramesIndexSet mutableCopy];
    } else {
        indexesToCache = [[NSMutableIndexSet alloc] init];
        
        //在两个单独的块中添加索引——第一个从请求的帧索引开始，直到限制或结束。
        //第二帧，如果需要，从索引0开始的剩余帧数。
        NSUInteger firstLength = MIN(self.frameCacheSizeCurrent, self.frameCount - self.requestedFrameIndex);
        NSRange firstRange = NSMakeRange(self.requestedFrameIndex, firstLength);
        [indexesToCache addIndexesInRange:firstRange];
        NSUInteger secondLength = self.frameCacheSizeCurrent - firstLength;
        if (secondLength > 0) {
            NSRange secondRange = NSMakeRange(0, secondLength);
            [indexesToCache addIndexesInRange:secondRange];
        }
        // 在我们添加海报图像索引之前，请仔细检查我们的数学运算，这可能会使其增加1。
        if ([indexesToCache count] != self.frameCacheSizeCurrent) {
            TFY_Log(TFY_LogLevelWarn, @"Number of frames to cache doesn't equal expected cache size.");
        }
        
        [indexesToCache addIndex:self.posterImageFrameIndex];
    }
    
    return indexesToCache;
}


- (void)purgeFrameCacheIfNeeded
{
    //清除当前缓存但不需要缓存的帧。
    //如果我们仍然在缓存帧数以下，则不会缓存。
    //这样，如果所有的帧都被允许缓存(通常情况下)，我们可以跳过所有的NSIndexSet。
    if ([self.cachedFrameIndexes count] > self.frameCacheSizeCurrent) {
        NSMutableIndexSet *indexesToPurge = [self.cachedFrameIndexes mutableCopy];
        [indexesToPurge removeIndexes:[self frameIndexesToCache]];
        [indexesToPurge enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
            // 遍历连续索引;可以比' enumerateIndexesInRange:options:usingBlock: '更快。
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
                [self.cachedFrameIndexes removeIndex:i];
                [self.cachedFramesForIndexes removeObjectForKey:@(i)];
                // 注意:不要在图像源上使用' CGImageSourceRemoveCacheAtIndex '，因为我们不希望在缓存中继续保持O(1)时间访问。
#if defined(DEBUG) && DEBUG
                if ([self.debug_delegate respondsToSelector:@selector(debug_animatedImage:didUpdateCachedFrames:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.debug_delegate debug_animatedImage:self didUpdateCachedFrames:self.cachedFrameIndexes];
                    });
                }
#endif
            }
        }];
    }
}


- (void)growFrameCacheSizeAfterMemoryWarning:(NSNumber *)frameCacheSize
{
    self.frameCacheSizeMaxInternal = [frameCacheSize unsignedIntegerValue];
    TFY_Log(TFY_LogLevelDebug, @"Grew frame cache size max to %lu after memory warning for animated image: %@", (unsigned long)self.frameCacheSizeMaxInternal, self);
    
    // 计划在一段时间后完全重置帧缓存大小最大值。
    const NSTimeInterval kResetDelay = 3.0;
    [self.weakProxy performSelector:@selector(resetFrameCacheSizeMaxInternal) withObject:nil afterDelay:kResetDelay];
}


- (void)resetFrameCacheSizeMaxInternal
{
    self.frameCacheSizeMaxInternal = TFY_AnimatedImageFrameCacheSizeNoLimit;
    TFY_Log(TFY_LogLevelDebug, @"Reset frame cache size max (current frame cache size: %lu) for animated image: %@", (unsigned long)self.frameCacheSizeCurrent, self);
}


#pragma mark System Memory Warnings Notification Handler

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    self.memoryWarningCount++;
    
    // 如果我们想要变得更大，但又被系统敲了一下指头，取消。
    [NSObject cancelPreviousPerformRequestsWithTarget:self.weakProxy selector:@selector(growFrameCacheSizeAfterMemoryWarning:) object:@(TFY_AnimatedImageFrameCacheSizeGrowAfterMemoryWarning)];
    [NSObject cancelPreviousPerformRequestsWithTarget:self.weakProxy selector:@selector(resetFrameCacheSizeMaxInternal) object:nil];
    
    // 降低到最小值，如果不被系统丢弃，隐式地立即从缓存中清除，并开始按需生成帧。
    TFY_Log(TFY_LogLevelDebug, @"Attempt setting frame cache size max to %lu (previous was %lu) after memory warning #%lu for animated image: %@", (unsigned long)TFY_AnimatedImageFrameCacheSizeLowMemory, (unsigned long)self.frameCacheSizeMaxInternal, (unsigned long)self.memoryWarningCount, self);
    self.frameCacheSizeMaxInternal = TFY_AnimatedImageFrameCacheSizeLowMemory;
    
    const NSUInteger kGrowAttemptsMax = 2;
    const NSTimeInterval kGrowDelay = 2.0;
    if ((self.memoryWarningCount - 1) <= kGrowAttemptsMax) {
        [self.weakProxy performSelector:@selector(growFrameCacheSizeAfterMemoryWarning:) withObject:@(TFY_AnimatedImageFrameCacheSizeGrowAfterMemoryWarning) afterDelay:kGrowDelay];
    }
}


#pragma mark Image Decoding

//解码图像的数据，并在内存中绘制它完全脱离屏幕;它是线程安全的，因此可以在后台线程上调用。
//如果成功，返回的对象是一个新的' UIImage '实例，具有与传入的相同的内容。
//失败时，返回的对象是传入的不变对象;数据将不会预先绘制在内存中，错误将被记录。
+ (UIImage *)predrawnImageFromImage:(UIImage *)imageToPredraw
{
    // 始终使用设备RGB颜色空间，以保持简单性和可预测性。
    CGColorSpaceRef colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB();
    // 早归失败!
    if (!colorSpaceDeviceRGBRef) {
        TFY_Log(TFY_LogLevelError, @"Failed to `CGColorSpaceCreateDeviceRGB` for image %@", imageToPredraw);
        return imageToPredraw;
    }
    
    //即使图像没有透明度，我们也必须添加额外的通道，因为Quartz不支持其他像素格式，除了32 bpp/8 bpc的RGB:
    // kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst, kCGImageAlphaPremultipliedLast . //
    //(来源:docs "Quartz 2D Programming Guide > Graphics Contexts > Table 2-1 pixels formats supported for bitmap Graphics Contexts ")
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceDeviceRGBRef) + 1; // 4: RGB + A
    
    // “在iOS 4.0及更高版本，OS X v10.6及更高版本，如果你想让Quartz为位图分配内存，你可以传递NULL。”(来源:文档)
    void *data = NULL;
    size_t width = imageToPredraw.size.width;
    size_t height = imageToPredraw.size.height;
    size_t bitsPerComponent = CHAR_BIT;
    
    size_t bitsPerPixel = (bitsPerComponent * numberOfComponents);
    size_t bytesPerPixel = (bitsPerPixel / BYTE_SIZE);
    size_t bytesPerRow = (bytesPerPixel * width);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageToPredraw.CGImage);
    // 如果alpha信息不匹配支持的格式之一(见上文)，选择一个合理的支持格式。
    // 对于iOS 3.2及以后版本创建的位图，绘图环境使用预乘的ARGB格式来存储位图数据。(来源:文档)
    if (alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaOnly) {
        alphaInfo = kCGImageAlphaNoneSkipFirst;
    } else if (alphaInfo == kCGImageAlphaFirst) {
        alphaInfo = kCGImageAlphaPremultipliedFirst;
    } else if (alphaInfo == kCGImageAlphaLast) {
        alphaInfo = kCGImageAlphaPremultipliedLast;
    }
    // "用于指定alpha通道信息的常量是用' CGImageAlphaInfo '类型声明的，但可以安全地传递给这个参数。"(来源:文档)
    bitmapInfo |= alphaInfo;
    
    CGContextRef bitmapContextRef = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpaceDeviceRGBRef, bitmapInfo);
    CGColorSpaceRelease(colorSpaceDeviceRGBRef);
    // 早归失败!
    if (!bitmapContextRef) {
        TFY_Log(TFY_LogLevelError, @"Failed to `CGBitmapContextCreate` with color space %@ and parameters (width: %zu height: %zu bitsPerComponent: %zu bytesPerRow: %zu) for image %@", colorSpaceDeviceRGBRef, width, height, bitsPerComponent, bytesPerRow, imageToPredraw);
        return imageToPredraw;
    }
    
    // 在位图上下文中绘制图像，并通过保留接收方的属性来创建图像。
    CGContextDrawImage(bitmapContextRef, CGRectMake(0.0, 0.0, imageToPredraw.size.width, imageToPredraw.size.height), imageToPredraw.CGImage);
    CGImageRef predrawnImageRef = CGBitmapContextCreateImage(bitmapContextRef);
    UIImage *predrawnImage = [UIImage imageWithCGImage:predrawnImageRef scale:imageToPredraw.scale orientation:imageToPredraw.imageOrientation];
    CGImageRelease(predrawnImageRef);
    CGContextRelease(bitmapContextRef);
    
    // 早归失败!
    if (!predrawnImage) {
        TFY_Log(TFY_LogLevelError, @"Failed to `imageWithCGImage:scale:orientation:` with image ref %@ created with color space %@ and bitmap context %@ and properties and properties (scale: %f orientation: %ld) for image %@", predrawnImageRef, colorSpaceDeviceRGBRef, bitmapContextRef, imageToPredraw.scale, (long)imageToPredraw.imageOrientation, imageToPredraw);
        return imageToPredraw;
    }
    
    return predrawnImage;
}


#pragma mark - Description

- (NSString *)description
{
    NSString *description = [super description];
    
    description = [description stringByAppendingFormat:@" size=%@", NSStringFromCGSize(self.size)];
    description = [description stringByAppendingFormat:@" frameCount=%lu", (unsigned long)self.frameCount];
    
    return description;
}


@end

#pragma mark - Logging

@implementation TFY_AnimatedImage (Logging)

static void (^_logBlock)(NSString *logString, TFY_LogLevel logLevel) = nil;
static TFY_LogLevel _logLevel;

+ (void)setLogBlock:(void (^)(NSString *logString, TFY_LogLevel logLevel))logBlock logLevel:(TFY_LogLevel)logLevel
{
    _logBlock = logBlock;
    _logLevel = logLevel;
}

+ (void)logStringFromBlock:(NSString *(^)(void))stringBlock withLevel:(TFY_LogLevel)level
{
    if (level <= _logLevel && _logBlock && stringBlock) {
        _logBlock(stringBlock(), level);
    }
}

@end


#pragma mark - FLWeakProxy

@interface TFY_WeakProxy ()

@property (nonatomic, weak) id target;

@end


@implementation TFY_WeakProxy

#pragma mark Life Cycle

+ (instancetype)weakProxyForObject:(id)targetObject
{
    TFY_WeakProxy *weakProxy = [TFY_WeakProxy alloc];
    weakProxy.target = targetObject;
    return weakProxy;
}


#pragma mark Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector {return _target;}


#pragma mark - NSWeakProxy Method Overrides
#pragma mark Handling Unimplemented Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}


@end

