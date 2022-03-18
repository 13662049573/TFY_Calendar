//
//  UIView+Toast.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/2/3.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString * _Nonnull TFYToastPositionTop;
extern const NSString * _Nonnull TFYToastPositionCenter;
extern const NSString * _Nonnull TFYToastPositionBottom;

@class TFYToastStyle;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Toast)
/**
 创建并显示带有消息的新吐司视图，并使用
 默认的持续时间和位置。使用共享样式进行样式化。
 message需要显示的消息
 */
- (void)tfy_makeToast:(NSString *)message;

/**
 创建并显示一个带有消息的新的toast视图。持续时间
 可以显式设置。使用共享样式进行样式化。
 
  message需要显示的消息
  duration吐司时长
 */
- (void)tfy_makeToast:(NSString *)message
         duration:(NSTimeInterval)duration;

/**
 创建并显示一个带有消息的新的toast视图。持续时间和位置
 可以显式设置。使用共享样式进行样式化。

 message需要显示的消息
 duration吐司时长
 吐司的中心点。可以是预定义的CSToastPosition之一吗
 或包装在NSValue对象中的' CGPoint '。
 */
- (void)tfy_makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position;

/**
 创建并显示一个带有消息的新的toast视图。时间、位置和
 样式可以显式设置。

 message需要显示的消息
 duration吐司时长
 吐司的中心点。可以是预定义的CSToastPosition之一吗
 或包装在NSValue对象中的' CGPoint '。
 style样式当为nil时，将使用共享样式
 */
- (void)tfy_makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            style:(TFYToastStyle *)style;

/**
 创建并显示一个带有消息、标题和图像的新的toast视图。持续时间、
 位置和样式可以显式设置。完成块执行时
 吐司视图完成。' didTap '将是' YES '如果toast视图被取消
 一个水龙头。

 message需要显示的消息
 duration吐司时长
 吐司的中心点。可以是预定义的CSToastPosition之一吗
 或包装在NSValue对象中的' CGPoint '。
 title标题
 image图像
 style样式当为nil时，将使用共享样式
 完成块，在toast视图消失后执行。
 didTap将是' YES '，如果toast视图从一个点击被取消。
 */
- (void)tfy_makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            title:(NSString *)title
            image:(NSString *)image
            style:(TFYToastStyle *)style
       completion:(void(^)(BOOL didTap))completion;

/**
 使用消息、标题和图像的任意组合创建新的toast视图。
 外观是通过样式配置的。与' makeToast: '方法不同，
 此方法不会自动显示toast视图。其中一个showToast:
 方法必须用于表示生成的视图。

 @warning如果message, title和image都是nil，这个方法将返回nil。
 message需要显示的消息
 title标题
 image图像
 style样式当为nil时，将使用共享样式
 新创建的toast视图
 */
- (UIView *)tfy_toastViewForMessage:(NSString *)message
                          title:(NSString *)title
                          image:(NSString *)image
                          style:(TFYToastStyle *)style;

/**
 隐藏主动的祝酒词。如果视图中有多个toast活动，则此方法
 隐藏最古老的祝酒词(第一个被提出的祝酒词)。

 @see ' hideAllToasts '从视图中移除所有激活的toasts。

 这个方法对活动祝酒词没有影响。使用“hideToastActivity”
 隐藏活动祝酒。
 */
- (void)tfy_hideToast;

/**
 隐藏积极的祝酒词。

 toast要解散的活动toast视图。当前显示的任何吐司
 在屏幕上被认为是活动的。

 @warning不清除当前正在队列中等待的toast视图。
 */
- (void)tfy_hideToast:(UIView *)toast;

/**
 隐藏所有活动toast视图并清除队列。
 */
- (void)tfy_hideAllToasts;

/**
 隐藏所有活动的toast视图，以及隐藏活动和清除队列的选项。

 如果' true '， toast活动也将被隐藏。默认设置是“假”。
 clearQueue如果为true，则从队列中移除所有toast视图。默认设置是“真正的”。
 */
- (void)tfy_hideAllToasts:(BOOL)includeActivity clearQueue:(BOOL)clearQueue;

/**
 从队列中删除所有toast视图。这对祝酒词的观点没有影响
 活跃。使用' hideAllToasts '隐藏活动的toasts视图并清除队列。
 */
- (void)tfy_clearToastQueue;

/**
 在指定位置创建并显示新的toast活动指示器视图。

 每个父视图只能显示一个toast活动指示器视图。后续
 对' makeToastActivity: '的调用将被忽略，直到hideToastActivity被调用。

 @warning ' makeToastActivity: '独立于showToast:方法工作。烤面包的活动
 在显示toast视图时，可以显示或取消视图。“makeToastActivity:”
 对showToast:方法的排队行为没有影响。

 吐司的中心点。可以是预定义的CSToastPosition之一吗
 或包装在NSValue对象中的' CGPoint '。
 */
- (void)tfy_makeToastActivity:(id)position;

/**
 撤销活动的toast活动指示器视图。
 */
- (void)tfy_hideToastActivity;

/**
 使用默认的持续时间和位置将任何视图显示为toast。
 toast要显示为toast的视图
 */
- (void)tfy_showToast:(UIView *)toast;

/**
 在指定的位置和持续时间将任何视图显示为toast。完成块
 在吐司视图完成时执行。' didTap '将是' YES '如果toast视图是
 从水龙头里出来。

 toast要显示为toast的视图
 duration通知持续时间
 吐司的中心点。可以是预定义的CSToastPosition之一吗
 或包装在NSValue对象中的' CGPoint '。
 完成块，在toast视图消失后执行。
 didTap将是' YES '，如果toast视图从一个点击被取消。
 */
- (void)tfy_showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position
       completion:(void(^)(BOOL didTap))completion;

@end

@interface TFYToastStyle : NSObject

/**
 背景颜色。默认是' [UIColor blackColor] '，透明度为80%。
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/**
 标题的颜色。默认是' [UIColor whiteColor] '。
 */
@property (strong, nonatomic) UIColor *titleColor;

/**
 消息的颜色。默认是' [UIColor whiteColor] '。
 */
@property (strong, nonatomic) UIColor *messageColor;

/**
 从0.0到1.0的百分比值，表示吐司的最大宽度
 视图相对于它的父视图。默认值是0.8(父视图宽度的80%)。
 */
@property (assign, nonatomic) CGFloat maxWidthPercentage;

/**
 从0.0到1.0的百分比值，表示吐司的最大高度
 视图相对于它的父视图。默认值是0.8(父视图高度的80%)。
 */
@property (assign, nonatomic) CGFloat maxHeightPercentage;

/**
 从toast视图的水平边缘到内容的间距。当一个图像
 ，这也被用作图像和文本之间的填充。
 默认是10.0。
 */
@property (assign, nonatomic) CGFloat horizontalPadding;

/**
 从吐司视图的垂直边缘到内容的间距。当一个标题
 ，它也用作标题和消息之间的填充。
 默认是10.0。
 */
@property (assign, nonatomic) CGFloat verticalPadding;

/**
 圆角半径。默认是10.0。
 */
@property (assign, nonatomic) CGFloat cornerRadius;

/**
 标题字体。默认是' [UIFont boldSystemFontOfSize:16.0] '。
 */
@property (strong, nonatomic) UIFont *titleFont;

/**
 字体的消息。默认是' [UIFont systemFontOfSize:16.0] '。
 */
@property (strong, nonatomic) UIFont *messageFont;

/**
 标题文本对齐方式。默认设置是“NSTextAlignmentLeft”。
 */
@property (assign, nonatomic) NSTextAlignment titleAlignment;

/**
 消息文本对齐。默认设置是“NSTextAlignmentLeft”。
 */
@property (assign, nonatomic) NSTextAlignment messageAlignment;

/**
 标题的最大行数。默认值是0(没有限制)。
 */
@property (assign, nonatomic) NSInteger titleNumberOfLines;

/**
 消息的最大行数。默认值是0(没有限制)。
 */
@property (assign, nonatomic) NSInteger messageNumberOfLines;

/**
 启用或禁用toast视图上的阴影。默认设置是“不”。
 */
@property (assign, nonatomic) BOOL displayShadow;

/**
 阴影颜色。默认为' [UIColor blackColor] '。
 */
@property (strong, nonatomic) UIColor *shadowColor;

/**
 从0.0到1.0的值，表示阴影的不透明度。
 默认值是0.8(80%的不透明度)。
 */
@property (assign, nonatomic) CGFloat shadowOpacity;

/**
 影子半径。默认是6.0。
 */
@property (assign, nonatomic) CGFloat shadowRadius;

/**
 影子偏移量。默认值是' CGSizeMake(4.0, 4.0) '。
 */
@property (assign, nonatomic) CGSize shadowOffset;

/**
 图像的大小。默认值是' CGSizeMake(80.0, 80.0) '。
 */
@property (assign, nonatomic) CGSize imageSize;

/**
 调用' makeToastActivity: '时toast活动视图的大小。
 默认为' CGSizeMake(100.0, 100.0) '。
 */
@property (assign, nonatomic) CGSize activitySize;

/**
 淡入/淡出动画持续时间。默认是0.2。
 */
@property (assign, nonatomic) NSTimeInterval fadeDuration;

/**
 创建' TFYToastStyle '的新实例，并设置所有默认值。
 */
- (instancetype)initWithDefaultStyle NS_DESIGNATED_INITIALIZER;

/**
 只能使用指定的初始化器来创建
 ' TFYToastStyle '的一个实例。
 */
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 `TFYToastManager '为所有toast提供通用配置选项
 通知。由单例实例支持。
 */
@interface TFYToastManager : NSObject

/**
 设置单例的共享样式。无论何时都使用共享样式
 调用' makeToast: '方法(或' toastviewformmessage:title:image:style: ')
 和nil样式。默认情况下，它被设置为' TFYToastStyle '的默认值
 风格。
 sharedStyle共享样式
 */
+ (void)setSharedStyle:(TFYToastStyle *)sharedStyle;

/**
 从单例对象获取共享样式。默认情况下，这是
 TFYToastStyle”年代默认风格。
 共享样式
 */
+ (TFYToastStyle *)sharedStyle;

/**
 启用或禁用在吐司视图上的点击以解散。默认是“是的”。
 taptodismissenabledyes或NO
 */
+ (void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled;

/**
 如果启用了“关闭”，则返回“YES”，否则返回“NO”。
 默认是“是的”。
 BOOL是或否
 */
+ (BOOL)isTapToDismissEnabled;

/**
 启用或禁用toast视图的排队行为。“是”的时候,
 Toast视图将一个接一个地出现。当回答“不”时，多吐司
 视图将同时出现(可能重叠，视情况而定)
 在他们的位置)。这对toast活动视图没有影响，
 它独立于普通toast视图进行操作。默认设置是“不”。
 queueEnabled是或否
 */
+ (void)setQueueEnabled:(BOOL)queueEnabled;

/**
 如果队列被启用，返回' YES '，否则返回' NO '。
 默认设置是“不”。
 BOOL
 */
+ (BOOL)isQueueEnabled;

/**
 设置默认的持续时间。用于makeToast:和
 不需要显式持续时间的' showToast: '方法。
 默认是3.0。
 duration吐司时长
 */
+ (void)setDefaultDuration:(NSTimeInterval)duration;

/**
 返回默认的持续时间。默认是3.0。
 duration吐司时长
*/
+ (NSTimeInterval)defaultDuration;

/**
 设置默认位置。用于makeToast:和
 不需要显式位置的' showToast: '方法。
 默认设置是“TUICSToastPositionBottom”。

 默认的中心点。可以是预定义的吗
 CSToastPosition常量或包装在NSValue对象中的' CGPoint '。
 */
+ (void)setDefaultPosition:(id)position;

/**
 返回默认的toast位置。默认设置是“TFYToastPositionBottom”。

 默认的中心点。会是预定义的吗
 CSToastPosition常量或包装在NSValue对象中的' CGPoint '。
 */
+ (id)defaultPosition;

@end


NS_ASSUME_NONNULL_END
