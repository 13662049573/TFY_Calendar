//
//  TFY_TextTagStyle.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_TextTagStyle.h"

@implementation TFY_TextTagStyle

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor lightGrayColor];
        _textAlignment = NSTextAlignmentCenter;
        _enableGradientBackground = NO;
        _cornerRadius = 4;
        _borderColor = [UIColor whiteColor];
        _borderWidth = 1;
        _shadowColor = [UIColor blackColor];
        _shadowOffset = CGSizeMake(2, 2);
        _shadowRadius = 2;
        _shadowOpacity = 0.3;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TFY_TextTagStyle *copy = (TFY_TextTagStyle *)[[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.backgroundColor = self.backgroundColor;
        copy.textAlignment = self.textAlignment;
        copy.enableGradientBackground = self.enableGradientBackground;
        copy.gradientBackgroundStartColor = self.gradientBackgroundStartColor;
        copy.gradientBackgroundEndColor = self.gradientBackgroundEndColor;
        copy.gradientBackgroundStartPoint = self.gradientBackgroundStartPoint;
        copy.gradientBackgroundEndPoint = self.gradientBackgroundEndPoint;
        copy.cornerRadius = self.cornerRadius;
        copy.cornerTopRight = self.cornerTopRight;
        copy.cornerTopLeft = self.cornerTopLeft;
        copy.cornerBottomRight = self.cornerBottomRight;
        copy.cornerBottomLeft = self.cornerBottomLeft;
        copy.borderWidth = self.borderWidth;
        copy.borderColor = self.borderColor;
        copy.shadowColor = self.shadowColor;
        copy.shadowOffset = self.shadowOffset;
        copy.shadowRadius = self.shadowRadius;
        copy.shadowOpacity = self.shadowOpacity;
        copy.extraSpace = self.extraSpace;
        copy.maxWidth = self.maxWidth;
        copy.minWidth = self.minWidth;
        copy.maxHeight = self.maxHeight;
        copy.minHeight = self.minHeight;
        copy.exactWidth = self.exactWidth;
        copy.exactHeight = self.exactHeight;
    }

    return copy;
}

- (UIColor *)backgroundColor {
    return _backgroundColor ?: [UIColor clearColor];
}

- (UIColor *)gradientBackgroundStartColor {
    return _gradientBackgroundStartColor ?: [UIColor clearColor];
}

- (UIColor *)gradientBackgroundEndColor {
    return _gradientBackgroundEndColor ?: [UIColor clearColor];
}

- (UIColor *)borderColor {
    return _borderColor ?: [UIColor clearColor];
}

- (UIColor *)shadowColor {
    return _shadowColor ?: [UIColor clearColor];
}


@end
