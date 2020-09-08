//
//  UIAlertController+TFY_Chain.m
//  TFY_Category
//
//  Created by 田风有 on 2019/11/23.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UIAlertController+TFY_Chain.h"
#import <objc/runtime.h>

static void *kActionBlock = & kActionBlock;
static void *kCategoryActionViewController = &kCategoryActionViewController;

@interface UIAlertActionWithController : NSObject
@property (nonatomic, weak) UIAlertController * alertViewController;
@end
@implementation UIAlertActionWithController
@end

@implementation UIAlertAction (Category)

- (void)setAlertViewController:(UIAlertActionWithController *)model{
    objc_setAssociatedObject(self, kCategoryActionViewController, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIAlertActionWithController *)alertViewActionWithController{
    return objc_getAssociatedObject(self, kCategoryActionViewController);
}

- (UIAlertController *)tfy_alertViewController{
    return [self alertViewActionWithController].alertViewController;
}

- (void)tfy_setAlertActionTitleColor:(UIColor *)color{
    [self setValue:color forKey:@"_titleTextColor"];
}

- (void)tfy_setAlertImage:(UIImage *)image{
    [self setValue:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
}

@end


@implementation UIAlertController (TFY_Chain)

- (UIAlertController * _Nonnull (^)(NSString * _Nonnull, UIAlertActionStyle, NSInteger))tfy_addAction{
    return ^ (NSString *title, UIAlertActionStyle style, NSInteger index){
        
        __weak typeof(self)weakSelf = self;
        [self tfy_addActionTitle:title style:style block:^(UIAlertAction * _Nonnull action) {
            if ([weakSelf tfy_actionBlock]) {
                [weakSelf tfy_actionBlock](index, action);
            }
        }];
        return self;
    };
}

- (UIAlertController * _Nonnull (^)(NSString * _Nonnull, NSInteger))tfy_addDesAction{
    return ^ (NSString *title, NSInteger index){
        return self.tfy_addAction(title, UIAlertActionStyleDestructive, index);
    };
}
- (UIAlertController * _Nonnull (^)(NSString * _Nonnull, NSInteger))tfy_addCancelAction{
    return ^ (NSString *title, NSInteger index){
        return self.tfy_addAction(title, UIAlertActionStyleCancel, index);
    };
}
- (UIAlertController * _Nonnull (^)(NSString * _Nonnull, NSInteger))tfy_addDefaultAction{
    return ^ (NSString *title, NSInteger index){
        return self.tfy_addAction(title, UIAlertActionStyleDefault, index);
    };
}

- (UIAlertController * _Nonnull (^)(void (^ _Nonnull)(UIAlertAction * _Nonnull)))tfy_actionStyle{
    return ^ (void (^style) (UIAlertAction *action)){
        if (style) {
            style([self tfy_currentAction]);
        }
        return self;
    };
}

- (UIAlertController * _Nonnull (^)(AlertTapBlock _Nonnull))tfy_actionTap{
    return ^ (AlertTapBlock block){
        [self setWtc_actionBlock:block];
        return self;
    };
}

- (UIAlertController * _Nonnull (^)(void (^ _Nonnull)(UITextField * _Nonnull)))tfy_addTextField{
    return ^ (void (^ textField)(UITextField * textField)){
        [self addTextFieldWithConfigurationHandler:textField];
        return self;
    };
}

- (UIAlertController * _Nonnull (^)(void (^ _Nonnull)(UIAlertController * _Nonnull)))tfy_alertStyle{
    return ^ (void(^ alert) (UIAlertController * alert)){
        if (alert) {
            alert(self);
        }
        return self;
    };
}

- (UIAlertAction *)tfy_currentAction{
    return [self.actions lastObject];
}

- (AlertTapBlock)tfy_actionBlock{
    return objc_getAssociatedObject(self, kActionBlock);
}


- (void)setWtc_actionBlock:(AlertTapBlock)block{
    objc_setAssociatedObject(self, kActionBlock, block,OBJC_ASSOCIATION_COPY);
}


- (UIAlertController * _Nonnull (^)(NSUInteger))tfy_alertTitleMaxNum{
    return ^ (NSUInteger number){
        [self tfy_setTitleLineMaxNumber:number];
        return self;
    };
}

- (UIAlertController * _Nonnull (^)(NSLineBreakMode))tfy_alertTitleLineBreakMode{
    return ^ (NSLineBreakMode mode){
        [self tfy_setTitleLineBreakModel:mode];
        return self;
    };
}


- (UIAlertController * _Nonnull (^)(UIFont * _Nonnull, UIColor * _Nonnull))tfy_alertTitleAttributeFontWithColor{
    return ^ (UIFont *font,UIColor *color){
        return self.tfy_alertTitleAttributeWidthDictionary(^(NSMutableDictionary * _Nonnull attributes) {
            attributes[NSFontAttributeName] = font;
            attributes[NSForegroundColorAttributeName] = color;
        });
    };
}

- (UIAlertController * _Nonnull (^)(void (^ _Nonnull)(NSMutableDictionary * _Nonnull)))tfy_alertTitleAttributeWidthDictionary{
    return ^ (void (^attribute)(NSMutableDictionary *attribute)){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (attribute) {
            attribute(dic);
        }
        if (self.message.length > 0) {
            [self tfy_setTitleAttributedString:[[NSAttributedString alloc]initWithString:self.title attributes:dic]];
        }else{
            [self tfy_setTitleAttributedString:nil];
        }
        return self;
    };
}

- (UIAlertController * _Nonnull (^)(UIFont * _Nonnull, UIColor * _Nonnull))tfy_alertMessageAttributeFontWithColor{
    return ^ (UIFont *font,UIColor *color){
        return self.tfy_alertMessageAttributeWidthDictionary(^(NSMutableDictionary * _Nonnull attributes) {
            attributes[NSFontAttributeName] = font;
            attributes[NSForegroundColorAttributeName] = color;
        });
    };
}

- (UIAlertController * _Nonnull (^)(void (^ _Nonnull)(NSMutableDictionary * _Nonnull)))tfy_alertMessageAttributeWidthDictionary{
    return ^ (void (^attribute)(NSMutableDictionary *attribute)){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (attribute) {
            attribute(dic);
        }
        if (self.message.length > 0) {
            [self tfy_setMessageAttributedString:[[NSAttributedString alloc]initWithString:self.message attributes:dic]];
        }else{
            [self tfy_setMessageAttributedString:nil];
        }
        return self;
    };
}

- (void)tfy_setTitleAttributedString:(NSAttributedString *)attributedString{
    [self setValue:attributedString forKey:@"attributedTitle"];
}

- (void)tfy_setDetailAttributedString:(NSAttributedString *)attributedString{
    [self setValue:attributedString forKey:@"_attributedDetailMessage"];
}

- (void)tfy_setMessageAttributedString:(NSAttributedString *)attributedString{
    [self setValue:attributedString forKey:@"attributedMessage"];
}

- (void)tfy_setTitleLineMaxNumber:(NSInteger)number{
    [self setValue:@(number) forKey:@"titleMaximumLineCount"];
}

- (void)tfy_setTitleLineBreakModel:(NSLineBreakMode)mode{
    [self setValue:@(mode) forKey:@"titleLineBreakMode"];
}

- (UIAlertAction *)tfy_addActionTitle:(NSString *)title style:(UIAlertActionStyle)style block:(void (^)(UIAlertAction * _Nonnull))block{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:block];
    [self addAction:action];
    UIAlertActionWithController *model = [UIAlertActionWithController new];
    model.alertViewController = self;
    [action setAlertViewController:model];
    return action;
}

- (UIAlertController * _Nonnull (^)(UIViewController * _Nonnull))tfy_showFromViewController{
    return  ^ (UIViewController *vc){
        [vc presentViewController:self animated:YES completion:nil];
        return self;
    };
}

@end
