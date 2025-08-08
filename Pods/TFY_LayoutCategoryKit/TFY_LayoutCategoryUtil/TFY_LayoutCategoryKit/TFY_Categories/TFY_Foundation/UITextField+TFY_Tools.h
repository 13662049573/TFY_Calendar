//
//  UITextField+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

/**
 - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
     return YES;
 }

 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
     return [UITextField inputTextField:textField
          shouldChangeCharactersInRange:range
                      replacementString:string
                         blankLocations:@[@4,@9,@14,@19,@24]
                             limitCount:24];
     
 }
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (TFY_Tools)

- (void)tfy_addLeftViewBlock:(UIView * (^) (UITextField *))leftBlock mode:(UITextFieldViewMode)mode;

- (void)tfy_addRightViewBlock:(UIView * (^) (UITextField *))rightBlock mode:(UITextFieldViewMode)mode;

- (NSRange)tfy_selectedRange;

- (void)tfy_selectedText;

- (void)tfy_setSelectedRange:(NSRange)range;

/**
 textField中输入的空格格式化
 blankLocation 要加的空格的位置 比如手机号11 位 如果需要 344的显示格式 空格位置就是 @[@4,@9]
                      身份证号最大 18位 684格式 空格位置 位@[@6,@15]
                      银行卡号最大 24 空格位置 @[@4,@9,@14,@19,@24] 不同的账号显示格式可以自定义
  limitCount 限制的长度 超过此限制长度 则不能输入 如果输入的为0 则不显示输入的长度
  textField中输入的身份证号 ，手机号，银行卡号 有需要在中间加入空格的需求 此扩展就是为了解决这类问题的
 */
+ (BOOL)tfy_inputTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
     replacementString:(NSString *)string
        blankLocations:(NSArray <NSNumber *>*)blankLocation
            limitCount:(NSInteger )limitCount;

/// 中文 和 数字，英文限制
- (void)tfy_textFieldTextDidChange:(UITextField *)textField;

/**
 已输入字符串
 */
@property (nonatomic, copy) void (^tfy_editedText) (NSString *text);
/**
 需要结合delegate中的方法
 */
@property (nonatomic, assign) NSUInteger limitLength;

/**行间距 必须在文本输入之后赋值*/
@property (nonatomic , assign)CGFloat tfy_lineSpace;

/**字体间距 必须在文本输入之后赋值*/
@property (nonatomic , assign)CGFloat tfy_textSpace;

/**首行缩进 必须在文本输入之后赋值*/
@property (nonatomic , assign)CGFloat tfy_firstLineHeadIndent;

/**修改label内容距 `top` `left` `bottom` `right` 边距  只有在真机的情况下使用，*/
@property (nonatomic, assign) UIEdgeInsets tfy_contentInsets;

@end

NS_ASSUME_NONNULL_END
