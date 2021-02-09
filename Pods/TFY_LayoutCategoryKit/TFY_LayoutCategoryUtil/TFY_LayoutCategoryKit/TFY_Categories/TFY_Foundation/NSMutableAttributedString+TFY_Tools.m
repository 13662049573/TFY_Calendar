//
//  NSMutableAttributedString+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/11.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSMutableAttributedString+TFY_Tools.h"
#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation NSMutableAttributedString (TFY_Tools)

/**
 *  初始化
 */
NSMutableAttributedString *tfy_MutableString(NSString *string){
    return [[NSMutableAttributedString alloc] initWithString:string];
}
/**
 *  副本初始化
 */
NSMutableAttributedString *tfy_MutableAttributedString(NSAttributedString *attrStr){
    return [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
}
/**
 *  字体大小
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_FontName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSFontAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体间距
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_KernName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSKernAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ForegroundColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSForegroundColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字符连体
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_LigatureName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSLigatureAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  段落格式
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ParagraphStyleName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSParagraphStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  背景颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_BackgroundColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSBackgroundColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  删除线格式
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrikethroughStyleName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrikethroughStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  下划线
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_UnderlineStyleName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSUnderlineStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  下划线的颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_UnderlineColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSUnderlineStyleAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  描绘边颜色
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrokeColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrokeColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  描边宽度，value是NSNumber
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrokeWidthName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrokeWidthAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  阴影，value是NSShadow对象
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ShadowName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSShadowAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  文字效果，value是NSString
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_TextEffectName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSTextEffectAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  附属，value是NSTextAttachment 对象
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_AttachmentName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSAttachmentAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  链接，value是NSURL or NSString
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_LinkName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSLinkAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  链接，value是NSURL or NSString
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_BaselineOffsetName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSBaselineOffsetAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  删除线颜色，value是UIColor
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_StrikethroughColorName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSStrikethroughColorAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体倾斜
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ObliquenessName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSObliquenessAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  字体扁平化
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_ExpansionName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSExpansionAttributeName value:value range:range];
        return myself;
    };
}

/**
 *  垂直或者水平，value是 NSNumber，0表示水平，1垂直
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_VerticalGlyphFormName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSVerticalGlyphFormAttributeName value:value range:range];
        return myself;
    };
}
/**
 *  文字的书写方向
 */
-(NSMutableAttributedString *(^)(id value,NSRange range))tfy_WritingDirectionName{
    WSelf(myself);
    return ^(id value,NSRange range){
        [myself addAttribute:NSWritingDirectionAttributeName value:value range:range];
        return myself;
    };
}

/**
 * 删除不需要的约束
 */
-(NSMutableAttributedString *(^)(NSAttributedStringKey name,NSRange range))tfy_removeAttributeStringKey{
    WSelf(myself);
    return ^(NSAttributedStringKey name,NSRange range){
        [myself removeAttribute:name range:range];
        return myself;
    };
}

/**
 *  替换属性字符串中某个位置,某个长度的字符串;
 */
-(NSMutableAttributedString *(^)(NSRange range,NSString *String))tfy_replacewithString{
    WSelf(myself);
    return ^(NSRange range,NSString *String){
        [myself replaceCharactersInRange:range withString:String];
        return myself;
    };
}
/**
 *  替换属性<NSAttributedString>中某个位置,某个长度的字符串;或者从某个属性字符串某个位置插入.
 */
-(NSMutableAttributedString *(^)(NSRange range,NSAttributedString *attrString))tfy_replaceAttributedString{
    WSelf(myself);
    return ^(NSRange range,NSAttributedString *attrString){
        [myself replaceCharactersInRange:range withAttributedString:attrString];
        return myself;
    };
}
/**
 *  或者从某个属性字符串某个位置插入.
 */
-(NSMutableAttributedString *(^)(NSAttributedString *attrString,NSUInteger atIndex))tfy_insertString{
    WSelf(myself);
    return ^(NSAttributedString *attrString,NSUInteger atIndex){
        [myself insertAttributedString:attrString atIndex:atIndex];
        return myself;
    };
}
/**
*   添加新的参数
*/
-(NSMutableAttributedString *(^)(NSAttributedString *attrString))tfy_appendString{
    WSelf(myself);
    return ^(NSAttributedString *attrString){
        [myself appendAttributedString:attrString];
        return myself;
    };
}
/**
* 删除对应的长度
*/
-(NSMutableAttributedString *(^)(NSRange range))tfy_deleteInRange{
    WSelf(myself);
    return ^(NSRange range){
        [myself deleteCharactersInRange:range];
        return myself;
    };
}

@end
