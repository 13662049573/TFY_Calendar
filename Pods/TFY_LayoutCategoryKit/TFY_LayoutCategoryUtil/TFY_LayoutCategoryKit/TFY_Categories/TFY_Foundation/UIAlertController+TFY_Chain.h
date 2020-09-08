//
//  UIAlertController+TFY_Chain.h
//  TFY_Category
//
//  Created by 田风有 on 2019/11/23.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

CG_INLINE UIAlertController * _Nonnull TFY_AlertControllerCreate(NSString *_Nullable title, NSString *_Nullable message, UIAlertControllerStyle style){
    return [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
}
CG_INLINE UIAlertController * _Nonnull TFY_AlertControllerAlertCreate(NSString *_Nullable title,NSString *_Nullable message){
    return [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
}
CG_INLINE UIAlertController * _Nonnull TFY_AlertControllerSheetCreate(NSString *_Nullable title, NSString *_Nullable message){
    return [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
}
typedef void (^AlertTapBlock)(NSInteger index, UIAlertAction * _Nonnull action);

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (TFY_Chain)
/*** 添加Action，并设置key值，需要在点击方法中使用*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_addAction)(NSString *title, UIAlertActionStyle style, NSInteger index);
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_addDesAction)(NSString *title, NSInteger index);
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_addCancelAction)(NSString *title, NSInteger index);
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_addDefaultAction)(NSString *title, NSInteger index);


@property (nonatomic, copy, readonly) UIAlertController * (^tfy_addTextField) (void (^ textField) (UITextField *textField));
/***在点语法中用来返回一个最近添加的UIAlertAction，用来设置样式*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_actionStyle) (void (^ actionStyle)(UIAlertAction * action));

/**action点击方法，返回的key值是上面添加的key值*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_actionTap) (AlertTapBlock tapIndex);

/**在点语法中用来返回当前的UIAlertVController，用来设置样式*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertStyle) (void (^ alert)(UIAlertController *alertVC));

/**title样式设置*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertTitleAttributeFontWithColor)(UIFont *font, UIColor *color);
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertTitleAttributeWidthDictionary)(void (^attribute)(NSMutableDictionary * attributes));

/**message样式设置*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertMessageAttributeFontWithColor)(UIFont *font, UIColor *color);
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertMessageAttributeWidthDictionary)(void (^attribute)(NSMutableDictionary * attributes));

/**title属性*/
@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertTitleMaxNum)(NSUInteger numberOfLines);

@property (nonatomic, copy, readonly) UIAlertController * (^tfy_alertTitleLineBreakMode)(NSLineBreakMode mode);
/**设置title字体颜色*/
- (void)tfy_setTitleAttributedString:(nullable NSAttributedString *)attributedString;

/**设置message字体颜色*/
- (void)tfy_setMessageAttributedString:(nullable NSAttributedString *)attributedString;

/**设置介绍字体颜色*/
- (void)tfy_setDetailAttributedString:(nullable NSAttributedString *)attributedString;

/**设置title最大行数*/
- (void)tfy_setTitleLineMaxNumber:(NSInteger)number;

/**设置title截断模式*/
- (void)tfy_setTitleLineBreakModel:(NSLineBreakMode)mode;

/**添加action*/
- (UIAlertAction *)tfy_addActionTitle:(NSString *)title style:(UIAlertActionStyle)style block:(void (^) (UIAlertAction *action))block;

@property (nonatomic, copy, readonly) UIAlertController * (^tfy_showFromViewController)(UIViewController *viewController);

@end

@interface UIAlertAction (Category)

@property (nonatomic, weak, readonly) UIAlertController * tfy_alertViewController;
/**
 设置action颜色
 */
- (void)tfy_setAlertActionTitleColor:(UIColor *)color;

/**
 设置action图片
 
 */
- (void)tfy_setAlertImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
