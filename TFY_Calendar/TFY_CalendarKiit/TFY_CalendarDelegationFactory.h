//
//  TFY_CalendarDelegationFactory.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_CalendarDelegationProxy.h"
NS_ASSUME_NONNULL_BEGIN

@interface TFY_CalendarDelegationFactory : NSObject
+ (TFY_CalendarDelegationProxy *)dataSourceProxy;
+ (TFY_CalendarDelegationProxy *)delegateProxy;
@end

NS_ASSUME_NONNULL_END
