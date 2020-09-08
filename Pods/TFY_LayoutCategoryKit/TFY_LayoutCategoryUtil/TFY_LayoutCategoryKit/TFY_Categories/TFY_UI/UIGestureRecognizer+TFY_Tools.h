//
//  UIGestureRecognizer+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GestureTargetAction)(id gesture);

@interface UIGestureRecognizer (TFY_Tools)

- (instancetype)initWithActionBlock:(void (^)(id sender))block;

- (void)tfy_addTargetBlock:(GestureTargetAction)block;

- (void)tfy_addTargetBlock:(GestureTargetAction)block tag:(NSString *)tag;

- (void)tfy_removeTargetBlockByTag:(NSString *)tag;

- (void)tfy_removeAllTargetBlock;
@end

NS_ASSUME_NONNULL_END
