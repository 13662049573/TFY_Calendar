//
//  UIScrollView+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EmptyDataSetSource;
@protocol EmptyDataSetDelegate;
/**
 当视图没有内容要显示时，显示空数据集的UITableView/UICollectionView超类类别。
 它将自动工作，只要符合EmptyDataSetSource，并返回您想要显示的数据。
 */
@interface UIScrollView (TFY_Tools)

- (void)tfy_adJustedContentIOS11;
/**
 * 头部缩放视图图片
 */
@property (nonatomic, strong)UIImage *_Nonnull tfy_headerScaleImage;
/**
 * 头部缩放视图图片高度 默认200
 */
@property (nonatomic, assign)CGFloat tfy_headerScaleImageHeight;
/**
 * 生成图片
 */
- (void)tfy_screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;
/**
 * 生成图片
 */
+(UIImage *_Nonnull)tfy_screenSnapshotWithSnapshotView:(UIView *_Nonnull)snapshotView;
/**
 * 生成图片
 */
+(UIImage *_Nonnull)tfy_screenSnapshotWithSnapshotView:(UIView *_Nonnull)snapshotView snapshotSize:(CGSize)snapshotSize;

/**
 空数据集数据源。
 */
@property (nonatomic, weak) id <EmptyDataSetSource> tfy_emptyDataSetSource;
/**
 空数据集委托。
 */
@property (nonatomic, weak) id <EmptyDataSetDelegate> tfy_emptyDataSetDelegate;
/**
 如果任何空数据集是可见的，则是。
 */
@property (nonatomic, readonly, getter = tfy_isEmptyDataSetVisible) BOOL tfy_emptyDataSetVisible;

/**
 重新加载空数据集内容接收器。
 调用这个方法来强制刷新所有数据。调用-reloadData与此类似，但这只强制重新加载空数据集，而不是整个表视图或集合视图。
 */
- (void)tfy_reloadEmptyDataSet;

@end

///作为空数据集数据源的对象。数据源必须采用EmptyDataSetSource协议。数据源不被保留。所有的数据源方法都是可选的。
@protocol EmptyDataSetSource <NSObject>
@optional

/**
 向数据源请求数据集的标题。
 如果没有设置属性，数据集默认使用固定的字体样式。如果你想要不同的字体样式，返回一个带属性的字符串。
 
 返回：数据集标题的带属性字符串，结合字体、文本颜色、文本段落样式等。
 */
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;

/**
 向数据源请求数据集的描述。
 如果没有设置属性，数据集默认使用固定的字体样式。如果你想要不同的字体样式，返回一个带属性的字符串。

 一个通知数据源的scrollView子类。
 返回：一个带有属性的字符串，用于数据集描述文本，结合字体、文本颜色、文本段落样式等。
 */
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView;

/**
 向数据源请求数据集的图像。

 一个通知数据源的scrollView子类。
  返回：数据集的图像。
 */
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView;


/**
 请求数据源获取图像数据集的色调颜色。默认是零。

 一个通知数据源的scrollView子类对象。
 返回：一个颜色来着色数据集的图像。
 */
- (UIColor *)imageTintColorForEmptyDataSet:(UIScrollView *)scrollView;

/**
 向数据源请求数据集的图像动画。
 scrollView的子类对象，通知委托。
 
 返回：图像动画
 */
- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *) scrollView;

/**
 请求数据源提供用于指定按钮状态的标题。
 如果没有设置属性，数据集默认使用固定的字体样式。如果你想要不同的字体样式，返回一个带属性的字符串。

 一个通知数据源的scrollView子类对象。
 使用指定标题的状态。可能的值在UIControlState中描述。
 返回：一个带有属性的字符串，用于dataset按钮的标题，结合字体、文本颜色、文本段落样式等。
 */
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/**
 请求数据源提供用于指定按钮状态的图像。
 这个方法将覆盖buttonTitleForEmptyDataSet:forState:并且只显示图像而不显示任何文本。

 一个通知数据源的scrollView子类对象。
 使用指定标题的状态。可能的值在UIControlState中描述。
 返回：数据集按钮imageview的图像。
 */
- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/**
 请求数据源提供用于指定按钮状态的背景图像。
 此调用没有默认样式。

 一个通知数据源的scrollView子类。
 使用指定图像的状态。这些值在UIControlState中描述。
 返回：一个带有属性的字符串，用于dataset按钮的标题，结合字体、文本颜色、文本段落样式等。
 */
- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/**
 向数据源请求数据集的背景颜色。默认为透明颜色。

 一个通知数据源的scrollView子类对象。
 返回：一个应用到数据集背景视图的颜色。
 */
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView;

/**
 要求数据源显示一个自定义视图，而不是默认的视图，如标签，imageview和按钮。默认是零。
 使用此方法可以为加载反馈或为完整的自定义空数据集显示活动视图指示器。
 返回自定义视图将忽略-offsetForEmptyDataSet和-spaceHeightForEmptyDataSet配置。

 一个通知委托的scrollView子类对象。
 返回：自定义视图。
 */
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView;

/**
 请求数据源提供内容的垂直和水平对齐的偏移量。默认是CGPointZero。

 一个通知委托的scrollView子类对象。
 返回：垂直和水平对齐的偏移量。
 */
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView;

/**
 请求数据源提供元素之间的垂直空间。默认得分是11分。

 一个通知委托的scrollView子类对象。
 返回：元素之间的空格高度。
 */
- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView;

@end


/**
 作为空数据集的委托的对象。
 委托可以采用EmptyDataSetDelegate协议。委托不被保留。所有委托方法都是可选的。

 所有委托方法都是可选的。使用这个委托来接收动作回调。
 */
@protocol EmptyDataSetDelegate <NSObject>
@optional

/**
 请求委托知道显示空数据集时是否应渐隐。默认是肯定的。

 一个通知委托的scrollView子类对象。
 如果空数据集应该淡入，则返回YES。
 */
- (BOOL)emptyDataSetShouldFadeIn:(UIScrollView *)scrollView;

/**
 请求委托知道当项的数量大于0时是否仍应显示空数据集。默认是没有

 一个通知委托的scrollView子类对象。
 返回： YES如果空数据集应该被强制显示
 */
- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView;

/**
 询问委托是否应该呈现和显示空数据集。默认是肯定的。

 一个通知委托的scrollView子类对象。
 如果空数据集应该显示，则返回YES。
 */
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView;

/**
 请求委托触摸许可。默认是肯定的。

 一个通知委托的scrollView子类对象。
 返回： YES如果空数据集接收触摸手势。ES如果空数据集应该显示。
 */
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView;

/**
 请求委托获得滚动权限。默认是否定的。

 一个通知委托的scrollView子类对象。
 如果空数据集允许可滚动，则返回YES。
 */
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView;

/**
 请求委托图像视图动画权限。默认是否定的。
 确保从imageAnimationForEmptyDataSet返回一个有效的CAAnimation对象:

 一个通知委托的scrollView子类对象。
 返回： YES如果空数据集被允许动画
 */
- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView;
/**
 告诉委托空数据集视图已被选中。
 使用这个方法可以重新定义textfield或searchBar的firstresponder。

 一个通知委托的scrollView子类。
 view用户点击的视图
 */
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view;

/**
 告诉委托操作按钮被点击了。

 一个通知委托的scrollView子类。
 按钮用户点击的按钮
 */
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button;

/**
 告诉委托将出现空数据集。

 一个通知委托的scrollView子类。
 */
- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView;

/**
 告诉委托空数据集确实出现了。

 一个通知委托的scrollView子类。
 */
- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView;

/**
 告诉委托空数据集将消失。

 一个通知委托的scrollView子类。
 */
- (void)emptyDataSetWillDisappear:(UIScrollView *)scrollView;

/**
 告诉委托空数据集确实消失了。

 一个通知委托的scrollView子类。
 */
- (void)emptyDataSetDidDisappear:(UIScrollView *)scrollView;

@end


NS_ASSUME_NONNULL_END
