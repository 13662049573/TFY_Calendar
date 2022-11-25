//
//  CalendarTagView.m
//  TFY_Calendar
//
//  Created by 田风有 on 2022/11/22.
//  Copyright © 2022 田风有. All rights reserved.
//  default_1

#import "CalendarTagView.h"

@implementation CalendarTagView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
    
        self.openImageView1.makeChain
            .addToSuperView(self);
        
        self.openImageView2.makeChain
            .addToSuperView(self);

        self.openImageView3.makeChain
            .addToSuperView(self);

        self.openImageView4.makeChain
            .addToSuperView(self);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width_w = CGRectGetWidth(self.bounds)-1;
    CGFloat height_h = CGRectGetHeight(self.bounds)-1;
    
    self.openImageView1.frame = CGRectMake(0, 0, width_w/2, height_h/2);
    
    self.openImageView2.frame = CGRectMake(CGRectGetMaxX(self.openImageView1.frame)+1, 0, CGRectGetWidth(self.openImageView1.frame), CGRectGetHeight(self.openImageView1.frame));
    
    self.openImageView3.frame = CGRectMake(0, CGRectGetMaxY(self.openImageView2.frame)+1, CGRectGetWidth(self.openImageView2.frame), CGRectGetHeight(self.openImageView2.frame));
    
    self.openImageView4.frame = CGRectMake(CGRectGetMaxX(self.openImageView3.frame)+1, CGRectGetMaxY(self.openImageView2.frame)+1, CGRectGetWidth(self.openImageView3.frame), CGRectGetHeight(self.openImageView3.frame));
}

- (UIImageView *)openImageView1 {
    if (!_openImageView1) {
        _openImageView1 = UIImageViewSet();
        _openImageView1.makeChain
            .image([UIImage imageNamed:@"open_selected_1"]);
    }
    return _openImageView1;
}

- (UIImageView *)openImageView2 {
    if (!_openImageView2) {
        _openImageView2 = UIImageViewSet();
        _openImageView2.makeChain
            .image([UIImage imageNamed:@"open_selected_2"]);
    }
    return _openImageView2;
}

- (UIImageView *)openImageView3 {
    if (!_openImageView3) {
        _openImageView3 = UIImageViewSet();
        _openImageView3.makeChain
            .image([UIImage imageNamed:@"open_selected_3"]);
    }
    return _openImageView3;
}

- (UIImageView *)openImageView4 {
    if (!_openImageView4) {
        _openImageView4 = UIImageViewSet();
        _openImageView4.makeChain
            .image([UIImage imageNamed:@"open_selected_4"]);
    }
    return _openImageView4;
}

@end
