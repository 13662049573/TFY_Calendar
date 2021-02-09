//
//  NSMutableParagraphStyle+TFY_Chain.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/11.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSMutableParagraphStyle+TFY_Chain.h"
#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation NSMutableParagraphStyle (TFY_Chain)

/**
 *  按钮初始化
 */
NSMutableParagraphStyle *tfy_MutableParagraphStyle(void){
    return [NSMutableParagraphStyle new];
}

/**
 *  字体的行间距
 */
-(NSMutableParagraphStyle *(^)(CGFloat lineSpacing))tfy_lineSpacing{
    WSelf(myself);
    return ^(CGFloat lineSpacing){
        myself.lineSpacing = lineSpacing;
        return myself;
    };
}
/**
 *  文本首行缩进
 */
-(NSMutableParagraphStyle *(^)(CGFloat firstLineHeadIndent))tfy_firstLineHeadIndent{
    WSelf(myself);
    return ^(CGFloat firstLineHeadIndent){
        myself.firstLineHeadIndent = firstLineHeadIndent;
        return myself;
    };
}
/**
 *  （两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
 */
-(NSMutableParagraphStyle *(^)(NSTextAlignment alignment))tfy_alignment{
    WSelf(myself);
    return ^(NSTextAlignment alignment){
        myself.alignment = alignment;
        return myself;
    };
}
/**
 *  结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
 */
-(NSMutableParagraphStyle *(^)(NSLineBreakMode breakMode))tfy_lineBreakMode{
    WSelf(myself);
    return ^(NSLineBreakMode breakMode){
        myself.lineBreakMode = breakMode;
        return myself;
    };
}
/**
 *  整体缩进(首行除外)
 */
-(NSMutableParagraphStyle *(^)(CGFloat headIndent))tfy_headIndent{
    WSelf(myself);
    return ^(CGFloat headIndent){
        myself.headIndent = headIndent;
        return myself;
    };
}
/**
 *  距页边距到后边缘的距离；如果是负数或0，则来自其他边距
 */
-(NSMutableParagraphStyle *(^)(CGFloat tailIndent))tfy_tailIndent{
    WSelf(myself);
    return ^(CGFloat tailIndent){
        myself.tailIndent = tailIndent;
        return myself;
    };
}
/**
 *  最低行高
 */
-(NSMutableParagraphStyle *(^)(CGFloat minimumLineHeight))tfy_minimumLineHeight{
    WSelf(myself);
    return ^(CGFloat minimumLineHeight){
        myself.minimumLineHeight = minimumLineHeight;
        return myself;
    };
}

/**
 *  最低行高
 */
-(NSMutableParagraphStyle *(^)(CGFloat maximumLineHeight))tfy_maximumLineHeight{
    WSelf(myself);
    return ^(CGFloat maximumLineHeight){
        myself.maximumLineHeight = maximumLineHeight;
        return myself;
    };
}
/**
 *  段与段之间的间距
 */
-(NSMutableParagraphStyle *(^)(CGFloat paragraphSpacing))tfy_paragraphSpacing{
    WSelf(myself);
    return ^(CGFloat paragraphSpacing){
        myself.paragraphSpacing = paragraphSpacing;
        return myself;
    };
}

/**
 *  段首行空白空间
 */
-(NSMutableParagraphStyle *(^)(CGFloat paragraphSpacingBefore))tfy_paragraphSpacingBefore{
    WSelf(myself);
    return ^(CGFloat paragraphSpacingBefore){
        myself.paragraphSpacingBefore = paragraphSpacingBefore;
        return myself;
    };
}
/**
 *  段首行空白空间
 */
-(NSMutableParagraphStyle *(^)(NSWritingDirection baseWritingDirection))tfy_baseWritingDirection{
    WSelf(myself);
    return ^(NSWritingDirection baseWritingDirection){
        myself.baseWritingDirection = baseWritingDirection;
        return myself;
    };
}
/**
 *  在限制最小和最大线条高度之前，将自然线条高度乘以该因子（如果为正）。
 */
-(NSMutableParagraphStyle *(^)(CGFloat lineHeightMultiple))tfy_lineHeightMultiple{
    WSelf(myself);
    return ^(CGFloat lineHeightMultiple){
        myself.lineHeightMultiple = lineHeightMultiple;
        return myself;
    };
}

/**
 *  在限制最小和最大线条高度之前，将自然线条高度乘以该因子（如果为正）。
 */
-(NSMutableParagraphStyle *(^)(CGFloat hyphenationFactor))tfy_hyphenationFactor{
    WSelf(myself);
    return ^(CGFloat hyphenationFactor){
        myself.hyphenationFactor = hyphenationFactor;
        return myself;
    };
}
/**
 *  文档范围的默认选项卡间隔
 */
-(NSMutableParagraphStyle *(^)(CGFloat defaultTabInterval))tfy_defaultTabInterval{
    WSelf(myself);
    return ^(CGFloat defaultTabInterval){
        myself.defaultTabInterval = defaultTabInterval;
        return myself;
    };
}
/**
 *  一组NSTextTabs。 内容应按位置排序。 默认值是一个由12个左对齐制表符组成的数组，间隔为28pt
 */
-(NSMutableParagraphStyle *(^)(NSArray<NSTextTab *> *tabStops))tfy_tabStops{
    WSelf(myself);
    return ^(NSArray<NSTextTab *> *tabStops){
        myself.tabStops = tabStops;
        return myself;
    };
}
/**
 *  一个布尔值，指示系统在截断文本之前是否可以收紧字符间间距
 */
-(NSMutableParagraphStyle *(^)(BOOL allowsDefaultTighteningForTruncation))tfy_allowsDefaultTighteningForTruncation{
    WSelf(myself);
    return ^(BOOL allowsDefaultTighteningForTruncation){
        myself.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation;
        return myself;
    };
}

@end
