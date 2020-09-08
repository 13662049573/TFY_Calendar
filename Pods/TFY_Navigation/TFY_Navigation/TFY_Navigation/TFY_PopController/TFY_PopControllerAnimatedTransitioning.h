//
//  TFY_PopControllerAnimatedTransitioning.h
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_PopController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PopAnimationContext : NSObject

@property (nonatomic, assign, readonly) PopState state;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign) NSTimeInterval duration;

- (instancetype)initWithState:(PopState)state containerView:(UIView *)containerView;

@end


@interface TFY_PopControllerAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign, readonly)PopState state;
@property (nonatomic, weak, readonly)TFY_PopController *popController;

- (instancetype)initWithState:(PopState)state popController:(TFY_PopController *)popController NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
