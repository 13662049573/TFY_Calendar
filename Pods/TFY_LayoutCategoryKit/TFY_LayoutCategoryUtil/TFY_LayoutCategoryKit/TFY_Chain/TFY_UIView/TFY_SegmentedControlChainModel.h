//
//  TFY_SegmentedControlChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_SegmentedControlChainModel;
@interface TFY_SegmentedControlChainModel : TFY_BaseControlChainModel<TFY_SegmentedControlChainModel *>

TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ momentary) (BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ apportionsSegmentWidthsByContent) (BOOL);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ removeAllSegments) (void);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ insertSegmentWithTitle) (NSString * title, NSUInteger index, BOOL animated);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ insertSegmentWithImage) (UIImage * image, NSUInteger index, BOOL animated);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ removeSegmentAtIndex) (NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setTitle) (NSString *, NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setImage) (UIImage *, NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setWidth) (CGFloat, NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setContentOffset) (CGSize, NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setEnabled) (BOOL, NSUInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ selectedSegmentIndex) (NSInteger);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setBackgroundImage) (UIImage *, UIControlState, UIBarMetrics);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setDividerImage) (UIImage *, UIControlState, UIControlState, UIBarMetrics);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setTitleTextAttributes) (NSDictionary <NSAttributedStringKey ,id>* attributes, UIControlState);
TFY_PROPERTY_CHAIN_READONLY TFY_SegmentedControlChainModel* (^ setContentPositionAdjustment) (UIOffset, UISegmentedControlSegment, UIBarMetrics);

@end

TFY_CATEGORY_EXINTERFACE(UISegmentedControl, TFY_SegmentedControlChainModel)

NS_ASSUME_NONNULL_END
