//
//  TFY_BaseGestureChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseGestureChainModel.h"
#import "UIGestureRecognizer+TFY_Tools.h"
#import "TFY_ChainBaseModel+TFY_Tools.h"

#define TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, id, UIGestureRecognizer)


@implementation TFY_BaseGestureChainModel
- (instancetype)initWithGesture:(UIGestureRecognizer *)gesture modelClass:(nonnull Class)modelClass{
    if (self = [super initWithModelObject:gesture modelClass:modelClass]) {
        
    }
    return self;
}

TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(delegate, id<UIGestureRecognizerDelegate>)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(enabled, BOOL)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(cancelsTouchesInView, BOOL)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(delaysTouchesBegan, BOOL)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(delaysTouchesEnded, BOOL)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(requiresExclusiveTouchType, BOOL)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(allowedTouchTypes, NSArray<NSNumber *> *)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(allowedPressTypes, NSArray<NSNumber *> *)
TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION(name, NSString *)

- (id  _Nonnull (^)(UIGestureRecognizer * _Nonnull))requireGestureRecognizerToFail{
    return ^ (UIGestureRecognizer *gesture){
        if (gesture) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj) {
                [obj requireGestureRecognizerToFail:gesture];
            }];
        }
        return self;
    };
}

- (id  _Nonnull (^)(id _Nonnull, SEL _Nonnull))addTarget{
    return ^ (id target, SEL action){
        if (target && action) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj) {
                [obj addTarget:target action:action];
            }];
        }
        return self;
    };
}

- (id  _Nonnull (^)(id _Nonnull, SEL _Nonnull))removeTarget{
    return ^ (id target, SEL action){
        if (target) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj) {
                [obj removeTarget:target action:action];
            }];
        }
        return self;
    };
}

- (id  _Nonnull (^)(void (^ _Nonnull)(id _Nonnull)))addTargetBlock{
    return ^ (GestureTargetAction action){
        if (action) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj) {
                [obj tfy_addTargetBlock:action];
            }];
        }
        return self;
    };
}

- (id  _Nonnull (^)(void (^ _Nonnull)(id _Nonnull), NSString * _Nonnull))addTargetBlockWithTag{
    return ^ (GestureTargetAction action, NSString *tag){
        if (action) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj) {
                [obj tfy_addTargetBlock:action tag:tag];
            }];
        }
        return self;
    };
}

- (id  _Nonnull (^)(NSString * _Nonnull))removeTargetBlockWithTag{
    return ^ (NSString *tag){
        if (tag) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj) {
                [obj tfy_removeTargetBlockByTag:tag];
            }];
            
        }
        return self;
    };
}

- (id  _Nonnull (^)(void))removeAllTargetBlock{
    return ^(){
        [self enumerateObjectsUsingBlock:^(UIGestureRecognizer * _Nonnull obj) {
            [obj tfy_removeAllTargetBlock];
        }];
        return self;
    };
}

- (id  _Nonnull (^)(UIView * _Nonnull))addToSuperView{
    return ^ (UIView *superView){
        if (superView) {
            [self enumerateObjectsUsingBlock:^(UIGestureRecognizer * _Nonnull obj) {
                [superView addGestureRecognizer:obj];
            }];
        }
        return self;
    };
}

- (UIGestureRecognizer *)gesture{
    return self.effectiveObjects.firstObject;
}
@end

#undef TFY_CATEGORY_CHAIN_GESTURE_IMPLEMENTATION
