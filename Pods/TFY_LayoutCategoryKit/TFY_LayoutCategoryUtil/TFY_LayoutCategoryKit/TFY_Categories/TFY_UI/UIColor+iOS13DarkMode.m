//
//  UIColor+iOS13DarkMode.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIColor+iOS13DarkMode.h"
#import "TFY_iOS13DarkModeDefine.h"
#import <objc/runtime.h>

@implementation UIColor (iOS13DarkMode)

+ (UIColor *(^)(UIColor *color))tfy_iOS13LightColor
{
    return ^UIColor *(UIColor *color){
        if (!color) {
            return nil;
        }
        objc_setAssociatedObject(color, TFY_iOS13DarkMode_LightColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return [color tfy_createiOS13DarkModeColor];
    };
}

+ (UIColor *(^)(UIColor *color))tfy_iOS13DarkColor {
    return ^UIColor *(UIColor *color){
        if (!color) {
            return nil;
        }
        objc_setAssociatedObject(color, TFY_iOS13DarkMode_DarkColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return [color tfy_createiOS13DarkModeColor];
    };
}

- (UIColor *(^)(UIColor *color))tfy_iOS13LightColor {
    return ^UIColor *(UIColor *color){
        if (!color) {
            return nil;
        }
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_LightColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return [self tfy_createiOS13DarkModeColor];
    };
}

- (UIColor *(^)(UIColor *color))tfy_iOS13DarkColor {
    return ^UIColor *(UIColor *color){
        if (!color) {
            return nil;
        }
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_DarkColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return [self tfy_createiOS13DarkModeColor];
    };
}


#pragma mark - private
- (UIColor *)tfy_createiOS13DarkModeColor {
    UIColor *lightColor = objc_getAssociatedObject(self, TFY_iOS13DarkMode_LightColor_Key);
    UIColor *darkColor = objc_getAssociatedObject(self, TFY_iOS13DarkMode_DarkColor_Key);
    if (!lightColor) lightColor = darkColor;
    if (!darkColor) darkColor = lightColor;
#if __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        UIColor *dynamicColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [darkColor resolvedColorWithTraitCollection:traitCollection];
            } else {
                return [lightColor resolvedColorWithTraitCollection:traitCollection];
            }
        }];
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_LightColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_DarkColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(dynamicColor, TFY_iOS13DarkMode_LightColor_Key, lightColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(dynamicColor, TFY_iOS13DarkMode_DarkColor_Key, darkColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return dynamicColor;
    } else {
#endif
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_LightColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_DarkColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return lightColor;
#if __IPHONE_13_0
    }
#endif
}

/* Some colors that are used by system elements and applications.
 * These return named colors whose values may vary between different contexts and releases.
 * Do not make assumptions about the color spaces or actual colors used.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemRedColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemRedColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGreenColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemGreenColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemBlueColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemBlueColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemOrangeColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemOrangeColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemYellowColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemYellowColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemPinkColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemPinkColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemPurpleColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_9_0
        if (@available(iOS 9.0, *)) {
            return UIColor.systemPurpleColor;
        } else {
#endif
            return color;
#if __IPHONE_9_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemTealColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemTealColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemIndigoColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemIndigoColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* Shades of gray. systemGray is the base gray color.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGrayColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_7_0
        if (@available(iOS 7.0, *)) {
            return UIColor.systemGrayColor;
        } else {
#endif
            return color;
#if __IPHONE_7_0
        }
#endif
    };
}

/* The numbered variations, systemGray2 through systemGray6, are grays which increasingly
 * trend away from systemGray and in the direction of systemBackgroundColor.
 *
 * In UIUserInterfaceStyleLight: systemGray1 is slightly lighter than systemGray.
 *                               systemGray2 is lighter than that, and so on.
 * In UIUserInterfaceStyleDark:  systemGray1 is slightly darker than systemGray.
 *                               systemGray2 is darker than that, and so on.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray2Color
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemGray2Color;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray3Color
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemGray3Color;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray4Color
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemGray4Color;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray5Color
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemGray5Color;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGray6Color
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemGray6Color;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

#pragma mark Foreground colors

/* Foreground colors for static text and related elements.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13LabelColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.labelColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondaryLabelColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.secondaryLabelColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiaryLabelColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.tertiaryLabelColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13QuaternaryLabelColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.quaternaryLabelColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* Foreground color for standard system links.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13LinkColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.linkColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* Foreground color for placeholder text in controls or text fields or text views.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13PlaceholderTextColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.placeholderTextColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* Foreground colors for separators (thin border or divider lines).
 * `separatorColor` may be partially transparent, so it can go on top of any content.
 * `opaqueSeparatorColor` is intended to look similar, but is guaranteed to be opaque, so it will
 * completely cover anything behind it. Depending on the situation, you may need one or the other.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SeparatorColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.separatorColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13OpaqueSeparatorColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.opaqueSeparatorColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

#pragma mark Background colors

/* We provide two design systems (also known as "stacks") for structuring an iOS app's backgrounds.
 *
 * Each stack has three "levels" of background colors. The first color is intended to be the
 * main background, farthest back. Secondary and tertiary colors are layered on top
 * of the main background, when appropriate.
 *
 * Inside of a discrete piece of UI, choose a stack, then use colors from that stack.
 * We do not recommend mixing and matching background colors between stacks.
 * The foreground colors above are designed to work in both stacks.
 *
 * 1. systemBackground
 *    Use this stack for views with standard table views, and designs which have a white
 *    primary background in light mode.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemBackgroundColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemBackgroundColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondarySystemBackgroundColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.secondarySystemBackgroundColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiarySystemBackgroundColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.tertiarySystemBackgroundColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* 2. systemGroupedBackground
 *    Use this stack for views with grouped content, such as grouped tables and
 *    platter-based designs. These are like grouped table views, but you may use these
 *    colors in places where a table view wouldn't make sense.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemGroupedBackgroundColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemGroupedBackgroundColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondarySystemGroupedBackgroundColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.secondarySystemGroupedBackgroundColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiarySystemGroupedBackgroundColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.tertiarySystemGroupedBackgroundColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

#pragma mark Fill colors

/* Fill colors for UI elements.
 * These are meant to be used over the background colors, since their alpha component is less than 1.
 *
 * systemFillColor is appropriate for filling thin and small shapes.
 * Example: The track of a slider.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SystemFillColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.systemFillColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* secondarySystemFillColor is appropriate for filling medium-size shapes.
 * Example: The background of a switch.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13SecondarySystemFillColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.secondarySystemFillColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* tertiarySystemFillColor is appropriate for filling large shapes.
 * Examples: Input fields, search bars, buttons.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13TertiarySystemFillColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.tertiarySystemFillColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}

/* quaternarySystemFillColor is appropriate for filling large areas containing complex content.
 * Example: Expanded table cells.
 */
+ (UIColor *(^)(UIColor *color))tfy_iOS13QuaternarySystemFillColor
{
    return ^UIColor *(UIColor *color){
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UIColor.quaternarySystemFillColor;
        } else {
#endif
            return color;
#if __IPHONE_13_0
        }
#endif
    };
}


@end
