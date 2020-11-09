//
//  TFY_iOS13DarkMode_MonitorView.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_iOS13DarkMode_MonitorView.h"

NSString *const TFY_iOS13DarkMode_MonitorView_callbackList = @"TFY_iOS13DarkMode_MonitorView_callbackList";
NSString *const TFY_iOS13DarkMode_MonitorView_callbackMap = @"TFY_iOS13DarkMode_MonitorView_callbackMap";

@interface TFY_iOS13DarkMode_MonitorView ()
@property (nonatomic, copy) NSMapTable <NSString *, id> *callObjectMap;
@end

@implementation TFY_iOS13DarkMode_MonitorView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.hidden = YES;
    _callObjectMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
#if __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            
            for (id object in self.callObjectMap) {
                NSMutableDictionary *list = [self.callObjectMap objectForKey:object];
                NSMutableArray *callbackList = [list objectForKey:TFY_iOS13DarkMode_MonitorView_callbackList];
                for (TFY_iOS13DarkMode_MonitorView_TraitCollectionCallback callback in callbackList) {
                    callback(self);
                }
            }
        }
    }
#endif
}

#pragma mark - public
- (void)tfy_setTraitCollectionChange:(TFY_iOS13DarkMode_MonitorView_TraitCollectionCallback)callback forKey:(NSString *)key forObject:(id)object
{
    NSMutableDictionary *list = [self.callObjectMap objectForKey:object];
    if (list == nil) {
        list = [NSMutableDictionary dictionary];
        [list setObject:[NSMutableDictionary dictionary] forKey:TFY_iOS13DarkMode_MonitorView_callbackMap];
        [list setObject:[NSMutableArray array] forKey:TFY_iOS13DarkMode_MonitorView_callbackList];
        [self.callObjectMap setObject:list forKey:object];
    }
    
    NSMutableDictionary *callbackMap = [list objectForKey:TFY_iOS13DarkMode_MonitorView_callbackMap];
    NSMutableArray *callbackList = [list objectForKey:TFY_iOS13DarkMode_MonitorView_callbackList];
    
    TFY_iOS13DarkMode_MonitorView_TraitCollectionCallback oldCallback = [callbackMap objectForKey:key];
    if (oldCallback) {
        [callbackList removeObject:oldCallback];
        [callbackMap removeObjectForKey:key];
        oldCallback = nil;
    }
    if (callback) {
        [callbackList addObject:callback];
        [callbackMap setObject:callback forKey:key];
    }
    
    if (callbackList.count == 0) {
        [self.callObjectMap removeObjectForKey:object];
    }
}


@end
