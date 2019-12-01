//
//  TFY_CalendarHeaderView.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_Calendar,TFY_CalendarAppearance,TFY_CalendarHeaderLayout,TFY_CalendarCollectionView;
NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarHeaderView : UIView
@property (weak, nonatomic) TFY_CalendarCollectionView *collectionView;
@property (weak, nonatomic) TFY_CalendarHeaderLayout *collectionViewLayout;
@property (weak, nonatomic) TFY_Calendar *calendar;

@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL scrollEnabled;

- (void)setScrollOffset:(CGFloat)scrollOffset;
- (void)setScrollOffset:(CGFloat)scrollOffset animated:(BOOL)animated;
- (void)reloadData;
- (void)configureAppearance;
@end

@interface TFY_CalendarHeaderCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) TFY_CalendarHeaderView *header;

@end

@interface TFY_CalendarHeaderLayout : UICollectionViewFlowLayout

@end

@interface TFY_CalendarHeaderTouchDeliver : UIView

@property (weak, nonatomic) TFY_Calendar *calendar;
@property (weak, nonatomic) TFY_CalendarHeaderView *header;

@end

NS_ASSUME_NONNULL_END
