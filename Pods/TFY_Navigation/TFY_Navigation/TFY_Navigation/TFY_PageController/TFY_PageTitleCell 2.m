//
//  TFY_PageTitleCell.m
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "TFY_PageTitleCell.h"

#pragma mark 自定义cell类
@interface TFY_PageTitleLabel : UILabel

@property (nonatomic, assign) TFY_PageTextVerticalAlignment textVerticalAlignment;

@end

@implementation TFY_PageTitleLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.textVerticalAlignment) {
        case TFY_PageTextVerticalAlignmentCenter:
            textRect.origin.y = (bounds.size.height - textRect.size.height)/2.0;
            break;
        case TFY_PageTextVerticalAlignmentTop: {
            CGFloat topY = self.font.pointSize > [UIFont labelFontSize] ? 0 : 2;
            textRect.origin.y = topY;
        }
            break;
        case TFY_PageTextVerticalAlignmentBottom:
            textRect.origin.y = bounds.size.height - textRect.size.height;
            break;
        default:
            break;
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end

@implementation TFY_PageTitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textLabel = [[TFY_PageTitleLabel alloc] init];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
        self.config = [TFY_PageControllerConfig defaultConfig];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

- (void)configCellOfSelected:(BOOL)selected {
    self.textLabel.textColor = selected ? self.config.titleSelectedColor : self.config.titleNormalColor;
    self.textLabel.font = selected ? self.config.titleSelectedFont : self.config.titleNormalFont;
    TFY_PageTitleLabel *label = (TFY_PageTitleLabel *)self.textLabel;
    label.textVerticalAlignment = self.config.textVerticalAlignment;
    
    if (self.config.celltextAnimationType == TFY_PageTitleCellAnimationTypeZoom) {
        if (selected) {
            self.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }else {
            self.transform = CGAffineTransformIdentity;
        }
    }
}

- (void)showAnimationOfProgress:(CGFloat)progress type:(TFY_PageTitleCellAnimationType)type {
    if (type == TFY_PageTitleCellAnimationTypeSelected) {
        self.textLabel.textColor = [TFY_PageControllerUtil colorTransformFrom:self.config.titleSelectedColor to:self.config.titleNormalColor progress:progress];
    }else if (type == TFY_PageTitleCellAnimationTypeWillSelected){
        self.textLabel.textColor = [TFY_PageControllerUtil colorTransformFrom:self.config.titleNormalColor to:self.config.titleSelectedColor progress:progress];
    }
    
    if (self.config.celltextAnimationType == TFY_PageTitleCellAnimationTypeZoom) {
        //动画包括颜色渐变 缩放
        if (type == TFY_PageTitleCellAnimationTypeSelected) {
            CGFloat scale = (1 - progress)*(1.25 - 1);
            self.transform = CGAffineTransformMakeScale(1 + scale, 1 + scale);
        }else if (type == TFY_PageTitleCellAnimationTypeWillSelected){
            CGFloat scale = progress*(1.25 - 1);
            self.transform = CGAffineTransformMakeScale(1 + scale, 1 + scale);
        }
    }
}
@end
