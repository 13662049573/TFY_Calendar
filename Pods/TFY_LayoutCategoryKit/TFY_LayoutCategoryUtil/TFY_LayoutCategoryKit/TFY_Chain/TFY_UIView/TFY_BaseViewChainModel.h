//
//  TFY_BaseViewChainModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ChainBaseModel.h"
#import "UIView+TFY_Tools.h"

#define TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ModelType, TFY_PropertyClass) TFY_CATEGORY_CHAIN_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ModelType, TFY_PropertyClass)


#define TFY_CATEGORY_VIEW_IMPLEMENTATION(TFY_Class, modelType)\
@interface modelType(EffectiveEXT)\
@property (nonatomic, strong, readonly) NSMutableArray <TFY_Class *>* effectiveObjects;\
@end\
@implementation TFY_Class (EXT)\
- (modelType *)makeChain{\
    return [[modelType alloc] initWithTag:self.tag andView:self modelClass:[TFY_Class class]];\
}\
@end


NS_ASSUME_NONNULL_BEGIN

typedef void(^TFY_AssignViewLoad)(__kindof UIView *view);

@interface TFY_BaseViewChainModel<__covariant  ObjectType> : TFY_ChainBaseModel<ObjectType>

- (instancetype)initWithTag:(NSInteger)tag andView:(UIView *)view modelClass:(Class)modelClass;

TFY_PROPERTY_ASSIGN_READONLY NSInteger tag;

TFY_PROPERTY_STRONG_READONLY __kindof UIView *view;

TFY_PROPERTY_ASSIGN_READONLY Class viewClass;

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ bounds) (CGRect);
#pragma mark - frame -
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ frame) (CGRect);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ origin) (CGPoint);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ x) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ y) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ size) (CGSize);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ width) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ height) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ center) (CGPoint);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ centerX) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ centerY) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ top) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ left) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ bottom) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ right) (CGFloat);


TFY_PROPERTY_CHAIN_READONLY CGFloat (^ visibleAlpha) (void);

TFY_PROPERTY_CHAIN_READONLY CGRect (^ convertRectTo) (CGRect, UIView *);

TFY_PROPERTY_CHAIN_READONLY CGRect (^ convertRectFrom) (CGRect, UIView *);

TFY_PROPERTY_CHAIN_READONLY CGPoint (^ convertPointTo) (CGPoint, UIView *);

TFY_PROPERTY_CHAIN_READONLY CGPoint (^ convertPointFrom) (CGPoint, UIView *);

TFY_PROPERTY_CHAIN_READONLY UIView *(^ viewWithTag) (NSInteger);

#pragma mark - show -

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ backgroundColor) (UIColor *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ tintColor) (UIColor *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ alpha) (CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ hidden) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ clipsToBounds) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ opaque) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ userInteractionEnabled) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ multipleTouchEnabled) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ endEditing) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ contentMode) (UIViewContentMode);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ transform) (CGAffineTransform);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ autoresizingMask) (UIViewAutoresizing);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ autoresizesSubviews) (BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ makeTag) (NSInteger);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ clipRadius) (CornerClipType,CGFloat);
/**暗黑设置*/
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ ios13BackgroundColor) (UIColor *);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ ios13BorderColor) (UIColor *);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ ios13ShadowColor) (UIColor *);

#pragma mark - control -

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addToSuperView) (UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addSubView) (UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addGesture) (UIGestureRecognizer *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addGestureBlock) (void (^ gestureBlock) (id));


TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeGesture) (UIGestureRecognizer *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ addGestureWithTag) (UIGestureRecognizer *, NSString *);

TFY_PROPERTY_STRONG_READONLY UIGestureRecognizer * (^ getGestureByTag) (NSString *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeGestureByTag) (NSString *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ bringSubViewToFront) (UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ sendSubViewToBack) (UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ exchangeSubView) (UIView *, UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ exchangeSubviewWithIndex) (NSInteger, NSInteger);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ insertSubViewBelow) (UIView*, UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ insertSubViewAbove) (UIView*, UIView *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ insertSubViewIndex) (UIView*, NSInteger);


#pragma mark - layer -

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shouldRasterize)(BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ layerOpacity)(float);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ layerBackGroundColor)(UIColor *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ layerOpaque)(BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ rasterizationScale)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ masksToBounds)(BOOL);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ cornerRadius)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ border)(CGFloat, UIColor *);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ borderWidth)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ borderColor)(CGColorRef);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ zPosition)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ anchorPoint)(CGPoint);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shadow)(CGSize, CGFloat, UIColor *, CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shadowColor)(CGColorRef);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shadowOpacity)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shadowOffset)(CGSize);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shadowRadius)(CGFloat);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ layerTransform)(CATransform3D);

TFY_PROPERTY_CHAIN_READONLY ObjectType (^ shadowPath) (CGPathRef);

#pragma mark - method -



TFY_PROPERTY_CHAIN_READONLY ObjectType (^ assignTo)(TFY_AssignViewLoad);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ sizeToFit) (void);
TFY_PROPERTY_CHAIN_READONLY CGSize (^ sizeToFitSize) (CGSize);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ removeFormSuperView) (void);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ layoutIfNeeded) (void);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ setNeedsLayout) (void);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ setNeedsDisplay) (void);
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ setNeedsDisplayRect) (CGRect);
@end

NS_ASSUME_NONNULL_END
