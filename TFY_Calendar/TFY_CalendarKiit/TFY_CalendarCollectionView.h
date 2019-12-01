//
//  TFY_CalendarCollectionView.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_CalendarCollectionView;

@protocol TFYCa_CalendarCollectionViewInternalDelegate <UICollectionViewDelegate>
@optional
- (void)collectionViewDidFinishLayoutSubviews:(TFY_CalendarCollectionView *_Nonnull)collectionView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarCollectionView : UICollectionView

@property (weak, nonatomic) id<TFYCa_CalendarCollectionViewInternalDelegate> internalDelegate;

@end

NS_ASSUME_NONNULL_END
