//
//  TFY_ProgressHUD.h
//  TFY_AutoLayoutModelTools
//
//  Created by 田风有 on 2019/5/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProgressHUDDelegate;

typedef NS_ENUM(NSInteger, ProgressHUDMode) {
    /**使用UIActivityIndicatorView显示进度。这是默认值。*/
    ProgressHUDModeIndeterminate,
    /** 进度使用圆形的、类似饼状图的进度视图来显示。 */
    ProgressHUDModeDeterminate,
    /** 使用水平进度条显示进度*/
    ProgressHUDModeDeterminateHorizontalBar,
    /** 使用环形进度视图显示进度。 */
    ProgressHUDModeAnnularDeterminate,
    /** 显示自定义视图 */
    ProgressHUDModeCustomView,
    /** 只显示标签 */
    ProgressHUDModeText
};

typedef NS_ENUM(NSInteger, ProgressHUDAnimation) {
    ProgressHUDAnimationFade,
    ProgressHUDAnimationZoom,
    ProgressHUDAnimationZoomOut = ProgressHUDAnimationZoom,
    ProgressHUDAnimationZoomIn
};

#ifndef TFY_INSTANCETYPE
#if __has_feature(objc_instancetype)
    #define TFY_INSTANCETYPE instancetype
#else
    #define TFY_INSTANCETYPE id
#endif
#endif

#ifndef TFY_ProgressSTRONG
#if __has_feature(objc_arc)
    #define TFY_ProgressSTRONG strong
#else
    #define TFY_ProgressSTRONG retain
#endif
#endif

#ifndef TFY_ProgressWEAK
#if __has_feature(objc_arc_weak)
    #define TFY_ProgressWEAK weak
#elif __has_feature(objc_arc)
    #define TFY_ProgressWEAK unsafe_unretained
#else
    #define TFY_ProgressWEAK assign
#endif
#endif

#if NS_BLOCKS_AVAILABLE
typedef void (^ProgressHUDCompletionBlock)(void);
#endif

@interface TFY_ProgressHUD : UIView

+ (TFY_INSTANCETYPE)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;

+ (NSUInteger)hideAllHUDsForView:(UIView *)view animated:(BOOL)animated;

+ (TFY_INSTANCETYPE)HUDForView:(UIView *)view;

+ (NSArray *)allHUDsForView:(UIView *)view;

- (id)initWithWindow:(UIWindow *)window;

- (id)initWithView:(UIView *)view;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

#if NS_BLOCKS_AVAILABLE

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(nullable dispatch_block_t)block;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(nullable dispatch_block_t)block completionBlock:(nullable ProgressHUDCompletionBlock)completion;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(nullable dispatch_block_t)block onQueue:(nullable dispatch_queue_t)queue;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(nullable dispatch_block_t)block onQueue:(nullable dispatch_queue_t)queue
          completionBlock:(ProgressHUDCompletionBlock)completion;

@property (copy,nullable) ProgressHUDCompletionBlock completionBlock;

#endif

@property (assign) ProgressHUDMode mode;

@property (assign) ProgressHUDAnimation animationType;

@property (TFY_ProgressSTRONG) UIView *customView;

@property (TFY_ProgressWEAK) id<ProgressHUDDelegate> delegate;

@property (copy,nullable) NSString *labelText;

@property (copy,nullable) NSString *detailsLabelText;

@property (assign) float opacity;

@property (TFY_ProgressSTRONG,nullable) UIColor *color;

@property (assign) float xOffset;

@property (assign) float yOffset;

@property (assign) float margin;

@property (assign) float cornerRadius;

@property (assign) BOOL dimBackground;

@property (assign) float graceTime;

@property (assign) float minShowTime;

@property (assign) BOOL taskInProgress;

@property (assign) BOOL removeFromSuperViewOnHide;

@property (TFY_ProgressSTRONG) UIFont* labelFont;

@property (TFY_ProgressSTRONG) UIColor* labelColor;

@property (TFY_ProgressSTRONG) UIFont* detailsLabelFont;

@property (TFY_ProgressSTRONG) UIColor* detailsLabelColor;

@property (TFY_ProgressSTRONG) UIColor *activityIndicatorColor;

@property (assign) float progress;

@property (assign) CGSize minSize;

@property (atomic, assign, readonly) CGSize size;

@property (assign, getter = isSquare) BOOL square;

@end

@protocol ProgressHUDDelegate <NSObject>

@optional

- (void)hudWasHidden:(TFY_ProgressHUD *)hud;

@end

@interface TFY_RoundProgressView : UIView

@property (nonatomic, assign) float progress;

@property (nonatomic, TFY_ProgressSTRONG) UIColor *progressTintColor;

@property (nonatomic, TFY_ProgressSTRONG) UIColor *backgroundTintColor;

@property (nonatomic, assign, getter = isAnnular) BOOL annular;

@end

@interface TFY_BarProgressView : UIView

@property (nonatomic, assign) float progress;

@property (nonatomic, TFY_ProgressSTRONG) UIColor *lineColor;

@property (nonatomic, TFY_ProgressSTRONG) UIColor *progressRemainingColor;

@property (nonatomic, TFY_ProgressSTRONG) UIColor *progressColor;

@end

NS_ASSUME_NONNULL_END
