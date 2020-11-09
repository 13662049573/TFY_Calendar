//
//  UIColor+iOS13DarkMode.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (iOS13DarkMode)

+ (UIColor *(^)(UIColor *color))tfy_iOS13LightColor;

+ (UIColor *(^)(UIColor *color))tfy_iOS13DarkColor;

- (UIColor *(^)(UIColor *color))tfy_iOS13LightColor;

- (UIColor *(^)(UIColor *color))tfy_iOS13DarkColor;


#pragma mark System colors

/* 系统元素和应用程序使用的一些颜色。
 * 这些返回命名的颜色，其值可能在不同的上下文和释放之间变化。
 * 不要对颜色空间或实际使用的颜色进行假设。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemRedColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGreenColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemBlueColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemOrangeColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemYellowColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemPinkColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemPurpleColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemTealColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemIndigoColor;

/* 都是灰色。系统灰色是基础灰色。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGrayColor;

/* 编号的变化，systemGray2到systemGray6，是灰色的，并且越来越多
 * 趋向于远离系统灰色而向系统背景色方向发展。
 *
 * 在UIUserInterfaceStyleLight: systemGray1比systemGray稍浅。
 *                               系统灰度2比这个浅，以此类推。
 * In UIUserInterfaceStyleDark:  systemGray1比systemGray稍暗。
 *                               systemGray2比这个暗，以此类推。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray2Color;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray3Color;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray4Color;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray5Color;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray6Color;

#pragma mark Foreground colors

/* 用于静态文本和相关元素的前景色。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13LabelColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondaryLabelColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiaryLabelColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13QuaternaryLabelColor;

/* 标准系统链接的前景色。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13LinkColor;

/* 控件、文本字段或文本视图中的占位符文本的前景色。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13PlaceholderTextColor;

/* 用于分隔符(细边框或分隔线)的前景色。
 * “separatorColor”可能是部分透明的，所以它可以放在任何内容的顶部。
 * “opaqueSeparatorColor”的设计意图是看起来类似，但保证是不透明的
 * 完全掩盖它背后的一切。根据具体情况，您可能需要其中一种。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SeparatorColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13OpaqueSeparatorColor;

#pragma mark Background colors

/* 我们提供了两个设计系统(也称为“堆栈”)来构造一个iOS应用程序的背景。
 *
 * 每个堆栈有三个“层次”的背景颜色。第一个颜色是
 * 主背景，最远的背面。第二色和第三色被分层在上面
 * 在适当情况下显示主要背景。
 *
 * 在一个离散的UI中，选择一个堆栈，然后使用该堆栈中的颜色。
 * 我们不建议在堆栈之间混合和匹配背景颜色。
 * 前面的颜色被设计为在两个堆栈中工作。
 *
 * 1. systemBackground
 *    使用这个堆栈的视图与标准表格视图，和设计有一个白色
 *    光模式下的主背景
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemBackgroundColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondarySystemBackgroundColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiarySystemBackgroundColor;

/* 2. systemGroupedBackground
 *    将这个堆栈用于分组内容的视图，例如分组的表和
 *    盘片的设计。它们类似于分组的表视图，但您可以使用它们
 *    在表格视图没有意义的地方使用颜色。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGroupedBackgroundColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondarySystemGroupedBackgroundColor;
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiarySystemGroupedBackgroundColor;

#pragma mark 填充颜色

/* 为UI元素填充颜色。
 * 这些用于背景色，因为它们的alpha组件小于1。
 *
 *  systemFillColor适用于填充薄和小的形状。
 * 示例:滑块的轨迹。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemFillColor;

/* 第二系统填充色适合填充中等大小的形状。
 * 例如:开关的背景。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondarySystemFillColor;

/* 第三系统填充颜色适用于填充较大的形状。
 * 例如:输入框，搜索栏，按钮。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiarySystemFillColor;

/* 四元胺系统填充色适用于填充含有复杂内容的大面积区域。
 * 示例:展开的表格单元格。
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13QuaternarySystemFillColor;



@end

NS_ASSUME_NONNULL_END
