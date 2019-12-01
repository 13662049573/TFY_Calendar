//
//  TFY_CalendarDelegationFactory.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarDelegationFactory.h"

@implementation TFY_CalendarDelegationFactory

+ (TFY_CalendarDelegationProxy *)dataSourceProxy
{
    TFY_CalendarDelegationProxy *delegation = [[TFY_CalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(TFYCa_CalendarDataSource);
    return delegation;
}

+ (TFY_CalendarDelegationProxy *)delegateProxy
{
    TFY_CalendarDelegationProxy *delegation = [[TFY_CalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(TFYCa_CalendarDelegateAppearance);
    return delegation;
}
@end
