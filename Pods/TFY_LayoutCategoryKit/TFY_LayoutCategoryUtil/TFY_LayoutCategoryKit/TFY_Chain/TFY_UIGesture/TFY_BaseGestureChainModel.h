//
//  TFY_BaseGestureChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ChainBaseModel.h"

#define TFY_CATEGORY_CHAIN_GESTURECLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ModelType, TFY_PropertyClass) TFY_CATEGORY_CHAIN_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ModelType, TFY_PropertyClass)

#define TFY_CATEGORY_GESTURE_IMPLEMENTATION(TFY_Class, modelType)\
@implementation TFY_Class (EXT)\
- (modelType *)makeChain{\
    return [[modelType alloc] initWithGesture:self modelClass:[TFY_Class class]];\
}\
@end
NS_ASSUME_NONNULL_BEGIN

@interface TFY_BaseGestureChainModel<__covariant  ObjectType> : TFY_ChainBaseModel<ObjectType>

- (instancetype)initWithGesture:(UIGestureRecognizer *)gesture modelClass:(Class)modelClass;

TFY_PROPERTY_STRONG_READONLY __kindof UIGestureRecognizer * gesture;

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ delegate) (id<UIGestureRecognizerDelegate> delegate);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ enabled) (BOOL enabled);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ cancelsTouchesInView) (BOOL cancelsTouchesInView);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ delaysTouchesBegan) (BOOL delaysTouchesBegan);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ delaysTouchesEnded) (BOOL delaysTouchesEnded);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ allowedTouchTypes) (NSArray<NSNumber *> *allowedTouchTypes) API_AVAILABLE(ios(9));

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ allowedPressTypes) (NSArray<NSNumber *> *allowedPressTypes) API_AVAILABLE(ios(9));

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ requiresExclusiveTouchType) (BOOL requiresExclusiveTouchType)API_AVAILABLE(ios(9.2));

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ name) (NSString * name) API_AVAILABLE(ios(11));

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ requireGestureRecognizerToFail) (UIGestureRecognizer * requireGestureRecognizerToFail);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addTarget) (id target, SEL action);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeTarget) (id target, SEL action);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addTargetBlock) (void (^) (id gesture));

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addTargetBlockWithTag) (void (^) (id gesture), NSString *tag);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeTargetBlockWithTag) (NSString *tag);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeAllTargetBlock)(void);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addToSuperView) (UIView *view);
@end

NS_ASSUME_NONNULL_END
