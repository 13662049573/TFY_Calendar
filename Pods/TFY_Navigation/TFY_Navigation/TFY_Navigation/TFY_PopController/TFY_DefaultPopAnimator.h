//
//  TFY_DefaultPopAnimator.h
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_PopControllerAnimationProtocol.h"
#import "TFY_PopController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DefaultPopAnimator : NSObject<TFY_PopControllerAnimationProtocol>
@property (nonatomic, assign) PopType popType;
@property (nonatomic, assign) DismissType dismissType;
@end

NS_ASSUME_NONNULL_END
