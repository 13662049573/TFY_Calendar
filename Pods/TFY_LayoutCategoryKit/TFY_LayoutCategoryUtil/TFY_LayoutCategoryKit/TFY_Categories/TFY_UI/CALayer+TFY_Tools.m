//
//  CALayer+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "CALayer+TFY_Tools.h"
#import "TFY_iOS13DarkMode_MonitorView.h"
#import "UIView+TFY_iOS13DarkMode_MonitorView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface CALayer (TFY_iOS13DarkModePrivate)

- (id)tfy_iOS13KVOSupperLayer;

- (void)tfy_setiOS13KVOSupperLayer:(id __nullable)object;

@end

typedef void(^tfy_iOS13DarkModeLayerKVOCallback)(CALayer *layer);

@interface TFY_iOS13DarkModeLayerKVO : NSObject

@property (nonatomic, copy) tfy_iOS13DarkModeLayerKVOCallback callback;
@property (nonatomic, weak) CALayer *layer;

@end

@implementation TFY_iOS13DarkModeLayerKVO

- (void)removeKVOSupperLayer:(CALayer *)layer
{
    self.callback = nil;
    if (self.layer && self.layer == layer) {
        [TFY_iOS13DarkModeDefine tfy_ExchangeMethodWithOriginalClass:self.class swizzledClass:CALayer.class originalSelector:@selector(tfy_iOS13DarkMode_addSublayer:) swizzledSelector:@selector(addSublayer:)];
        self.layer = nil;
    }
}

- (void)addKVOSupperLayer:(CALayer *)layer complete:(tfy_iOS13DarkModeLayerKVOCallback)complete
{
    if (self.layer != layer) {
        [self removeKVOSupperLayer:self.layer];
        self.layer = layer;
        [TFY_iOS13DarkModeDefine tfy_ExchangeMethodWithOriginalClass:layer.class swizzledClass:self.class originalSelector:@selector(addSublayer:) swizzledSelector:@selector(tfy_iOS13DarkMode_addSublayer:)];
    }
    self.callback = complete;
}

- (void)tfy_iOS13DarkMode_addSublayer:(CALayer *)layer
{
    [self tfy_iOS13DarkMode_addSublayer:layer];
    TFY_iOS13DarkModeLayerKVO *object = [layer tfy_iOS13KVOSupperLayer];
    if (object && object.layer == layer) {
        if (object.callback) {
            object.callback(layer);
        }
    }
}

@end

@implementation CALayer (TFY_Tools)

static const char * TFY_iOS13DarkMode_LayerView_Key = "TFY_iOS13DarkMode_LayerView_Key";
static const char * TFY_iOS13DarkMode_LayerKVO_Key = "TFY_iOS13DarkMode_LayerKVO_Key";

- (void(^)(UIColor *color))tfy_iOS13BorderColor {
    return ^(UIColor *color){
        UIView *view = [self tfy_iOS13DarkMode_TopLayerView];
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerBorderColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (view) {
            [self tfy_executeiOS13DarkModeLayerColor];
        } else {
            self.borderColor = color.CGColor;
        }
    };
}

- (void(^)(UIColor *color))tfy_iOS13ShadowColor {
    return ^(UIColor *color){
        UIView *view = [self tfy_iOS13DarkMode_TopLayerView];
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerShadowColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (view) {
            [self tfy_executeiOS13DarkModeLayerColor];
        } else {
            self.shadowColor = color.CGColor;
        }
    };
}

- (void(^)(UIColor *color))tfy_iOS13BackgroundColor {
    return ^(UIColor *color){
        UIView *view = [self tfy_iOS13DarkMode_TopLayerView];
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerBackgroundColor_Key, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (view) {
            [self tfy_executeiOS13DarkModeLayerColor];
        } else {
            self.backgroundColor = color.CGColor;
        }
    };
}


-(id)tfy_iOS13KVOSupperLayer {
    return objc_getAssociatedObject(self, TFY_iOS13DarkMode_LayerKVO_Key);
}

- (void)tfy_setiOS13KVOSupperLayer:(id)object {
    objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerKVO_Key, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private
- (void)tfy_executeiOS13DarkModeLayerColor {
    
    UIView *view = [self tfy_iOS13DarkMode_TopLayerView];
    
    if (!view) {
        return;
    }
    
    UIColor *borderColor = objc_getAssociatedObject(self, TFY_iOS13DarkMode_LayerBorderColor_Key);
    [self tfy_setiOS13DarkModeColor:borderColor forProperty:@"borderColor" withView:view];
    objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerBorderColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIColor *shadowColor = objc_getAssociatedObject(self, TFY_iOS13DarkMode_LayerShadowColor_Key);
    [self tfy_setiOS13DarkModeColor:shadowColor forProperty:@"shadowColor" withView:view];
    objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerShadowColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIColor *backgroundColor = objc_getAssociatedObject(self, TFY_iOS13DarkMode_LayerBackgroundColor_Key);
    [self tfy_setiOS13DarkModeColor:backgroundColor forProperty:@"backgroundColor" withView:view];
    objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerBackgroundColor_Key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)tfy_iOS13DarkMode_TopLayerView
{
    UIView *view = objc_getAssociatedObject(self, TFY_iOS13DarkMode_LayerView_Key);
    if (!view) {
        view = [self tfy_iOS13DarkMode_FindLayerView];
    }
    
    if (!view && ![self tfy_iOS13KVOSupperLayer]) {
        TFY_iOS13DarkModeLayerKVO *object = [TFY_iOS13DarkModeLayerKVO new];
        __weak typeof(self) weakSelf = self;
        __weak typeof(object) weakObject = object;
        [object addKVOSupperLayer:self complete:^(CALayer *layer) {
            if ([layer tfy_iOS13DarkMode_FindLayerView]) {
                [weakSelf tfy_executeiOS13DarkModeLayerColor];
                [weakObject removeKVOSupperLayer:weakSelf];
                [weakSelf tfy_setiOS13KVOSupperLayer:nil];
            }
        }];
        [self tfy_setiOS13KVOSupperLayer:object];
    }
    
    objc_setAssociatedObject(self, TFY_iOS13DarkMode_LayerView_Key, view, OBJC_ASSOCIATION_ASSIGN);
    return view;
}

- (UIView *)tfy_iOS13DarkMode_FindLayerView
{
    CALayer *layer = self;
    while (![layer.delegate isKindOfClass:[UIView class]]) {
        layer = layer.superlayer;
        if (!layer) {
            break;
        }
    }
    if ([layer.delegate isKindOfClass:[UIView class]]) {
        return (UIView *)layer.delegate;
    }
    return nil;
}

- (void)tfy_setiOS13DarkModeColor:(UIColor *)color forProperty:(NSString *)property withView:(UIView *)contentView {
    
    if (property.length == 0) {
        return;
    }
    
    NSString *proSetStr = [NSString stringWithFormat:@"set%@:",[property stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[property substringToIndex:1] capitalizedString]]];
    SEL proSetSel = NSSelectorFromString(proSetStr);
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(contentView) weakContentView = contentView;
    if ([self respondsToSelector:proSetSel]) {
#if __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            
            if (color) {
                [contentView.tfy_iOS13DrakMove_MonitorView tfy_setTraitCollectionChange:^(UIView * _Nonnull view) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [weakSelf performSelector:proSetSel withObject:(id)[color resolvedColorWithTraitCollection:weakContentView.traitCollection].CGColor];
#pragma clang diagnostic pop
                } forKey:property forObject:self];
            } else {
                [contentView.tfy_iOS13DrakMove_MonitorView tfy_setTraitCollectionChange:nil forKey:property forObject:self];
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:proSetSel withObject:(id)[color resolvedColorWithTraitCollection:contentView.traitCollection].CGColor];
#pragma clang diagnostic pop
        } else {
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:proSetSel withObject:(id)color.CGColor];
#pragma clang diagnostic pop
#if __IPHONE_13_0
        }
#endif
    }
}


@end
