//
//  TFY_BaseControlChainModel.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BaseControlChainModel.h"
#import "UIControl+TFY_Tools.h"
#define TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION(TFY_Method,TFY_ParaType) TFY_CATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(TFY_Method,TFY_ParaType, id ,UIControl)
@implementation TFY_BaseControlChainModel
TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION(enabled, BOOL)
TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION(selected, BOOL)
TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION(highlighted, BOOL)
TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION(contentVerticalAlignment, UIControlContentVerticalAlignment)
TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION(contentHorizontalAlignment, UIControlContentHorizontalAlignment)

- (id  _Nonnull (^)(id _Nonnull, SEL _Nonnull, UIControlEvents))addTarget{
    return ^ (id target, SEL action, UIControlEvents events){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
            [obj addTarget:target action:action forControlEvents:events];
        }];
        return self;
    };
}
- ( id  _Nonnull (^)(id _Nonnull, SEL _Nonnull, UIControlEvents))setTarget{
    return ^ (id target, SEL action, UIControlEvents events){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
             [obj tfy_setTarget:target eventAction:action forControlEvents:events];
        }];
       
        return self;
    };
}
- (id  _Nonnull (^)(TFY_TargetActionBlock _Nonnull, UIControlEvents))addTargetBlock{
    return ^ (controlTargeAction block, UIControlEvents events){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
            [obj tfy_addEventBlock:block forEvents:events];
        }];
        return self;
    };
}
- (id  _Nonnull (^)(TFY_TargetActionBlock _Nonnull, UIControlEvents))setTargetBlock{
    return ^ (controlTargeAction block, UIControlEvents events){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
            [obj tfy_setEventBlock:block forEvents:events];
        }];
        return self;
    };
}

- ( id  _Nonnull (^)(id _Nonnull, SEL _Nonnull, UIControlEvents))removeTarget{
    return ^ (id target, SEL action, UIControlEvents events){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
            [obj removeTarget:target action:action forControlEvents:events];
        }];
        return self;
    };
}
- ( id  _Nonnull (^)(void))removeAllTarget{
    return ^ (){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
            [obj tfy_removeAllEvents];
        }];
        
        return self;
    };
}
- ( id  _Nonnull (^)(UIControlEvents))removeAllTargetBlock{
    return ^ (UIControlEvents events){
        [self enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj) {
            [obj tfy_removeAllEventBlocksForEvents:events];
        }];
        return self;
    };
}
@end
#undef TFY_CATEGORY_CHAIN_CONTROL_IMPLEMENTATION
