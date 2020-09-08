//
//  UILabel+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RichTextDelegate <NSObject>
@optional
/**RichTextDelegate  string  点击的字符串  range   点击的字符串range  index   点击的字符在数组中的index*/
- (void)tfy_tapAttributeInLabel:(UILabel *_Nonnull)label string:(NSString *_Nonnull)string range:(NSRange)range index:(NSInteger)index;;
@end

@interface NSAttributedString (Chain)
/**lable点击颜色设置*/
+(NSAttributedString *_Nonnull)tfy_getAttributeId:(id _Nonnull )sender string:(NSString *_Nonnull)string orginFont:(CGFloat)orginFont orginColor:(UIColor *_Nonnull)orginColor attributeFont:(CGFloat)attributeFont attributeColor:(UIColor *_Nonnull)attributeColor;

@end

@interface UILabel (TFY_Tools)
/**获取lable 高宽*/
- (CGSize)tfy_sizeWithLimitSize:(CGSize)size;

/**获取lable大小*/
- (CGSize)tfy_sizeWithoutLimitSize;

/**行间距 必须在文本输入之后赋值*/
@property (nonatomic , assign)CGFloat tfy_lineSpace;

/**字体间距 必须在文本输入之后赋值*/
@property (nonatomic , assign)CGFloat tfy_textSpace;

/**首行缩进 必须在文本输入之后赋值*/
@property (nonatomic , assign)CGFloat tfy_firstLineHeadIndent;

/**修改label内容距 `top` `left` `bottom` `right` 边距*/
@property (nonatomic, assign) UIEdgeInsets tfy_contentInsets;

/**是否打开点击效果，默认是打开*/
@property (nonatomic, assign) BOOL tfy_enabledTapEffect;

/**点击高亮色 默认是[UIColor lightGrayColor] 需打开enabledTapEffect才有效*/
@property (nonatomic, strong) UIColor * _Nonnull tfy_tapHighlightedColor;

/**是否扩大点击范围，默认是打开*/
@property (nonatomic, assign) BOOL tfy_enlargeTapArea;

/**给文本添加点击事件Block回调  strings  需要添加的字符串数组  tapClick 点击事件回调*/
- (void)tfy_addAttributeTapActionWithStrings:(NSArray <NSString *> *_Nonnull)strings tapClicked:(void (^_Nonnull) (UILabel * _Nonnull label, NSString * _Nonnull string, NSRange range, NSInteger index))tapClick;

/**给文本添加点击事件delegate回调  strings  需要添加的字符串数组  delegate delegate*/
- (void)tfy_addAttributeTapActionWithStrings:(NSArray <NSString *> *_Nonnull)strings delegate:(id <RichTextDelegate> _Nonnull )delegate;

/**根据range给文本添加点击事件Block回调 ranges 需要添加的Range字符串数组  tapClick 点击事件回调*/
- (void)tfy_addAttributeTapActionWithRanges:(NSArray <NSString *> *_Nonnull)ranges tapClicked:(void (^_Nonnull) (UILabel * _Nonnull label, NSString * _Nonnull string, NSRange range, NSInteger index))tapClick;

/**根据range给文本添加点击事件delegate回调 ranges  需要添加的Range字符串数组 delegate delegate*/
- (void)tfy_addAttributeTapActionWithRanges:(NSArray <NSString *> *_Nonnull)ranges delegate:(id <RichTextDelegate> _Nonnull )delegate;

/**删除label上的点击事件*/
- (void)tfy_removeAttributeTapActions;

@end

NS_ASSUME_NONNULL_END
