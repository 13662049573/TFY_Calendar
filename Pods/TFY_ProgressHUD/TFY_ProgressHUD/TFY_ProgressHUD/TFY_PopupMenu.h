//
//  TFY_PopupMenu.h
//  TFY_ProgressHUD
//
//  Created by 田风有 on 2019/11/3.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_STATIC_INLINE CGFloat TFY_RectWidth(CGRect rect){
    return rect.size.width;
}


UIKIT_STATIC_INLINE CGFloat TFY_RectHeight(CGRect rect)
{
    return rect.size.height;
}

UIKIT_STATIC_INLINE CGFloat TFY_RectX(CGRect rect)
{
    return rect.origin.x;
}

UIKIT_STATIC_INLINE CGFloat TFY_RectY(CGRect rect)
{
    return rect.origin.y;
}

UIKIT_STATIC_INLINE CGFloat TFY_RectTop(CGRect rect)
{
    return rect.origin.y;
}

UIKIT_STATIC_INLINE CGFloat TFY_RectBottom(CGRect rect)
{
    return rect.origin.y + rect.size.height;
}

UIKIT_STATIC_INLINE CGFloat TFY_RectLeft(CGRect rect)
{
    return rect.origin.x;
}

UIKIT_STATIC_INLINE CGFloat TFY_RectRight(CGRect rect)
{
    return rect.origin.x + rect.size.width;
}

typedef NS_ENUM(NSInteger, PopupMenuArrowDirection) {
    PopupMenuArrowDirectionTop = 0,  //箭头朝上
    PopupMenuArrowDirectionBottom,   //箭头朝下
    PopupMenuArrowDirectionLeft,     //箭头朝左
    PopupMenuArrowDirectionRight,    //箭头朝右
    PopupMenuArrowDirectionNone      //没有箭头
};

typedef NS_ENUM(NSInteger , PopupMenuType) {
    PopupMenuTypeDefault = 0,
    PopupMenuTypeDark
};

/**
 箭头方向优先级

 当控件超出屏幕时会自动调整成反方向
 */
typedef NS_ENUM(NSInteger , PopupMenuPriorityDirection) {
    PopupMenuPriorityDirectionTop = 0,  //Default
    PopupMenuPriorityDirectionBottom,
    PopupMenuPriorityDirectionLeft,
    PopupMenuPriorityDirectionRight,
    PopupMenuPriorityDirectionNone      //不自动调整
};


@interface PopupMenuPath : NSObject

+ (CAShapeLayer *)tfy_maskLayerWithRect:(CGRect)rect
                            rectCorner:(UIRectCorner)rectCorner
                          cornerRadius:(CGFloat)cornerRadius
                            arrowWidth:(CGFloat)arrowWidth
                           arrowHeight:(CGFloat)arrowHeight
                         arrowPosition:(CGFloat)arrowPosition
                        arrowDirection:(PopupMenuArrowDirection)arrowDirection;

+ (UIBezierPath *)tfy_bezierPathWithRect:(CGRect)rect
                             rectCorner:(UIRectCorner)rectCorner
                           cornerRadius:(CGFloat)cornerRadius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor
                        backgroundColor:(UIColor *)backgroundColor
                             arrowWidth:(CGFloat)arrowWidth
                            arrowHeight:(CGFloat)arrowHeight
                          arrowPosition:(CGFloat)arrowPosition
                         arrowDirection:(PopupMenuArrowDirection)arrowDirection;

@end

@class TFY_PopupMenu;
@protocol PopupMenuDelegate <NSObject>

@optional
/**
 点击事件回调
 */
- (void)tfy_PopupMenuBeganDismiss;
- (void)tfy_PopupMenuDidDismiss;
- (void)tfy_PopupMenuBeganShow;
- (void)tfy_PopupMenuDidShow;
/**
 * 点击方法
 */
- (void)tfy_PopupMenu:(TFY_PopupMenu *)PopupMenu didSelectedAtIndex:(NSInteger)index;
/**
 * 自定义cell  可以自定义cell，设置后会忽略 fontSize textColor backColor type 属性 cell 的高度是根据 itemHeight 的，直接设置无效  建议cell 背景色设置为透明色，不然切的圆角显示不出来
 */
- (UITableViewCell *)tfy_PopupMenu:(TFY_PopupMenu *)PopupMenu cellForRowAtIndex:(NSInteger)index;

@end

@interface TFY_PopupMenu : UIView
/**
 * 标题数组 只读属性
 */
@property (nonatomic, strong, readonly) NSArray  * titles;

/**
 * 图片数组 只读属性
 */
@property (nonatomic, strong, readonly) NSArray  * images;

/**
 * tableView  Default separatorStyle is UITableViewCellSeparatorStyleNone
 */
@property (nonatomic, strong) UITableView * tableView;

/**
 * 圆角半径 Default is 5.0
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 * 自定义圆角 Default is UIRectCornerAllCorners
 * 当自动调整方向时corner会自动转换至镜像方向
 */
@property (nonatomic, assign) UIRectCorner rectCorner;

/**
 * 是否显示阴影 Default is YES
 */
@property (nonatomic, assign , getter=isShadowShowing) BOOL isShowShadow;
/**
 * 是否显示灰色覆盖层 Default is YES
 */
@property (nonatomic, assign) BOOL showMaskView;
/**
 * 选择菜单项后消失 Default is YES
 */
@property (nonatomic, assign) BOOL dismissOnSelected;
/**
 * 点击菜单外消失  Default is YES
 */
@property (nonatomic, assign) BOOL dismissOnTouchOutside;

/**
 * 设置字体大小 自定义cell时忽略 Default is 15
 */
@property (nonatomic, assign) CGFloat fontSize;
/**
 * 设置字体颜色 自定义cell时忽略 Default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor * textColor;
/**
 * 设置偏移距离 (>= 0) Default is 0.0
 */
@property (nonatomic, assign) CGFloat offset;

/**
 * 边框宽度 Default is 0.0  设置边框需 > 0
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 * 边框颜色 Default is LightGrayColor  borderWidth <= 0 无效
 */
@property (nonatomic, strong) UIColor * borderColor;

/**
 * 箭头宽度 Default is 15
 */
@property (nonatomic, assign) CGFloat arrowWidth;

/**
 * 箭头高度 Default is 10
 */
@property (nonatomic, assign) CGFloat arrowHeight;

/**
 * 箭头位置 Default is center
 * 只有箭头优先级是PopupMenuPriorityDirectionLeft/PopupMenuPriorityDirectionRight/PopupMenuPriorityDirectionNone时需要设置
 */
@property (nonatomic, assign) CGFloat arrowPosition;

/**
 * 箭头方向 Default is PopupMenuArrowDirectionTop
 */
@property (nonatomic, assign) PopupMenuArrowDirection arrowDirection;

/**
 * 箭头优先方向 Default is PopupMenuPriorityDirectionTop
 * 当控件超出屏幕时会自动调整箭头位置
 */
@property (nonatomic, assign) PopupMenuPriorityDirection priorityDirection;

/**
 * 可见的最大行数 Default is 5;
 */
@property (nonatomic, assign) NSInteger maxVisibleCount;

/**
 * menu背景色 自定义cell时忽略 Default is WhiteColor
 */
@property (nonatomic, strong) UIColor * backColor;

/**
 * item的高度 Default is 44;
 */
@property (nonatomic, assign) CGFloat itemHeight;

/**
 * popupMenu距离最近的Screen的距离 Default is 10
 */
@property (nonatomic, assign) CGFloat minSpace;

/**
 * 设置显示模式 自定义cell时忽略 Default is PopupMenuTypeDefault
 */
@property (nonatomic, assign) PopupMenuType type;

/**
 * 代理
 */
@property (nonatomic, weak) id <PopupMenuDelegate> delegate;

/**
 * 在指定位置弹出
 *  titles    标题数组  数组里是NSString/NSAttributedString
 *  icons     图标数组  数组里是NSString/UIImage
 *  itemWidth 菜单宽度
 *  delegate  代理
 */
+ (TFY_PopupMenu *)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<PopupMenuDelegate>)delegate;

/**
 * 在指定位置弹出(推荐方法)
 * point          弹出的位置
 * titles         标题数组  数组里是NSString/NSAttributedString
 * icons          图标数组  数组里是NSString/UIImage
 * itemWidth      菜单宽度
 * otherSetting   其他设置
 */
+ (TFY_PopupMenu *)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth otherSettings:(void (^) (TFY_PopupMenu * popupMenu))otherSetting;

/**
 * 依赖指定view弹出
 * titles    标题数组  数组里是NSString/NSAttributedString
 * icons     图标数组  数组里是NSString/UIImage
 * itemWidth 菜单宽度
 * delegate  代理
 */
+ (TFY_PopupMenu *)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<PopupMenuDelegate>)delegate;

/**
 * 依赖指定view弹出(推荐方法)
 *  titles         标题数组  数组里是NSString/NSAttributedString
 *  icons          图标数组  数组里是NSString/UIImage
 *  itemWidth      菜单宽度
 *  otherSetting   其他设置
 */
+ (TFY_PopupMenu *)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth otherSettings:(void (^) (TFY_PopupMenu * popupMenu))otherSetting;

/**
 消失
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
