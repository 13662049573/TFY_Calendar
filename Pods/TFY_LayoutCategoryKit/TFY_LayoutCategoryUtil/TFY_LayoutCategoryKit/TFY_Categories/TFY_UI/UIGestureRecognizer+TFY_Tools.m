//
//  UIGestureRecognizer+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIGestureRecognizer+TFY_Tools.h"
#import <objc/runtime.h>
static const int block_key;

@interface TFY_GetureTarget : NSObject
@property (nonatomic, copy) GestureTargetAction action;
@end

@implementation TFY_GetureTarget

- (instancetype)initWithBlock:(GestureTargetAction)action{
    if (self = [super init]) {
        _action = action;
    }
    return self;
}

- (void)sendGesture:(UIGestureRecognizer *)ges{
    if (_action) {
        _action(ges);
    }
}

@end

@implementation UIGestureRecognizer (TFY_Tools)

- (instancetype)initWithActionBlock:(void (^)(id sender))block {
    self = [self init];
    [self tfy_addTargetBlock:block];
    return self;
}

- (void)tfy_addTargetBlock:(GestureTargetAction)block{
    TFY_GetureTarget *target = [[TFY_GetureTarget alloc]initWithBlock:block];
    [self addTarget:target action:@selector(sendGesture:)];
    [[self TFY_getstureTagetsArr] addObject:target];
}

- (void)tfy_addTargetBlock:(GestureTargetAction)block tag:(NSString *)tag{
    if (!block) return;
    if (!tag) {
        [self tfy_addTargetBlock:block];
    }else{
      [self tfy_removeTargetBlockByTag:tag];
      TFY_GetureTarget *target = [[TFY_GetureTarget alloc]initWithBlock:block];
      [self addTarget:target action:@selector(sendGesture:)];
      [[self TFY_getstureTagetsDic] setObject:target forKey:tag];
    }
}

- (void)tfy_removeTargetBlockByTag:(NSString *)tag{
    if (!tag) return;
    NSMutableDictionary *targets = [self TFY_getstureTagetsDic];
    TFY_GetureTarget *target = [targets objectForKey:tag];
    if (!target) return;
    [self removeTarget:target action:@selector(sendGesture:)];
    [targets removeObjectForKey:tag];
}

- (void)tfy_removeAllTargetBlock{
    [[self TFY_getstureTagetsDic] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:@selector(sendGesture:)];
    }];
    [[self TFY_getstureTagetsArr] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:@selector(sendGesture:)];
    }];
}

- (NSMutableArray *)TFY_getstureTagetsArr{
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

- (NSMutableDictionary *)TFY_getstureTagetsDic{
    NSMutableDictionary *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}
@end
