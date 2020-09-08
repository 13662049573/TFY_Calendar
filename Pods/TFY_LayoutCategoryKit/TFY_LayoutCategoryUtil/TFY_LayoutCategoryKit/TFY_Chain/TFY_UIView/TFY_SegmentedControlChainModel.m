//
//  TFY_SegmentedControlChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_SegmentedControlChainModel.h"
#define TFY_CATEGORY_CHAIN_SEGMENT_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_SegmentedControlChainModel *,UISegmentedControl)
TFY_CATEGORY_VIEW_IMPLEMENTATION(UISegmentedControl, TFY_SegmentedControlChainModel)

#define TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION(TFY_TYPE,METHOD)\
- (TFY_SegmentedControlChainModel * _Nonnull (^)(TFY_TYPE, NSUInteger))METHOD{\
    return ^ (TFY_TYPE t, NSUInteger i){\
        [(UISegmentedControl *)self.view METHOD:t forSegmentAtIndex:i];\
        return self;\
    };\
}\

@implementation TFY_SegmentedControlChainModel

TFY_CATEGORY_CHAIN_SEGMENT_IMPLEMENTATION(momentary, BOOL)
TFY_CATEGORY_CHAIN_SEGMENT_IMPLEMENTATION(apportionsSegmentWidthsByContent, BOOL)

- (TFY_SegmentedControlChainModel * _Nonnull (^)(void))removeAllSegments{
    return ^ (){
        [self enumerateObjectsUsingBlock:^(UISegmentedControl * _Nonnull obj) {
           [obj removeAllSegments];
        }];
        return self;
    };
}
TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION(NSString * , setTitle)
TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION(UIImage * , setImage)
TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION(CGFloat , setWidth)
TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION(CGSize, setContentOffset)
TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION(BOOL , setEnabled)
TFY_CATEGORY_CHAIN_SEGMENT_IMPLEMENTATION(selectedSegmentIndex, NSInteger)

- (TFY_SegmentedControlChainModel * _Nonnull (^)(UIImage * _Nonnull, UIControlState, UIBarMetrics))setBackgroundImage{
    return ^ (UIImage * _Nonnull a , UIControlState b, UIBarMetrics c){
        [self enumerateObjectsUsingBlock:^(UISegmentedControl * _Nonnull obj) {
            [obj setBackgroundImage:a forState:b barMetrics:c];
        }];
        return self;
    };
}

- (TFY_SegmentedControlChainModel * _Nonnull (^)(UIImage * _Nonnull, UIControlState, UIControlState, UIBarMetrics))setDividerImage{
    return ^ (UIImage * _Nonnull a , UIControlState b, UIControlState b1, UIBarMetrics c){
        [self enumerateObjectsUsingBlock:^(UISegmentedControl * _Nonnull obj) {
            [obj setDividerImage:a forLeftSegmentState:b rightSegmentState:b1 barMetrics:c];
        }];
        return self;
    };
}

- (TFY_SegmentedControlChainModel * _Nonnull (^)(NSDictionary<NSAttributedStringKey,id> * _Nonnull, UIControlState))setTitleTextAttributes{
    return ^ (NSDictionary<NSAttributedStringKey,id> * _Nonnull a, UIControlState b){
        [self enumerateObjectsUsingBlock:^(UISegmentedControl * _Nonnull obj) {
            [obj setTitleTextAttributes:a forState:b];
        }];
        return self;
    };
}


- (TFY_SegmentedControlChainModel * _Nonnull (^)(UIOffset, UISegmentedControlSegment, UIBarMetrics))setContentPositionAdjustment{
    return ^ (UIOffset a, UISegmentedControlSegment b, UIBarMetrics c){
        [self enumerateObjectsUsingBlock:^(UISegmentedControl * _Nonnull obj) {
            [obj setContentPositionAdjustment:a forSegmentType:b barMetrics:c];
        }];
        return self;
    };
}

@end
#undef TFY_CATEGORY_CHAIN_SEGMENT_IMPLEMENTATION
#undef TFY_CATEGORY_CHAIN_SEGMENT_METHOD_IMPLEMENTATION

