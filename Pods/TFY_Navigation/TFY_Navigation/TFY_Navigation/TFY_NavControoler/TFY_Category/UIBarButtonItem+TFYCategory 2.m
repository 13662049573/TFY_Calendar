//
//  UIBarButtonItem+TFYCategory.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "UIBarButtonItem+TFYCategory.h"

static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    str = [[str stringByTrimmingCharactersInSet:set] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    NSUInteger length = [str length];
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}


@implementation UIBarButtonItem (TFYCategory)

/**
 *  按钮初始化
 */
UIBarButtonItem *tfy_barbtnItem(void){
    return [UIBarButtonItem new];
}

/**
 *  添加图片和点击事件
 */
-(UIBarButtonItem * _Nonnull (^)(id _Nonnull, id _Nonnull, SEL _Nonnull))tfy_imageItem {
    return ^(id image_str,id object, SEL action){
        if ([image_str isKindOfClass:NSString.class]) {
            image_str = [UIImage imageNamed:image_str];
        }
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[image_str imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:object action:action];
        return item;
    };
}

/**
 *  添加 title_str 字体文本  fontOfSize字体大小  color 字体颜色
 */
-(UIBarButtonItem * _Nonnull (^)(NSString * _Nonnull, CGFloat, UIColor * _Nonnull, id _Nonnull, SEL _Nonnull))tfy_titleItem {
    return ^(NSString *title_str,CGFloat fontOfSize,UIColor *color,id object, SEL action){
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title_str style:UIBarButtonItemStylePlain target:object action:action];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontOfSize],NSFontAttributeName, color,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        return item;
    };
}

// 文字--文字状态-文字颜色-文字大小  图片--图片UIImage--图片状态   点击方法
- (UIBarButtonItem * _Nonnull (^)(CGSize, NSString * _Nonnull, id _Nonnull, UIFont * _Nonnull, id, NAV_ButtonImageDirection, CGFloat, id _Nonnull, SEL _Nonnull, UIControlEvents))tfy_titleItembtn {
    return ^(CGSize size,NSString *title_str,id color,UIFont *font,id image,NAV_ButtonImageDirection direction,CGFloat space,id object, SEL action,UIControlEvents evrnts){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (size.width>65 && size.height>44) {
            btn.frame = CGRectMake(0, 0, size.width, size.height);
        }
        btn.frame = CGRectMake(0, 0, 65, 44);
        
        [btn setTitle:title_str forState:UIControlStateNormal];
    
        if ([color isKindOfClass:[NSString class]]) {
            color = [self colorWithHexString:color];
        }
        [btn setTitleColor:color forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        
        btn.titleLabel.font = font;
        
        if ([image isKindOfClass:NSString.class]) {
            image = [UIImage imageNamed:image];
        }
        [btn setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        
        [btn imageDirection:direction space:space];
        
        [btn addTarget:object action:action forControlEvents:evrnts];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        return item;
    };
}

- (UIColor *)colorWithHexString:(NSString *)hexStr{
    return [self colorWithHexString:hexStr alpha:-1];
}

- (UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha{
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        if (@available(iOS 10.0, *)) {
            return [UIColor colorWithDisplayP3Red:r green:g blue:b alpha:alpha < 0?a : alpha];
        }else{
            return [UIColor colorWithRed:r green:g blue:b alpha:alpha < 0?a : alpha];
        }
    }
    return [UIColor whiteColor];
}

@end

@implementation UIButton (TFYCategory)

- (void)imageDirection:(NAV_ButtonImageDirection)direction space:(CGFloat)space {
    CGFloat imageWidth, imageHeight, textWidth, textHeight, x, y;
    imageWidth = self.currentImage.size.width;
    imageHeight = self.currentImage.size.height;
    [self.titleLabel sizeToFit];
    textWidth = self.titleLabel.frame.size.width;
    textHeight = self.titleLabel.frame.size.height;
    space = space / 2;
    switch (direction) {
        case NAV_ButtonImageDirectionTop:{
            x = textHeight / 2 + space;
            y = textWidth / 2;
            self.imageEdgeInsets = UIEdgeInsetsMake(-x, y, x, - y);
            x = imageHeight / 2 + space;
            y = imageWidth / 2;
            self.titleEdgeInsets = UIEdgeInsetsMake(x, - y, - x, y);
        }
            break;
        case NAV_ButtonImageDirectionBottom:{
            x = textHeight / 2 + space;
            y = textWidth / 2;
            self.imageEdgeInsets = UIEdgeInsetsMake(x, y, -x, - y);
            x = imageHeight / 2 + space;
            y = imageWidth / 2;
            self.titleEdgeInsets = UIEdgeInsetsMake(-x, - y, x, y);
        }
            break;
        case NAV_ButtonImageDirectionLeft:{
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -space,0, space);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, space , 0, - space);
        }
            break;
        case NAV_ButtonImageDirectionRight:{
            self.imageEdgeInsets = UIEdgeInsetsMake(0, space + textWidth, 0, - (space + textWidth));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(space + imageWidth), 0, (space + imageWidth));
        }
            break;
        default:
            break;
    }
}

@end
