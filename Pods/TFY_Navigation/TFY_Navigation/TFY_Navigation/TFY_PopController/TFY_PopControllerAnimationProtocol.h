//
//  TFY_PopControllerAnimationProtocol.h
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#ifndef TFY_PopControllerAnimationProtocol_h
#define TFY_PopControllerAnimationProtocol_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PopAnimationContext;

@protocol TFY_PopControllerAnimationProtocol <NSObject>

- (NSTimeInterval)popControllerAnimationDuration:(PopAnimationContext *)context;
- (void)popAnimate:(PopAnimationContext *)context completion:(void (^)(BOOL finished))completion;
- (void)dismissAnimate:(PopAnimationContext *)context completion:(void (^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END


#endif /* TFY_PopControllerAnimationProtocol_h */
