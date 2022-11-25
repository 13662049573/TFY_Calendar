//
//  CalendarTagCollectionCell.m
//  TFY_Calendar
//
//  Created by 田风有 on 2022/11/22.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "CalendarTagCollectionCell.h"
#import "CalendarTagView.h"

@interface CalendarTagCollectionCell ()
@property(nonatomic , strong)CalendarTagView *tagView;
@end

@implementation CalendarTagCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.tagView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height_h = CGRectGetHeight(self.contentView.bounds);
    CGFloat width_w = CGRectGetWidth(self.contentView.bounds);
    
    self.titleLabel.frame = CGRectMake(5, 0, width_w-10, 20);
    self.shapeLayer.frame = self.titleLabel.frame;
    
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:self.shapeLayer.bounds
                                                cornerRadius:4].CGPath;
    
    self.shapeLayer.path = path;
    
    self.tagView.frame = CGRectMake(5, CGRectGetMaxY(self.titleLabel.frame)+5, CGRectGetWidth(self.titleLabel.frame), height_h-30);
}

- (CalendarTagView *)tagView {
    if (!_tagView) {
        _tagView = [[CalendarTagView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.titleLabel.frame)+5, CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(self.titleLabel.frame)-5)];
    }
    return _tagView;
}

@end
