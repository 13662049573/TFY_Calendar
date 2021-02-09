//
//  NSMutableAttributedString+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/11.
//  Copyright © 2020 田风有. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (TFY_Tools)
/**
 *  字符串初始化
 */
NSMutableAttributedString *tfy_MutableString(NSString *string);
/**
 *  副本初始化
 */
NSMutableAttributedString *tfy_MutableAttributedString(NSAttributedString *attrStr);
/**
 *  字体大小  value是UIFont对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_FontName)(id value,NSRange range);
/**
 *  字体间距  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_KernName)(id value,NSRange range);
/**
 *  字体颜色  value是UIFont对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ForegroundColorName)(id value,NSRange range);
/**
 *  字符连体  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_LigatureName)(id value,NSRange range);
/**
 *   段落格式  绘图的风格（居中，换行模式，间距等诸多风格），value是NSParagraphStyle对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ParagraphStyleName)(id value,NSRange range);
/**
 *  背景颜色  value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_BackgroundColorName)(id value,NSRange range);
/**
 *  删除线格式  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrikethroughStyleName)(id value,NSRange range);
/**
 *  下划线  value是NSNumber
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_UnderlineStyleName)(id value,NSRange range);
/**
 *  下划线的颜色
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_UnderlineColorName)(id value,NSRange range);
/**
 *  描绘边颜色  value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrokeColorName)(id value,NSRange range);
/**
 *  描边宽度 value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrokeWidthName)(id value,NSRange range);
/**
 *  阴影，value是NSShadow对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ShadowName)(id value,NSRange range);
/**
 *  文字效果，value是NSString
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_TextEffectName)(id value,NSRange range);
/**
 *  附属，value是NSTextAttachment 对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_AttachmentName)(id value,NSRange range);
/**
 *  链接，value是NSURL or NSString
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_LinkName)(id value,NSRange range);
/**
 *  基础偏移量，value是NSNumber对象
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_BaselineOffsetName)(id value,NSRange range);
/**
 *  删除线颜色，value是UIColor
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_StrikethroughColorName)(id value,NSRange range);
/**
 *  字体倾斜
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ObliquenessName)(id value,NSRange range);
/**
 *  字体扁平化
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_ExpansionName)(id value,NSRange range);
/**
 *  垂直或者水平，value是 NSNumber，0表示水平，1垂直
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_VerticalGlyphFormName)(id value,NSRange range);
/**
 *  文字的书写方向
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_WritingDirectionName)(id value,NSRange range);
/**
 * 删除不需要的约束
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_removeAttributeStringKey)(NSAttributedStringKey name,NSRange range);
/**
 *   替换属性字符串中某个位置,某个长度的字符串;或者从某个属性字符串某个位置插入.
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_replacewithString)(NSRange range,NSString *String);
/**
 *   替换属性<NSAttributedString>中某个位置,某个长度的字符串;
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_replaceAttributedString)(NSRange range,NSAttributedString *attrString);

/**
 *   或者从某个属性字符串某个位置插入.
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_insertString)(NSAttributedString *attrString,NSUInteger atIndex);
/**
 *   添加新的参数
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_appendString)(NSAttributedString *attrString);
/**
 * 删除对应的长度
 */
@property(nonatomic,copy,readonly)NSMutableAttributedString *(^tfy_deleteInRange)(NSRange range);

@end

NS_ASSUME_NONNULL_END
