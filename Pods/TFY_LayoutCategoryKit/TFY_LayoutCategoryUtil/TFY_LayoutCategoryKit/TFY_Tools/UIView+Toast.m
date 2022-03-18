//
//  UIView+Toast.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/2/3.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "UIView+Toast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Positions
NSString * TFYToastPositionTop                       = @"TFYToastPositionTop";
NSString * TFYToastPositionCenter                    = @"TFYToastPositionCenter";
NSString * TFYToastPositionBottom                    = @"TFYToastPositionBottom";

// Keys for values associated with toast views
static const NSString * TFYToastTimerKey             = @"TFYToastTimerKey";
static const NSString * TFYToastDurationKey          = @"TFYToastDurationKey";
static const NSString * TFYToastPositionKey          = @"TFYToastPositionKey";
static const NSString * TFYToastCompletionKey        = @"TFYToastCompletionKey";

// Keys for values associated with self
static const NSString * TFYToastActiveKey            = @"TFYToastActiveKey";
static const NSString * TFYToastActivityViewKey      = @"TFYToastActivityViewKey";
static const NSString * TFYToastQueueKey             = @"TFYToastQueueKey";

@interface UIView (TUIToastPrivate)

/**
 这些私有方法被冠以“tfy_的前缀，以减少不明显的可能性
 与其他UIView方法命名冲突。

 公共API也应该使用cs_前缀吗?从技术上讲，它应该是，但它
 结果产生的代码不易辨认。当前的公共方法名似乎不太可能引起
 所以我认为我们现在应该支持更干净的API。
 */
- (void)tfy_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position;
- (void)tfy2_hideToast:(UIView *)toast;
- (void)tfy_hideToast:(UIView *)toast fromTap:(BOOL)fromTap;
- (void)tfy_toastTimerDidFinish:(NSTimer *)timer;
- (void)tfy_handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)tfy_centerPointForPosition:(id)position withToast:(UIView *)toast;
- (NSMutableArray *)tfy_toastQueue;

@end

@implementation UIView (Toast)
#pragma mark - Make Toast Methods

- (void)tfy_makeToast:(NSString *)message {
    [self tfy_makeToast:message duration:[TFYToastManager defaultDuration] position:[TFYToastManager defaultPosition] style:[TFYToastManager sharedStyle]];
}

- (void)tfy_makeToast:(NSString *)message duration:(NSTimeInterval)duration {
    [self tfy_makeToast:message duration:duration position:[TFYToastManager defaultPosition] style:[TFYToastManager sharedStyle]];
}

- (void)tfy_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    [self tfy_makeToast:message duration:duration position:position style:[TFYToastManager sharedStyle]];
}

- (void)tfy_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position style:(TFYToastStyle *)style {
    UIView *toast = [self tfy_toastViewForMessage:message title:@"" image:@"" style:style];
    [self tfy_showToast:toast duration:duration position:position completion:^(BOOL didTap) {}];
}

- (void)tfy_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title image:(NSString *)image style:(TFYToastStyle *)style completion:(void(^)(BOOL didTap))completion {
    UIView *toast = [self tfy_toastViewForMessage:message title:title image:image style:style];
    [self tfy_showToast:toast duration:duration position:position completion:completion];
}

#pragma mark - Show Toast Methods

- (void)tfy_showToast:(UIView *)toast {
    [self tfy_showToast:toast duration:[TFYToastManager defaultDuration] position:[TFYToastManager defaultPosition] completion:^(BOOL didTap) {}];
}

- (void)tfy_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position completion:(void(^)(BOOL didTap))completion {
    // sanity
    if (toast == nil) return;
    
    // store the completion block on the toast view
    objc_setAssociatedObject(toast, &TFYToastCompletionKey, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([TFYToastManager isQueueEnabled] && [self.tfy_activeToasts count] > 0) {
        // we're about to queue this toast view so we need to store the duration and position as well
        objc_setAssociatedObject(toast, &TFYToastDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(toast, &TFYToastPositionKey, position, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // enqueue
        [self.tfy_toastQueue addObject:toast];
    } else {
        // present
        [self tfy_showToast:toast duration:duration position:position];
    }
}

#pragma mark - Hide Toast Methods

- (void)tfy_hideToast {
    [self tfy_hideToast:[[self tfy_activeToasts] firstObject]];
}

- (void)tfy_hideToast:(UIView *)toast {
    // sanity
    if (!toast || ![[self tfy_activeToasts] containsObject:toast]) return;
    
    [self tfy2_hideToast:toast];
}

- (void)tfy_hideAllToasts {
    [self tfy_hideAllToasts:NO clearQueue:YES];
}

- (void)tfy_hideAllToasts:(BOOL)includeActivity clearQueue:(BOOL)clearQueue {
    if (clearQueue) {
        [self tfy_clearToastQueue];
    }
    
    for (UIView *toast in [self tfy_activeToasts]) {
        [self tfy_hideToast:toast];
    }
    
    if (includeActivity) {
        [self tfy_hideToastActivity];
    }
}

- (void)tfy_clearToastQueue {
    [[self tfy_toastQueue] removeAllObjects];
}

#pragma mark - Private Show/Hide Methods

- (void)tfy_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position {
    toast.center = [self tfy_centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;
    
    if ([TFYToastManager isTapToDismissEnabled]) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tfy_handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    
    [[self tfy_activeToasts] addObject:toast];
    
    [self addSubview:toast];
    
    [UIView animateWithDuration:[[TFYToastManager sharedStyle] fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(tfy_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                         objc_setAssociatedObject(toast, &TFYToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}

- (void)tfy2_hideToast:(UIView *)toast {
    [self tfy_hideToast:toast fromTap:NO];
}
    
- (void)tfy_hideToast:(UIView *)toast fromTap:(BOOL)fromTap {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &TFYToastTimerKey);
    [timer invalidate];
    
    [UIView animateWithDuration:[[TFYToastManager sharedStyle] fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         
                         // remove
                         [[self tfy_activeToasts] removeObject:toast];
                         
                         // execute the completion block, if necessary
                         void (^completion)(BOOL didTap) = objc_getAssociatedObject(toast, &TFYToastCompletionKey);
                         if (completion) {
                             completion(fromTap);
                         }
                         
                         if ([self.tfy_toastQueue count] > 0) {
                             // dequeue
                             UIView *nextToast = [[self tfy_toastQueue] firstObject];
                             [[self tfy_toastQueue] removeObjectAtIndex:0];
                             
                             // present the next toast
                             NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &TFYToastDurationKey) doubleValue];
                             id position = objc_getAssociatedObject(nextToast, &TFYToastPositionKey);
                             [self tfy_showToast:nextToast duration:duration position:position];
                         }
                     }];
}

#pragma mark - View Construction

- (UIView *)tfy_toastViewForMessage:(NSString *)message title:(NSString *)title image:(NSString *)image style:(TFYToastStyle *)style {
    // sanity
    if ([self emptyWithString:message] && [self emptyWithString:title] && [self emptyWithString:image]) return nil;
    
    // default to the shared style
    if (style == nil) {
        style = [TFYToastManager sharedStyle];
    }
    
    // dynamically build a toast view with any combination of message, title, & image
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = style.cornerRadius;
    
    if (style.displayShadow) {
        wrapperView.layer.shadowColor = style.shadowColor.CGColor;
        wrapperView.layer.shadowOpacity = style.shadowOpacity;
        wrapperView.layer.shadowRadius = style.shadowRadius;
        wrapperView.layer.shadowOffset = style.shadowOffset;
    }
    
    wrapperView.backgroundColor = style.backgroundColor;
    
    if(![self emptyWithString:image]) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(style.horizontalPadding, style.verticalPadding, style.imageSize.width, style.imageSize.height);
    }
    
    CGRect imageRect = CGRectZero;
    
    if(imageView != nil) {
        imageRect.origin.x = style.horizontalPadding;
        imageRect.origin.y = style.verticalPadding;
        imageRect.size.width = imageView.bounds.size.width;
        imageRect.size.height = imageView.bounds.size.height;
    }
    
    if (![self emptyWithString:title]) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = style.titleNumberOfLines;
        titleLabel.font = style.titleFont;
        titleLabel.textAlignment = style.titleAlignment;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = style.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeTitle = [titleLabel sizeThatFits:maxSizeTitle];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeTitle = CGSizeMake(MIN(maxSizeTitle.width, expectedSizeTitle.width), MIN(maxSizeTitle.height, expectedSizeTitle.height));
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (![self emptyWithString:message]) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = style.messageNumberOfLines;
        messageLabel.font = style.messageFont;
        messageLabel.textAlignment = style.messageAlignment;
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textColor = style.messageColor;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    CGRect titleRect = CGRectZero;
    
    if(titleLabel != nil) {
        titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        titleRect.origin.y = style.verticalPadding;
        titleRect.size.width = titleLabel.bounds.size.width;
        titleRect.size.height = titleLabel.bounds.size.height;
    }
    
    CGRect messageRect = CGRectZero;
    
    if(messageLabel != nil) {
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding;
        messageRect.size.width = messageLabel.bounds.size.width;
        messageRect.size.height = messageLabel.bounds.size.height;
    }
    
    CGFloat longerWidth = MAX(titleRect.size.width, messageRect.size.width);
    CGFloat longerX = MAX(titleRect.origin.x, messageRect.origin.x);
    
    // Wrapper width uses the longerWidth or the image width, whatever is larger. Same logic applies to the wrapper height.
    CGFloat wrapperWidth = MAX((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    
    if(titleLabel != nil) {
        titleLabel.frame = titleRect;
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        messageLabel.frame = messageRect;
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}

-(BOOL)emptyWithString:(NSString *)string {
    if (string.length == 0 || [string isEqualToString:@""] || string == nil || string == NULL || [string isEqual:[NSNull null]] || [string isEqualToString:@" "] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    return NO;
}

#pragma mark - Storage

- (NSMutableArray *)tfy_activeToasts {
    NSMutableArray *tfy_activeToasts = objc_getAssociatedObject(self, &TFYToastActiveKey);
    if (tfy_activeToasts == nil) {
        tfy_activeToasts = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &TFYToastActiveKey, tfy_activeToasts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tfy_activeToasts;
}

- (NSMutableArray *)tfy_toastQueue {
    NSMutableArray *tfy_toastQueue = objc_getAssociatedObject(self, &TFYToastQueueKey);
    if (tfy_toastQueue == nil) {
        tfy_toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &TFYToastQueueKey, tfy_toastQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tfy_toastQueue;
}

#pragma mark - Events

- (void)tfy_toastTimerDidFinish:(NSTimer *)timer {
    [self tfy2_hideToast:(UIView *)timer.userInfo];
}

- (void)tfy_handleToastTapped:(UITapGestureRecognizer *)recognizer {
    UIView *toast = recognizer.view;
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &TFYToastTimerKey);
    [timer invalidate];
    [self tfy_hideToast:toast fromTap:YES];
}

#pragma mark - Activity Methods

- (void)tfy_makeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &TFYToastActivityViewKey);
    if (existingActivityView != nil) return;
    
    TFYToastStyle *style = [TFYToastManager sharedStyle];
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, style.activitySize.width, style.activitySize.height)];
    activityView.center = [self tfy_centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = style.backgroundColor;
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = style.cornerRadius;
    
    if (style.displayShadow) {
        activityView.layer.shadowColor = style.shadowColor.CGColor;
        activityView.layer.shadowOpacity = style.shadowOpacity;
        activityView.layer.shadowRadius = style.shadowRadius;
        activityView.layer.shadowOffset = style.shadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate the activity view with self
    objc_setAssociatedObject (self, &TFYToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)tfy_hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &TFYToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[TFYToastManager sharedStyle] fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &TFYToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark - Helpers

- (CGPoint)tfy_centerPointForPosition:(id)point withToast:(UIView *)toast {
    TFYToastStyle *style = [TFYToastManager sharedStyle];
    
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }
    
    CGFloat topPadding = style.verticalPadding + safeInsets.top;
    CGFloat bottomPadding = style.verticalPadding + safeInsets.bottom;
    
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:TFYToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, (toast.frame.size.height / 2.0) + topPadding);
        } else if([point caseInsensitiveCompare:TFYToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width / 2.0, (self.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding);
}

@end

@implementation TFYToastStyle

#pragma mark - Constructors

- (instancetype)initWithDefaultStyle {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.titleColor = [UIColor whiteColor];
        self.messageColor = [UIColor whiteColor];
        self.maxWidthPercentage = 0.8;
        self.maxHeightPercentage = 0.8;
        self.horizontalPadding = 10.0;
        self.verticalPadding = 10.0;
        self.cornerRadius = 10.0;
        self.titleFont = [UIFont boldSystemFontOfSize:16.0];
        self.messageFont = [UIFont systemFontOfSize:16.0];
        self.titleAlignment = NSTextAlignmentLeft;
        self.messageAlignment = NSTextAlignmentLeft;
        self.titleNumberOfLines = 0;
        self.messageNumberOfLines = 0;
        self.displayShadow = NO;
        self.shadowOpacity = 0.8;
        self.shadowRadius = 6.0;
        self.shadowOffset = CGSizeMake(4.0, 4.0);
        self.imageSize = CGSizeMake(80.0, 80.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
        self.fadeDuration = 0.2;
    }
    return self;
}

- (void)setMaxWidthPercentage:(CGFloat)maxWidthPercentage {
    _maxWidthPercentage = MAX(MIN(maxWidthPercentage, 1.0), 0.0);
}

- (void)setMaxHeightPercentage:(CGFloat)maxHeightPercentage {
    _maxHeightPercentage = MAX(MIN(maxHeightPercentage, 1.0), 0.0);
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end

@interface TFYToastManager ()

@property (strong, nonatomic) TFYToastStyle *sharedStyle;
@property (assign, nonatomic, getter=isTapToDismissEnabled) BOOL tapToDismissEnabled;
@property (assign, nonatomic, getter=isQueueEnabled) BOOL queueEnabled;
@property (assign, nonatomic) NSTimeInterval defaultDuration;
@property (strong, nonatomic) id defaultPosition;

@end

@implementation TFYToastManager

#pragma mark - Constructors

+ (instancetype)sharedManager {
    static TFYToastManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sharedStyle = [[TFYToastStyle alloc] initWithDefaultStyle];
        self.tapToDismissEnabled = YES;
        self.queueEnabled = NO;
        self.defaultDuration = 3.0;
        self.defaultPosition = TFYToastPositionBottom;
    }
    return self;
}

#pragma mark - Singleton Methods

+ (void)setSharedStyle:(TFYToastStyle *)sharedStyle {
    [[self sharedManager] setSharedStyle:sharedStyle];
}

+ (TFYToastStyle *)sharedStyle {
    return [[self sharedManager] sharedStyle];
}

+ (void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled {
    [[self sharedManager] setTapToDismissEnabled:tapToDismissEnabled];
}

+ (BOOL)isTapToDismissEnabled {
    return [[self sharedManager] isTapToDismissEnabled];
}

+ (void)setQueueEnabled:(BOOL)queueEnabled {
    [[self sharedManager] setQueueEnabled:queueEnabled];
}

+ (BOOL)isQueueEnabled {
    return [[self sharedManager] isQueueEnabled];
}

+ (void)setDefaultDuration:(NSTimeInterval)duration {
    [[self sharedManager] setDefaultDuration:duration];
}

+ (NSTimeInterval)defaultDuration {
    return [[self sharedManager] defaultDuration];
}

+ (void)setDefaultPosition:(id)position {
    if ([position isKindOfClass:[NSString class]] || [position isKindOfClass:[NSValue class]]) {
        [[self sharedManager] setDefaultPosition:position];
    }
}

+ (id)defaultPosition {
    return [[self sharedManager] defaultPosition];
}

@end
