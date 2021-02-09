//
//  NSMutableParagraphStyle+TFY_Chain.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/11.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableParagraphStyle (TFY_Chain)
/**
 *  按钮初始化
 */
NSMutableParagraphStyle *tfy_MutableParagraphStyle(void);
/**
 *  字体的行间距
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_lineSpacing)(CGFloat lineSpacing);
/**
 *  文本首行缩进
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_firstLineHeadIndent)(CGFloat firstLineHeadIndent);
/**
 *  （两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_alignment)(NSTextAlignment alignment);
/**
 *  （结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_lineBreakMode)(NSLineBreakMode breakMode);
/**
 *  （整体缩进(首行除外)
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_headIndent)(CGFloat headIndent);
/**
 *  （距页边距到后边缘的距离；如果是负数或0，则来自其他边距
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_tailIndent)(CGFloat tailIndent);
/**
 *  （最低行高
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_minimumLineHeight)(CGFloat minimumLineHeight);
/**
 *  （最大行高
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_maximumLineHeight)(CGFloat maximumLineHeight);
/**
 *  （段与段之间的间距
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_paragraphSpacing)(CGFloat paragraphSpacing);

/**
 *  （段与段之间的间距
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_paragraphSpacingBefore)(CGFloat paragraphSpacingBefore);

/**
 *  （从左到右的书写方向
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_baseWritingDirection)(NSWritingDirection baseWritingDirection);

/**
 *  （在限制最小和最大线条高度之前，将自然线条高度乘以该因子（如果为正）。
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_lineHeightMultiple)(CGFloat lineHeightMultiple);
/**
 *  连字属性 在iOS，唯一支持的值分别为0和1
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_hyphenationFactor)(CGFloat hyphenationFactor);
/**
 *  文档范围的默认选项卡间隔
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_defaultTabInterval)(CGFloat defaultTabInterval);
/**
 *  一组NSTextTabs。 内容应按位置排序。 默认值是一个由12个左对齐制表符组成的数组，间隔为28pt
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_tabStops)(NSArray<NSTextTab *> *tabStops);
/**
 *  一组NSTextTabs。 内容应按位置排序。 默认值是一个由12个左对齐制表符组成的数组，间隔为28pt
 */
@property(nonatomic,copy,readonly)NSMutableParagraphStyle *(^tfy_allowsDefaultTighteningForTruncation)(BOOL allowsDefaultTighteningForTruncation);

@end

NS_ASSUME_NONNULL_END
