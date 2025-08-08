//
//  TFY_CalendarDelegationFactory.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_CalendarDelegationProxy.h"

// Ensure NS_SWIFT_NAME is available
#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(name)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarDelegationFactory : NSObject
+ (TFY_CalendarDelegationProxy *)dataSourceProxy NS_SWIFT_NAME(dataSourceProxy());
+ (TFY_CalendarDelegationProxy *)delegateProxy NS_SWIFT_NAME(delegateProxy());
@end

NS_ASSUME_NONNULL_END
