//
//  UIControl+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^controlTargeAction)(id sender);

@interface UIControl (TFY_Tools)
/**
 移除所有点击事件
 */
- (void)tfy_removeAllEvents;

/**
 添加一个点击事件
 */
- (void)tfy_addEventBlock:(controlTargeAction)block forEvents:(UIControlEvents)events;

/**
 移除所有事件，并添加一个新的事件
 */
- (void)tfy_setTarget:(id)target eventAction:(SEL)action forControlEvents:(UIControlEvents)events;


/**
 是否包含某个tag
 
 */
- (BOOL)tfy_containsEventBlockForKey:(NSString *)key;
/**
 添加点击block
 @param key 键值
 */
- (void)tfy_addEventBlock:(controlTargeAction)block forEvents:(UIControlEvents)events ForKey:(NSString *)key;

/**
 移除点击block
 
 @param key 键值
 */
- (void)tfy_removeEventBlockForKey:(NSString *)key event:(UIControlEvents)events;

/**
 移除所有block，并添加一个新的block
 */
- (void)tfy_setEventBlock:(controlTargeAction)block forEvents:(UIControlEvents)events;

/**
 移除所有block事件
 */
- (void)tfy_removeAllEventBlocksForEvents:(UIControlEvents)controlEvents;
@end

NS_ASSUME_NONNULL_END
