//
//  NSObject+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TFY_Tools)

@property (nonatomic, copy, readonly) NSString * tfy_clasName;

+ (NSString *)tfy_clasName;

+ (BOOL)tfy_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

+ (BOOL)tfy_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

- (void)tfy_setAssociateValue:(id)value forKey:(void *)key;

- (id)tfy_getAssociateValueByKey:(void *)key;

- (void)tfy_removeAllAssociatedValues;

- (nullable id)tfy_performSelectorWithArguments:(SEL)sel, ...;

- (void)tfy_performSelectorWithArguments:(SEL)sel delay:(NSTimeInterval)delay, ...;

- (nullable id)tfy_performSelectorWaitUntilDone:(BOOL)wait onMainThreadWithArguments:(SEL)sel ,...;

- (nullable id)tfy_performSelectorwaitUntilDone:(BOOL)wait withArguments:(SEL)sel onThread:(NSThread *)thread, ...;

- (void)tfy_performSelectorWithArgumentsInBackground:(SEL)sel, ...;
@end

NS_ASSUME_NONNULL_END
