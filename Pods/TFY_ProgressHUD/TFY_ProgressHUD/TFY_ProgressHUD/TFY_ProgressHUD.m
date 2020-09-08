//
//  TFY_ProgressHUD.m
//  TFY_AutoLayoutModelTools
//
//  Created by 田风有 on 2019/5/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_ProgressHUD.h"
#import <AvailabilityMacros.h>
#import <QuartzCore/QuartzCore.h>

#define NotificationCenter [NSNotificationCenter defaultCenter]
//屏幕高
#define   TFY_HUD_Height [UIScreen mainScreen].bounds.size.height
//屏幕宽
#define   TFY_HUD_Width  [UIScreen mainScreen].bounds.size.width

#define Ipad ((double)TFY_HUD_Height/(double)TFY_HUD_Width) < 1.6 ? YES : NO
/**
 * 是否是竖屏
 */
#define isPortrait      ( [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ||  [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown ) ?YES:NO

//对应屏幕比例宽
#define TFY_HUD_DEBI_width(width)    width *(isPortrait ?(375/TFY_HUD_Width):(TFY_HUD_Height/375))

#define TFY_HUD_DEBI_height(height)  height *(isPortrait ?(667/TFY_HUD_Height):(TFY_HUD_Width/667))

typedef NS_ENUM(NSUInteger, ProgressHUDType){
    ProgressHUD_ERROR = 0,  // 错误信息
    ProgressHUD_SUCCESS,    // 成功信息
    ProgressHUD_PROMPT,     // 提示信息
    ProgressHUD_LOADING,     //加载圈
    ProgressHUD_DISMISS
};

static const CGFloat kDefaultSpringDamping = 0.8;
static const CGFloat kDefaultSpringVelocity = 10.0;
static const CGFloat kDefaultAnimateDuration = 0.15;
static const NSInteger kAnimationOptionCurve = (7 << 16);
static NSString *const kParametersViewName = @"parameters.view";
static NSString *const kParametersLayoutName = @"parameters.layout";
static NSString *const kParametersCenterName = @"parameters.center-point";
static NSString *const kParametersDurationName = @"parameters.duration";

TFY_PopupLayout TFY_PopupLayoutMake(TFY_PopupHorizontalLayout horizontal, TFY_PopupVerticalLayout vertical) {
    TFY_PopupLayout layout;
    layout.horizontal = horizontal;
    layout.vertical = vertical;
    return layout;
}

const TFY_PopupLayout TFY_PopupLayout_Center = { TFY_PopupHorizontalLayout_Center, TFY_PopupVerticalLayout_Center };

@interface NSValue (TFY_PopupLayout)
+ (NSValue *)valueWithTFY_PopupLayout:(TFY_PopupLayout)layout;
- (TFY_PopupLayout)TFY_PopupLayoutValue;
@end

@interface UIView (TFY_Popup)
- (void)containsPopupBlock:(void (^)(TFY_ProgressHUD *popup))block;
- (void)dismissShowingPopup:(BOOL)animated;
@end


@interface TFY_ProgressHUD ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isBeingShown;
@property (nonatomic, assign) BOOL isBeingDismissed;
@property (nonatomic,  strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic,  strong) UIImageView *imageView;
@property (nonatomic,  strong) UIView *hudView;
@property (nonatomic,  strong) UILabel *stringLabel;

@end

@implementation TFY_ProgressHUD

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

+ (TFY_ProgressHUD*)sharedView{
    static dispatch_once_t once;
    static TFY_ProgressHUD *sharedView;
    dispatch_once(&once,^{sharedView = [[TFY_ProgressHUD alloc] init];});
    return sharedView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColor.clearColor;
        self.alpha = 0.0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        self.shouldDismissOnBackgroundTouch = YES;
        self.shouldDismissOnContentTouch = NO;
        
        self.showType = TFY_PopupShowType_BounceInFromTop;
        self.dismissType = TFY_PopupDismissType_BounceOutToBottom;
        self.maskType = TFY_PopupMaskType_Dimmed;
        self.dimmedMaskAlpha = 0.5;
        self.toastMaskAlpha = 1;
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = NO;
        self.backcolor = [UIColor colorWithWhite:0 alpha:0.8];
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.containerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusbarOrientation:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        if (_shouldDismissOnBackgroundTouch) {
            [self dismissAnimated:YES];
        }
        return _maskType == TFY_PopupMaskType_None ? nil : hitView;
    } else {
        if ([hitView isDescendantOfView:_containerView] && _shouldDismissOnContentTouch) {//subview是否是superView的子视图
            [self dismissAnimated:YES];
        }
        return hitView;
    }
}

#pragma mark - Public Class Methods
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView {
    TFY_ProgressHUD *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    return popup;
}

/***  带有加载圈的文字提示*/
+ (void)showWithStatus:(NSString*)content{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:content showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_LOADING stopTime:2];
}
/***  带有加载圈的文字提示 attributedString */
+ (void)showWithAttributedContent:(NSAttributedString *)attributedString{
    [[TFY_ProgressHUD sharedView] showToastViewWithAttributedContent:attributedString showType:TFY_PopupShowType_GrowIn dismissType:TFY_PopupDismissType_None maskType:TFY_PopupMaskType_None Status:ProgressHUD_LOADING stopTime:2];
}
/***  带有加载圈 maskType 交互枚举类型 */
+ (void)showWithStatus:(NSString*)content maskType:(TFY_PopupMaskType)maskType{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:content showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:maskType Status:ProgressHUD_LOADING stopTime:2];
}
/***  带有加载圈 maskType 交互枚举类型 */
+ (void)showWithAttributedContent:(NSAttributedString *)attributedString MaskType:(TFY_PopupMaskType)maskType{
     [[TFY_ProgressHUD sharedView] showToastViewWithAttributedContent:attributedString showType:TFY_PopupShowType_GrowIn dismissType:TFY_PopupDismissType_None maskType:maskType Status:ProgressHUD_LOADING stopTime:2];
}

/**
 *  展示成功的状态  string 传字符串
 */
+ (void)showSuccessWithStatus:(NSString*)string{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_SUCCESS stopTime:2];
}
/**
 *  展示成功的状态 string   传字符串  duration 设定显示时间
 */
+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_SUCCESS stopTime:duration];
}
/**
 *  展示失败的状态 string 字符串
 */
+ (void)showErrorWithStatus:(NSString *)string{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_ERROR stopTime:2];
}
+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_ERROR stopTime:duration];
}
/**
 *  展示提示信息  string 字符串
 */
+ (void)showPromptWithStatus:(NSString *)string{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_PROMPT stopTime:2];
}

+ (void)showPromptWithStatus:(NSString *)string duration:(NSTimeInterval)duration{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_PROMPT stopTime:duration];
}

-(void)showToastViewWithAttributedContent:(NSAttributedString *)attributedString showType:(TFY_PopupShowType)showType dismissType:(TFY_PopupDismissType)dismissType maskType:(TFY_PopupMaskType)maskType Status:(ProgressHUDType)status stopTime:(NSInteger)time {
    UIView *contentView = [self toastViewWithContentString:@"" AttributedString:attributedString Status:status];
    self.contentView = contentView;
    self.showType = showType;
    self.dismissType = dismissType;
    self.maskType = maskType;
    if (status == ProgressHUD_LOADING) {
        [self show];
    }
    else{
       [self showWithDuration:time];
    }
}

-(void)showToastVieWiththContent:(NSString *)content showType:(TFY_PopupShowType)showType dismissType:(TFY_PopupDismissType)dismissType maskType:(TFY_PopupMaskType)maskType Status:(ProgressHUDType)status stopTime:(NSInteger)time {
    UIView *contentView = [self toastViewWithContentString:content AttributedString:nil Status:status];
    self.contentView = contentView;
    self.showType = showType;
    self.dismissType = dismissType;
    self.maskType = maskType;
    if (status == ProgressHUD_LOADING) {
        [self show];
    }
    if (status == ProgressHUD_DISMISS) {
        [self dismiss];
    }
    else{
       [self showWithDuration:time];
    }
}

+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView showType:(TFY_PopupShowType)showType dismissType:(TFY_PopupDismissType)dismissType maskType:(TFY_PopupMaskType)maskType{
    TFY_ProgressHUD *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = maskType;
    return popup;
}

+ (void)dismissAllPopups {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        [window containsPopupBlock:^(TFY_ProgressHUD * _Nonnull popup) {
            [popup dismissAnimated:NO];
        }];
    }
}

+ (void)dismissStatus:(NSString *)string{
    [[TFY_ProgressHUD sharedView] showToastVieWiththContent:string showType:TFY_PopupShowType_FadeIn dismissType:TFY_PopupDismissType_ShrinkOut maskType:TFY_PopupMaskType_None Status:ProgressHUD_DISMISS stopTime:1];
}

/**
 * 关闭对应的弹出框
 */
+ (void)dismiss{
    [self dismissSuperPopupIn:[TFY_ProgressHUD sharedView].hudView animated:YES];
}

+ (void)dismissSuperPopupIn:(UIView *)view animated:(BOOL)animated {
    [view dismissShowingPopup:animated];
}

#pragma mark - Public Instance Methods
- (void)show {
    [self showWithLayout:TFY_PopupLayout_Center];
}

- (void)showWithLayout:(TFY_PopupLayout)layout {
    [self showWithLayout:layout duration:0.0];
}

- (void)showWithDuration:(NSTimeInterval)duration {
    [self showWithLayout:TFY_PopupLayout_Center duration:duration];
}

- (void)showWithLayout:(TFY_PopupLayout)layout duration:(NSTimeInterval)duration {
    NSDictionary *parameters = @{kParametersLayoutName: [NSValue valueWithTFY_PopupLayout:layout],
                                 kParametersDurationName: @(duration)};
    [self showWithParameters:parameters];
}

- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view {
    [self showAtCenterPoint:point inView:view duration:0.0];
}

- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view duration:(NSTimeInterval)duration {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSValue valueWithCGPoint:point] forKey:kParametersCenterName];
    [parameters setValue:@(duration) forKey:kParametersDurationName];
    [parameters setValue:view forKey:kParametersViewName];
    [self showWithParameters:parameters.mutableCopy];
}

- (void)dismissAnimated:(BOOL)animated {
    [self dismiss:animated];
}

//计算文字的大小
- (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize fontSize:(UIFont *)font {
    CGSize nameSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return nameSize;
}
#pragma mark - Private Methods
- (UIView *)toastViewWithContentString:(NSString *)content AttributedString:(NSAttributedString *)attributedString Status:(ProgressHUDType)status{
    self.hudView.alpha = self.toastMaskAlpha;
    [self.hudView addSubview:self.spinnerView];
    [self.hudView addSubview:self.imageView];
    [self StatusContentString:content AttributedString:attributedString Status:status];
    [self.hudView addSubview:self.stringLabel];
    return self.hudView;
}

- (void)StatusContentString:(NSString *)content AttributedString:(NSAttributedString *)attributedString Status:(ProgressHUDType)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image;
        if(status == ProgressHUD_ERROR){
            image = [self tfy_fileImage:@"my_error" fileName:nil];
        }
        if(status == ProgressHUD_SUCCESS) {
            image = [self tfy_fileImage:@"my_success" fileName:nil];
        }
        if(status == ProgressHUD_PROMPT) {
            image = [self tfy_fileImage:@"my_prompt" fileName:nil];
        }
        if (status == ProgressHUD_LOADING){
            self.imageView.hidden = YES;
            [self.spinnerView startAnimating];
        }
        if (status!=ProgressHUD_LOADING) {
            self.imageView.hidden = NO;
            [self.spinnerView stopAnimating];
            if ([image isKindOfClass:[UIImage class]]) {
                self.imageView.image = image;
            }
            else{
                self.imageView.hidden = YES;
                [self.spinnerView startAnimating];
            }
        }
       [self setStatusContentString:content AttributedString:attributedString];
    });
}

-(UIImage *)tfy_fileImage:(NSString *)fileImage fileName:(NSString *)fileName {
    return [UIImage imageWithContentsOfFile:[[[[NSBundle mainBundle] pathForResource:@"TFY_ProgressHUD" ofType:@"bundle"] stringByAppendingPathComponent:fileName] stringByAppendingPathComponent:fileImage]];
}

- (void)setStatusContentString:(NSString *)content AttributedString:(NSAttributedString *)attributedString{
    CGFloat hudWidth = TFY_HUD_DEBI_width(100);
    CGFloat hudHeight = TFY_HUD_DEBI_width(100);
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    if(content!=nil || ![content isEqualToString:@""]) {
        
        CGSize stringSize = [self sizeWithText:content maxSize:CGSizeMake(TFY_HUD_DEBI_width(200), TFY_HUD_DEBI_width(300)) fontSize:self.stringLabel.font];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        hudHeight = TFY_HUD_DEBI_width(80) + stringHeight;
        
        if (stringWidth > hudWidth)
            hudWidth = ceil(stringWidth / 2) * 2;
        
        if (hudHeight > TFY_HUD_DEBI_width(100)) {
            labelRect = CGRectMake(12, TFY_HUD_DEBI_width(66), hudWidth, stringHeight);
            hudWidth += 24;
        } else {
            hudWidth += 24;
            labelRect = CGRectMake(0, TFY_HUD_DEBI_width(66), hudWidth, stringHeight);
        }
    }
    
    self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    
    if(content!=nil || ![content isEqualToString:@""])
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, TFY_HUD_DEBI_width(36));
    else
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    
    self.stringLabel.hidden = NO;
    
    if (content.length>0) {
        self.stringLabel.text = content;
    }
    else{
        self.stringLabel.attributedText = attributedString;
    }
    
    self.stringLabel.frame = labelRect;
    
    if(content!=nil || ![content isEqualToString:@""])
        self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, TFY_HUD_DEBI_width(40.5));
    else
        self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, ceil(self.hudView.bounds.size.height/2)+0.5);
}

- (void)showWithParameters:(NSDictionary *)parameters {
    if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
        _isBeingShown = YES;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        if (self.willStartShowingBlock != nil) {
            self.willStartShowingBlock();
        }
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //准备弹出
            if (!strongSelf.superview) {
                [[self lastWindow] addSubview:self];
            }
            
            [strongSelf updateInterfaceOrientation];
            
            strongSelf.hidden = NO;
            strongSelf.alpha = 1.0;
            
            //设置背景视图
            strongSelf.backgroundView.alpha = 0.0;
            if (strongSelf.maskType == TFY_PopupMaskType_Dimmed) {
                strongSelf.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:strongSelf.dimmedMaskAlpha];
                strongSelf.shouldDismissOnBackgroundTouch = NO;
                strongSelf.shouldDismissOnContentTouch = NO;
            }
            if (strongSelf.maskType == TFY_PopupMaskType_Clear) {
                strongSelf.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
                strongSelf.shouldDismissOnBackgroundTouch = YES;
                strongSelf.shouldDismissOnContentTouch = NO;
            }
            if (strongSelf.maskType == TFY_PopupMaskType_None) {
                strongSelf.backgroundView.backgroundColor = UIColor.clearColor;
            }
            
            //判断是否需要动画
            void (^backgroundAnimationBlock)(void) = ^(void) {
                strongSelf.backgroundView.alpha = 1.0;
            };
            
            //展示动画
            if (strongSelf.showType != TFY_PopupShowType_None) {
                CGFloat showInDuration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                [UIView animateWithDuration:showInDuration
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            //设置自动消失事件
            NSNumber *durationNumber = parameters[kParametersDurationName];
            NSTimeInterval duration = durationNumber != nil ? durationNumber.doubleValue : 0.0;
            
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                strongSelf.isBeingShown = NO;
                strongSelf.isShowing = YES;
                strongSelf.isBeingDismissed = NO;
                if (strongSelf.didFinishShowingBlock) {
                    strongSelf.didFinishShowingBlock();
                }
                
                if (duration > 0.0) {
                    [strongSelf performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
                }
            };
            
            if (strongSelf.contentView.superview != strongSelf.containerView) {
                [strongSelf.containerView addSubview:strongSelf.contentView];
            }
            
            [strongSelf.contentView layoutIfNeeded];
            
            CGRect containerFrame = strongSelf.containerView.frame;
            containerFrame.size = strongSelf.contentView.frame.size;
            strongSelf.containerView.frame = containerFrame;
            
            CGRect contentFrame = strongSelf.contentView.frame;
            contentFrame.origin = CGPointZero;
            strongSelf.contentView.frame = contentFrame;
            
            UIView *contentView = strongSelf.contentView;
            NSDictionary *viewsDict = NSDictionaryOfVariableBindings(contentView);
            [strongSelf.containerView removeConstraints:strongSelf.containerView.constraints];
            [strongSelf.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:viewsDict]];
            [strongSelf.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:viewsDict]];
            
            CGRect finalContainerFrame = containerFrame;
            UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
            
            NSValue *centerValue = parameters[kParametersCenterName];
            if (centerValue) {
                CGPoint centerInView = centerValue.CGPointValue;
                CGPoint centerInSelf;
                /// 将坐标从提供的视图转换为self。
                UIView *fromView = parameters[kParametersViewName];
                centerInSelf = fromView != nil ? [self convertPoint:centerInView toView:fromView] : centerInView;
                finalContainerFrame.origin.x = centerInSelf.x - CGRectGetWidth(finalContainerFrame)*0.5;
                finalContainerFrame.origin.y = centerInSelf.y - CGRectGetHeight(finalContainerFrame)*0.5;
                containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            } else {
                
                NSValue *layoutValue = parameters[kParametersLayoutName];
                TFY_PopupLayout layout = layoutValue ? [layoutValue TFY_PopupLayoutValue] : TFY_PopupLayout_Center;
                switch (layout.horizontal) {
                    case TFY_PopupHorizontalLayout_Left:
                        finalContainerFrame.origin.x = 0.0;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case TFY_PopupHoricontalLayout_Right:
                        finalContainerFrame.origin.x = CGRectGetWidth(strongSelf.bounds) - CGRectGetWidth(containerFrame);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
                        break;
                    case TFY_PopupHorizontalLayout_LeftOfCenter:
                        finalContainerFrame.origin.x = floorf(CGRectGetWidth(strongSelf.bounds) / 3.0 - CGRectGetWidth(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case TFY_PopupHorizontalLayout_RightOfCenter:
                        finalContainerFrame.origin.x = floorf(CGRectGetWidth(strongSelf.bounds) * 2.0 / 3.0 - CGRectGetWidth(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case TFY_PopupHorizontalLayout_Center:
                        finalContainerFrame.origin.x = floorf((CGRectGetWidth(strongSelf.bounds) - CGRectGetWidth(containerFrame)) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    default:
                        break;
                }
                
                switch (layout.vertical) {
                    case TFY_PopupVerticalLayout_Top:
                        finalContainerFrame.origin.y = 0.0;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case TFY_PopupVerticalLayout_AboveCenter:
                        finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) / 3.0 - CGRectGetHeight(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case TFY_PopupVerticalLayout_Center:
                        finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame)) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case TFY_PopupVerticalLayout_BelowCenter:
                        finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) * 2.0 / 3.0 - CGRectGetHeight(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case TFY_PopupVerticalLayout_Bottom:
                        finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
                        break;
                    default:
                        break;
                }
            }
            
            strongSelf.containerView.autoresizingMask = containerAutoresizingMask;
            
            switch (strongSelf.showType) {
                case TFY_PopupShowType_FadeIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    strongSelf.containerView.frame = finalContainerFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                        strongSelf.containerView.alpha = 1.0;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_GrowIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_ShrinkIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.frame = finalContainerFrame;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_SlideInFromTop: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_SlideInFromBottom: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_SlideInFromLeft: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_SlideInFromRight: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kDefaultAnimateDuration animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_BounceIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_BounceInFromTop: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_BounceInFromBottom: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_BounceInFromLeft: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case TFY_PopupShowType_BounceInFromRight: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                default: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    completionBlock(YES);
                }   break;
            }
        });
    }
}

- (UIWindow*)lastWindow {
    NSEnumerator  *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;

        BOOL windowIsVisible = !window.hidden&& window.alpha>0;

        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);

        BOOL windowKeyWindow = window.isKeyWindow;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)dismiss:(BOOL)animated {
    if (_isShowing && !_isBeingDismissed) {
        _isShowing = NO;
        _isBeingShown = NO;
        _isBeingDismissed = YES;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
        
        if (self.willStartDismissingBlock) {
            self.willStartDismissingBlock();
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = self;
            void (^backgroundAnimationBlock)(void) = ^(void) {
                strongSelf.backgroundView.alpha = 0.0;
            };
            
            if (animated && strongSelf.showType != TFY_PopupShowType_None) {
                CGFloat duration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
                [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:backgroundAnimationBlock completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                [strongSelf.spinnerView stopAnimating];
                [strongSelf.hudView removeFromSuperview];
                strongSelf.hudView = nil;
                [strongSelf.stringLabel removeFromSuperview];
                strongSelf.stringLabel = nil;
                [strongSelf.imageView removeFromSuperview];
                strongSelf.imageView = nil;
                [strongSelf.spinnerView removeFromSuperview];
                strongSelf.spinnerView = nil;
                [strongSelf removeFromSuperview];
                strongSelf.isBeingShown = NO;
                strongSelf.isShowing = NO;
                strongSelf.isBeingDismissed = NO;
                if (strongSelf.didFinishDismissingBlock) {
                    strongSelf.didFinishDismissingBlock();
                }
            };
            
            NSTimeInterval duration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
            NSTimeInterval bounceDurationA = duration * 1.0 / 3.0;
            NSTimeInterval bounceDurationB = duration * 2.0 / 3.0;
            
            /// Animate contentView if needed.
            if (animated) {
                NSTimeInterval dismissOutDuration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
                switch (strongSelf.dismissType) {
                    case TFY_PopupDismissType_FadeOut: {
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                            strongSelf.containerView.alpha = 0.0;
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_GrowOut: {
                        [UIView animateKeyframesWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.alpha = 0.0;
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_ShrinkOut: {
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.alpha = 0.0;
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_SlideOutToTop: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.y = - CGRectGetHeight(finalFrame);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_SlideOutToBottom: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.y = CGRectGetHeight(strongSelf.bounds);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_SlideOutToLeft: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.x = - CGRectGetWidth(finalFrame);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_SlideOutToRight: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.x = CGRectGetWidth(strongSelf.bounds);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case TFY_PopupDismissType_BounceOut: {
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.alpha = 0.0;
                                strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                            } completion:completionBlock];
                        }];
                    }   break;
                    case TFY_PopupDismissType_BounceOutToTop: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.y += 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.y = - CGRectGetHeight(finalFrameB);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case TFY_PopupDismissType_BounceOutToBottom: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.y -= 20;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.y = CGRectGetHeight(self.bounds);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case TFY_PopupDismissType_BounceOutToLeft: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.x += 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.x = - CGRectGetWidth(finalFrameB);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case TFY_PopupDismissType_BounceOutToRight: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.x -= 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.x = CGRectGetWidth(strongSelf.bounds);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    default: {
                        strongSelf.containerView.alpha = 0.0;
                        completionBlock(YES);
                    }   break;
                }
            } else {
                strongSelf.containerView.alpha = 0.0;
                completionBlock(YES);
            }
        });
    }
}

- (void)didChangeStatusbarOrientation:(NSNotification *)notification {
    [self updateInterfaceOrientation];
}

- (void)updateInterfaceOrientation {
    self.frame = self.window.bounds;
}

- (void)dismiss {
    [self dismiss:YES];
}

#pragma mark - Properties
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = UIColor.clearColor;
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = UIColor.clearColor;
    }
    return _containerView;
}

- (UIActivityIndicatorView *)spinnerView {
    if (!_spinnerView) {
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinnerView.hidesWhenStopped = YES;
        _spinnerView.bounds = CGRectMake(0, 0, 37, 37);
    }
    return _spinnerView;
}
- (UIImageView *)imageView {
    if (!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    }
    return _imageView;
}

- (UIView *)hudView {
    if(!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.layer.cornerRadius = 10;
        _hudView.backgroundColor = self.backcolor;
        _hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin     | UIViewAutoresizingFlexibleRightMargin   | UIViewAutoresizingFlexibleLeftMargin);
    }
    return _hudView;
}

- (UILabel *)stringLabel {
    if (!_stringLabel) {
        _stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stringLabel.textColor = [UIColor whiteColor];
        _stringLabel.backgroundColor = [UIColor clearColor];
        _stringLabel.adjustsFontSizeToFitWidth = YES;
        _stringLabel.textAlignment = NSTextAlignmentCenter;
        _stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _stringLabel.font = [UIFont boldSystemFontOfSize:16];
        _stringLabel.shadowColor = [UIColor blackColor];
        _stringLabel.shadowOffset = CGSizeMake(0, -1);
        _stringLabel.numberOfLines = 0;
    }
    return _stringLabel;
}
@end

@implementation NSValue (TFY_PopupLayout)
+ (NSValue *)valueWithTFY_PopupLayout:(TFY_PopupLayout)layout {
    return [NSValue valueWithBytes:&layout objCType:@encode(TFY_PopupLayout)];
}

- (TFY_PopupLayout)TFY_PopupLayoutValue {
    TFY_PopupLayout layout;
    [self getValue:&layout];
    return layout;
}

@end

@implementation UIView (TFY_Popup)
- (void)containsPopupBlock:(void (^)(TFY_ProgressHUD *popup))block {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[TFY_ProgressHUD class]]) {
            block((TFY_ProgressHUD *)subview);
        } else {
            [subview containsPopupBlock:block];
        }
    }
}

- (void)dismissShowingPopup:(BOOL)animated {
    UIView *view = self;
    while (view) {
        if ([view isKindOfClass:[TFY_ProgressHUD class]]) {
            [(TFY_ProgressHUD *)view dismissAnimated:animated];
            break;
        }
        view = view.superview;
    }
}
@end
