//
//  UIControl+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIControl+TFY_Tools.h"
#import <objc/runtime.h>
#import "NSDictionary+TFY_Tools.h"
static const int block_array_key;
static const int block_dic_key;

@interface ControlTarget : NSObject

@property (nonatomic, copy) controlTargeAction block;

@property (nonatomic, assign) UIControlEvents  events;

@end

@implementation ControlTarget

- (instancetype)initWithBlock:(controlTargeAction)block events:(UIControlEvents)events{
    if (self = [super init]) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)sendControl:(UIControl *)control{
    if (_block) {
        _block(control);
    }
}
@end

@implementation UIControl (TFY_Tools)

- (void)tfy_addEventBlock:(controlTargeAction)block forEvents:(UIControlEvents)events{
    if (!events) return;
    if (!block) return;
    ControlTarget *target = [[ControlTarget alloc] initWithBlock:block events:events];
    [self addTarget:target action:@selector(sendControl:) forControlEvents:events];
    NSMutableArray *targets = [self tfy_controlTargetsArray];
    [targets addObject:target];
}

- (void)tfy_removeAllEvents{
    [self.allTargets enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    
    [[self tfy_controlTargetsArray] removeAllObjects];
    [[self tfy_controlTargetsDic] removeAllObjects];
}

- (void)tfy_setTarget:(id)target eventAction:(SEL)action forControlEvents:(UIControlEvents)events{
    if (!target || !action || !events) return;
    NSSet *targets = [self allTargets];
    for (id nowTarget in targets) {
        NSArray *actions = [self actionsForTarget:nowTarget forControlEvent:events];
        for (NSString *nowAction in actions) {
            [self removeTarget:nowTarget action:NSSelectorFromString(nowAction) forControlEvents:events];
        }
    }
    [self addTarget:target action:action forControlEvents:events];
}

- (void)tfy_setEventBlock:(controlTargeAction)block forEvents:(UIControlEvents)events{
    [self tfy_removeAllEventBlocksForEvents:events];
    [self tfy_addEventBlock:block forEvents:events];
}

- (BOOL)tfy_containsEventBlockForKey:(NSString *)key{
    NSMutableDictionary *dic = [self tfy_controlTargetsDic];
    return [dic tfy_containsObjectForKey:key];
}

- (void)tfy_addEventBlock:(controlTargeAction)block forEvents:(UIControlEvents)events ForKey:(NSString *)key{
    if (!block || !events || !key) return;
    [self tfy_removeEventBlockForKey:key event:events];
    ControlTarget *target = [[ControlTarget alloc] initWithBlock:block events:events];
    [self addTarget:target action:@selector(sendControl:) forControlEvents:events];
    [[self tfy_controlTargetsDic] setObject:target forKey:key];
}

- (void)tfy_removeEventBlockForKey:(NSString *)key event:(UIControlEvents)events{
    NSMutableDictionary *dic = [self tfy_controlTargetsDic];
    ControlTarget *target = [dic objectForKey:key];
    if (target) {
        UIControlEvents newEVent = target.events & (~events);
        if (newEVent) {
            [self removeTarget:target action:@selector(sendControl:) forControlEvents:target.events];
            target.events = newEVent;
            [self addTarget:target action:@selector(sendControl:) forControlEvents:target.events];
        }else{
            [self removeTarget:target action:@selector(sendControl:) forControlEvents:target.events];
            [dic removeObjectForKey:key];
        }
        
    }
}


- (void)tfy_removeAllEventBlocksForEvents:(UIControlEvents)controlEvents{
    if (!controlEvents) return;
    NSMutableArray *targets = [self tfy_controlTargetsArray];
    NSMutableArray *removes = [NSMutableArray array];
    for (ControlTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEVent = target.events & (~controlEvents);
            if (newEVent) {
                [self removeTarget:target action:@selector(sendControl:) forControlEvents:target.events];
                target.events = newEVent;
                [self addTarget:target action:@selector(sendControl:) forControlEvents:target.events];
            }else{
                [self removeTarget:target action:@selector(sendControl:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
    
    NSMutableArray *removeDicKeys = [NSMutableArray array];
    NSMutableDictionary *targetsDic = [self tfy_controlTargetsDic];
    [targetsDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ControlTarget * _Nonnull target, BOOL * _Nonnull stop) {
        if (target.events & controlEvents) {
            UIControlEvents newEVent = target.events & (~controlEvents);
            if (newEVent) {
                [self removeTarget:target action:@selector(sendControl:) forControlEvents:target.events];
                target.events = newEVent;
                [self addTarget:target action:@selector(sendControl:) forControlEvents:target.events];
            }else{
                [self removeTarget:target action:@selector(sendControl:) forControlEvents:target.events];
                [removeDicKeys addObject:key];
            }
        }
    }];
    [targetsDic removeObjectsForKeys:removeDicKeys];
}


- (NSMutableArray <ControlTarget *>*)tfy_controlTargetsArray{
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_array_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_array_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

- (NSMutableDictionary <NSString * ,ControlTarget *>*)tfy_controlTargetsDic{
    NSMutableDictionary *targets = objc_getAssociatedObject(self, &block_dic_key);
    if (!targets) {
        targets = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &block_dic_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
