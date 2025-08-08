//
//  TFY_CalendarDelegationProxy.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_Calendar.h"

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(name)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarDelegationProxy : NSProxy

@property (weak  , nonatomic) id delegation;
@property (strong, nonatomic) Protocol *protocol;
@property (strong, nonatomic) NSDictionary<NSString *,NSString *> *deprecations;

- (instancetype)init NS_SWIFT_NAME(init());
- (SEL)deprecatedSelectorOfSelector:(SEL)selector NS_SWIFT_NAME(deprecatedSelector(ofSelector:));
@end

NS_ASSUME_NONNULL_END
