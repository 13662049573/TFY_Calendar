//
//  UIButton+ButtonItem.m
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/4/7.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "UIButton+ButtonItem.h"

@implementation UIButton (ButtonItem)

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
